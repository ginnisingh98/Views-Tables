--------------------------------------------------------
--  DDL for Package Body CSP_PROD_TASK_HIST_RULE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_PROD_TASK_HIST_RULE" as
/* $Header: cspgphrb.pls 115.2 2002/11/26 07:54:12 hhaugeru ship $ */
-- Start of Comments
-- Package name     : CSP_PROD_TASK_HIST_RULE
-- Purpose          : This package includes the functions that decide whether to use the history
--                    of Product-Task-Parts details based on value defined in CSP_PROD_TASK_HIST_RULE profile.
-- History          : 03-Aug-2001, Arul Joseph.
-- NOTE             :
-- End of Comments

Function get_quantity
	(p_prod_task_times_used number,
         p_manual_quantity  number,
	 p_rollup_quantity_used  number,
	 p_rollup_times_used number,
         p_quantity_used    number,
         p_part_actual_times_used number
	) return number IS
        l_value Varchar2(100);
        l_quantity Number;
Begin
    Fnd_profile.get('CSP_PROD_TASK_HIST_RULE',L_VALUE);
    If p_manual_quantity is not null then
       l_quantity := p_manual_quantity;
    Else
       if l_value > p_prod_task_times_used then
          l_quantity := null;
       elsif l_value <= p_prod_task_times_used then
          l_quantity := Nvl((p_rollup_quantity_used/p_rollup_times_used),(p_quantity_used/p_part_actual_times_used));
       end if;
    end if;
    return l_quantity;
End;

Function get_percentage
	(p_prod_task_times_used number,
         p_manual_percentage number,
	 p_rollup_times_used number,
         p_part_actual_times_used number)
         return number IS
         l_value Varchar2(100);
         l_percentage number;
Begin
    Fnd_profile.get('CSP_PROD_TASK_HIST_RULE',L_VALUE);
    If p_manual_percentage is not null then
       l_percentage := p_manual_percentage;
    Else
       if l_value > p_prod_task_times_used then
          l_percentage := null;
       elsif l_value <= p_prod_task_times_used then
          l_percentage := Nvl((p_rollup_times_used/p_prod_task_times_used)*100, ((p_part_actual_times_used/p_prod_task_times_used)*100));
       end if;
    end if;
    return l_percentage;
End;
END CSP_PROD_TASK_HIST_RULE;

/
