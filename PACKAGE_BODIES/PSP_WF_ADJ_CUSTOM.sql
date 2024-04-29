--------------------------------------------------------
--  DDL for Package Body PSP_WF_ADJ_CUSTOM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSP_WF_ADJ_CUSTOM" AS
/* $Header: PSPWFACB.pls 120.4 2006/02/09 09:32:11 vdharmap noship $ */

/*************************************************************************
** Procedure select_approver_custom  returns the approver_id   	  	**
** for the given employee. It is called from                             **
** PSP_WF_ADJ_PKG.SELECT_APPROVER.                                      **
**************************************************************************/
PROCEDURE SELECT_APPROVER_CUSTOM
			(itemtype               IN      VARCHAR2,
                          itemkey               IN      VARCHAR2,
                          actid                 IN      VARCHAR2,
                          funcmode              IN      VARCHAR2,
			  p_person_id		IN	NUMBER,
			  p_assignment_number	IN	VARCHAR2,
			  p_approver_id		OUT NOCOPY	NUMBER) IS
BEGIN
	-- Enter your code here and comment out the follwoing line.
	p_approver_id := NULL;
END;

/*************************************************************************
** Procedure omit_approval_custom  returns 'Y' or 'N'   	  	**
** It is called from PSP_WF_ADJ_PKG.OMIT_APPROVAL.
**************************************************************************/
PROCEDURE OMIT_APPROVAL_CUSTOM
			(itemtype               IN      VARCHAR2,
                          itemkey               IN      VARCHAR2,
                          actid                 IN      VARCHAR2,
                          funcmode              IN      VARCHAR2,
			  p_omit_approval	OUT NOCOPY     VARCHAR2) IS
BEGIN
	-- Enter your code here and assign result the value in
	-- p_omit_approval parameter. Only assign 'Y' or 'N'
	-- to p_omit_approval.
	p_omit_approval := 'N';
END;


/*************************************************************************
** Procedure record_creator_custom  returns approver id  	  	**
** It is called from PSP_WF_ADJ_PKG.record_creator
**************************************************************************/
PROCEDURE RECORD_CREATOR_CUSTOM
			(itemtype               IN      VARCHAR2,
                          itemkey               IN      VARCHAR2,
                          actid                 IN      VARCHAR2,
                          funcmode              IN      VARCHAR2,
			  p_custom_approver_id	OUT NOCOPY     VARCHAR2) IS
BEGIN
	-- Enter your code here and assign result the value in
	-- p_custom_approver_id parameter. Please comment out the
	-- following line and assign the proper value.
	p_custom_approver_id := null;
END;

--- added 2 procedures below for 4992668

PROCEDURE PRORATE_DFF_HOOK(p_batch_name in varchar2,
                           p_business_group_id in integer,
                           p_set_of_books_id in integer) is
BEGIN

/*
   update psp_adjustment_lines pal
     set pal.attribute1 = (select round((percent /100 ) * to_number(pgh.attribute1), 2)
                         from psp_pre_gen_dist_lines_history pgh
                         where pgh.pre_gen_dist_line_id = pal.orig_line_id)
 where pal.batch_name = p_batch_name
   and pal.original_line_flag = 'N'
   and pal.orig_source_type = 'P'
   and pal.business_group_id = p_business_group_id
   and pal.set_of_books_id = p_set_of_books_id;

   update psp_adjustment_lines pal
     set pal.attribute1 = (select pgh.attribute1 * (-1)
                         from psp_pre_gen_dist_lines_history pgh
                         where pgh.pre_gen_dist_line_id = pal.orig_line_id)
 where pal.batch_name = p_batch_name
   and pal.original_line_flag = 'Y'
   and pal.orig_source_type = 'P'
   and pal.business_group_id = p_business_group_id
   and pal.set_of_books_id = p_set_of_books_id;

 update psp_adjustment_lines pal
    set pal.attribute1 = (select round((pal.percent /100 ) * to_number(palh.attribute1), 2)
                         from psp_adjustment_lines_history palh
                         where palh.adjustment_line_id = pal.orig_line_id)
 where pal.batch_name = p_batch_name
   and original_line_flag = 'N'
   and orig_source_type = 'A'
      and pal.business_group_id = p_business_group_id
   and pal.set_of_books_id = p_set_of_books_id;

 update psp_adjustment_lines pal
    set pal.attribute1 = (select palh.attribute1 * (-1)
                         from psp_adjustment_lines_history palh
                         where palh.adjustment_line_id = pal.orig_line_id)
 where pal.batch_name = p_batch_name
   and original_line_flag = 'Y'
   and orig_source_type = 'A'
      and pal.business_group_id = p_business_group_id
   and pal.set_of_books_id = p_set_of_books_id;  */

 /*  following statement  to be used only if you use non oracle payroll sub lines or Oracle payroll
                update psp_adjustment_lines pal
                   set pal.attribute1 = (select round((percent /100 ) * pdl.attribute1
                                           from psp_distribution_lines_history pdlh
                                          where pdlh.distribution_line_id = pal.orig_line_id)
                where pal.batch_name = p_batch_name
                  and orig_source_type = 'A'; */
  NULL;
END;


procedure dff_for_approver(p_batch_name in varchar2,
                           p_run_id in integer,
                           p_business_group_id in integer,
                           p_set_of_books_id in integer) is
begin

/* sample code to show total sum hours in DFF approval window */
 /* update psp_temp_Dest_sumlines ptds
    set ptds.attribute1 = ( select sum(to_number(nvl(pal.attribute1,'0')))
                              from psp_adjustment_lines pal
                             where pal.business_group_id = p_business_group_id
                               and pal.set_of_books_id = p_set_of_books_id
                               and pal.batch_name = p_batch_name
                               and pal.adj_set_number = ptds.adj_set_number
                               and pal.line_number = ptds.line_number
                               and (ptds.element_type_id is null or
                                    ptds.element_type_id = pal.element_type_id)
                                and nvl(pal.gl_code_combination_id, -999) = nvl(ptds.gl_code_combination_id, -999)
                                  and nvl(pal.expenditure_organization_id, -999) = nvl(ptds.expenditure_organization_id, -999)
                                  and nvl(pal.project_id, -999) = nvl(ptds.project_id, -999)
                                  and nvl(pal.task_id, -999) = nvl(ptds.task_id, -999)
                                  and nvl(pal.expenditure_type, '-999') = nvl(ptds.expenditure_type, '-999')
                                  and pal.original_line_flag = ptds.original_line_flag)
    where ptds.run_id = p_run_id; */

   null;
end;


END psp_wf_adj_custom;


/
