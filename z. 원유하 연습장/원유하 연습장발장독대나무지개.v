여기는 저희 끄적 연습장입니다
주형국씨는 나가주세요

일단 집 가서 VScode에 verilog extension 깔고, 간단한 verilog 코드 작성해봅시다.

1. 기본 정리
ToyCom3 Plus 구조
블록	        역할
PC	            CPU가 다음에 읽을 명령어 주소
SP	            스택 주소
SR	            상태 플래그
IR	            현재 읽어온 명령어 저장 장소
Decoder	        IR 안의 명령어를 보고 해석 (아주 중요함)
ALU	계산        (중요해요 아주)
Register	    임시 저장
Program Bus	    명령어 메모리 연결
Data Bus	    데이터 메모리 연결
State Control	실행 순서 제어

ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ

2. CPU가 일하는 순서
단계	    이름    	의미
T1	        IF	       명령어 읽기
T2	        ID	       해석
T3	        EXE	       계산
T4	        MEM	       메모리 접근
T5	        WB	       결과 저장

EX) 
T1
메모리에서 ADD 읽음

T2
ADD라고 해석

T3
R1 + R2 계산

T4
(메모리 안씀)

T5
결과를 R1 저장

ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ

3. CPU 설계 전투 모드로 돌입

3-1. State Machine + PC를 먼저 만든다.
CPU 동작 흐름 다시 기억 -> 즉 클럭마다 상태가 바뀐다
이걸 HDL로 예시를 통해서 만든다면?

module state_ctrl(
    input clk,
    input reset,
    output reg [2:0] state
);

always @(posedge clk or posedge reset)
begin
    if(reset)
        state <= 3'd1;   // T1 시작
    else begin
        if(state == 3'd5)
            state <= 3'd1;
        else
            state <= state + 1;
    end
end

endmodule
1 -> 2 -> 3 -> 4 -> 5 -> 1 -> ... 이렇게 반복한다

ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ

3-2. PC 설계
PC는 다음 명령어 주소 기억이다.
보통 명령어는 16bit = 2byte라서 pc는 2씩 증가한다
0x0000 -> 0x0002 -> 0x0004 -> ... 이런 식으로

module pc(
    input clk,
    input reset,
    input [2:0] state,
    output reg [15:0] pc_out
);

always @(posedge clk or posedge reset)
begin
    if(reset)
        pc_out <= 16'h0000;
    else if(state == 3'd1)   // IF 단계
        pc_out <= pc_out + 16'd2;
end

endmodule

그럼 왜 T1에서"만" 증가하는 것인가 => T1은 명령어 읽는 순간임
즉, 현재 주소 읽고 다음 주소로 이동하는 순간이 T1이기 때문에 T1에서 증가

초반 구상도
CLK ──> state_ctrl ──> 현재 상태(T1~T5)
             |
             └──> PC 제어

^^^^^^^^^CPU는 계산기 이전에 타이밍 기계이다^^^^^^^^^
이 말은 CPU가 "언제 읽고 언제 계산하고 언제 저장하느냐"가 더 중요하다는 말

ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ

4. CPU는 공장처럼 움직인다 (구조도)
       ┌──────────┐
       │   PC     │ ← 다음 명령어 주소
       └────┬─────┘
            ↓
     Program Memory
            ↓
       ┌──────────┐
       │   IR     │ ← 읽은 명령어 저장
       └────┬─────┘
            ↓
       ┌──────────┐
       │ Decoder  │ ← 해석기
       └────┬─────┘
            ↓
   ┌────────┴────────┐
   ↓                 ↓
Register File      Control Signal
(R0~R7)               |
   ↓                  |
   └────→ ALU ←──────┘
            ↓
         결과 저장

한 줄 요약 : 주소 찾기 → 명령 읽기 → 해석 → 계산 → 저장

ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ

5. Register File 만들기 (ㅈ밥임 ㅋ)

module regfile(
    input clk,
    input we,
    input [2:0] waddr,
    input [15:0] wdata,

    input [2:0] raddr1,
    input [2:0] raddr2,

    output [15:0] rdata1,
    output [15:0] rdata2
);

reg [15:0] R[0:7];

assign rdata1 = R[raddr1];
assign rdata2 = R[raddr2];

always @(posedge clk)
begin
    if(we)
        R[waddr] <= wdata;
end

endmodule

ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
6. ALU 만들기 (ㅈ됨)
ALU = CPU 안의 계산기 => ALU는 CPU 속 진짜 일꾼이다.
ㄴ> 하는 일 : 덧셈, 뺄셈, 논리 연산(AND. OR, XOR), shift 등등

ALU 기능    ADD (덧셈)
            SUB (뺄셈)
            MUL (곱셈)
            DIV (나눗셈)
            MOD (나머지)
            AND (논리 AND)
            OR  (논리 OR)
            XOR (논리 XOR)
            NOT (논리 NOT)
            SHIFT (시프트)
            CMP (비교)
            NEG (부호 반전)
            SWAP (값 교환)

HDL 코드

module alu(
    input [15:0] A,
    input [15:0] B,
    input [2:0] OP,
    output reg [15:0] RESULT
);

always @(*) // 입력 바뀌면 즉시 계산 다시 해라
begin
    case(OP) // case(op) = op 값 보고 무엇을 할지 결정

    3'b000: RESULT = A + B;   // ADD
    3'b001: RESULT = A - B;   // SUB
    3'b010: RESULT = A & B;   // AND
    3'b011: RESULT = A | B;   // OR

    default: RESULT = 16'd0;

    endcase
end

endmodule

case(OP) 속 op 예시
op = 3'b000 -> 덧셈
op = 3'b001 -> 뺄셈
op = 3'b010 -> 논리 AND
op = 3'b011 -> 논리 OR
op = 3'b100 -> 논리 XOR

ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ

6-1. ALU에 상태 플래그(Flag) 추가하기 (중요)

플래그 종류
Flag	    의미
H	        Half Carry      (4비트 덧셈에서 3비트에서 4비트로 넘어갈 때)
S	        signed          (부호 있는 연산에서 음수 결과)
V	        Overflow        (산술에서 결과가 표현 범위를 초과할 때)
N	        Negative        (결과가 음수일 때)
Z	        Zero            (결과가 0일 때)
C	        Carry           (덧셈에서 자리 올림, 뺄셈에서 자리 빌림)
LT	        Less Than       (A < B)
GT	        Greater Than    (A > B)

Ex) 5-5 = 0 (Z=1), 5-6 = -1 (N=1). 
    5+3 = 8 (C=0, V=0), 5+10 = 15 (C=1, V=0), 127+1 = -128 (C=1,V=1)

플래그는 분기 명령어 때문에 중요해용
뭔 소리냐고요? => Z=1이면 점프, GT=1이면 점프, LT=1이면 점프
결론은 걍 CPU에서 플래그(Flag) 없으면 if문, while문, 비교문, 조건 점프 못 만듭느드 ㄷㄷㄷ

이제 ALU + Flag 만들기

module alu_flag(
    input [15:0] A, // 피연산자 A
    input [15:0] B, // 피연산자 B
    input [2:0] OP, // 연산 종류

    output reg [15:0] RESULT, // 연산 결과
    output reg Z,
    output reg N,
    output reg C,
    output reg V
);

reg [16:0] temp; // 16비트 결과 + 캐리 비트 저장할 17비트 레지스터

always @(*) // 입력 바뀌면 즉시 계산 다시 해라
begin
    C = 0;  // 캐리 초기화
    V = 0;  // 오버플로 초기화

    case(OP)

    3'b000: begin
        temp = A + B;
        RESULT = temp[15:0]; // 결과 저장
        C = temp[16]; // 덧셈에서 16비트 넘어가는지 체크
    end

    3'b001: begin
        temp = A - B;
        RESULT = temp[15:0];
        C = temp[16]; 
    end

    3'b010: RESULT = A & B;

    3'b011: RESULT = A | B;

    default: RESULT = 16'd0; // 기본값

    endcase

    Z = (RESULT == 16'd0); // 결과가 0이면 Z=1
    N = RESULT[15];        // 결과가 음수면 N=1 (최상위 비트(16비트 맨 앞 비트)가 1이면 음수 = 부호 비트)

end

endmodule

ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ

6-2. SR(Status Register) 만들기 (CPU의 기억력 느낌)
SR = ALU에서 계산 후 플래그 저장하는 레지스터
즉, ALU 결과 상태를 저장하는 메모장 느낌

왜 저장하는가? => 다음 명령어에서 플래그 보고 조건 분기할 때 필요하기 때문
Ex) BRZ LOOP : Z=1이면 LOOP로 점프해라

SR 구조 (대충 이런 느낌)
비트	의미
bit0	Z
bit1	N
bit2	C
bit3	V

HDL 코드

module sr_reg(
    input clk,
    input reset,
    input we,

    input Z_in,
    input N_in,
    input C_in,
    input V_in,

    output reg [3:0] SR // SR = {V, C, N, Z}
);

always @(posedge clk or posedge reset)
begin
    if(reset)
        SR <= 4'b0000; // 초기화

    else if(we) // 쓰기 허용되면 플래그 업데이트, we=1일 때만 새 플래그 저장, we=0이면 플래그 유지
        SR <= {V_in, C_in, N_in, Z_in};
end

endmodule

Ex)코드에서 Z=1, N=0, C=1, V=0 이렇게 나온다면 SR = 4'b0101 이렇게 저장

그럼 CPU 안에서는 ADD 수행 후 -> ALU 결과 발생 -> Flag 생성 -> SR 저장

이렇게 ALU, Flag, SR까지 만들었으니 Register File + ALU + SR 연결 해서 CPU 계산 부분 완성 시키기

ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ

6-3. Register File + ALU + SR 연결하기

집 가서 하기