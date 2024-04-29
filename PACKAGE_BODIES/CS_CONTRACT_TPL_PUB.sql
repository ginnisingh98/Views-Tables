--------------------------------------------------------
--  DDL for Package Body CS_CONTRACT_TPL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_CONTRACT_TPL_PUB" as
/* $Header: csctptpb.pls 115.2 99/07/16 08:53:30 porting ship  $ */

PROCEDURE Contract_to_Template
(
	p_api_version             	IN NUMBER,
	p_init_msg_list           	IN VARCHAR2  DEFAULT FND_API.G_FALSE,
	p_commit                  	IN VARCHAR2  DEFAULT FND_API.G_FALSE,
	x_return_status          	OUT VARCHAR2,
	x_msg_count              	OUT NUMBER,
	x_msg_data               	OUT VARCHAR2,
	p_contract_id	         	IN NUMBER,
	p_template_name			IN VARCHAR2,
	x_template_id			OUT NUMBER
) IS
    	CURSOR l_Contract_csr IS
      		SELECT *
 		FROM cs_contracts
       		WHERE contract_id = p_contract_id;
    	CURSOR l_Service_Csr IS
      		SELECT *
 		FROM cs_cp_services
       		WHERE contract_id = p_contract_id;


	l_api_name	  	CONSTANT VARCHAR2(30) := 'Contract_to_Template';
	l_api_version 		CONSTANT NUMBER       := 1.0;
	l_ContractTmpl_Rec	Cs_ContractTmpl_Pvt.ContractTmpl_Rec_Type;
	l_ContractTmpl_Val_Rec	Cs_ContractTmpl_Pvt.ContractTmpl_Val_Rec_Type;
	l_object_version_number NUMBER;
	l_contract_template_id	NUMBER;
	l_contract_line_template_id	NUMBER;
	l_Contract_rec          l_Contract_Csr%ROWTYPE;
	l_Service_Rec           l_Service_Csr%ROWTYPE;
	CONTRACT_NOT_FOUND	EXCEPTION;
BEGIN
	l_return_status := TAPI_DEV_KIT.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              l_api_version,
                                              p_api_version,
                                              p_init_msg_list,
                                              l_api_type,
                                              x_return_status);
	--dbms_output.put_line('l_return_status ' || l_return_status);
    	IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    	ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      		RAISE FND_API.G_EXC_ERROR;
    	END IF;
	-- Get the contract details
	Open l_Contract_Csr;
	Fetch l_Contract_Csr into l_Contract_Rec;
	if l_Contract_Csr%NOTFOUND THEN
		RAISE CONTRACT_NOT_FOUND;
	end if;

		l_ContractTmpl_Rec.contract_template_id           := NULL;
    		l_ContractTmpl_Rec.name                           := p_template_name;
    		l_ContractTmpl_Rec.contract_type_id               := l_Contract_Rec.contract_type_id;
    		l_ContractTmpl_Rec.duration                       := l_Contract_Rec.duration;
    		l_ContractTmpl_Rec.period_code                    := l_Contract_Rec.period_code;
    		l_ContractTmpl_Rec.workflow                       := l_Contract_Rec.workflow;
    		l_ContractTmpl_Rec.price_list_id                  := l_Contract_Rec.price_list_id;
    		l_ContractTmpl_Rec.currency_code                  := l_Contract_Rec.currency_code;
    		l_ContractTmpl_Rec.conversion_type_code           := l_Contract_Rec.conversion_type_code;
    		l_ContractTmpl_Rec.conversion_rate                := l_Contract_Rec.conversion_rate;
    		l_ContractTmpl_Rec.conversion_date                := l_Contract_Rec.conversion_date;
    		l_ContractTmpl_Rec.invoicing_rule_id              := l_Contract_Rec.invoicing_rule_id;
    		l_ContractTmpl_Rec.accounting_rule_id             := l_Contract_Rec.accounting_rule_id;
    		l_ContractTmpl_Rec.billing_frequency_period       := l_Contract_Rec.billing_frequency_period;
    		l_ContractTmpl_Rec.create_sales_order             := l_Contract_Rec.create_sales_order;
    		l_ContractTmpl_Rec.renewal_rule                   := l_Contract_Rec.renewal_rule;
    		l_ContractTmpl_Rec.termination_rule               := l_Contract_Rec.termination_rule;
    		l_ContractTmpl_Rec.terms_id                       := l_Contract_Rec.terms_id;
    		l_ContractTmpl_Rec.tax_handling                   := l_Contract_Rec.tax_handling;
    		l_ContractTmpl_Rec.tax_exempt_num                 := l_Contract_Rec.tax_exempt_num;
    		l_ContractTmpl_Rec.tax_exempt_reason_code         := l_Contract_Rec.tax_exempt_reason_code;
    		---l_ContractTmpl_Rec.contract_amount                := l_Contract_Rec.contract_amount;
    		l_ContractTmpl_Rec.discount_id                    := l_Contract_Rec.discount_id;
    		l_ContractTmpl_Rec.last_update_date               := sysdate;
    		l_ContractTmpl_Rec.last_updated_by                := FND_GLOBAL.user_id;
    		l_ContractTmpl_Rec.creation_date                  := sysdate;
    		l_ContractTmpl_Rec.created_by                     := FND_GLOBAL.user_id;
    		l_ContractTmpl_Rec.auto_renewal_flag              := l_Contract_Rec.auto_renewal_flag;
    		l_ContractTmpl_Rec.last_update_login              := FND_GLOBAL.login_id;
    		l_ContractTmpl_Rec.start_date_active              := l_Contract_Rec.start_date_active;
    		l_ContractTmpl_Rec.end_date_active                := l_Contract_Rec.end_date_active;
    		l_ContractTmpl_Rec.attribute1                     := l_Contract_Rec.attribute1;
    		l_ContractTmpl_Rec.attribute2                     := l_Contract_Rec.attribute2;
    		l_ContractTmpl_Rec.attribute3                     := l_Contract_Rec.attribute3;
    		l_ContractTmpl_Rec.attribute4                     := l_Contract_Rec.attribute4;
    		l_ContractTmpl_Rec.attribute5                     := l_Contract_Rec.attribute5;
    		l_ContractTmpl_Rec.attribute6                     := l_Contract_Rec.attribute6;
    		l_ContractTmpl_Rec.attribute7                     := l_Contract_Rec.attribute7;
    		l_ContractTmpl_Rec.attribute8                     := l_Contract_Rec.attribute8;
    		l_ContractTmpl_Rec.attribute9                     := l_Contract_Rec.attribute9;
    		l_ContractTmpl_Rec.attribute10                    := l_Contract_Rec.attribute10;
    		l_ContractTmpl_Rec.attribute11                    := l_Contract_Rec.attribute11;
    		l_ContractTmpl_Rec.attribute12                    := l_Contract_Rec.attribute12;
    		l_ContractTmpl_Rec.attribute13                    := l_Contract_Rec.attribute13;
    		l_ContractTmpl_Rec.attribute14                    := l_Contract_Rec.attribute14;
    		l_ContractTmpl_Rec.attribute15                    := l_Contract_Rec.attribute15;
    		l_ContractTmpl_Rec.context                        := l_Contract_Rec.context;
    		l_ContractTmpl_Rec.object_version_number          := 1;

	--dbms_output.put_line('Before inserting template');
	-- Call insert API for cs_contracts_template
		CS_ContractTmpl_Pvt.Insert_Row
  		(
    			p_api_version                  => 1.0,
    			p_init_msg_list                => TAPI_DEV_KIT.G_FALSE,
    			p_validation_level             => 100,
    			p_commit                       => TAPI_DEV_KIT.G_FALSE,
    			x_return_status                => l_return_status,
    			x_msg_count                    => l_msg_count,
    			x_msg_data                     => l_msg_data,
    			p_contracttmpl_rec             => l_ContractTmpl_Rec,
    			x_contract_template_id         => l_contract_template_id,
    			x_object_version_number        => l_object_version_number
		);
	--dbms_output.put_line('After inserting template');
		FOR l_Service_Rec in l_Service_Csr
		LOOP
			--- insert into cs_contract_line_tplts
			CS_CONTRACTLTMPL_PVT.Insert_Row
  			(
    			p_api_version                  => 1.0,
    			p_init_msg_list                => TAPI_DEV_KIT.G_FALSE,
    			p_validation_level             => 100,
    			p_commit                       => TAPI_DEV_KIT.G_FALSE,
    			x_return_status                => l_return_status,
    			x_msg_count                    => l_msg_count,
    			x_msg_data                     => l_msg_data,
    			p_contract_template_id         => l_contract_template_id,
    			p_coverage_id                  => l_Service_Rec.coverage_schedule_id,
    			p_service_manufacturing_org_id  => l_Service_Rec.service_manufacturing_org_id,
    			p_service_inventory_item_id    => l_Service_Rec.service_inventory_item_id,
    			p_workflow                     => l_Service_Rec.workflow,
    			p_original_system_reference    => l_Service_Rec.original_system_line_reference,
    			p_duration              		 => l_Service_Rec.duration_quantity,
    			p_unit_of_measure_code         => l_Service_Rec.unit_of_measure_code,
    			p_last_update_date             => sysdate,
    			p_last_updated_by              => FND_GLOBAL.user_id,
    			p_creation_date                => sysdate,
    			p_created_by                   => FND_GLOBAL.user_id,
    			p_last_update_login            => FND_GLOBAL.login_id,
    			p_start_date_active            => NULL,
    			p_end_date_active              => NULL,
    			p_attribute1                   => l_Service_Rec.attribute1,
    			p_attribute2                   => l_Service_Rec.attribute2,
    			p_attribute3                   => l_Service_Rec.attribute3,
    			p_attribute4                   => l_Service_Rec.attribute4,
    			p_attribute5                   => l_Service_Rec.attribute5,
    			p_attribute6                   => l_Service_Rec.attribute6,
    			p_attribute7                   => l_Service_Rec.attribute7,
    			p_attribute8                   => l_Service_Rec.attribute8,
    			p_attribute9                   => l_Service_Rec.attribute9,
    			p_attribute10                  => l_Service_Rec.attribute10,
    			p_attribute11                  => l_Service_Rec.attribute11,
    			p_attribute12                  => l_Service_Rec.attribute12,
    			p_attribute13                  => l_Service_Rec.attribute13,
    			p_attribute14                  => l_Service_Rec.attribute14,
    			p_attribute15                  => l_Service_Rec.attribute15,
    			p_context                      => l_Service_Rec.context,
    			p_object_version_number        => 1,
    			x_contract_line_template_id    => l_contract_line_template_id,
    			x_object_version_number        => l_object_version_number
			);
		END LOOP;

	CLOSE l_Contract_Csr;

	x_template_id         :=  l_contract_template_id;

	TAPI_DEV_KIT.END_ACTIVITY(p_commit, x_msg_count, x_msg_data);

	--dbms_output.put_line('End act');

  EXCEPTION
    WHEN CONTRACT_NOT_FOUND THEN
      IF (l_Contract_csr%ISOPEN) THEN
        CLOSE l_Contract_csr;
      ELSIF (l_Service_Csr%ISOPEN) THEN
        CLOSE l_Service_Csr;
      END IF;
      --DBMS_TRANSACTION.ROLLBACK_SAVEPOINT(l_api_name || l_api_type);
      x_return_status := FND_API.G_RET_STS_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
        FND_MESSAGE.SET_NAME('CS', 'CS_CONTRACT_NOT_FOUND');
	FND_MSG_PUB.Add;
      END IF;
      FND_MSG_PUB.Count_And_Get( p_count	=> x_msg_count,
			         p_data		=> x_msg_data,
			         p_encoded	=> FND_API.G_FALSE );
    WHEN FND_API.G_EXC_ERROR THEN
      IF (l_Contract_csr%ISOPEN) THEN
        CLOSE l_Contract_csr;
      ELSIF (l_Service_Csr%ISOPEN) THEN
        CLOSE l_Service_Csr;
      END IF;
      --DBMS_TRANSACTION.ROLLBACK_SAVEPOINT(l_api_name || l_api_type);
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get( p_count	=> x_msg_count,
			         p_data		=> x_msg_data,
			         p_encoded	=> FND_API.G_FALSE );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	--dbms_output.put_line('UNEXP EXCEPTION');
      IF (l_Contract_csr%ISOPEN) THEN
        CLOSE l_Contract_csr;
      ELSIF (l_Service_Csr%ISOPEN) THEN
        CLOSE l_Service_Csr;
      END IF;
      --DBMS_TRANSACTION.ROLLBACK_SAVEPOINT(l_api_name || l_api_type);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get( p_count	=> x_msg_count,
			         p_data		=> x_msg_data,
			         p_encoded	=> FND_API.G_FALSE );
END Contract_to_template;


PROCEDURE Template_to_Contract
(
	p_api_version		  	IN NUMBER,
	p_init_msg_list	  		IN VARCHAR2  DEFAULT FND_API.G_FALSE,
       	p_commit                  	IN VARCHAR2  DEFAULT FND_API.G_FALSE,
	x_return_status	 		OUT VARCHAR2,
	x_msg_count		 	OUT NUMBER,
	x_msg_data		 	OUT VARCHAR2,
	p_template_id		  	IN NUMBER,
	p_customer_id		 	IN NUMBER,
	p_contract_number	 	IN NUMBER,
	p_bill_to_site_use_id	 	IN NUMBER,
	p_ship_to_site_use_id	 	IN NUMBER,
	p_start_date			IN DATE,
	p_end_date			IN DATE,
	x_contract_id			OUT NUMBER
)
IS
	Cursor l_Contract_Tmpl_Csr is
		Select * from cs_contract_templates
	where contract_template_id = p_template_id;
	Cursor l_Tmpl_Csr is
		Select * from cs_contract_line_tplts
			where contract_template_id =  p_template_id;

	l_api_name	  	CONSTANT VARCHAR2(30) := 'Template_to_Contract';
	l_api_version 		CONSTANT NUMBER       := 1.0;
	l_Contract_Tmpl_Rec	l_Contract_Tmpl_Csr%ROWTYPE;
	l_Tmpl_Rec		l_Tmpl_Csr%ROWTYPE;
	l_contract_rec 		CS_CONTRACT_PVT.Contract_Rec_Type;
	l_object_version_number NUMBER;
	l_contract_id		NUMBER;
	l_cp_service_id		NUMBER;
	template_not_found	EXCEPTION;
BEGIN
	l_return_status := TAPI_DEV_KIT.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              l_api_version,
                                              p_api_version,
                                              p_init_msg_list,
                                              l_api_type,
                                              x_return_status);
	--dbms_output.put_line('l_return_status ' || l_return_status);
    	IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    	ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      		RAISE FND_API.G_EXC_ERROR;
    	END IF;
	-- Get the contract template details
	Open l_Contract_Tmpl_Csr;
	Fetch l_Contract_Tmpl_Csr into l_Contract_Tmpl_Rec;
	if l_Contract_Tmpl_Csr%NOTFOUND THEN
		raise TEMPLATE_NOT_FOUND;
	end if;
	Close l_Contract_Tmpl_Csr;
	--dbms_output.put_line('Template Found');

	l_contract_rec.contract_id                    := NULL;
    	l_contract_rec.contract_number                := p_contract_number;
    	l_contract_rec.workflow                       := l_Contract_Tmpl_Rec.workflow;
    	l_contract_rec.workflow_process_id            := NULL;
    	l_contract_rec.agreement_id                   := null;
    	l_contract_rec.price_list_id                  := l_Contract_Tmpl_Rec.price_list_id;
    	l_contract_rec.currency_code                  := l_Contract_Tmpl_Rec.currency_code;
    	l_contract_rec.conversion_type_code           := l_Contract_Tmpl_Rec.conversion_type_code;
    	l_contract_rec.conversion_rate                := l_Contract_Tmpl_Rec.conversion_rate;
    	l_contract_rec.conversion_date                := l_Contract_Tmpl_Rec.conversion_date;
    	l_contract_rec.invoicing_rule_id              := l_Contract_Tmpl_Rec.invoicing_rule_id;
    	l_contract_rec.accounting_rule_id             := l_Contract_Tmpl_Rec.accounting_rule_id;
    	l_contract_rec.billing_frequency_period       := l_Contract_Tmpl_Rec.billing_frequency_period;
    	l_contract_rec.first_bill_date                := NULL;
    	l_contract_rec.next_bill_date                 := NULL;
    	l_contract_rec.create_sales_order             := l_Contract_Tmpl_Rec.create_sales_order;
    	l_contract_rec.renewal_rule                   := l_Contract_Tmpl_Rec.renewal_rule;
    	l_contract_rec.termination_rule               := l_Contract_Tmpl_Rec.termination_rule;
    	l_contract_rec.bill_to_site_use_id            := p_bill_to_site_use_id;
    	l_contract_rec.contract_type_id               := l_Contract_Tmpl_Rec.contract_type_id;
    	l_contract_rec.contract_status_id               := FND_PROFILE.Value('CS_CONTRACTS_DEFAULT_HDR_STATUS');
    	l_contract_rec.contract_template_id           := p_template_id;
    	l_contract_rec.contract_group_id              := NULL;
    	l_contract_rec.customer_id                    := p_customer_id;
    	l_contract_rec.duration                       := l_Contract_Tmpl_Rec.duration;
    	l_contract_rec.period_code                    := l_Contract_Tmpl_Rec.period_code;
    	l_contract_rec.ship_to_site_use_id            := p_ship_to_site_use_id;
    	l_contract_rec.salesperson_id                 := NULL;
    	l_contract_rec.ordered_by_contact_id          := NULL;
    	l_contract_rec.source_code                    := NULL;
    	l_contract_rec.source_reference               := NULL;
    	l_contract_rec.terms_id                       := l_Contract_Tmpl_Rec.terms_id;
    	l_contract_rec.po_number                      := NULL;
    	l_contract_rec.bill_on                        := NULL;
    	l_contract_rec.tax_handling                   := l_Contract_Tmpl_Rec.tax_handling;
    	l_contract_rec.tax_exempt_num                 := l_Contract_Tmpl_Rec.tax_exempt_num;
    	l_contract_rec.tax_exempt_reason_code         := l_Contract_Tmpl_Rec.tax_exempt_reason_code;
---    	l_contract_rec.contract_amount                := l_Contract_Tmpl_Rec.contract_amount;
    	l_contract_rec.auto_renewal_flag              := l_Contract_Tmpl_Rec.auto_renewal_flag;
    	l_contract_rec.original_end_date              := p_end_date;
    	l_contract_rec.terminate_reason_code          := NULL;
    	l_contract_rec.discount_id                    := l_Contract_Tmpl_Rec.discount_id;
    	l_contract_rec.po_required_to_service         := NULL;
    	l_contract_rec.pre_payment_required           := NULL;
    	l_contract_rec.last_update_date               := sysdate;
    	l_contract_rec.last_updated_by                := FND_GLOBAL.user_id;
    	l_contract_rec.creation_date                  := sysdate;
    	l_contract_rec.created_by                     := FND_GLOBAL.user_id;
    	l_contract_rec.last_update_login              := FND_GLOBAL.login_id;
    	l_contract_rec.start_date_active              := p_start_date;
    	l_contract_rec.end_date_active                := p_end_date;
    	l_contract_rec.attribute1                     := l_Contract_Tmpl_Rec.attribute1;
    	l_contract_rec.attribute2                     := l_Contract_Tmpl_Rec.attribute2;
    	l_contract_rec.attribute3                     := l_Contract_Tmpl_Rec.attribute3;
    	l_contract_rec.attribute4                     := l_Contract_Tmpl_Rec.attribute4;
    	l_contract_rec.attribute5                     := l_Contract_Tmpl_Rec.attribute5;
    	l_contract_rec.attribute6                     := l_Contract_Tmpl_Rec.attribute6;
    	l_contract_rec.attribute7                     := l_Contract_Tmpl_Rec.attribute7;
    	l_contract_rec.attribute8                     := l_Contract_Tmpl_Rec.attribute8;
    	l_contract_rec.attribute9                     := l_Contract_Tmpl_Rec.attribute9;
    	l_contract_rec.attribute10                    := l_Contract_Tmpl_Rec.attribute10;
	l_contract_rec.attribute11                    := l_Contract_Tmpl_Rec.attribute11;
	l_contract_rec.attribute12                    := l_Contract_Tmpl_Rec.attribute12;
    	l_contract_rec.attribute13                    := l_Contract_Tmpl_Rec.attribute13;
    	l_contract_rec.attribute14                    := l_Contract_Tmpl_Rec.attribute14;
    	l_contract_rec.attribute15                    := l_Contract_Tmpl_Rec.attribute15;
    	l_contract_rec.context                        := l_Contract_Tmpl_Rec.context;
    	l_contract_rec.object_version_number          := 1;

	--dbms_output.put_line('before insert');
	CS_CONTRACT_PVT.insert_row
  	(
    		p_api_version                  => 1.0,
    		p_init_msg_list                => TAPI_DEV_KIT.G_FALSE,
    		p_validation_level             => 100,
    		p_commit                       => TAPI_DEV_KIT.G_FALSE,
    		x_return_status                => l_return_status,
    		x_msg_count                    => l_msg_count,
    		x_msg_data                     => l_msg_data,
    		p_contract_rec                 => l_contract_rec,
    		x_contract_id                  => l_contract_id,
    		x_object_version_number        => l_object_version_number
	);

	FOR l_Tmpl_Rec in l_Tmpl_Csr LOOP
		--dbms_output.put_line('Inserted lines');
		CS_SERVICES_PVT.Insert_Service
  		(
    			p_api_version                  => 1.0,
    			p_init_msg_list                => TAPI_DEV_KIT.G_FALSE,
    			p_validation_level             => 100,
    			p_commit                       => TAPI_DEV_KIT.G_FALSE,
    			x_return_status                => l_return_status,
    			x_msg_count                    => l_msg_count,
    			x_msg_data                     => l_msg_data,
    			p_contract_line_template_id    => l_Tmpl_Rec.contract_line_template_id,
    			p_contract_id                  => l_contract_id,
			p_contract_line_status_id	=> FND_PROFILE.VALUE('CS_CONTRACTS_DEFAULT_LINE_STATUS'),
    			p_service_inventory_item_id    => l_Tmpl_Rec.service_inventory_item_id,
    			p_service_manufacturing_org_id => l_Tmpl_Rec.service_manufacturing_org_id,
    			p_original_start_date          => l_Tmpl_Rec.start_date_active,
    			p_original_end_date            => l_Tmpl_Rec.end_date_active,
    			p_workflow                     => l_Tmpl_Rec.workflow,
    			p_riginl_systm_lin_rfrnc       => l_Tmpl_Rec.original_system_reference,
    			p_duration_quantity            => l_Tmpl_Rec.duration,
    			p_unit_of_measure_code         => l_Tmpl_Rec.unit_of_measure_code,
    			p_creation_date                => sysdate,
    			p_created_by                   => FND_GLOBAL.user_id,
    			p_last_update_date             => sysdate,
    			p_last_updated_by              => FND_GLOBAL.user_id,
    			p_last_update_login            => FND_GLOBAL.login_id,
    			p_start_date_active            => l_Tmpl_Rec.start_date_active,
    			p_end_date_active              => l_Tmpl_Rec.end_date_active,
    			x_cp_service_id                => l_cp_service_id
		);
	END LOOP;

	x_contract_id := l_contract_id;

	TAPI_DEV_KIT.END_ACTIVITY(p_commit, x_msg_count, x_msg_data);

	--dbms_output.put_line('End act');

  EXCEPTION
    WHEN TEMPLATE_NOT_FOUND THEN
      IF (l_Contract_Tmpl_csr%ISOPEN) THEN
        CLOSE l_Contract_Tmpl_csr;
      END IF;
      --DBMS_TRANSACTION.ROLLBACK_SAVEPOINT(l_api_name || l_api_type);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
        FND_MESSAGE.SET_NAME('CS', 'CS_TEMPLATE_NOT_FOUND');
	FND_MSG_PUB.Add;
      END IF;
      FND_MSG_PUB.Count_And_Get( p_count	=> x_msg_count,
			         p_data		=> x_msg_data,
			         p_encoded	=> FND_API.G_FALSE );
    WHEN FND_API.G_EXC_ERROR THEN
      IF (l_Contract_Tmpl_csr%ISOPEN) THEN
        CLOSE l_Contract_Tmpl_csr;
      END IF;
      --DBMS_TRANSACTION.ROLLBACK_SAVEPOINT(l_api_name || l_api_type);
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get( p_count	=> x_msg_count,
			         p_data		=> x_msg_data,
			         p_encoded	=> FND_API.G_FALSE );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	--dbms_output.put_line('UNEXP EXCEPTION');
      IF (l_Contract_Tmpl_csr%ISOPEN) THEN
        CLOSE l_Contract_Tmpl_csr;
      END IF;
      --DBMS_TRANSACTION.ROLLBACK_SAVEPOINT(l_api_name || l_api_type);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get( p_count	=> x_msg_count,
			         p_data		=> x_msg_data,
			         p_encoded	=> FND_API.G_FALSE );
END Template_to_Contract;

END CS_Contract_Tpl_Pub;

/
