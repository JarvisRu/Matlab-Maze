function [ansArr sol doorRoute] = DFS_Maze2(maze, ansArr, record, doorx, doory, doorRoute)
% ���禡�β`���u���j�M�D�Ѱg�c���Ҧ����|
% maze:�O�g�c�x�}�A�䤤1��ܥi�H�h������
%                     0��ܻ�ê
%                     9��ܤJ�f
%                     8��ܥX�f
%                     5��ܤw���L���|
%                     2��ܶǰe��

% �w�q�|�Ӥ�V
directions = kron(eye(2),[-1,1]);
% ���|�Ӽ�
sol = 0;
move_time = 0;
enterDoor = 0;
global Door_count;
Door_count = 1;
% ���_�I
[I,J] = find(maze == 9);

search(I,J);
% �禡�P�_���|�O�_�i�H��
    function z = cango(x,y)
        % ��try�P�_���
        z = true;
        try
            if ismember(maze(x,y),[0,9,5])% ���٩Ϊ̤w�g���L
                z = false;
            end
        catch
            z = false; % ���
        end
    end
    function search(x,y)
        if maze(x,y) == 8 % ���X�f
            sol = sol + 1;% �Ѫ��ӼƼW�[
            if( record == 2 )
                ansArr(:,:,sol) = maze;
                %�P�_�O�_�g�L�ǰe��
                if enterDoor == 1
                    doorRoute(1,Door_count) = sol;
                    Door_count = Door_count + 1;
                end
            end
            return        % ��^
        %�o�䰵�ǰe�������� 
        elseif maze(x,y) == 2 %���ǰe��
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
        % �j��4�Ӥ�V
        for i = 1 : 4
            if cango(x + directions(1,i),y + directions(2,i)) % �p�G�i�H��
                %���ǰe�����P�_
                if maze(x + directions(1,i),y + directions(2,i)) == 2
                    maze(x + directions(1,i),y + directions(2,i)) = 2;
                %�p�G���O���I�A�N���]��5
                elseif maze(x + directions(1,i),y + directions(2,i)) ~= 8
                    maze(x + directions(1,i),y + directions(2,i)) = 5;
                end
                search(x + directions(1,i),y + directions(2,i)); % �~���U�@���I
                %���ǰe�����P�_
                if maze(x + directions(1,i),y + directions(2,i)) == 2
                    maze(x + directions(1,i),y + directions(2,i)) = 2;
                    if move_time == 1
                        enterDoor = 0;
                        move_time = move_time - 1;
                    elseif move_time > 1
                        move_time = move_time - 1;
                    end
                %�����|���q�A�N���]��1
                elseif maze(x + directions(1,i),y + directions(2,i)) ~= 8
                    maze(x + directions(1,i),y + directions(2,i)) = 1; % �^��W�@���I�A�~���U�@�Ӥ�V
                end
            end
        end
    end
end