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
1 -> 2 -> 3 -> 4 -> 5 -> 1 -> ...

