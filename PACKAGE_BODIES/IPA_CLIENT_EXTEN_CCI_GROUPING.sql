--------------------------------------------------------
--  DDL for Package Body IPA_CLIENT_EXTEN_CCI_GROUPING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IPA_CLIENT_EXTEN_CCI_GROUPING" AS
/* $Header: IPAGCCIB.pls 120.0 2005/05/31 16:26:36 appldev noship $ */
FUNCTION CLIENT_GROUPING_METHOD( p_proj_id         IN PA_PROJECTS_ALL.project_id%TYPE,
                                 p_task_id        IN PA_TASKS.task_id%TYPE,
                                 p_expnd_item_id  IN PA_EXPENDITURE_ITEMS_ALL.expenditure_item_id%TYPE,
                                 p_expnd_id       IN PA_EXPENDITURE_ITEMS_ALL.expenditure_id%TYPE,
                                 p_expnd_type     IN PA_EXPENDITURE_TYPES.expenditure_type%TYPE,
                                 p_expnd_category IN PA_EXPENDITURE_CATEGORIES.expenditure_category%TYPE,
                                 p_attribute1     IN PA_EXPENDITURE_ITEMS_ALL.attribute1%TYPE,
                                 p_attribute2     IN PA_EXPENDITURE_ITEMS_ALL.attribute1%TYPE,
                                 p_attribute3     IN PA_EXPENDITURE_ITEMS_ALL.attribute1%TYPE,
                                 p_attribute4     IN PA_EXPENDITURE_ITEMS_ALL.attribute1%TYPE,
                                 p_attribute5     IN PA_EXPENDITURE_ITEMS_ALL.attribute1%TYPE,
                                 p_attribute6     IN PA_EXPENDITURE_ITEMS_ALL.attribute1%TYPE,
                                 p_attribute7     IN PA_EXPENDITURE_ITEMS_ALL.attribute1%TYPE,
                                 p_attribute8     IN PA_EXPENDITURE_ITEMS_ALL.attribute1%TYPE,
                                 p_attribute9     IN PA_EXPENDITURE_ITEMS_ALL.attribute1%TYPE,
                                 p_attribute10    IN PA_EXPENDITURE_ITEMS_ALL.attribute1%TYPE,
                                 p_attribute_category IN PA_EXPENDITURE_ITEMS_ALL.attribute_category%TYPE,
                                 p_transaction_source IN PA_EXPENDITURE_ITEMS_ALL.transaction_source%TYPE)
return VARCHAR2 IS

  v_grouping_method varchar2(2000);

begin

 v_grouping_method:='ALL';

 return v_grouping_method;

end;

END IPA_CLIENT_EXTEN_CCI_GROUPING;

/
