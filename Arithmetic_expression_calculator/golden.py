if __name__ == "__main__":
    with open("./testcase.dat", 'r') as file:
        content = file.read()
    
    content = content.split(" ")  
    content.pop()  # 移除最後一個 space

    string = []
    is_valid = 1

    for num in content:
        int_num = int(num)
        if 96 < int_num < 103:  # a~f -> 10~15
            string.append(str(int_num - 87))
        elif 48 <= int_num <= 57 or int_num in [40, 41, 42, 43, 45]:
            string.append(chr(int_num))
        else:
            is_valid = 0

    if is_valid:
        joined_string = "".join(string)
        invalid_pattern = [
            "++", "+-", "+*", 
            "--", "-+", "-*",
            "**", "*+", "*-",
            "(+", "(-", "(*",
            "*)", "+)", "-)"
        ]

        for pattern in invalid_pattern:
            if pattern in joined_string:
                is_valid = 0
                
    string = " ".join(string)
    print(string + "=")
    if is_valid == 0:
        with open("./golden.dat", 'w') as file:
            file.write('0')  
    else:
        try:
            ans = eval(string)
            with open("./golden.dat", 'w') as file:
                file.write('1\n')
                file.write(str(ans)) 
        except:
            with open("./golden.dat", 'w') as file:
                file.write('0') 
