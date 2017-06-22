function [ansArr sol doorRoute] = DFS_Maze2(maze, ansArr, record, doorx, doory, doorRoute)
% 本函式用深度優先搜尋求解迷宮的所有路徑
% maze:是迷宮矩陣，其中1表示可以去走的路
%                     0表示障礙
%                     9表示入口
%                     8表示出口
%                     5表示已走過路徑
%                     2表示傳送門

% 定義四個方向
directions = kron(eye(2),[-1,1]);
% 路徑個數
sol = 0;
move_time = 0;
enterDoor = 0;
global Door_count;
Door_count = 1;
% 找到起點
[I,J] = find(maze == 9);

search(I,J);
% 函式判斷路徑是否可以走
    function z = cango(x,y)
        % 用try判斷邊界
        z = true;
        try
            if ismember(maze(x,y),[0,9,5])% 路障或者已經走過
                z = false;
            end
        catch
            z = false; % 邊界
        end
    end
    function search(x,y)
        if maze(x,y) == 8 % 找到出口
            sol = sol + 1;% 解的個數增加
            if( record == 2 )
                ansArr(:,:,sol) = maze;
                %判斷是否經過傳送門
                if enterDoor == 1
                    doorRoute(1,Door_count) = sol;
                    Door_count = Door_count + 1;
                end
            end
            return        % 返回
        %這邊做傳送門的移動 
        elseif maze(x,y) == 2 %找到傳送門
            move_time = move_time + 1;
            enterDoor = 1;
            if x==doorx(1) && y==doory(1)
                x=doorx(2);
                y=doory(2);
            elseif x==doorx(2) && y==doory(2)
                x=doorx(1);
                y=doory(1);
            end
        end
        % 搜索4個方向
        for i = 1 : 4
            if cango(x + directions(1,i),y + directions(2,i)) % 如果可以走
                %做傳送門的判斷
                if maze(x + directions(1,i),y + directions(2,i)) == 2
                    maze(x + directions(1,i),y + directions(2,i)) = 2;
                %如果不是終點，將它設為5
                elseif maze(x + directions(1,i),y + directions(2,i)) ~= 8
                    maze(x + directions(1,i),y + directions(2,i)) = 5;
                end
                search(x + directions(1,i),y + directions(2,i)); % 繼續找下一個點
                %做傳送門的判斷
                if maze(x + directions(1,i),y + directions(2,i)) == 2
                    maze(x + directions(1,i),y + directions(2,i)) = 2;
                    if move_time == 1
                        enterDoor = 0;
                        move_time = move_time - 1;
                    elseif move_time > 1
                        move_time = move_time - 1;
                    end
                %此路徑不通，將它設為1
                elseif maze(x + directions(1,i),y + directions(2,i)) ~= 8
                    maze(x + directions(1,i),y + directions(2,i)) = 1; % 回到上一個點，繼續找下一個方向
                end
            end
        end
    end
end