--------------------------------------------------------
--  DDL for Package Body IGR_INQUIRY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGR_INQUIRY_PKG" AS
/* $Header: IGSRT03B.pls 120.1 2005/11/23 13:26:39 appldev noship $ */

  l_rowid VARCHAR2(25);

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_enquiry_appl_number               OUT NOCOPY NUMBER,
    x_sales_lead_id                     OUT NOCOPY NUMBER,
    x_acad_cal_type                     IN     VARCHAR2,
    x_acad_ci_sequence_number           IN     NUMBER,
    x_adm_cal_type                      IN     VARCHAR2,
    x_adm_ci_sequence_number            IN     NUMBER,
    x_enquiry_dt                        IN     DATE,
    x_registering_person_id             IN     NUMBER,
    x_override_process_ind              IN     VARCHAR2,
    x_indicated_mailing_dt              IN     DATE,
    x_last_process_dt                   IN     DATE,
    x_comments                          IN     VARCHAR2,
    x_org_id                            IN     NUMBER,
    x_inq_entry_level_id                IN     NUMBER,
    x_edu_goal_id                       IN     NUMBER,
    x_party_id                          IN     NUMBER,
    x_how_knowus_id                     IN     NUMBER,
    x_who_influenced_id                 IN     NUMBER,
    x_attribute_category                IN     VARCHAR2,
    x_attribute1                        IN     VARCHAR2,
    x_attribute2                        IN     VARCHAR2,
    x_attribute3                        IN     VARCHAR2,
    x_attribute4                        IN     VARCHAR2,
    x_attribute5                        IN     VARCHAR2,
    x_attribute6                        IN     VARCHAR2,
    x_attribute7                        IN     VARCHAR2,
    x_attribute8                        IN     VARCHAR2,
    x_attribute9                        IN     VARCHAR2,
    x_attribute10                       IN     VARCHAR2,
    x_attribute11                       IN     VARCHAR2,
    x_attribute12                       IN     VARCHAR2,
    x_attribute13                       IN     VARCHAR2,
    x_attribute14                       IN     VARCHAR2,
    x_attribute15                       IN     VARCHAR2,
    x_attribute16                       IN     VARCHAR2,
    x_attribute17                       IN     VARCHAR2,
    x_attribute18                       IN     VARCHAR2,
    x_attribute19                       IN     VARCHAR2,
    x_attribute20                       IN     VARCHAR2,
    x_s_enquiry_status                  IN     VARCHAR2,
    x_enabled_flag                      IN     VARCHAR2,
    x_inquiry_method_code               IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 ,
    x_action                            IN     VARCHAR2,
    x_person_type_code                  IN     VARCHAR2,
    x_funnel_status                     IN     VARCHAR2,
    x_source_promotion_id               IN     VARCHAR2,
    x_ret_status                        OUT NOCOPY VARCHAR2,
    x_msg_data                          OUT NOCOPY VARCHAR2,
    x_msg_count                         OUT NOCOPY NUMBER,
    x_pkg_reduct_ind                    IN      VARCHAR2 DEFAULT NULL

  ) AS
  /*
  ||  Created By : hreddych
  ||  Created On : 22-JAN-2003
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    x_last_update_date           DATE;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;
    x_request_id                 NUMBER;
    x_program_id                 NUMBER;
    x_program_application_id     NUMBER;
    x_program_update_date        DATE;
    l_lead_proc_ret_status       VARCHAR2(1);
    l_lead_proc_msg_count        NUMBER;
    l_lead_proc_msg_data         VARCHAR2(2000);

    l_tmp_var VARCHAR2(2000);
    l_employee_id     as_sales_leads.assign_to_person_id%TYPE;
    l_resource_id     as_sales_leads.assign_to_Salesforce_id%TYPE;
    l_sales_lead_id   as_sales_leads.sales_lead_id%TYPE;
    l_address_id      as_sales_leads.address_id%TYPE;
    l_sales_lead_rec  as_sales_leads_pub.G_MISS_SALES_LEAD_REC%TYPE ;


    ddx_sales_lead_line_out_tbl as_sales_leads_pub.sales_lead_line_out_tbl_type;
    ddx_sales_lead_cnt_out_tbl  as_sales_leads_pub.sales_lead_cnt_out_tbl_type;
    ddp_sales_lead_profile_tbl  as_utility_pub.profile_tbl_type;
    ddp_sales_lead_line_tbl     as_sales_leads_pub.sales_lead_line_tbl_type;
    ddp_sales_lead_contact_tbl  as_sales_leads_pub.sales_lead_contact_tbl_type;

    CURSOR c_primary_address IS
    SELECT party_site_id
    FROM   hz_party_sites
    WHERE  identifying_address_flag = 'Y'
    AND    status = 'A'
    AND    party_id = x_person_id;

  BEGIN

      OPEN  c_primary_address;
      FETCH c_primary_address INTO l_address_id;
      CLOSE c_primary_address;

      l_sales_lead_rec.status_code                   :=x_s_enquiry_status;
      l_sales_lead_rec.vehicle_response_code         :=x_inquiry_method_code;
      l_sales_lead_rec.lead_number                   :=NULL;
      l_sales_lead_rec.customer_id                   :=x_person_id;
      l_sales_lead_rec.address_id                    :=l_address_id;
      l_sales_lead_rec.source_promotion_id           :=x_source_promotion_id ;


   AS_SALES_LEADS_PUB.CREATE_SALES_LEAD(
	P_API_VERSION_NUMBER      => 2.0,
	P_INIT_MSG_LIST           => FND_API.G_TRUE,
	P_COMMIT                  => FND_API.G_FALSE,
        P_VALIDATION_LEVEL        => AS_UTILITY_PUB.G_VALID_LEVEL_ITEM,
        P_CHECK_ACCESS_FLAG       => FND_API.G_MISS_CHAR,
        P_ADMIN_FLAG              => 'Y',
        P_ADMIN_GROUP_ID          => FND_API.G_MISS_NUM,
	P_SALES_LEAD_PROFILE_TBL  => ddp_sales_lead_profile_tbl,
	P_SALES_LEAD_LINE_TBL     => ddp_sales_lead_line_tbl,
	P_SALES_LEAD_CONTACT_TBL  => ddp_sales_lead_contact_tbl,
	X_SALES_LEAD_ID           => l_sales_lead_id,
	X_SALES_LEAD_LINE_OUT_TBL => ddx_sales_lead_line_out_tbl,
	X_SALES_LEAD_CNT_OUT_TBL  => ddx_sales_lead_cnt_out_tbl,
	P_SALES_LEAD_REC          => L_SALES_LEAD_REC ,
	X_RETURN_STATUS           => x_ret_status,
	X_MSG_COUNT               => x_msg_count,
	X_MSG_DATA                => x_msg_data);

   IF x_ret_status  IN ('E','U') THEN
      IF x_msg_count > 1 THEN
         FOR i IN 1..x_msg_count LOOP
           l_tmp_var := l_tmp_var || ' '||fnd_msg_pub.get(p_encoded => fnd_api.g_false);
         END LOOP;
         x_msg_data := trim(l_tmp_var);
       END IF;
   END IF;

  IF x_ret_status = 'S' then  -- lead properly created

   X_sales_lead_id := l_sales_lead_id ;

   IGR_I_APPL_Pkg.insert_row (
        X_Mode                              => 'R',
        X_RowId                             =>X_RowId                   ,
        X_Person_Id                         =>X_Person_Id               ,
        X_sales_lead_id                     =>l_sales_lead_id           ,
        X_Enquiry_Appl_Number               =>X_Enquiry_Appl_Number     ,
        X_Acad_Cal_Type                     =>X_Acad_Cal_Type           ,
        X_Acad_Ci_Sequence_Number           =>X_Acad_Ci_Sequence_Number ,
        X_Adm_Cal_Type                      =>X_Adm_Cal_Type            ,
        X_Adm_Ci_Sequence_Number            =>X_Adm_Ci_Sequence_Number  ,
        X_Enquiry_Dt                        =>X_Enquiry_Dt              ,
        X_Registering_Person_Id             =>X_Registering_Person_Id   ,
        X_Override_Process_Ind              =>X_Override_Process_Ind    ,
        X_Indicated_Mailing_Dt              =>X_Indicated_Mailing_Dt    ,
        X_Last_Process_Dt                   =>X_Last_Process_Dt         ,
        X_Comments                          =>X_Comments                ,
        X_INQ_ENTRY_LEVEL_ID                =>X_INQ_ENTRY_LEVEL_ID      ,
        X_EDU_GOAL_ID                       =>X_EDU_GOAL_ID             ,
        X_PARTY_ID                          =>X_PARTY_ID                ,
        X_HOW_KNOWUS_ID                     =>X_HOW_KNOWUS_ID           ,
        X_WHO_INFLUENCED_ID                 =>X_WHO_INFLUENCED_ID       ,
        X_ATTRIBUTE_CATEGORY                =>X_ATTRIBUTE_CATEGORY      ,
        X_ATTRIBUTE1                        =>X_ATTRIBUTE1              ,
        X_ATTRIBUTE2                        =>X_ATTRIBUTE2              ,
        X_ATTRIBUTE3                        =>X_ATTRIBUTE3              ,
        X_ATTRIBUTE4                        =>X_ATTRIBUTE4              ,
        X_ATTRIBUTE5                        =>X_ATTRIBUTE5              ,
        X_ATTRIBUTE6                        =>X_ATTRIBUTE6              ,
        X_ATTRIBUTE7                        =>X_ATTRIBUTE7              ,
        X_ATTRIBUTE8                        =>X_ATTRIBUTE8              ,
        X_ATTRIBUTE9                        =>X_ATTRIBUTE9              ,
        X_ATTRIBUTE10                       =>X_ATTRIBUTE10             ,
        X_ATTRIBUTE11                       =>X_ATTRIBUTE11             ,
        X_ATTRIBUTE12                       =>X_ATTRIBUTE12             ,
        X_ATTRIBUTE13                       =>X_ATTRIBUTE13             ,
        X_ATTRIBUTE14                       =>X_ATTRIBUTE14             ,
        X_ATTRIBUTE15                       =>X_ATTRIBUTE15             ,
        X_ATTRIBUTE16                       =>X_ATTRIBUTE16             ,
        X_ATTRIBUTE17                       =>X_ATTRIBUTE17             ,
        X_ATTRIBUTE18                       =>X_ATTRIBUTE18             ,
        X_ATTRIBUTE19                       =>X_ATTRIBUTE19             ,
        X_ATTRIBUTE20                       =>X_ATTRIBUTE20             ,
        X_Org_Id                            =>X_Org_Id                  ,
        X_PKG_REDUCT_IND                    =>x_pkg_reduct_ind
    );
  Igr_in_jtf_interactions_pkg.start_int_and_act (     p_doc_ref	=>  'LEAD',
                         p_person_id      =>  X_PERSON_ID,
			 p_sales_lead_id  =>  l_sales_lead_id,
                         p_item_id	  =>  NULL,
			 p_doc_id         =>  l_sales_lead_id,
                         p_action         =>  X_ACTION ,
                         p_action_item    => 'INQUIRY',
	                 p_ret_status     =>  x_ret_status,
	 		 p_msg_data       =>  x_msg_data,
	                 p_msg_count      =>  x_msg_count);

       IF NVL(x_ret_status,'S') NOT IN ('E','U') THEN
           igr_person_type_pkg.update_persontype_funnel(
             p_person_id           =>  x_person_id,
             p_person_type_code    =>  x_person_type_code,
	     p_funnel_status       =>  x_funnel_status,
	     p_return_status       =>  x_ret_status,
	     p_message_text        =>  x_msg_data) ;
       END IF;

    -- call Sales Real Time lead assignment API, passing in local ret/msg
    -- variables, as failure of this API should not preclude lead
    -- or inquiry creation.

       AS_SALES_LEADS_PUB.Lead_Process_After_Create (
          P_Api_Version_Number	=> 2.0,
          P_Init_Msg_List       => FND_API.G_FALSE,
          P_Commit              => FND_API.G_FALSE,
          P_Validation_Level    => AS_UTILITY_PUB.G_VALID_LEVEL_ITEM,
          P_Check_Access_Flag   => FND_API.G_MISS_CHAR,
          P_Admin_Flag          => FND_API.G_MISS_CHAR,
          P_Admin_Group_Id      => FND_API.G_MISS_NUM,
          P_identity_salesforce_id => FND_API.G_MISS_NUM,
          P_Salesgroup_id       => FND_API.G_MISS_NUM,
          P_Sales_Lead_Id       => l_sales_lead_id,
          X_Return_Status       => l_lead_proc_ret_status,
          X_Msg_Count           => l_lead_proc_msg_count,
          X_Msg_Data            => l_lead_proc_msg_data
       );

       IF NVL(l_lead_proc_ret_status,'S') IN ('E','U') THEN
	 fnd_file.put_line(fnd_file.log, 'AS_SALES_LEADS_PUB.Lead_Process_After_Create failed.');
       END IF;

  END IF; -- end lead properly created


  END insert_row;


  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_enquiry_appl_number               IN     NUMBER,
    x_sales_lead_id                     IN     NUMBER,
    x_acad_cal_type                     IN     VARCHAR2,
    x_acad_ci_sequence_number           IN     NUMBER,
    x_adm_cal_type                      IN     VARCHAR2,
    x_adm_ci_sequence_number            IN     NUMBER,
    x_enquiry_dt                        IN     DATE,
    x_registering_person_id             IN     NUMBER,
    x_override_process_ind              IN     VARCHAR2,
    x_indicated_mailing_dt              IN     DATE,
    x_last_process_dt                   IN     DATE,
    x_comments                          IN     VARCHAR2,
    x_org_id                            IN     NUMBER,
    x_inq_entry_level_id                IN     NUMBER,
    x_edu_goal_id                       IN     NUMBER,
    x_party_id                          IN     NUMBER,
    x_how_knowus_id                     IN     NUMBER,
    x_who_influenced_id                 IN     NUMBER,
    x_attribute_category                IN     VARCHAR2,
    x_attribute1                        IN     VARCHAR2,
    x_attribute2                        IN     VARCHAR2,
    x_attribute3                        IN     VARCHAR2,
    x_attribute4                        IN     VARCHAR2,
    x_attribute5                        IN     VARCHAR2,
    x_attribute6                        IN     VARCHAR2,
    x_attribute7                        IN     VARCHAR2,
    x_attribute8                        IN     VARCHAR2,
    x_attribute9                        IN     VARCHAR2,
    x_attribute10                       IN     VARCHAR2,
    x_attribute11                       IN     VARCHAR2,
    x_attribute12                       IN     VARCHAR2,
    x_attribute13                       IN     VARCHAR2,
    x_attribute14                       IN     VARCHAR2,
    x_attribute15                       IN     VARCHAR2,
    x_attribute16                       IN     VARCHAR2,
    x_attribute17                       IN     VARCHAR2,
    x_attribute18                       IN     VARCHAR2,
    x_attribute19                       IN     VARCHAR2,
    x_attribute20                       IN     VARCHAR2,
    x_s_enquiry_status                  IN     VARCHAR2,
    x_enabled_flag                      IN     VARCHAR2,
    x_inquiry_method_code               IN     VARCHAR2,
    x_mode                              IN     VARCHAR2,
    x_action                            IN     VARCHAR2,
    x_source_promotion_id               IN     VARCHAR2,
    x_ret_status                        OUT NOCOPY VARCHAR2,
    x_msg_data                          OUT NOCOPY VARCHAR2,
    x_msg_count                         OUT NOCOPY NUMBER,
    x_pkg_reduct_ind                    IN      VARCHAR2 DEFAULT NULL
  ) AS
  /*
  ||  Created By : hreddych
  ||  Created On : 22-JAN-2003
  ||  Purpose : Handles the UPDATE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    x_last_update_date           DATE ;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;
    x_request_id                 NUMBER;
    x_program_id                 NUMBER;
    x_program_application_id     NUMBER;
    x_program_update_date        DATE;

    l_lead_proc_ret_status       VARCHAR2(1);
    l_lead_proc_msg_count        NUMBER;
    l_lead_proc_msg_data         VARCHAR2(2000);

    l_tmp_var VARCHAR2(2000);
    l_employee_id     as_sales_leads.assign_to_person_id%TYPE;
    l_resource_id     as_sales_leads.assign_to_Salesforce_id%TYPE;
    ddp_sales_lead_profile_tbl  as_utility_pub.profile_tbl_type;
    ddp_sales_lead_line_tbl     as_sales_leads_pub.sales_lead_line_tbl_type;
    ddp_sales_lead_contact_tbl  as_sales_leads_pub.sales_lead_contact_tbl_type;
    l_sales_lead_rec  as_sales_leads_pub.G_MISS_SALES_LEAD_REC%TYPE ;

    CURSOR cur_last_update_date IS
    SELECT last_update_date
    FROM   as_sales_leads
    WHERE  sales_lead_id = x_sales_lead_id;

    CURSOR cur_sales_lead_rec IS
    SELECT assign_to_person_id, assign_to_salesforce_id
    FROM   as_sales_leads
    WHERE  sales_lead_id = x_sales_lead_id;

  BEGIN
      OPEN cur_sales_lead_rec ;
      FETCH cur_sales_lead_rec INTO l_employee_id,l_resource_id ;
      CLOSE cur_sales_lead_rec ;

      l_sales_lead_rec.assign_to_person_id           :=l_employee_id ;
      l_sales_lead_rec.assign_to_Salesforce_id       :=l_resource_id ;
      l_sales_lead_rec.source_promotion_id           :=x_source_promotion_id ;

      l_sales_lead_rec.status_code                   :=x_s_enquiry_status;
      l_sales_lead_rec.vehicle_response_code         :=x_inquiry_method_code;
      l_sales_lead_rec.customer_id                   :=x_person_id;
      l_sales_lead_rec.sales_lead_id                 :=x_sales_lead_id;

      OPEN cur_last_update_date ;
      FETCH cur_last_update_date INTO l_sales_lead_rec.last_update_date ;
      CLOSE cur_last_update_date;

 as_sales_leads_pub.update_sales_lead(
    P_Api_Version_Number     => 2.0  ,
    P_Init_Msg_List          => FND_API.G_FALSE,
    P_Commit                 => FND_API.G_FALSE,
    P_Validation_Level       => AS_UTILITY_PUB.G_VALID_LEVEL_ITEM,
    P_Check_Access_Flag      => FND_API.G_MISS_CHAR,
    P_Admin_Flag             => 'Y',
    P_Admin_Group_Id         => FND_API.G_MISS_NUM,
    P_identity_salesforce_id => FND_API.G_MISS_NUM,
    P_Sales_Lead_Profile_Tbl => ddp_sales_lead_profile_tbl,
    P_SALES_LEAD_Rec         => l_sales_lead_rec,
    X_Return_Status          => x_ret_status ,
    X_Msg_Count              => x_msg_count,
    X_Msg_Data               => x_msg_data);

   IF x_ret_status  IN ('E','U') THEN
      IF x_msg_count > 1 THEN
         FOR i IN 1..x_msg_count LOOP
           l_tmp_var := l_tmp_var || ' '||fnd_msg_pub.get(p_encoded => fnd_api.g_false);
         END LOOP;
         x_msg_data := trim(l_tmp_var);
       END IF;
  ELSE
  igr_i_appl_pkg.update_row (
  X_ROWID			=>  X_ROWID ,
  X_PERSON_ID			=>  X_PERSON_ID ,
  X_SALES_LEAD_ID		=>  X_SALES_LEAD_ID ,
  X_ENQUIRY_APPL_NUMBER		=>  X_ENQUIRY_APPL_NUMBER ,
  X_ACAD_CAL_TYPE		=>  X_ACAD_CAL_TYPE ,
  X_ACAD_CI_SEQUENCE_NUMBER	=>  X_ACAD_CI_SEQUENCE_NUMBER ,
  X_ADM_CAL_TYPE		=>  X_ADM_CAL_TYPE ,
  X_ADM_CI_SEQUENCE_NUMBER	=>  X_ADM_CI_SEQUENCE_NUMBER ,
  X_ENQUIRY_DT			=>  X_ENQUIRY_DT ,
  X_REGISTERING_PERSON_ID	=>  X_REGISTERING_PERSON_ID ,
  X_OVERRIDE_PROCESS_IND	=>  X_OVERRIDE_PROCESS_IND ,
  X_INDICATED_MAILING_DT	=>  X_INDICATED_MAILING_DT ,
  X_LAST_PROCESS_DT		=>  X_LAST_PROCESS_DT ,
  X_COMMENTS			=>  X_COMMENTS ,
  X_INQ_ENTRY_LEVEL_ID		=>  X_INQ_ENTRY_LEVEL_ID ,
  X_EDU_GOAL_ID			=>  X_EDU_GOAL_ID ,
  X_PARTY_ID			=>  X_PARTY_ID ,
  X_HOW_KNOWUS_ID		=>  X_HOW_KNOWUS_ID ,
  X_WHO_INFLUENCED_ID		=>  X_WHO_INFLUENCED_ID ,
  X_ATTRIBUTE_CATEGORY		=>  X_ATTRIBUTE_CATEGORY ,
  X_ATTRIBUTE1			=>  X_ATTRIBUTE1 ,
  X_ATTRIBUTE2			=>  X_ATTRIBUTE2 ,
  X_ATTRIBUTE3			=>  X_ATTRIBUTE3 ,
  X_ATTRIBUTE4			=>  X_ATTRIBUTE4 ,
  X_ATTRIBUTE5			=>  X_ATTRIBUTE5 ,
  X_ATTRIBUTE6			=>  X_ATTRIBUTE6 ,
  X_ATTRIBUTE7			=>  X_ATTRIBUTE7 ,
  X_ATTRIBUTE8			=>  X_ATTRIBUTE8 ,
  X_ATTRIBUTE9			=>  X_ATTRIBUTE9 ,
  X_ATTRIBUTE10			=>  X_ATTRIBUTE10 ,
  X_ATTRIBUTE11			=>  X_ATTRIBUTE11 ,
  X_ATTRIBUTE12			=>  X_ATTRIBUTE12 ,
  X_ATTRIBUTE13			=>  X_ATTRIBUTE13 ,
  X_ATTRIBUTE14			=>  X_ATTRIBUTE14 ,
  X_ATTRIBUTE15			=>  X_ATTRIBUTE15 ,
  X_ATTRIBUTE16			=>  X_ATTRIBUTE16 ,
  X_ATTRIBUTE17			=>  X_ATTRIBUTE17 ,
  X_ATTRIBUTE18			=>  X_ATTRIBUTE18 ,
  X_ATTRIBUTE19			=>  X_ATTRIBUTE19 ,
  X_ATTRIBUTE20			=>  X_ATTRIBUTE20 ,
  X_MODE                        =>   'R'          ,
  X_PKG_REDUCT_IND              => x_pkg_reduct_ind

  );
  Igr_in_jtf_interactions_pkg.start_int_and_act (     p_doc_ref	=>  'LEAD',
                         p_person_id      =>  X_PERSON_ID,
			 p_sales_lead_id  =>  X_SALES_LEAD_ID,
                         p_item_id	  =>  NULL,
			 p_doc_id         =>  X_SALES_LEAD_ID,
                         p_action         =>  X_ACTION ,
                         p_action_item    => 'INQUIRY',
	                 p_ret_status     =>  x_ret_status,
	 		 p_msg_data       =>  x_msg_data,
	                 p_msg_count      =>  x_msg_count);


    -- call Sales Real Time lead assignment API, passing in local ret/msg
    -- variables, as failure of this API should not preclude lead
    -- or inquiry creation.

       AS_SALES_LEADS_PUB.Lead_Process_After_Update (
          P_Api_Version_Number	=> 2.0,
          P_Init_Msg_List       => FND_API.G_FALSE,
          P_Commit              => FND_API.G_FALSE,
          P_Validation_Level    => AS_UTILITY_PUB.G_VALID_LEVEL_ITEM,
          P_Check_Access_Flag   => FND_API.G_MISS_CHAR,
          P_Admin_Flag          => FND_API.G_MISS_CHAR,
          P_Admin_Group_Id      => FND_API.G_MISS_NUM,
          P_identity_salesforce_id => FND_API.G_MISS_NUM,
          P_Salesgroup_id       => FND_API.G_MISS_NUM,
          P_Sales_Lead_Id       => x_sales_lead_id,
          X_Return_Status       => l_lead_proc_ret_status,
          X_Msg_Count           => l_lead_proc_msg_count,
          X_Msg_Data            => l_lead_proc_msg_data
       );

       IF NVL(l_lead_proc_ret_status,'S') IN ('E','U') THEN
         fnd_file.put_line(fnd_file.log, 'AS_SALES_LEADS_PUB.Lead_Process_After_Update failed.');
       END IF;

    END IF;

  END update_row;

END igr_inquiry_pkg;

/
