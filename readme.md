## Суть
Программа, которая вставляет текущую дату и время при нажатии на Ctrl+Alt+D

## План
баг: не очищается текущее значения хоткея
Избавиться от задержки, проверять не нажаты ли какие-либо кнопки
Вычистить все лишнее

## Сделал
### v0.6
теперь нет задержки при вставке
### v0.5
Добавил файл, который посоветовал учитель отсюда:
http://vk.com/wall810067_2475
http://forums.purebasic.com/english/viewtopic.php?f=12&t=61117
Настроил. Работает. 
### v0.4
Начал писать смену хоткеев, а потом понял, что это ж ппц придется для всех комбинаций клавишь писать поведение...
### v0.3
Странная фигня. После вчерашнего добавления иконки в трей программа работает только когда запущена из IDE. Когда скомпилена как отдельный exe файл - не работает. v0.1 как отдельный exe - работает. Заработало
Переделал форматирование. Исходные отступы были в один пробел. Выровнял весь код по левому краю и отформатировал Ctrl+I
### v0.2
Добавил иконку
Сперва добавил editorGadget прямо в окно программы, чтобы тестировать вставку в неё, но потом отказался от этого, т.к. это не проверяет глобальность хоткея. 
Сделал то, что планировал сделать в самом конце: Избавиться от окна, засунув все в трей, по примеру Capser
Прободался с отловом ненажатия клавиш, штудировал эти ссылки: 
http://purebasic.mybb.ru/viewtopic.php?id=25
https://msdn.microsoft.com/ru-ru/library/windows/desktop/ms646299(v=vs.85).aspx
Сделать не получилось. Кажется это пока слишком высокий уровень для меня. Говорят о подключении какой-то dll'ки...
###v0.1
Из кусков кода с форума PB и исходников софтины Capser, написанной учителем, большей частью руками учителя сделана первая работающая версия http://www.purebasic.fr/english/viewtopic.php?t=22270 https://github.com/deseven/pbsamples/tree/master/win/Capser
2015.06.20 14:38