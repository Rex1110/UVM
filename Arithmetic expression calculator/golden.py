if __name__ == "__main__":
    with open("./testcase.dat", 'r') as file:
        content = file.read()
    content = content.split(" ") # [, ,]
    content.pop()
    # print(content)
    string = []
    for num in content:
        if (int(num) > 96 and int(num) < 103):
            # a~f -> 10~15
            string.append(str(int(num)-87))
        else:
            string.append(chr(int(num)))
    string = "".join(string)
    ans = eval(string)
    print(string + "=")
    # print("correct answer is %0d"%(ans))

    with open("./golden.dat", 'w') as file:
        file.write(str(ans))

