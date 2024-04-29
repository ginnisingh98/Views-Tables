--------------------------------------------------------
--  DDL for Package PA_RESOURCE_LIST_TBL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_RESOURCE_LIST_TBL_PKG" AUTHID CURRENT_USER AS
/* $Header: PARELSTS.pls 120.1 2005/08/19 16:50:26 mwasowic noship $ */
-- Standard Table Handler procedures for PA_RESOURCE_LISTS table



PROCEDURE Insert_Row(
			p_name                     PA_RESOURCE_LISTS_ALL_BG.name%TYPE,
		        p_description              PA_RESOURCE_LISTS_ALL_BG.description%TYPE,
			p_public_flag              PA_RESOURCE_LISTS_ALL_BG.public_flag%TYPE,
		        p_group_resource_type_id   NUMBER,
		        p_start_date_active        DATE,
		        p_end_date_active          DATE,
			p_uncategorized_flag       PA_RESOURCE_LISTS_ALL_BG.uncategorized_flag%TYPE,
			p_business_group_id        NUMBER,
		        p_adw_notify_flag          PA_RESOURCE_LISTS_ALL_BG.adw_notify_flag%TYPE,
		        p_job_group_id             NUMBER,
			p_resource_list_type       PA_RESOURCE_LISTS_ALL_BG.resource_list_type%TYPE,
		        p_control_flag             PA_RESOURCE_LISTS_ALL_BG.control_flag%TYPE,
		        p_use_for_wp_flag          PA_RESOURCE_LISTS_ALL_BG.use_for_wp_flag%TYPE,
		        p_migration_code           PA_RESOURCE_LISTS_ALL_BG.migration_code%TYPE,
		        x_resource_list_id  OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
			x_return_status     OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
			x_msg_data	    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
		 );


PROCEDURE Insert_row        (X_ROW_ID IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                             X_RESOURCE_LIST_ID        NUMBER,
                             X_NAME                    VARCHAR2,
                             X_DESCRIPTION             VARCHAR2,
                             X_PUBLIC_FLAG             VARCHAR2,
                             X_GROUP_RESOURCE_TYPE_ID  NUMBER,
                             X_START_DATE_ACTIVE       DATE,
                             X_END_DATE_ACTIVE         DATE,
                             X_UNCATEGORIZED_FLAG      VARCHAR2,
                             X_BUSINESS_GROUP_ID       NUMBER,
                          --   X_ADW_NOTIFY_FLAG         VARCHAR2,
                             X_JOB_GROUP_ID            NUMBER,
                             X_RESOURCE_LIST_TYPE      VARCHAR2 DEFAULT 'U',
                             X_LAST_UPDATED_BY         NUMBER,
                             X_LAST_UPDATE_DATE        DATE,
                             X_CREATION_DATE           DATE,
                             X_CREATED_BY              NUMBER,
                             X_LAST_UPDATE_LOGIN       NUMBER );

PROCEDURE Update_Row        (X_ROW_ID IN VARCHAR2,
                             X_RESOURCE_LIST_ID        NUMBER,
                             X_NAME                    VARCHAR2,
                             X_DESCRIPTION             VARCHAR2,
                             X_PUBLIC_FLAG             VARCHAR2,
                             X_GROUP_RESOURCE_TYPE_ID  NUMBER,
                             X_START_DATE_ACTIVE       DATE,
                             X_END_DATE_ACTIVE         DATE,
                             X_UNCATEGORIZED_FLAG      VARCHAR2,
                             X_BUSINESS_GROUP_ID       NUMBER,
                           --  X_ADW_NOTIFY_FLAG         VARCHAR2,
                             X_JOB_GROUP_ID            NUMBER,
                             X_RESOURCE_LIST_TYPE      VARCHAR2 DEFAULT 'U',
                             X_LAST_UPDATED_BY         NUMBER,
                             X_LAST_UPDATE_DATE        DATE,
                             X_LAST_UPDATE_LOGIN       NUMBER );

Procedure Lock_Row          (X_ROW_ID IN VARCHAR2,
                             X_RESOURCE_LIST_ID        NUMBER,
                             X_NAME                    VARCHAR2,
                             X_DESCRIPTION             VARCHAR2,
                             X_PUBLIC_FLAG             VARCHAR2,
                             X_GROUP_RESOURCE_TYPE_ID  NUMBER,
                             X_START_DATE_ACTIVE       DATE,
                             X_END_DATE_ACTIVE         DATE,
                             X_UNCATEGORIZED_FLAG      VARCHAR2,
                             X_BUSINESS_GROUP_ID       NUMBER,
                             X_JOB_GROUP_ID            NUMBER,
                            -- X_ADW_NOTIFY_FLAG         VARCHAR2,
                             X_LAST_UPDATED_BY         NUMBER);


Procedure Delete_Row (X_ROW_ID IN VARCHAR2);

END PA_Resource_List_tbl_Pkg;

 

/
