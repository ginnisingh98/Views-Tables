--------------------------------------------------------
--  DDL for Package Body IGR_INQUIRY_LINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGR_INQUIRY_LINES_PKG" AS
/* $Header: IGSRT04B.pls 120.1 2005/11/23 13:27:53 appldev noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_sales_lead_line_id                OUT NOCOPY    NUMBER,
    x_person_id                         IN     NUMBER,
    x_enquiry_appl_number               IN     NUMBER,
    x_enquiry_dt                        IN     DATE,
    x_inquiry_method_code               IN     VARCHAR2,
    x_preference                        IN     NUMBER,
    x_ret_status                        OUT NOCOPY VARCHAR2,
    x_msg_data                          OUT NOCOPY VARCHAR2,
    x_msg_count                         OUT NOCOPY NUMBER,
    x_mode                              IN     VARCHAR2,
    x_product_category_id               IN  NUMBER,
    x_product_category_set_id           IN  NUMBER
  ) AS
  /*
  ||  Created By : hreddych
  ||  Created On : 30-JAN-2003
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
     l_tmp_var VARCHAR2(2000);
     lv_rowid VARCHAR2(30);
     l_sales_lead_id             igr_i_appl_all.sales_lead_id%TYPE;
     l_sales_lead_line_id        igr_i_a_lines.sales_lead_line_id%TYPE;
     ddp_sales_lead_profile_tbl  as_utility_pub.profile_tbl_type;
     ddp_sales_lead_line_tbl     as_sales_leads_pub.sales_lead_line_tbl_type;
     ddx_sales_lead_line_out_tbl as_sales_leads_pub.sales_lead_line_out_tbl_type;
     l_lead_proc_ret_status       VARCHAR2(1);
     l_lead_proc_msg_count        NUMBER;
     l_lead_proc_msg_data         VARCHAR2(2000);


     CURSOR cur_sales_lead_id (p_person_id igr_i_appl_all.person_id%TYPE,
                               p_enquiry_appl_number igr_i_appl_all.enquiry_appl_number%TYPE) IS
     SELECT sales_lead_id
     FROM   igr_i_appl_all
     WHERE  person_id =p_person_id
     AND    enquiry_appl_number = p_enquiry_appl_number ;

  BEGIN

   IF get_uk_for_validation(x_person_id               => x_person_id,
                            x_enquiry_appl_number     => x_enquiry_appl_number,
                            x_product_category_id     => x_product_category_id,
                            x_product_category_set_id => x_product_category_set_id ) THEN
      FND_MESSAGE.SET_NAME('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
   END IF;

   OPEN cur_sales_lead_id( x_person_id,x_enquiry_appl_number);
   FETCH cur_sales_lead_id INTO l_sales_lead_id	;
   CLOSE cur_sales_lead_id;

   ddp_sales_lead_line_tbl(1).sales_lead_line_id := NULL;
   ddp_sales_lead_line_tbl(1).organization_id := FND_PROFILE.VALUE('ORG_ID');
   ddp_sales_lead_line_tbl(1).category_id := x_product_category_id;
   ddp_sales_lead_line_tbl(1).category_set_id := x_product_category_set_id;

   as_sales_leads_pub.Create_sales_lead_lines(
    P_Api_Version_Number          => 2.0,
    P_Init_Msg_List               => FND_API.G_FALSE,
    P_Commit                      => FND_API.G_FALSE,
    p_validation_level            => AS_UTILITY_PUB.G_VALID_LEVEL_ITEM,
    P_Check_Access_Flag           => FND_API.G_MISS_CHAR,
    P_Admin_Flag                  => 'Y',
    P_Admin_Group_Id              => FND_API.G_MISS_NUM,
    P_identity_salesforce_id      => FND_API.G_MISS_NUM,
    P_Sales_Lead_Profile_Tbl      => ddp_sales_lead_profile_tbl,
    P_SALES_LEAD_LINE_Tbl         => ddp_sales_lead_line_tbl,
    P_SALES_LEAD_ID               => l_sales_lead_id,
    X_SALES_LEAD_LINE_OUT_Tbl     => ddx_sales_lead_line_out_tbl,
    X_Return_Status               => x_ret_status,
    X_Msg_Count                   => x_msg_count,
    X_Msg_Data                    => x_msg_data
    );

 X_sales_lead_line_id :=ddx_sales_lead_line_out_tbl(1).sales_lead_line_id;
    IF x_ret_status  IN ('E','U') THEN
      IF x_msg_count > 1 THEN
         FOR i IN 1..x_msg_count LOOP
           l_tmp_var := l_tmp_var || ' '||fnd_msg_pub.get(p_encoded => fnd_api.g_false);
         END LOOP;
         x_msg_data := trim(l_tmp_var);
       END IF;
   ELSE
      lv_rowid := x_rowid ;
      igr_i_a_lines_pkg.insert_row (
      x_mode                              => 'R',
      x_rowid                             => lv_rowid,
      x_person_id                         => x_person_id,
      x_enquiry_appl_number               => x_enquiry_appl_number,
      x_sales_lead_line_id                => X_sales_lead_line_id,
      x_preference                        => x_preference
    );
      x_rowid := lv_rowid ;

    -- call Sales Real Time lead assignment API, passing in local ret/msg
    -- variables, as failure of this API should not preclude lead
    -- or inquiry line creation.

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
        P_Sales_Lead_Id       => l_sales_lead_id,
        X_Return_Status       => l_lead_proc_ret_status,
        X_Msg_Count           => l_lead_proc_msg_count,
        X_Msg_Data            => l_lead_proc_msg_data
      );

      IF NVL(l_lead_proc_ret_status,'S') IN ('E','U') THEN
        fnd_file.put_line(fnd_file.log, 'AS_SALES_LEADS_PUB.Lead_Process_After_Update failed.');
      END IF;

   END IF;

  END insert_row;



  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_sales_lead_line_id                IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_enquiry_appl_number               IN     NUMBER,
    x_enquiry_dt                        IN     DATE,
    x_inquiry_method_code               IN     VARCHAR2,
    x_preference                        IN     NUMBER,
    x_mode                              IN     VARCHAR2,
    x_ret_status                        OUT NOCOPY VARCHAR2,
    x_msg_data                          OUT NOCOPY VARCHAR2,
    x_msg_count                         OUT NOCOPY NUMBER,
    x_product_category_id               IN  NUMBER,
    x_product_category_set_id           IN  NUMBER
  ) AS
  /*
  ||  Created By : hreddych
  ||  Created On : 30-JAN-2003
  ||  Purpose : Handles the UPDATE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

     l_tmp_var VARCHAR2(2000);
     lv_rowid VARCHAR2(30);
     l_sales_lead_id             igr_i_appl_all.sales_lead_id%TYPE;
     l_sales_lead_line_id        igr_i_a_lines.sales_lead_line_id%TYPE;
     ddp_sales_lead_profile_tbl  as_utility_pub.profile_tbl_type;
     ddp_sales_lead_line_tbl     as_sales_leads_pub.sales_lead_line_tbl_type;
     ddx_sales_lead_line_out_tbl as_sales_leads_pub.sales_lead_line_out_tbl_type;
     l_lead_proc_ret_status       VARCHAR2(1);
     l_lead_proc_msg_count        NUMBER;
     l_lead_proc_msg_data         VARCHAR2(2000);

     CURSOR cur_sales_lead_id (p_person_id igr_i_appl_all.person_id%TYPE,
                               p_enquiry_appl_number igr_i_appl_all.enquiry_appl_number%TYPE) IS
     SELECT sales_lead_id
     FROM   igr_i_appl_all
     WHERE  person_id =p_person_id
     AND    enquiry_appl_number = p_enquiry_appl_number ;

     CURSOR cur_last_update_date IS
     SELECT last_update_date
     FROM   as_sales_lead_lines
     WHERE  sales_lead_line_id = x_sales_lead_line_id;

  BEGIN

   IF get_uk_for_validation(x_person_id           => x_person_id,
                            x_enquiry_appl_number => x_enquiry_appl_number,
			    x_rowid               => x_rowid,
                            x_product_category_id     => x_product_category_id,
                            x_product_category_set_id => x_product_category_set_id ) THEN
      FND_MESSAGE.SET_NAME('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
   END IF;

   OPEN cur_sales_lead_id( x_person_id,x_enquiry_appl_number);
   FETCH cur_sales_lead_id INTO l_sales_lead_id	;
   CLOSE cur_sales_lead_id;

   OPEN cur_last_update_date;
   FETCH cur_last_update_date INTO ddp_sales_lead_line_tbl(1).last_update_date ;
   CLOSE cur_last_update_date;

   ddp_sales_lead_line_tbl(1).sales_lead_id := l_sales_lead_id;
   ddp_sales_lead_line_tbl(1).sales_lead_line_id := x_sales_lead_line_id;
   ddp_sales_lead_line_tbl(1).organization_id := FND_PROFILE.VALUE('ORG_ID');
   ddp_sales_lead_line_tbl(1).category_id := x_product_category_id;
   ddp_sales_lead_line_tbl(1).category_set_id := x_product_category_set_id;

  as_sales_leads_pub.Update_sales_lead_lines(
    P_Api_Version_Number         =>2.0,
    P_Init_Msg_List              => FND_API.G_FALSE,
    P_Commit                     => FND_API.G_FALSE,
    p_validation_level           => AS_UTILITY_PUB.G_VALID_LEVEL_ITEM,
    P_Check_Access_Flag          => FND_API.G_MISS_CHAR,
    P_Admin_Flag                 => 'Y',
    P_Admin_Group_Id             => FND_API.G_MISS_NUM,
    P_identity_salesforce_id     => FND_API.G_MISS_NUM,
    P_Sales_Lead_Profile_Tbl     => ddp_sales_lead_profile_tbl,
    P_SALES_LEAD_LINE_Tbl        => ddp_sales_lead_line_tbl,
    X_SALES_LEAD_LINE_OUT_Tbl    => ddx_sales_lead_line_out_tbl,
    X_Return_Status              => x_ret_status,
    X_Msg_Count                  => x_msg_count,
    X_Msg_Data                   => x_msg_data
    );

   IF x_ret_status  IN ('E','U') THEN
      IF x_msg_count > 1 THEN
         FOR i IN 1..x_msg_count LOOP
           l_tmp_var := l_tmp_var || ' '||fnd_msg_pub.get(p_encoded => fnd_api.g_false);
         END LOOP;
         x_msg_data := trim(l_tmp_var);
       END IF;
  ELSE
    igr_i_a_lines_pkg.update_row (
      x_mode                              => 'R',
      x_rowid                             => x_rowid,
      x_person_id                         => x_person_id,
      x_enquiry_appl_number               => x_enquiry_appl_number,
      x_sales_lead_line_id                => x_sales_lead_line_id,
      x_preference                        => x_preference
    );

    -- call Sales Real Time lead assignment API, passing in local ret/msg
    -- variables, as failure of this API should not preclude lead
    -- or inquiry line update.

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
      P_Sales_Lead_Id       => l_sales_lead_id,
      X_Return_Status       => l_lead_proc_ret_status,
      X_Msg_Count           => l_lead_proc_msg_count,
      X_Msg_Data            => l_lead_proc_msg_data
    );

    IF NVL(l_lead_proc_ret_status,'S') IN ('E','U') THEN
      fnd_file.put_line(fnd_file.log, 'AS_SALES_LEADS_PUB.Lead_Process_After_Update failed.');
    END IF;

  END IF;

  END update_row;

  FUNCTION get_uk_for_validation (
    x_person_id           IN     NUMBER,
    x_enquiry_appl_number  IN     NUMBER,
    x_rowid IN VARCHAR2,
    x_product_category_id               IN  NUMBER,
    x_product_category_set_id           IN  NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By :
  ||  Created On : 28-NOV-2001
  ||  Purpose : Validates the Unique Keys of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid (p_person_id            igr_i_a_lines_v.person_id%TYPE ,
    		      p_enquiry_appl_number  igr_i_a_lines_v.enquiry_appl_number%TYPE ,
    		      p_product_category_id     igr_i_a_lines_v.product_category_id%TYPE,
    		      p_product_category_set_id igr_i_a_lines_v.product_category_set_id%TYPE,
		      l_rowid VARCHAR2)  IS
      SELECT   row_id
      FROM     igr_i_a_lines_v
      WHERE    person_id           = p_person_id
      AND      enquiry_appl_number = p_enquiry_appl_number
      AND      product_category_id   = p_product_category_id
      AND      product_category_set_id = p_product_category_set_id
      AND      ((l_rowid IS NULL) OR (row_id <> l_rowid));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid(x_person_id   ,
    		   x_enquiry_appl_number  ,
                   x_product_category_id,
    		   x_product_category_set_id,
    		   x_rowid);
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
        RETURN (true);
    ELSE
       CLOSE cur_rowid;
      RETURN(FALSE);
    END IF;

 END get_uk_for_validation;
END IGR_INQUIRY_LINES_PKG;

/
