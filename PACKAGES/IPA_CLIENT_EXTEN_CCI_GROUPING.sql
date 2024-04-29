--------------------------------------------------------
--  DDL for Package IPA_CLIENT_EXTEN_CCI_GROUPING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IPA_CLIENT_EXTEN_CCI_GROUPING" AUTHID CURRENT_USER AS
/* $Header: IPAGCCIS.pls 120.0 2005/05/29 13:16:26 appldev noship $ */
FUNCTION CLIENT_GROUPING_METHOD(    p_proj_id 	     IN PA_PROJECTS_ALL.project_id%TYPE,
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
 return VARCHAR2;

 END IPA_CLIENT_EXTEN_CCI_GROUPING;
 

/
