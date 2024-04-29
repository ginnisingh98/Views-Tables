--------------------------------------------------------
--  DDL for Package Body BIS_FN_SECURITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_FN_SECURITY" AS
/* $Header: BISLNKSB.pls 115.1 99/07/17 16:08:27 porting ship $ */

--------------------------------------
FUNCTION isAccessible
(
   p_function_id      	in number
   ,p_responsibility_id in number
)
RETURN VARCHAR2
IS

    CURSOR CM (x_menu_id in number) IS
    SELECT me.function_id, me.sub_menu_id
    FROM (SELECT m.menu_id, m.function_id, m.sub_menu_id,
                 decode(m.function_id, NULL, 'M', 'F') entry_type
          FROM fnd_menu_entries m
          WHERE m.menu_id = x_menu_id) me,
          fnd_resp_functions ex
    WHERE ex.responsibility_id (+) = p_responsibility_id
    AND   ex.rule_type(+) = me.entry_type
    AND   ex.action_id(+) <> decode(me.entry_type, 'F', me.function_id,
                                              'M', me.sub_menu_id, null);

    CURSOR CR IS
    SELECT menu_id
    FROM fnd_responsibility
    WHERE responsibility_id = p_responsibility_id
    AND   start_date <= sysdate
    AND   (nvl(end_date, sysdate) >= sysdate);


    TYPE t_Menu_Tbl_Type IS TABLE OF fnd_responsibility.menu_id%TYPE
         INDEX BY BINARY_INTEGER;

    l_menu_tbl   	t_Menu_Tbl_Type;
    l_add_index  	BINARY_INTEGER:= 0;
    l_read_index 	BINARY_INTEGER;
    l_menu_id	NUMBER;


BEGIN

    -- get the menu assigned to the responsibility and find if the
    -- function is an entry on the menu or any of the submenus
    -- note:submenus could be nested to any number of levels
    -----------------------------------------------------------
    OPEN CR;
    Fetch CR into l_menu_tbl(l_add_index);
    CLOSE CR;

    If (l_menu_tbl.COUNT = 0)  then
       return 'FALSE';
    End If;

    -- loop logic:
    -- store the menus to be processed in the l_menu_tbl
    -- for each menu, fetch the menu entries and compare the
    -- function id. if the menu entry is a submenu, add it to
    -- list of menus to be procesed.
    -- optimization based on of repeating sub menus on submenus
    -- is not considered.
    ------------------------------------------------------------
    l_read_index := l_menu_tbl.FIRST;
    l_menu_id     := l_menu_tbl(l_read_index);
    Loop

        For c_rec in CM(l_menu_id) Loop
           If (c_rec.sub_menu_id IS NOT NULL) Then
              l_add_index := l_add_index + 1;
   	        l_menu_tbl(l_add_index) := c_rec.sub_menu_id;
           Else
              If (c_rec.function_id = p_function_id) then
                 return 'TRUE';
                 Exit;
              End If;
           End If;
        End Loop;

        EXIT WHEN l_read_index = l_menu_tbl.LAST;
        l_read_index  := l_menu_tbl.NEXT(l_read_index);
        l_menu_id     := l_menu_tbl(l_read_index);
    End Loop;

    Return 'FALSE';

END isAccessible;
---------------------

END BIS_FN_SECURITY;

/
