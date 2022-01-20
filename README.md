출처:
https://www.inflearn.com/course/ethereum-dapp/lecture/20063?tab=note&volume=0.59&quality=auto&speed=1.75
# lottery-react-web
Lottery smart contract과 연동하는 리액트웹앱입니다.

  게임의 규칙은 간단합니다. 현재 참여하고 있는 블록 + 3의 블록해시 처음 두글자를 맞추면 win 한 글자만 맞추면 draw 두 글자 모두 틀리면
fail입니다.

한게임당 0.005eth 필요<br>
win  : 현재 Pot 머니 모두획득 <br>
draw : 참여비 반환 <br>
fail : 보상없음


배팅버튼을 눌리면 아래와같이 메타마스크에 트랜잭션승인요청이 발생합니다.

![11](https://user-images.githubusercontent.com/73014464/150363818-499caf79-355c-4abb-950e-640d1a380820.png)


#### 간단한 시연영상입니다.
https://www.youtube.com/watch?v=H6yQ12AT1No
