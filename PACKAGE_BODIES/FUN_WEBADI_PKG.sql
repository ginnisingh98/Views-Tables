--------------------------------------------------------
--  DDL for Package Body FUN_WEBADI_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FUN_WEBADI_PKG" As
-- $Header: funwadib.pls 120.13.12010000.11 2009/11/17 10:38:04 srampure ship $

   Procedure Insert_Header(
         p_recipient_name In Fun_Interface_Headers.recipient_name%type,
         p_to_le_name In Fun_Interface_Headers.to_le_name%type,
   	 p_trx_tbl In FUN_TRX_PUB.full_trx_tbl_type) Is
   Begin
      If p_trx_tbl.count = 1 Then
         Insert Into Fun_Interface_Headers(
            trx_id,
            trx_number,
            recipient_id,
            recipient_name,
            to_le_id,
            to_le_name,
            to_ledger_id,
            batch_id,
            init_amount_cr,
            init_amount_dr,
            invoicing_rule_flag,
            from_recurring_trx_id,
            initiator_instance_flag,
            recipient_instance_flag,
            description,
            attribute1,
            attribute2,
            attribute3,
            attribute4,
            attribute5,
            attribute6,
            attribute7,
            attribute8,
            attribute9,
            attribute10,
            attribute11,
            attribute12,
            attribute13,
            attribute14,
            attribute15,
            attribute_category,
            created_by,
            creation_date,
            last_updated_by,
            last_update_date,
            last_update_login,
            import_status_code)
         Values(
            p_trx_tbl(1).trx_id,
            p_trx_tbl(1).trx_number,
            p_trx_tbl(1).recipient_id,
            p_recipient_name,
            p_trx_tbl(1).to_le_id,
            p_to_le_name,
            p_trx_tbl(1).to_ledger_id,
            p_trx_tbl(1).batch_id,
            p_trx_tbl(1).init_amount_cr,
            p_trx_tbl(1).init_amount_dr,
            p_trx_tbl(1).invoice_flag,
            p_trx_tbl(1).from_recurring_trx_id,
            p_trx_tbl(1).initiator_instance_flag,
            p_trx_tbl(1).recipient_instance_flag,
            p_trx_tbl(1).description,
            p_trx_tbl(1).attribute1,
            p_trx_tbl(1).attribute2,
            p_trx_tbl(1).attribute3,
            p_trx_tbl(1).attribute4,
            p_trx_tbl(1).attribute5,
            p_trx_tbl(1).attribute6,
            p_trx_tbl(1).attribute7,
            p_trx_tbl(1).attribute8,
            p_trx_tbl(1).attribute9,
            p_trx_tbl(1).attribute10,
            p_trx_tbl(1).attribute11,
            p_trx_tbl(1).attribute12,
            p_trx_tbl(1).attribute13,
            p_trx_tbl(1).attribute14,
            p_trx_tbl(1).attribute15,
            p_trx_tbl(1).attribute_category,
            fnd_global.user_id,
            sysdate,
            fnd_global.user_id,
            sysdate,
            fnd_global.login_id,
            null);
      End If;
   End Insert_Header;

   Procedure Insert_Dists(
  	 p_dist_lines_tbl In FUN_TRX_PUB.full_dist_line_tbl_type,
         p_count In Number) Is
   Begin
      Insert Into Fun_Interface_Dist_Lines(
         trx_id,
         dist_id,
         batch_dist_id,
         dist_number,
         party_id,
         party_type_flag,
         dist_type_flag,
         amount_cr,
         amount_dr,
         ccid,
         attribute1,
         attribute2,
         attribute3,
         attribute4,
         attribute5,
         attribute6,
         attribute7,
         attribute8,
         attribute9,
         attribute10,
         attribute11,
         attribute12,
         attribute13,
         attribute14,
         attribute15,
         attribute_category,
         created_by,
         creation_date,
         last_updated_by,
         last_update_date,
         last_update_login,
         import_status_code,
         description)
      Values(
         p_dist_lines_tbl(p_count).trx_id,
         p_dist_lines_tbl(p_count).dist_id,
         null,
         p_dist_lines_tbl(p_count).dist_number,
         p_dist_lines_tbl(p_count).party_id,
         p_dist_lines_tbl(p_count).party_type_flag,
         p_dist_lines_tbl(p_count).dist_type_flag,
         p_dist_lines_tbl(p_count).amount_cr,
         p_dist_lines_tbl(p_count).amount_dr,
         p_dist_lines_tbl(p_count).ccid,
         p_dist_lines_tbl(p_count).attribute1,
         p_dist_lines_tbl(p_count).attribute2,
         p_dist_lines_tbl(p_count).attribute3,
         p_dist_lines_tbl(p_count).attribute4,
         p_dist_lines_tbl(p_count).attribute5,
         p_dist_lines_tbl(p_count).attribute6,
         p_dist_lines_tbl(p_count).attribute7,
         p_dist_lines_tbl(p_count).attribute8,
         p_dist_lines_tbl(p_count).attribute9,
         p_dist_lines_tbl(p_count).attribute10,
         p_dist_lines_tbl(p_count).attribute11,
         p_dist_lines_tbl(p_count).attribute12,
         p_dist_lines_tbl(p_count).attribute13,
         p_dist_lines_tbl(p_count).attribute14,
         p_dist_lines_tbl(p_count).attribute15,
         p_dist_lines_tbl(p_count).attribute_category,
         fnd_global.user_id,
         sysdate,
         fnd_global.user_id,
         sysdate,
         fnd_global.login_id,
         null,
         p_dist_lines_tbl(p_count).description);
   End Insert_Dists;

   Procedure Insert_Batch(
         p_batch_rec In FUN_TRX_PUB.full_batch_rec_type,
         p_initiator_name In Fun_Interface_Batches.initiator_name%type,
         p_trx_type_name In Fun_Interface_Batches.trx_type_name%type,
         p_from_le_name In Fun_Interface_Headers.to_le_name%type,
         p_insert_flag In Varchar2) Is

      l_group_id NUMBER;
   Begin

      SELECT fun_interface_controls_s.nextval
      INTO l_group_id
      FROM dual;

      If p_insert_flag = 'Y' Then
         Insert Into Fun_Interface_Batches(
            source,
            group_id,
            batch_id,
            batch_number,
            initiator_id,
            initiator_name,
            from_le_id,
            from_le_name,
            from_ledger_id,
            control_total,
            running_total_cr,
            running_total_dr,
            currency_code,
            exchange_rate_type,
            description,
            trx_type_id,
            trx_type_code,
            trx_type_name,
            gl_date,
            batch_date,
            reject_allowed_flag,
            from_recurring_batch_id,
            attribute1,
            attribute2,
            attribute3,
            attribute4,
            attribute5,
            attribute6,
            attribute7,
            attribute8,
            attribute9,
            attribute10,
            attribute11,
            attribute12,
            attribute13,
            attribute14,
            attribute15,
            attribute_category,
            created_by,
            creation_date,
            last_updated_by,
            last_update_date,
            last_update_login,
            import_status_code,
            note)
         Values(
            'Global Intercompany',
            l_group_id,
            p_batch_rec.batch_id,
            p_batch_rec.batch_number,
            p_batch_rec.initiator_id,
            p_initiator_name,
            p_batch_rec.from_le_id,
            p_from_le_name,
            p_batch_rec.from_ledger_id,
            p_batch_rec.control_total,
            null,
            null,
            p_batch_rec.currency_code,
            p_batch_rec.exchange_rate_type,
            p_batch_rec.description,
            p_batch_rec.trx_type_id,
            p_batch_rec.trx_type_code,
            p_trx_type_name,
            p_batch_rec.gl_Date,
            p_batch_rec.batch_Date,
            p_batch_rec.reject_allow_flag,
            p_batch_rec.from_recurring_batch_id,
            p_batch_rec.attribute1,
            p_batch_rec.attribute2,
            p_batch_rec.attribute3,
            p_batch_rec.attribute4,
            p_batch_rec.attribute5,
            p_batch_rec.attribute6,
            p_batch_rec.attribute7,
            p_batch_rec.attribute8,
            p_batch_rec.attribute9,
            p_batch_rec.attribute10,
            p_batch_rec.attribute11,
            p_batch_rec.attribute12,
            p_batch_rec.attribute13,
            p_batch_rec.attribute14,
            p_batch_rec.attribute15 ,
            p_batch_rec.attribute_category,
            fnd_global.user_id,
            sysdate,
            fnd_global.user_id,
            sysdate,
            fnd_global.login_id,
            null,
            p_batch_rec.note);

         Insert into Fun_Interface_Controls(
            source,
            group_id)
         Values(
            'Global Intercompany',
            l_group_id);
      Elsif p_insert_flag = 'N' Then
         Update Fun_Interface_Batches Set
            currency_code = p_batch_rec.currency_code,
            exchange_rate_type = p_batch_rec.exchange_rate_type,
            description = p_batch_rec.description,
            trx_type_id = p_batch_rec.trx_type_id,
            trx_type_code = p_batch_rec.trx_type_code,
            trx_type_name = p_trx_type_name,
            gl_date = p_batch_rec.gl_Date,
            batch_date = p_batch_rec.batch_Date,
            reject_allowed_flag = p_batch_rec.reject_allow_flag,
            from_recurring_batch_id = p_batch_rec.from_recurring_batch_id,
            attribute1 = p_batch_rec.attribute1,
            attribute2 = p_batch_rec.attribute2,
            attribute3 = p_batch_rec.attribute3,
            attribute4 = p_batch_rec.attribute4,
            attribute5 = p_batch_rec.attribute5,
            attribute6 = p_batch_rec.attribute6,
            attribute7 = p_batch_rec.attribute7,
            attribute8 = p_batch_rec.attribute8,
            attribute9 = p_batch_rec.attribute9,
            attribute10 = p_batch_rec.attribute10,
            attribute11 = p_batch_rec.attribute11,
            attribute12 = p_batch_rec.attribute12,
            attribute13 = p_batch_rec.attribute13,
            attribute14 = p_batch_rec.attribute14,
            attribute15 = p_batch_rec.attribute15,
            attribute_category = p_batch_rec.attribute_category,
            last_updated_by = fnd_global.user_id,
            last_update_date = sysdate,
            last_update_login = fnd_global.login_id,
            note = p_batch_rec.note
         Where batch_number = p_batch_rec.batch_number;
      End If;
   End Insert_Batch;

   Procedure Validate_Record(
         p_batch_rec In FUN_TRX_PUB.full_batch_rec_type,
         p_trx_tbl In FUN_TRX_PUB.full_trx_tbl_type,
         p_dist_lines_tbl In FUN_TRX_PUB.full_dist_line_tbl_type,
         p_batch_insert In Varchar2) Is
      l_batch_rec Fun_Trx_Pvt.batch_rec_type;
      l_trx_tbl	Fun_Trx_Pvt.trx_tbl_type;
      l_dist_lines_tbl Fun_Trx_Pvt.dist_line_tbl_type;
      l_init_dist_tbl Fun_Trx_Pvt.init_dist_tbl_type;
      l_trx_rec_type Fun_Trx_Pvt.trx_rec_type;
      l_dist_lines_rec_type Fun_Trx_Pvt.dist_line_rec_type;
      l_validation_level Number := 50;
      l_return_status Varchar2(1);
      l_msg_count Number;
      l_msg_data Varchar2(2000);
      l_insert Varchar2(1);

      -- 24-10-2007 MAKANSAL
      -- For Bug # 6249898 Introduced to keep the recipient party id and recipient legal entity id
      l_le_party_id Xle_Firstparty_Information_V.party_id%type;
      l_to_le_id GL_LEDGER_LE_BSV_SPECIFIC_V.LEGAL_ENTITY_ID%type;

      -- 24-10-2007 MAKANSAL
      -- For Bug # 6249898 Introduced the Cursor to fetch the Recipient Legal Entity Id
      Cursor C_Le_Id(cp_le_party_id In Xle_Entity_Profiles.party_id%type) Is
      	Select legal_entity_id
      	From Xle_Firstparty_Information_V
      	Where party_id = cp_le_party_id;
   Begin
      l_batch_rec.batch_id := p_batch_rec.batch_id;
      l_batch_rec.batch_number := p_batch_rec.batch_number;
      l_batch_rec.initiator_id := p_batch_rec.initiator_id;
      l_batch_rec.from_le_id := p_batch_rec.from_le_id;
      l_batch_rec.from_ledger_id := p_batch_rec.from_ledger_id;
      l_batch_rec.control_total := p_batch_rec.control_total;
      l_batch_rec.currency_code := p_batch_rec.currency_code;
      l_batch_rec.exchange_rate_type := p_batch_rec.exchange_rate_type;
      l_batch_rec.status := p_batch_rec.status;
      l_batch_rec.description := p_batch_rec.description;
      l_batch_rec.trx_type_id := p_batch_rec.trx_type_id;
      l_batch_rec.trx_type_code := p_batch_rec.trx_type_code;
      l_batch_rec.gl_date := p_batch_rec.gl_date;
      l_batch_rec.batch_date := p_batch_rec.batch_date;
      l_batch_rec.reject_allowed := p_batch_rec.reject_allow_flag;
      l_batch_rec.from_recurring_batch := p_batch_rec.from_recurring_batch_id;
      l_batch_rec.automatic_proration_flag := 'N';

      For l_count In 1..p_trx_tbl.count Loop
         l_trx_tbl(l_count).trx_id := p_trx_tbl(l_count).trx_id;
         l_trx_tbl(l_count).initiator_id := p_trx_tbl(l_count).initiator_id;
         l_trx_tbl(l_count).recipient_id := p_trx_tbl(l_count).recipient_id;
         l_trx_tbl(l_count).to_le_id := p_trx_tbl(l_count).to_le_id;
         l_trx_tbl(l_count).to_ledger_id := p_trx_tbl(l_count).to_ledger_id;
         l_trx_tbl(l_count).batch_id := p_trx_tbl(l_count).batch_id;
         l_trx_tbl(l_count).status := p_trx_tbl(l_count).status;
         l_trx_tbl(l_count).init_amount_cr := p_trx_tbl(l_count).init_amount_cr;
         l_trx_tbl(l_count).init_amount_dr := p_trx_tbl(l_count).init_amount_dr;
         l_trx_tbl(l_count).reci_amount_cr := p_trx_tbl(l_count).reci_amount_cr;
         l_trx_tbl(l_count).reci_amount_dr := p_trx_tbl(l_count).reci_amount_dr;
         l_trx_tbl(l_count).invoicing_rule := p_trx_tbl(l_count).invoice_flag;
         l_trx_tbl(l_count).approver_id := p_trx_tbl(l_count).approver_id;
         l_trx_tbl(l_count).approval_date := p_trx_tbl(l_count).approval_date;
         l_trx_tbl(l_count).original_trx_id := p_trx_tbl(l_count).original_trx_id;
         l_trx_tbl(l_count).reversed_trx_id := p_trx_tbl(l_count).reversed_trx_id;
         l_trx_tbl(l_count).from_recurring_trx_id := p_trx_tbl(l_count).from_recurring_trx_id;
         l_trx_tbl(l_count).initiator_instance := p_trx_tbl(l_count).initiator_instance_flag;
         l_trx_tbl(l_count).recipient_instance := p_trx_tbl(l_count).recipient_instance_flag;
         l_trx_tbl(l_count).automatic_proration_flag := 'N';
         l_trx_tbl(l_count).trx_number := p_trx_tbl(l_count).trx_number;
      End Loop;

      If p_dist_lines_tbl is not null Then
         For l_count In 1..p_dist_lines_tbl.Count Loop
            l_dist_lines_tbl(l_count).dist_id := p_dist_lines_tbl(l_count).dist_id;
            l_dist_lines_tbl(l_count).dist_number := p_dist_lines_tbl(l_count).dist_number;
            l_dist_lines_tbl(l_count).trx_id := p_dist_lines_tbl(l_count).trx_id;
            l_dist_lines_tbl(l_count).line_id := p_dist_lines_tbl(l_count).line_id;
            l_dist_lines_tbl(l_count).party_id := p_dist_lines_tbl(l_count).party_id ;
            l_dist_lines_tbl(l_count).party_type := p_dist_lines_tbl(l_count).party_type_flag;
            l_dist_lines_tbl(l_count).dist_type := p_dist_lines_tbl(l_count).dist_type_flag;
            l_dist_lines_tbl(l_count).batch_dist_id := p_dist_lines_tbl(l_count).batch_dist_id;
            l_dist_lines_tbl(l_count).amount_cr := p_dist_lines_tbl(l_count).amount_cr;
            l_dist_lines_tbl(l_count).amount_dr := p_dist_lines_tbl(l_count).amount_dr;
            l_dist_lines_tbl(l_count).ccid := p_dist_lines_tbl(l_count).ccid;
         End Loop;
      End If;

      IF (p_batch_insert ='Y') THEN
            l_insert := FND_API.G_TRUE;
      ELSE
            l_insert := FND_API.G_FALSE;
      END IF;

      Fun_Trx_Pvt.Init_Batch_Validate (
            1.0,
            Fnd_Api.G_TRUE,
            l_validation_level,
            l_return_status,
            l_msg_count,
            l_msg_data,
            l_insert,
            l_batch_rec,
            l_trx_tbl,
            l_init_dist_tbl,
            l_dist_lines_tbl);
      If l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR Then
 	 Raise Fnd_Api.G_EXC_UNEXPECTED_ERROR;
      Elsif l_return_status = Fnd_Api.G_RET_STS_ERROR Then
 	 Raise Fnd_Api.G_EXC_ERROR;
      End If;

      l_trx_tbl.Delete;
      l_init_dist_tbl.Delete;
      l_dist_lines_tbl.Delete;

      For l_count In 1..p_trx_tbl.count	Loop
	 l_trx_rec_type.trx_id := p_trx_tbl(l_count).trx_id;
	 l_trx_rec_type.initiator_id := p_trx_tbl(l_count).initiator_id;
	 l_trx_rec_type.recipient_id := p_trx_tbl(l_count).recipient_id;
	 l_trx_rec_type.to_le_id := p_trx_tbl(l_count).to_le_id;
	 l_trx_rec_type.to_ledger_id := p_trx_tbl(l_count).to_ledger_id;
	 l_trx_rec_type.batch_id := p_trx_tbl(l_count).batch_id;
	 l_trx_rec_type.status := p_trx_tbl(l_count).status;
	 l_trx_rec_type.init_amount_cr := p_trx_tbl(l_count).init_amount_cr;
	 l_trx_rec_type.init_amount_dr := p_trx_tbl(l_count).init_amount_dr;
	 l_trx_rec_type.reci_amount_cr := p_trx_tbl(l_count).reci_amount_cr;
	 l_trx_rec_type.reci_amount_dr := p_trx_tbl(l_count).reci_amount_dr;
	 l_trx_rec_type.invoicing_rule := p_trx_tbl(l_count).invoice_flag;
	 l_trx_rec_type.approver_id := p_trx_tbl(l_count).approver_id;
	 l_trx_rec_type.approval_date := p_trx_tbl(l_count).approval_date;
	 l_trx_rec_type.original_trx_id := p_trx_tbl(l_count).original_trx_id;
	 l_trx_rec_type.reversed_trx_id := p_trx_tbl(l_count).reversed_trx_id;
	 l_trx_rec_type.from_recurring_trx_id := p_trx_tbl(l_count).from_recurring_trx_id;
	 l_trx_rec_type.initiator_instance := p_trx_tbl(l_count).initiator_instance_flag;
	 l_trx_rec_type.recipient_instance := p_trx_tbl(l_count).recipient_instance_flag;
         l_trx_rec_type.trx_number := p_trx_tbl(l_count).trx_number;

	 If p_dist_lines_tbl is not null Then
	    For l_count In 1..p_dist_lines_tbl.Count Loop
	       l_dist_lines_tbl(l_count).dist_id := p_dist_lines_tbl(l_count).dist_id;
	       l_dist_lines_tbl(l_count).dist_number := p_dist_lines_tbl(l_count).dist_number;
	       l_dist_lines_tbl(l_count).trx_id := p_dist_lines_tbl(l_count).trx_id;
	       l_dist_lines_tbl(l_count).line_id := p_dist_lines_tbl(l_count).line_id;
	       l_dist_lines_tbl(l_count).party_id := p_dist_lines_tbl(l_count).party_id ;
	       l_dist_lines_tbl(l_count).party_type := p_dist_lines_tbl(l_count).party_type_flag;
	       l_dist_lines_tbl(l_count).dist_type := p_dist_lines_tbl(l_count).dist_type_flag;
	       l_dist_lines_tbl(l_count).batch_dist_id := p_dist_lines_tbl(l_count).batch_dist_id;
	       l_dist_lines_tbl(l_count).amount_cr := p_dist_lines_tbl(l_count).amount_cr;
	       l_dist_lines_tbl(l_count).amount_dr := p_dist_lines_tbl(l_count).amount_dr;
	       l_dist_lines_tbl(l_count).ccid := p_dist_lines_tbl(l_count).ccid;
	    End Loop;
         End If;
      End Loop;

      l_return_status := null;
      l_msg_count := null;
      l_msg_data := null;

      Fun_Trx_Pvt.Init_Trx_Validate (
            1.0,
            Fnd_Api.G_TRUE,
            l_validation_level,
            l_return_status,
            l_msg_count,
            l_msg_data,
            l_trx_rec_type,
            l_dist_lines_tbl,
            l_batch_rec.currency_code,
            l_batch_rec.gl_date,
            l_batch_rec.batch_date);
      If l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR Then
	 Raise Fnd_Api.G_EXC_UNEXPECTED_ERROR;
      Elsif l_return_status = Fnd_Api.G_RET_STS_ERROR Then
	 Raise Fnd_Api.G_EXC_ERROR;
      End If;

      If p_dist_lines_tbl is not null Then
         For l_count In 1..p_dist_lines_tbl.count Loop
	    l_dist_lines_rec_type.dist_id := p_dist_lines_tbl(l_count).dist_id;
	    l_dist_lines_rec_type.line_id := p_dist_lines_tbl(l_count).line_id;
	    l_dist_lines_rec_type.party_id := p_dist_lines_tbl(l_count).party_id;
	    l_dist_lines_rec_type.party_type := p_dist_lines_tbl(l_count).party_type_flag;
	    l_dist_lines_rec_type.dist_type := p_dist_lines_tbl(l_count).dist_type_flag;
	    l_dist_lines_rec_type.batch_dist_id := p_dist_lines_tbl(l_count).batch_dist_id;
	    l_dist_lines_rec_type.amount_cr :=  p_dist_lines_tbl(l_count).amount_cr;
	    l_dist_lines_rec_type.amount_dr := p_dist_lines_tbl(l_count).amount_dr;
	    l_dist_lines_rec_type.ccid := p_dist_lines_tbl(l_count).ccid;

            l_return_status := null;
            l_msg_count := null;
            l_msg_data := null;


	    -- 24-10-2007 Changes made by MAKANSAl for Bug # 6249898
            -- If the distribution line has the party type as 'R' then the recipient
            -- legal entity id is passed so that the validation for BSV linkage
            -- is successfully.

            If l_dist_lines_rec_type.party_type = 'R' Then

	       	--Fectch the recipient Legal Entity Id
	       	l_le_party_id := null;
		l_le_party_id := Fun_Tca_Pkg.Get_Le_Id(l_dist_lines_rec_type.party_id, sysdate);

		For C_Le_Id_Rec In C_Le_Id(l_le_party_id) Loop
			l_to_le_id := C_Le_Id_Rec.legal_entity_id;
		End Loop;

	       	-- Pass Recipient Legal entity Id

	       	Fun_Trx_Pvt.Init_IC_Dist_Validate (
			1.0,
			Fnd_Api.G_TRUE,
			l_validation_level,
			l_to_le_id,
			l_trx_rec_type.to_ledger_id,
			--p_batch_rec.from_ledger_id,
			l_return_status,
			l_msg_count,
			l_msg_data,
                	l_dist_lines_rec_type);
	    Else

	   	 -- Changes complete for Bug # 6249898

	   	 Fun_Trx_Pvt.Init_IC_Dist_Validate (
                	  1.0,
	                  Fnd_Api.G_TRUE,
        	          l_validation_level,
	        	  p_batch_rec.from_le_id,
	                  p_batch_rec.from_ledger_id,
	                  l_return_status,
	                  l_msg_count,
	                  l_msg_data,
	                  l_dist_lines_rec_type);

	    End If;

            If l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR Then
	       Raise Fnd_Api.G_EXC_UNEXPECTED_ERROR;
            Elsif l_return_status = Fnd_Api.G_RET_STS_ERROR Then
	       Raise Fnd_Api.G_EXC_ERROR;
	    End If;
         End Loop;
      End If;
   End Validate_Record;

   Procedure Get_Message_Text(p_data In Out NOCOPY Varchar2) Is
   Begin
      p_data := Fnd_Msg_Pub.Get(
            p_msg_index => Fnd_Msg_Pub.G_FIRST,
  	    p_encoded => Fnd_Api.G_FALSE);
   End Get_Message_Text;

   Procedure Upload_Batch(
      p_batch_number		 In Fun_Interface_Batches.batch_number%type,
      p_initiator_name           In Fun_Interface_Batches.initiator_name%type,
      p_currency_code            In Fun_Interface_Batches.currency_code%type,
      p_batch_date           	 In Fun_Interface_Batches.batch_date%type,
      p_gl_date              	 In Fun_Interface_Batches.gl_date%type,
      p_trx_type_name            In Fun_Interface_Batches.trx_type_name%type,
      p_description              In Fun_Interface_Batches.description%type,
      p_note                     In Fun_Interface_Batches.note%type,
      p_attribute1               In Fun_Interface_Batches.attribute1%type,
      p_attribute2               In Fun_Interface_Batches.attribute2%type,
      p_attribute3               In Fun_Interface_Batches.attribute3%type,
      p_attribute4               In Fun_Interface_Batches.attribute4%type,
      p_attribute5               In Fun_Interface_Batches.attribute5%type,
      p_attribute6               In Fun_Interface_Batches.attribute6%type,
      p_attribute7               In Fun_Interface_Batches.attribute7%type,
      p_attribute8               In Fun_Interface_Batches.attribute8%type,
      p_attribute9               In Fun_Interface_Batches.attribute9%type,
      p_attribute10              In Fun_Interface_Batches.attribute10%type,
      p_attribute11              In Fun_Interface_Batches.attribute11%type,
      p_attribute12              In Fun_Interface_Batches.attribute12%type,
      p_attribute13              In Fun_Interface_Batches.attribute13%type,
      p_attribute14              In Fun_Interface_Batches.attribute14%type,
      p_attribute15              In Fun_Interface_Batches.attribute15%type,
      p_attribute_category       In Fun_Interface_Batches.attribute_category%type,
      p_trx_number               In Fun_Interface_Headers.trx_number%type,
      p_recipient_name           In Fun_Interface_Headers.recipient_name%type,
      p_init_amount_dr           In Fun_Interface_Headers.init_amount_dr%type,
      p_init_amount_cr           In Fun_Interface_Headers.init_amount_cr%type,
      p_h_attribute1             In Fun_Interface_Headers.attribute1%type,
      p_h_attribute2             In Fun_Interface_Headers.attribute2%type,
      p_h_attribute3             In Fun_Interface_Headers.attribute3%type,
      p_h_attribute4             In Fun_Interface_Headers.attribute4%type,
      p_h_attribute5             In Fun_Interface_Headers.attribute5%type,
      p_h_attribute6             In Fun_Interface_Headers.attribute6%type,
      p_h_attribute7             In Fun_Interface_Headers.attribute7%type,
      p_h_attribute8             In Fun_Interface_Headers.attribute8%type,
      p_h_attribute9             In Fun_Interface_Headers.attribute9%type,
      p_h_attribute10            In Fun_Interface_Headers.attribute10%type,
      p_h_attribute11            In Fun_Interface_Headers.attribute11%type,
      p_h_attribute12            In Fun_Interface_Headers.attribute12%type,
      p_h_attribute13            In Fun_Interface_Headers.attribute13%type,
      p_h_attribute14            In Fun_Interface_Headers.attribute14%type,
      p_h_attribute15            In Fun_Interface_Headers.attribute15%type,
      p_h_attribute_category     In Fun_Interface_Headers.attribute_category%type,
      p_id_ccid                  In Fun_Interface_Dist_Lines.ccid%type,
      p_id_amount_dr             In Fun_Interface_Dist_Lines.amount_dr%type,
      p_id_amount_cr             In Fun_Interface_Dist_Lines.amount_cr%type,
      p_id_description           In Fun_Interface_Dist_Lines.description%type,
      p_id_attribute1            In Fun_Interface_Dist_Lines.attribute1%type,
      p_id_attribute2            In Fun_Interface_Dist_Lines.attribute2%type,
      p_id_attribute3            In Fun_Interface_Dist_Lines.attribute3%type,
      p_id_attribute4            In Fun_Interface_Dist_Lines.attribute4%type,
      p_id_attribute5            In Fun_Interface_Dist_Lines.attribute5%type,
      p_id_attribute6            In Fun_Interface_Dist_Lines.attribute6%type,
      p_id_attribute7            In Fun_Interface_Dist_Lines.attribute7%type,
      p_id_attribute8            In Fun_Interface_Dist_Lines.attribute8%type,
      p_id_attribute9            In Fun_Interface_Dist_Lines.attribute9%type,
      p_id_attribute10           In Fun_Interface_Dist_Lines.attribute10%type,
      p_id_attribute11           In Fun_Interface_Dist_Lines.attribute11%type,
      p_id_attribute12           In Fun_Interface_Dist_Lines.attribute12%type,
      p_id_attribute13           In Fun_Interface_Dist_Lines.attribute13%type,
      p_id_attribute14           In Fun_Interface_Dist_Lines.attribute14%type,
      p_id_attribute15           In Fun_Interface_Dist_Lines.attribute15%type,
      p_id_attribute_category    In Fun_Interface_Dist_Lines.attribute_category%type,
      p_rd_ccid_segments         In Varchar2,
      p_rd_ccid                  In Fun_Interface_Dist_Lines.ccid%type,
      p_rd_amount_dr             In Fun_Interface_Dist_Lines.amount_dr%type,
      p_rd_amount_cr             In Fun_Interface_Dist_Lines.amount_cr%type,
      p_rd_description           In Fun_Interface_Dist_Lines.description%type,
      p_dist_number              In Fun_Interface_Dist_Lines.dist_number%type)  Is

      Cursor C_Batch_Exists(cp_batch_number In Fun_Interface_Batches.batch_number%type) Is
         Select *
	 From Fun_Interface_Batches
         Where batch_number = cp_batch_number;

      Cursor C_Batch_Id Is
         Select Fun_Trx_Batches_S.nextval batch_id
         From Dual;

       -- Bug No: 6134848. 2 more condetions added to validate Party_usage_code.

       Cursor C_Party(cp_party_name In Fun_Interface_Batches.initiator_name%type) Is
         Select hzp.party_id
         From Hz_Parties Hzp, hz_party_usg_assignments hu
         Where hzp.party_type = 'ORGANIZATION'
         And hzp.party_name = cp_party_name
         And hzp.party_id = hu.party_id
         And hu.party_usage_code = 'INTERCOMPANY_ORG';

	--Bug No: 6134848 ends here

      Cursor C_Le_Id(cp_le_party_id In Xle_Entity_Profiles.party_id%type) Is
         Select legal_entity_id
         From Xle_Firstparty_Information_V
         Where party_id = cp_le_party_id;

      Cursor C_Le_Name (cp_party_id In Xle_Entity_Profiles.party_id%type) Is
         Select name
         From xle_firstparty_information_v
         Where party_id = cp_party_id;

      Cursor C_Trx_Type (cp_trx_type_name In Fun_Interface_Batches.trx_type_name%type) Is
         Select trx_type_code, trx_type_id, allow_invoicing_flag
         From Fun_Trx_Types_Vl
         Where trx_type_name = cp_trx_type_name;

      Cursor C_Trx_Number_Exists(
            cp_batch_id In Fun_Interface_Headers.batch_id%type,
            cp_trx_number In Fun_Interface_Headers.trx_number%type) Is
	 Select *
	 From Fun_Interface_Headers
	 Where batch_id = cp_batch_id
         And trx_number = cp_trx_number;

      Cursor C_Trx_Id Is
	 Select Fun_Trx_Headers_S.nextval trx_id
         From Dual;

      Cursor C_Dupl_Reci_In_Batch(
            cp_batch_id In Fun_Interface_Headers.batch_id%type,
            cp_trx_number In Fun_Interface_Headers.trx_number%type,
            cp_party_name In Fun_Interface_Headers.recipient_name%type) Is
         Select count(distinct trx_number) dupl_reci_count
         From Fun_Interface_Headers
         Where batch_id = cp_batch_id
         And trx_number <> cp_trx_number
         And recipient_name = cp_party_name;

      Cursor C_Dist_Lines_Exists(
            cp_trx_id In Fun_Interface_Dist_Lines.trx_id%type,
   	    cp_party_id In Fun_Interface_Dist_Lines.party_id%type,
	    cp_ccid In Fun_Interface_Dist_Lines.ccid%type,
            cp_party_type_flag In Fun_Interface_Dist_Lines.party_type_flag%type,
	    cp_dist_number in Fun_Interface_Dist_Lines.dist_number%type) Is
	 Select *
	 From Fun_Interface_Dist_Lines
         Where trx_id = cp_trx_id
         And party_id = cp_party_id
         And ccid     = cp_ccid
         And party_type_flag = cp_party_type_flag
	 And dist_number=cp_dist_number;

      Cursor C_Dist_Id Is
	 Select Fun_Dist_Lines_S.nextval dist_id
         From dual;

      Cursor C_Ccid(cp_party_name In Fun_Interface_Batches.initiator_name%type) Is
         Select chart_of_accounts_id
         From Hz_Parties hzp,
         xle_firstparty_information_v xfi ,
         Gl_Ledger_Le_V led
         Where hzp.party_name = cp_party_name
         And fun_tca_pkg.get_le_id(hzp.party_id) = xfi.party_id
         And xfi.legal_entity_id = led.legal_entity_id
         And led.ledger_category_code = 'PRIMARY';

      Cursor C_Flex_Info(cp_chart_of_accounts_id In Fnd_Id_Flex_Structures.id_flex_num%type) Is
         Select fa.application_short_name appl_short_name
         From Fnd_Id_Flex_Structures fs, Fnd_Application fa
         Where fs.application_id = fa.application_id
         And id_flex_num = cp_chart_of_accounts_id
         And id_flex_code = 'GL#';

      Cursor C_Sum_Dist(
            cp_trx_id In Fun_Interface_Dist_Lines.trx_id%type,
   	    cp_party_id In Fun_Interface_Dist_Lines.party_id%type,
            cp_party_type_flag In Fun_Interface_Dist_Lines.party_type_flag%type) Is
	 Select nvl(Sum(nvl(amount_dr,0)),0) Dr_Sum,
         nvl(Sum(nvl(amount_cr,0)),0) Cr_Sum
	 From Fun_Interface_Dist_Lines
         Where trx_id = cp_trx_id
         And party_id = cp_party_id
         And party_type_flag = cp_party_type_flag;

      l_count Number;
      l_batch_insert Varchar2(1);
      l_le_party_id Xle_Firstparty_Information_V.party_id%type;
      l_from_le_name Fun_Interface_Batches.from_le_name%type;
      l_reci_name Fun_Interface_Headers.recipient_name%type;
      l_trx_insert Varchar2(1);
      l_dup_reci_count Number;
      l_to_le_name Fun_Interface_Headers.to_le_name%type;
      l_init_dist_line_insert Varchar2(1);
      l_init_chart_of_accounts Fnd_Id_Flex_Structures.id_flex_num%type;
      l_reci_chart_of_accounts Fnd_Id_Flex_Structures.id_flex_num%type;
      l_appl_short_name Fnd_Application.application_short_name%type;
      l_reci_dist_line_insert Varchar2(1);
      l_data varchar2(2000);
      l_dr_sum Fun_Interface_Dist_Lines.amount_dr%type;
      l_cr_sum Fun_Interface_Dist_Lines.amount_cr%type;
      l_trx_id Fun_trx_headers.trx_id%type;
      l_recipient_id Fun_trx_headers.recipient_id%type;
      l_init_amount_cr Fun_Interface_Headers.init_amount_cr%type;
      l_init_amount_dr Fun_Interface_Headers.init_amount_dr%type;
      l_trx_number Fun_Interface_Headers.trx_number%type;

      l_batch_rec FUN_TRX_PUB.full_batch_rec_type;
      l_trx_tbl	FUN_TRX_PUB.full_trx_tbl_type;
      l_dist_lines_tbl FUN_TRX_PUB.full_dist_line_tbl_type;
      l_length NUMBER;
      l_num   NUMBER;                                         --6846666

      Initiator_Excpt Exception;
      Trx_Type_Excpt Exception;
      Tran_Reci_Diff_Excpt Exception;
      Tran_Dupl_Row_Excpt Exception;
      Recipient_Excpt Exception;
      Dupl_Reci_In_Batch Exception;
      Amount_Req_Excpt Exception;
      Init_Dupl_Row_Excpt Exception;
      Init_Dist_Sum_Excpt Exception;
      Init_Amount_Excpt Exception;
      Con_Seg_Not_Req_Excpt Exception;
      Con_Seg_Req_Excpt Exception;
      Ccid_Gen_Excpt Exception;
      Reci_Dupl_Row_Excpt Exception;
      Reci_Dist_Sum_Excpt Exception;
      Reci_Amount_Excpt Exception;
      Trx_Num_Not_Numeric_Excpt Exception;
      Batch_Num_Invalid_Excpt Exception;                      --6846666


   Begin
      l_count := 1;
      select length(p_batch_number) into l_length from dual;  --6846666
      IF(l_length>20) Then                                    --6846666
        Raise Batch_Num_Invalid_Excpt;
      End IF;
      l_batch_rec.batch_number := p_batch_number;

      For C_Batch_Exists_Rec In C_Batch_Exists(l_batch_rec.batch_number) Loop
	 l_batch_insert := 'N';
	 l_batch_rec.batch_id := C_Batch_Exists_Rec.batch_id;
      End Loop;

      If l_batch_rec.batch_id is null Then
	 l_batch_insert := 'Y';
	 For C_Batch_Id_Rec In C_Batch_Id Loop
            l_batch_rec.batch_id := C_Batch_ID_Rec.batch_id;
         End Loop;
      End If;

      For C_Party_Rec In  C_Party(p_initiator_name) Loop
         l_batch_rec.initiator_id := C_Party_Rec.party_id;
      End Loop;

      If l_batch_rec.initiator_id is null Then
         Raise Initiator_Excpt;
      End If;

      l_le_party_id := fun_tca_pkg.get_le_id(l_batch_rec.initiator_id, sysdate);

      For C_Le_Id_Rec In C_Le_Id(l_le_party_id) Loop
         l_batch_rec.from_le_id := C_Le_Id_Rec.legal_entity_id;
      End Loop;

      For  C_Le_Name_Rec In C_Le_Name(l_le_party_id) Loop
         l_from_le_name := C_Le_Name_Rec.name;
      End Loop;

      l_batch_rec.from_ledger_id := fun_trx_entry_util.Get_Ledger_id(l_batch_rec.initiator_id,'ORGANIZATION');
      l_batch_rec.currency_code := p_currency_code ;
      l_batch_rec.exchange_rate_type := fun_system_options_pkg.get_exchg_rate_type;
      l_batch_rec.description := p_description;
      l_batch_rec.note := p_note;

      For C_Trx_Type_Rec In C_Trx_Type( p_trx_type_name) Loop
         l_batch_rec.trx_type_id := C_Trx_Type_Rec.trx_type_id;
         l_batch_rec.trx_type_code := C_Trx_Type_Rec.trx_type_code;
         l_trx_tbl(l_count).invoice_flag := C_Trx_Type_Rec.allow_invoicing_flag;
      End Loop;

      If l_batch_rec.trx_type_id is null Then
         Raise Trx_Type_Excpt;
      End If;

      l_batch_rec.gl_date := trunc(p_gl_date);
      l_batch_rec.batch_date := trunc(p_batch_date);

      If fun_system_options_pkg.get_allow_reject = TRUE Then
         l_batch_rec.reject_allow_flag := 'Y';
      Else
         l_batch_rec.reject_allow_flag := 'N';
      End If;

      l_batch_rec.Attribute1 := p_attribute1;
      l_batch_rec.Attribute2 := p_attribute2;
      l_batch_rec.Attribute3 := p_attribute3;
      l_batch_rec.Attribute4 := p_attribute4;
      l_batch_rec.Attribute5 := p_attribute5;
      l_batch_rec.Attribute6 := p_attribute6;
      l_batch_rec.Attribute7 := p_attribute7;
      l_batch_rec.Attribute8 := p_attribute8;
      l_batch_rec.Attribute9 := p_attribute9;
      l_batch_rec.Attribute10 := p_attribute10;
      l_batch_rec.Attribute11 := p_attribute11;
      l_batch_rec.Attribute12 := p_attribute12;
      l_batch_rec.Attribute13 := p_attribute13;
      l_batch_rec.Attribute14 := p_attribute14;
      l_batch_rec.Attribute15 := p_attribute15;
      l_batch_rec.attribute_category := p_attribute_category;

      l_trx_tbl(l_count).trx_number := p_trx_number;

      -- Validate p_trx_number
      BEGIN
         l_num := replace(translate(p_trx_number,
                                 'N01234567890','XNNNNNNNNNN'),'N',null);
      EXCEPTION
      WHEN OTHERS THEN
           Raise Trx_Num_Not_Numeric_Excpt;
      END;


      For C_Trx_Number_Exists_Rec In C_Trx_Number_Exists(
            l_batch_rec.batch_id,
            l_trx_tbl(l_count).trx_number) Loop

         If (C_Trx_Number_Exists_Rec.recipient_name <> p_recipient_name) Then
            l_reci_name := C_Trx_Number_Exists_Rec.recipient_name;
            Raise Tran_Reci_Diff_Excpt;
         End If;

      	 l_trx_insert := 'N';
         l_trx_tbl(l_count).trx_id := C_Trx_Number_Exists_Rec.trx_id;
         l_trx_tbl(l_count).recipient_id := C_Trx_Number_Exists_Rec.recipient_id;
	 l_trx_tbl(l_count).to_le_id := C_Trx_Number_Exists_Rec.to_le_id;
      	 l_trx_tbl(l_count).to_ledger_id := C_Trx_Number_Exists_Rec.to_ledger_id;
	 l_trx_tbl(l_count).batch_id := C_Trx_Number_Exists_Rec.batch_id ;
	 l_trx_tbl(l_count).init_amount_cr := C_Trx_Number_Exists_Rec.init_amount_cr;
	 l_trx_tbl(l_count).init_amount_dr := C_Trx_Number_Exists_Rec.init_amount_dr;

         If (nvl(l_trx_tbl(l_count).init_amount_cr,0) <> nvl(p_init_amount_cr,0) Or
               nvl(l_trx_tbl(l_count).init_amount_dr,0) <> nvl(p_init_amount_dr,0)) Then
            Raise Tran_Dupl_Row_Excpt;
         End If;

	 l_trx_tbl(l_count).reci_amount_cr := C_Trx_Number_Exists_Rec.init_amount_cr;
	 l_trx_tbl(l_count).reci_amount_dr := C_Trx_Number_Exists_Rec.init_amount_dr;
	 l_trx_tbl(l_count).invoice_flag := C_Trx_Number_Exists_Rec.invoicing_rule_flag;
	 l_trx_tbl(l_count).from_recurring_trx_id := C_Trx_Number_Exists_Rec.from_recurring_trx_id;
	 l_trx_tbl(l_count).initiator_instance_flag := C_Trx_Number_Exists_Rec.initiator_instance_flag;
	 l_trx_tbl(l_count).recipient_instance_flag := C_Trx_Number_Exists_Rec.recipient_instance_flag;
         l_trx_tbl(l_count).Attribute1 := C_Trx_Number_Exists_Rec.attribute1;
         l_trx_tbl(l_count).Attribute2 := C_Trx_Number_Exists_Rec.attribute2;
  	 l_trx_tbl(l_count).Attribute3 := C_Trx_Number_Exists_Rec.attribute3;
  	 l_trx_tbl(l_count).Attribute4 := C_Trx_Number_Exists_Rec.attribute4;
  	 l_trx_tbl(l_count).Attribute5 := C_Trx_Number_Exists_Rec.attribute5;
  	 l_trx_tbl(l_count).Attribute6 := C_Trx_Number_Exists_Rec.attribute6;
  	 l_trx_tbl(l_count).Attribute7 := C_Trx_Number_Exists_Rec.attribute7;
  	 l_trx_tbl(l_count).Attribute8 := C_Trx_Number_Exists_Rec.attribute8;
  	 l_trx_tbl(l_count).Attribute9 := C_Trx_Number_Exists_Rec.attribute9;
  	 l_trx_tbl(l_count).Attribute10 := C_Trx_Number_Exists_Rec.attribute10;
  	 l_trx_tbl(l_count).Attribute11 := C_Trx_Number_Exists_Rec.attribute11;
  	 l_trx_tbl(l_count).Attribute12 := C_Trx_Number_Exists_Rec.attribute12;
  	 l_trx_tbl(l_count).Attribute13 := C_Trx_Number_Exists_Rec.attribute13;
  	 l_trx_tbl(l_count).Attribute14 := C_Trx_Number_Exists_Rec.attribute14;
  	 l_trx_tbl(l_count).Attribute15 := C_Trx_Number_Exists_Rec.attribute15;
  	 l_trx_tbl(l_count).attribute_category := C_Trx_Number_Exists_Rec.attribute_category;
      End Loop;

      If l_trx_tbl(l_count).trx_id is null Then
      	 l_trx_insert := 'Y';
         l_trx_tbl(l_count).batch_id := l_batch_rec.batch_id ;

	 For C_Trx_Id_Rec In C_Trx_Id Loop
	    l_trx_tbl(l_count).trx_id := C_Trx_Id_Rec.trx_id;
	 End Loop;

         For C_Party_Rec In  C_Party(p_recipient_name) Loop
             l_trx_tbl(l_count).recipient_id := C_Party_Rec.party_id;
         End Loop;

	 If l_trx_tbl(l_count).recipient_id is null Then
	    Raise Recipient_Excpt;
	 End If;


	 l_le_party_id := null;
         l_le_party_id := Fun_Tca_Pkg.Get_Le_Id(l_trx_tbl(l_count).recipient_id, sysdate);
         For C_Le_Id_Rec In C_Le_Id(l_le_party_id) Loop
            l_trx_tbl(l_count).to_le_id := C_Le_Id_Rec.legal_entity_id;
         End Loop;

         For  C_Le_Name_Rec In C_Le_Name(l_le_party_id) Loop
            l_to_le_name := C_Le_Name_Rec.name;
         End Loop;

	 l_trx_tbl(l_count).to_ledger_id := Fun_Trx_Entry_Util.Get_Ledger_Id(l_trx_tbl(l_count).recipient_id,'ORGANIZATION');

	 l_trx_tbl(l_count).init_amount_cr := p_init_amount_cr;
	 l_trx_tbl(l_count).init_amount_dr := p_init_amount_dr;
	 l_trx_tbl(l_count).reci_amount_cr := p_init_amount_cr;
	 l_trx_tbl(l_count).reci_amount_dr := p_init_amount_dr;

	 If (l_trx_tbl(l_count).init_amount_cr is null And
	       l_trx_tbl(l_count).init_amount_dr is null) Then
	    Raise Amount_Req_Excpt;
	 End If;

	 If (l_trx_tbl(l_count).init_amount_cr is not null And
 	       l_trx_tbl(l_count).init_amount_dr is not null) Then
	    Raise Amount_Req_Excpt;
	 End If;

	 l_trx_tbl(l_count).initiator_instance_flag := 'N';
	 l_trx_tbl(l_count).recipient_instance_flag := 'N';
         l_trx_tbl(l_count).Attribute1 := p_h_attribute1;
         l_trx_tbl(l_count).Attribute2 := p_h_attribute2;
         l_trx_tbl(l_count).Attribute3 := p_h_attribute3;
         l_trx_tbl(l_count).Attribute4 := p_h_attribute4;
         l_trx_tbl(l_count).Attribute5 := p_h_attribute5;
         l_trx_tbl(l_count).Attribute6 := p_h_attribute6;
         l_trx_tbl(l_count).Attribute7 := p_h_attribute7;
         l_trx_tbl(l_count).Attribute8 := p_h_attribute8;
         l_trx_tbl(l_count).Attribute9 := p_h_attribute9;
         l_trx_tbl(l_count).Attribute10 := p_h_attribute10;
         l_trx_tbl(l_count).Attribute11 := p_h_attribute11;
         l_trx_tbl(l_count).Attribute12 := p_h_attribute12;
         l_trx_tbl(l_count).Attribute13 := p_h_attribute13;
         l_trx_tbl(l_count).Attribute14 := p_h_attribute14;
         l_trx_tbl(l_count).Attribute15 := p_h_attribute15;
         l_trx_tbl(l_count).attribute_category := p_h_attribute_category;
      End If;

      For C_Dist_Lines_Exists_Rec In C_Dist_Lines_Exists(
            l_trx_tbl(l_count).trx_id,
  	    l_batch_rec.initiator_id,
	    p_id_ccid,
            'I', p_dist_number) Loop

	 l_init_dist_line_insert := 'N';
	 l_dist_lines_tbl(l_count).trx_id := C_Dist_Lines_Exists_Rec.trx_id;
	 l_dist_lines_tbl(l_count).dist_id := C_Dist_Lines_Exists_Rec.dist_id;
         l_dist_lines_tbl(l_count).dist_number := C_Dist_Lines_Exists_Rec.dist_number;
	 l_dist_lines_tbl(l_count).party_id := C_Dist_Lines_Exists_Rec.party_id;
	 l_dist_lines_tbl(l_count).party_type_flag := C_Dist_Lines_Exists_Rec.party_type_flag;
	 l_dist_lines_tbl(l_count).dist_type_flag := C_Dist_Lines_Exists_Rec.dist_type_flag;
	 l_dist_lines_tbl(l_count).amount_cr := C_Dist_Lines_Exists_Rec.amount_cr;
	 l_dist_lines_tbl(l_count).amount_dr := C_Dist_Lines_Exists_Rec.amount_dr;
	 l_dist_lines_tbl(l_count).ccid := C_Dist_Lines_Exists_Rec.ccid;
	 l_dist_lines_tbl(l_count).description := C_Dist_Lines_Exists_Rec.description;

	 If (nvl(l_dist_lines_tbl(l_count).amount_cr,0) <> nvl(p_id_amount_cr,0) Or
	       nvl(l_dist_lines_tbl(l_count).amount_dr,0) <> nvl(p_id_amount_dr,0) Or
	       nvl(l_dist_lines_tbl(l_count).description, 'NULL') <> nvl(p_id_description, 'NULL')) Then
	    Raise Init_Dupl_Row_Excpt;
	 End If;

         l_dist_lines_tbl(l_count).attribute1 := C_Dist_Lines_Exists_Rec.attribute1;
  	 l_dist_lines_tbl(l_count).attribute2 := C_Dist_Lines_Exists_Rec.attribute2;
  	 l_dist_lines_tbl(l_count).attribute3 := C_Dist_Lines_Exists_Rec.attribute3;
  	 l_dist_lines_tbl(l_count).attribute4 := C_Dist_Lines_Exists_Rec.attribute4;
  	 l_dist_lines_tbl(l_count).attribute5 := C_Dist_Lines_Exists_Rec.attribute5;
  	 l_dist_lines_tbl(l_count).attribute6 := C_Dist_Lines_Exists_Rec.attribute6;
  	 l_dist_lines_tbl(l_count).attribute7 := C_Dist_Lines_Exists_Rec.attribute7;
  	 l_dist_lines_tbl(l_count).attribute8 := C_Dist_Lines_Exists_Rec.attribute8;
  	 l_dist_lines_tbl(l_count).attribute9 := C_Dist_Lines_Exists_Rec.attribute9;
  	 l_dist_lines_tbl(l_count).attribute10 := C_Dist_Lines_Exists_Rec.attribute10;
  	 l_dist_lines_tbl(l_count).attribute11 := C_Dist_Lines_Exists_Rec.attribute11;
  	 l_dist_lines_tbl(l_count).attribute12 := C_Dist_Lines_Exists_Rec.attribute12;
  	 l_dist_lines_tbl(l_count).attribute13 := C_Dist_Lines_Exists_Rec.attribute13;
  	 l_dist_lines_tbl(l_count).attribute14 := C_Dist_Lines_Exists_Rec.attribute14;
  	 l_dist_lines_tbl(l_count).attribute15 := C_Dist_Lines_Exists_Rec.attribute15;
  	 l_dist_lines_tbl(l_count).attribute_category := p_id_attribute_category;
      End Loop;

      If (l_dist_lines_tbl.Count = 0 and (p_id_ccid is not null or p_id_amount_dr is not null or p_id_amount_cr is not null) ) Then

           l_init_dist_line_insert := 'Y';
	 l_dist_lines_tbl(l_count).trx_id := l_trx_tbl(l_count).trx_id;

         For C_Dist_Id_Rec In C_Dist_Id Loop
	    l_dist_lines_tbl(l_count).dist_id := C_Dist_Id_Rec.dist_id;
            l_dist_lines_tbl(l_count).dist_number := p_dist_number;
	 End Loop;

	 l_dist_lines_tbl(l_count).party_id := l_batch_rec.initiator_id;
	 l_dist_lines_tbl(l_count).party_type_flag := 'I';
	 l_dist_lines_tbl(l_count).dist_type_flag := 'L';
	 l_dist_lines_tbl(l_count).amount_cr := p_id_amount_cr;
	 l_dist_lines_tbl(l_count).amount_dr := p_id_amount_dr;

         -- Modified on 16th April 2005
         l_dr_sum := 0;
         l_cr_sum := 0;
         For C_Sum_Dist_Rec in C_Sum_Dist(
               l_trx_tbl(l_count).trx_id,
  	       l_batch_rec.initiator_id,
               'I') Loop
             l_dr_sum := C_Sum_Dist_Rec.Dr_Sum;
             l_cr_sum := C_Sum_Dist_Rec.Cr_Sum;
         End Loop;
         -- Modified on 16th April 2005
	 If l_trx_tbl(l_count).init_amount_cr is not null Then
            If (l_dist_lines_tbl(l_count).amount_dr is not null And
                  l_dist_lines_tbl(l_count).amount_cr is null) Then
               -- Modified on 16th April 2005
               If ((l_dist_lines_tbl(l_count).amount_dr + l_dr_sum)
                     > l_trx_tbl(l_count).init_amount_cr)  Then
                  Raise Init_Dist_Sum_Excpt;
               End If;
               -- Modified on 16th April 2005
            Else
               Raise Init_Amount_Excpt;
            End If;
         End If;

	 If l_trx_tbl(l_count).init_amount_dr is not null Then
            If (l_dist_lines_tbl(l_count).amount_cr is not null And
                  l_dist_lines_tbl(l_count).amount_dr is null) Then
               -- Modified on 16th April 2005
               If ((l_dist_lines_tbl(l_count).amount_cr + l_cr_sum) >
                        l_trx_tbl(l_count).init_amount_dr)  Then
                     Raise Init_Dist_Sum_Excpt;
               End If;
               -- Modified on 16th April 2005
            Else
               Raise Init_Amount_Excpt;
            End If;
         End If;

	 l_dist_lines_tbl(l_count).ccid := p_id_ccid;
	 l_dist_lines_tbl(l_count).description := p_id_description;
  	 l_dist_lines_tbl(l_count).attribute1 := p_id_attribute1;
  	 l_dist_lines_tbl(l_count).attribute2 := p_id_attribute2;
  	 l_dist_lines_tbl(l_count).attribute3 := p_id_attribute3;
  	 l_dist_lines_tbl(l_count).attribute4 := p_id_attribute4;
  	 l_dist_lines_tbl(l_count).attribute5 := p_id_attribute5;
  	 l_dist_lines_tbl(l_count).attribute6 := p_id_attribute6;
  	 l_dist_lines_tbl(l_count).attribute7 := p_id_attribute7;
  	 l_dist_lines_tbl(l_count).attribute8 := p_id_attribute8;
  	 l_dist_lines_tbl(l_count).attribute9 := p_id_attribute9;
  	 l_dist_lines_tbl(l_count).attribute10 := p_id_attribute10;
  	 l_dist_lines_tbl(l_count).attribute11 := p_id_attribute11;
  	 l_dist_lines_tbl(l_count).attribute12 := p_id_attribute12;
  	 l_dist_lines_tbl(l_count).attribute13 := p_id_attribute13;
  	 l_dist_lines_tbl(l_count).attribute14 := p_id_attribute14;
  	 l_dist_lines_tbl(l_count).attribute15 := p_id_attribute15;
  	 l_dist_lines_tbl(l_count).attribute_category := p_id_attribute_category;
	 l_dist_lines_tbl(l_count).dist_number := p_dist_number;
      End If;

      For C_Ccid_Rec In C_Ccid(p_initiator_name) Loop
         l_init_chart_of_accounts := C_Ccid_rec.chart_of_accounts_id;
      End Loop;

      For C_Ccid_Rec In C_Ccid(p_recipient_name) Loop
         l_reci_chart_of_accounts := C_Ccid_rec.chart_of_accounts_id;
      End Loop;
    -- start of recipient validation
    l_trx_id := l_trx_tbl(l_count).trx_id;
    l_recipient_id :=  l_trx_tbl(l_count).recipient_id;
    l_init_amount_cr := l_trx_tbl(l_count).init_amount_cr;
    l_init_amount_dr := l_trx_tbl(l_count).init_amount_dr;
    l_trx_number := l_trx_tbl(l_count).trx_number;

    If( p_id_ccid is null and p_id_amount_dr is null and p_id_amount_cr is null) THEN
	l_count := l_count - 1;
    End If;
    If (p_rd_amount_dr is not null OR p_rd_amount_cr is not null OR
         p_rd_ccid_segments is not null OR    p_rd_ccid is not null )  THEN


      If l_init_chart_of_accounts = l_reci_chart_of_accounts Then
         If p_rd_ccid_segments is not null Then
            Raise Con_Seg_Not_Req_Excpt;
         End if;
         l_dist_lines_tbl(l_count + 1).ccid := p_rd_ccid;
      Else
         If p_rd_ccid_segments is null Then
            Raise Con_Seg_Req_Excpt;
         End if;

         For C_Flex_Info_Rec In C_Flex_Info(l_reci_chart_of_accounts) Loop
            l_appl_short_name := C_Flex_Info_Rec.appl_short_name;
         End Loop;

         If Not Fnd_Flex_Keyval.Validate_Segs(
               'CREATE_COMBINATION',        -- Operation
               l_appl_short_name,           -- Application Short Name
               'GL#',                       -- Funds Flexfield Structure Code
               l_reci_chart_of_accounts,    -- Structure Id
               p_rd_ccid_segments,          -- Concatenated Segments
               'V',                         -- values
               sysdate,                     -- validation_date
               'ALL',                       -- displayable
               NULL,                        -- data_set
               NULL,                        -- vrule
               NULL,                        -- where_clause
               NULL,                        -- get_columns
               FALSE,                       -- allow_nulls
               FALSE,                       -- allow_orphans
               fnd_global.resp_appl_id,
               fnd_global.resp_id,
               fnd_global.user_id,
               'GL_CODE_COMBINATIONS',      -- select_comb_from_view
               NULL,                        -- no_combmsg
               NULL                         -- where_clause_msg
               ) Then
            Raise Ccid_Gen_Excpt;
         Else
            l_dist_lines_tbl(l_count + 1).ccid := Fnd_Flex_Keyval.combination_id;
         End if;
      End If;

      For C_Dist_Lines_Exists_Rec In C_Dist_Lines_Exists(
            l_trx_id,
	    l_recipient_id,
	    l_dist_lines_tbl(l_count + 1).ccid,
            'R', p_dist_number) Loop

         l_reci_dist_line_insert := 'N';
	 l_dist_lines_tbl(l_count + 1).dist_id := C_Dist_Lines_Exists_Rec.dist_id;
	 l_dist_lines_tbl(l_count + 1).dist_number := C_Dist_Lines_Exists_Rec.dist_number;
	 l_dist_lines_tbl(l_count + 1).trx_id := C_Dist_Lines_Exists_Rec.trx_id;
	 l_dist_lines_tbl(l_count + 1).party_id := C_Dist_Lines_Exists_Rec.party_id;
	 l_dist_lines_tbl(l_count + 1).party_type_flag := C_Dist_Lines_Exists_Rec.party_type_flag;
	 l_dist_lines_tbl(l_count + 1).dist_type_flag := C_Dist_Lines_Exists_Rec.dist_type_flag;
	 l_dist_lines_tbl(l_count + 1).amount_cr := C_Dist_Lines_Exists_Rec.amount_cr;
	 l_dist_lines_tbl(l_count + 1).amount_dr := C_Dist_Lines_Exists_Rec.amount_dr;
	 l_dist_lines_tbl(l_count + 1).ccid := C_Dist_Lines_Exists_Rec.ccid;
	 l_dist_lines_tbl(l_count + 1).description := C_Dist_Lines_Exists_Rec.description;
	 If (nvl(l_dist_lines_tbl(l_count + 1).amount_cr,0) <> nvl(p_rd_amount_cr,0) Or
	       nvl(l_dist_lines_tbl(l_count + 1).amount_dr,0) <> nvl(p_rd_amount_dr,0) Or
	       nvl(l_dist_lines_tbl(l_count + 1).description, 'NULL') <> nvl(p_rd_description, 'NULL')) Then
	    Raise Reci_Dupl_Row_Excpt;
	 End If;
      End Loop;

      If l_dist_lines_tbl(l_count + 1).dist_id is null Then
         l_reci_dist_line_insert := 'Y';
	 l_dist_lines_tbl(l_count + 1).trx_id := l_trx_id;
         For C_Dist_Id_Rec In C_Dist_Id Loop
	    l_dist_lines_tbl(l_count + 1).dist_id := C_Dist_Id_Rec.dist_id;
	    l_dist_lines_tbl(l_count + 1).dist_number := p_dist_number;
	 End Loop;

	 l_dist_lines_tbl(l_count + 1).party_id := l_recipient_id;
	 l_dist_lines_tbl(l_count + 1).party_type_flag := 'R';
	 l_dist_lines_tbl(l_count + 1).dist_type_flag := 'L';
	 l_dist_lines_tbl(l_count + 1).amount_cr := p_rd_amount_cr;
	 l_dist_lines_tbl(l_count + 1).amount_dr := p_rd_amount_dr;
	 l_dist_lines_tbl(l_count + 1).dist_number := p_dist_number;

         -- Modified on 16th April 2005
         l_dr_sum := 0;
         l_cr_sum := 0;
         For C_Sum_Dist_Rec in C_Sum_Dist(
               l_trx_id,
	       l_recipient_id,
               'R') Loop
            l_dr_sum := C_Sum_Dist_Rec.Dr_Sum;
            l_cr_sum := C_Sum_Dist_Rec.Cr_Sum;
         End Loop;
         -- Modified on 16th April 2005
	 If l_init_amount_cr is not null Then
            If (l_dist_lines_tbl(l_count + 1).amount_cr is not null And
                  l_dist_lines_tbl(l_count + 1).amount_dr is null) Then
               -- Modified on 16th April 2005
               If ((l_dist_lines_tbl(l_count + 1 ).amount_cr + l_cr_sum)
                     > l_init_amount_cr)  Then
                  Raise Reci_Dist_Sum_Excpt;
               End If;
               -- Modified on 16th April 2005
            Else
               Raise Reci_Amount_Excpt;
            End If;
         End If;

	 If l_init_amount_dr is not null Then
            If (l_dist_lines_tbl(l_count + 1).amount_dr is not null And
                  l_dist_lines_tbl(l_count + 1).amount_cr is null) Then
               -- Modified on 16th April 2005
               If ((l_dist_lines_tbl(l_count + 1 ).amount_dr + l_dr_sum)
                     > l_init_amount_dr)  Then
                  Raise Reci_Dist_Sum_Excpt;
               End If;
               -- Modified on 16th April 2005
            Else
               Raise Reci_Amount_Excpt;
            End If;
         End If;

	 l_dist_lines_tbl(l_count + 1).description := p_rd_description;
      End If;
   End If  ;--end of recipient validation
      Validate_Record(
            l_batch_rec,
            l_trx_tbl,
            l_dist_lines_tbl,
            l_batch_insert);

      Insert_Batch(
            l_batch_rec,
            p_initiator_name,
            p_trx_type_name,
            l_from_le_name,
            l_batch_insert);

      If nvl(l_trx_insert,'N') = 'Y' Then
         Insert_Header(
               p_recipient_name,
               l_to_le_name,
               l_trx_tbl);
      End If;

      If nvl(l_init_dist_line_insert,'N') = 'Y' Then
         Insert_Dists(
               l_dist_lines_tbl,
               l_count);
      End if;

      If nvl(l_reci_dist_line_insert,'N') = 'Y' Then
         Insert_Dists(
               l_dist_lines_tbl,
               l_count + 1);
      End if;
--Bug: 8966932
      --Commit;
   Exception

      When  Batch_Num_Invalid_Excpt Then                             --6846666
         Rollback;
	 Fnd_Message.Set_Name('FUN','FUN_BATCH_NUM_INVALID');
         Fnd_Message.Raise_Error;

      When  Trx_Num_Not_Numeric_Excpt Then
         Rollback;
	 Fnd_Message.Set_Name('FUN','FUN_TRX_NUM_NOT_NUMERIC');
         Fnd_Message.Raise_Error;

      When Initiator_Excpt Then
         Rollback;
	 Fnd_Message.Set_Name('FUN','FUN_API_INVALID_INITIATOR');
         Fnd_Message.Raise_Error;
      When Trx_Type_Excpt Then
	 Rollback;
         Fnd_Message.Set_Name('FUN','FUN_TRX_TYPE_NOT_FOUND');
         Fnd_Message.Raise_Error;
      When Tran_Reci_Diff_Excpt Then
         Rollback;
	 Fnd_Message.Set_Name('FUN','FUN_ADI_TRAN_RECI_DIFF');
         Fnd_Message.Set_Token('RECI_NAME', l_reci_name);
         Fnd_Message.Raise_Error;
      When Tran_Dupl_Row_Excpt Then
         Rollback;
	 Fnd_Message.Set_Name('FUN','FUN_ADI_TRAN_DUP_ERROR');
	 Fnd_Message.Set_Token('BATCH_NUMBER', l_batch_rec.batch_number);
         Fnd_Message.Set_Token('TRX_NUMBER', l_trx_tbl(l_count).trx_number);
         Fnd_Message.Set_Token('DEBIT', l_trx_tbl(l_count).init_amount_dr);
         Fnd_Message.Set_Token('CREDIT', l_trx_tbl(l_count).init_amount_cr);
         Fnd_Message.Raise_Error;
      When Recipient_Excpt Then
	 Rollback;
	 Fnd_Message.Set_Name('FUN','FUN_API_INVALID_RECIPIENT');
         Fnd_Message.Raise_Error;
      When Dupl_Reci_In_Batch Then
	 Rollback;
         Fnd_Message.Set_Name('FUN', 'FUN_API_DUPLICATE_RECP');
         Fnd_Message.Raise_Error;
      When Amount_Req_Excpt Then
	 Rollback;
	 Fnd_Message.Set_Name('FUN','FUN_TRX_DR_CR_AMT');
         Fnd_Message.Raise_Error;
      When Init_Dupl_Row_Excpt Then
	 Rollback;
	 Fnd_Message.Set_Name('FUN','FUN_ADI_INIT_DUP_ERROR');
	 Fnd_Message.Set_Token('DIST_NUMBER', p_dist_number);
         Fnd_Message.Set_Token('TRX_NUMBER', l_trx_tbl(l_count).trx_number);
         Fnd_Message.Set_Token('DEBIT', l_dist_lines_tbl(l_count).amount_dr);
         Fnd_Message.Set_Token('CREDIT', l_dist_lines_tbl(l_count).amount_cr);
         Fnd_Message.Set_Token('DESCRIPTION', l_dist_lines_tbl(l_count).description);
         Fnd_Message.Raise_Error;
      When Init_Dist_Sum_Excpt Then
	 Rollback;
	 Fnd_Message.Set_Name('FUN','FUN_ADI_INIT_SUM_ERROR');
         Fnd_Message.Raise_Error;
      When Init_Amount_Excpt Then
	 Rollback;
	 Fnd_Message.Set_Name('FUN','FUN_IC_INVALID_DRCR_DIST');
         Fnd_Message.Set_Token('TRX_NUMBER', p_trx_number);
         Fnd_Message.Raise_Error;
      When Con_Seg_Not_Req_Excpt Then
	 Rollback;
	 Fnd_Message.Set_Name('FUN','FUN_ADI_CON_SEGS_NOT_REQ');
         Fnd_Message.Raise_Error;
      When Con_Seg_Req_Excpt Then
	 Rollback;
	 Fnd_Message.Set_Name('FUN','FUN_ADI_CON_SEGS_REQ');
         Fnd_Message.Raise_Error;
      When Ccid_Gen_Excpt Then
	 Rollback;
	 Fnd_Message.Set_Name('FUN','FUN_ADI_CCID_ERROR');
         Fnd_Message.Set_Token('CON_SEGS', p_rd_ccid_segments);
         Fnd_Message.Raise_Error;
      When Reci_Dupl_Row_Excpt Then
	 Rollback;
	 Fnd_Message.Set_Name('FUN','FUN_ADI_RECI_DUP_ERROR');
	 Fnd_Message.Set_Token('DIST_NUMBER', p_dist_number);
         Fnd_Message.Set_Token('TRX_NUMBER', l_trx_number);
         Fnd_Message.Set_Token('DEBIT', l_dist_lines_tbl(l_count + 1).amount_dr);
         Fnd_Message.Set_Token('CREDIT', l_dist_lines_tbl(l_count + 1 ).amount_cr);
         Fnd_Message.Set_Token('DESCRIPTION', l_dist_lines_tbl(l_count + 1 ).description);
         Fnd_Message.Raise_Error;
      When Reci_Dist_Sum_Excpt Then
	 Rollback;
	 Fnd_Message.Set_Name('FUN','FUN_ADI_RECI_SUM_ERROR');
         Fnd_Message.Raise_Error;
      When Reci_Amount_Excpt Then
	 Rollback;
	 Fnd_Message.Set_Name('FUN','FUN_ADI_INVALID_DRCR_DIST');
         Fnd_Message.Set_Token('TRX_NUMBER', p_trx_number);
         Fnd_Message.Raise_Error;
      When Fnd_Api.G_EXC_UNEXPECTED_ERROR Then
	 Rollback;
         Get_Message_Text(l_data);
         Fnd_Message.Set_Name('FUN', 'FUN_ADI_ERROR');
         Fnd_Message.Set_Token('ERROR', l_data);
         Fnd_Message.Raise_Error;
      When Fnd_Api.G_EXC_ERROR Then
	 Rollback;
         Get_Message_Text(l_data);
         Fnd_Message.Set_Name('FUN', 'FUN_ADI_ERROR');
         Fnd_Message.Set_Token('ERROR', l_data);
      When Others Then
	 Rollback;
         Fnd_Message.Set_Name('FUN', 'FUN_ADI_ERROR');
         Fnd_Message.Set_Token('ERROR', sqlerrm);
         Fnd_Message.Raise_Error;
    End Upload_Batch;
End FUN_WEBADI_PKG;


/
