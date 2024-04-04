#include <iostream>
#include <fstream>
#include <vector>
#include <string>

int main(void) {
    std::vector<int> departure;
    std::vector<int> station;
    std::vector<int> ans;
    // open file and read testcase
    std::ifstream instream("./testcase.txt");
    std::ofstream outstream("./answer.txt");
    std::string line;
    if (instream.is_open()) {
        getline(instream, line);
    }
    instream.close();
    
    // save testcase according departure sequence
    for (int i = 0; i < line.size(); i++) {
        departure.push_back((int(line[i] - '0')));
    }
    // 排序 sequence
    while (!departure.empty()) {
        if (station.empty()) {
            station.push_back(departure.back());
            departure.pop_back();
        } else {
            if (station.back() > departure.back()) {
                ans.insert(ans.begin(), station.back());
                station.pop_back();
            } else {
                station.push_back(departure.back());
                departure.pop_back();
            }
        }
    }
    // 僅存於 station 的通通 pop 掉
    while (!station.empty()) {
        ans.insert(ans.begin(), station.back());
        station.pop_back();
    }
    // 如果對應位置不是對應數字 即錯誤
    for (int i = 0; i < ans.size(); i++) {
        if (ans[i] != i+1) {
            if (outstream.is_open()) {
                outstream << 0;
                outstream.close();
                return 0;
            }
        }
    }
    if (outstream.is_open()) {
        outstream << 1;
    }
    outstream.close();
    return 0;
}