--------------------------------------------------------
--  DDL for Package Body EAM_ASSET_OPERATION_TXN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_ASSET_OPERATION_TXN_PVT" AS
/* $Header: EAMVACHB.pls 120.13 2006/09/14 20:02:13 hkarmach noship $ */
/*#
 * This package is used for the ASSET CHECKIN/CHECKOUT transaction logging AND validation .
 * It defines procedures which take quality collection plans and meter readings as input
 * during checkin/checkoutand perform the respective operations.
 */



-- This function returns the employeeid  who checked-in the instance for the last transaction

FUNCTION get_created_by(
	p_instance_id		 IN	number)
	return NUMBER
	AS

		l_created_by		number;

BEGIN

	SELECT
	  created_by
	INTO l_created_by
	FROM eam_asset_operation_txn
	WHERE instance_id=p_instance_id
	 AND txn_date =
	  (
        SELECT
           max(txn_date)
        FROM eam_asset_operation_txn eaot
        WHERE eaot.instance_id=p_instance_id
        );


		IF SQL%NOTFOUND THEN
			return null;
		END IF;
		return l_created_by;

END get_created_by;


--This procedure accepts the transaction details from CheckIn/CheckOut UI

PROCEDURE process_checkinout_txn(

	p_api_version			IN		number		:= 1.0,
	p_init_msg_list			IN		varchar2	:= fnd_api.g_false,
	p_commit			IN		varchar2	:= fnd_api.g_false,
	p_validation_level		IN		number		:= fnd_api.g_valid_level_full,
	p_txn_date			IN		date		:= sysdate,
	p_txn_type			IN		number,
	p_instance_id			IN		number,
	p_comments			IN		varchar2	:= NULL,
	p_qa_collection_id		IN		number		:= NULL,
	p_operable_flag			IN		number,
	p_employee_id			IN		number,
	p_attribute_category		IN		varchar2	:= NULL,
	p_attribute1			IN		varchar2	:= NULL,
	p_attribute2			IN		varchar2	:= NULL,
	p_attribute3			IN		varchar2	:= NULL,
	p_attribute4			IN		varchar2	:= NULL,
	p_attribute5			IN		varchar2	:= NULL,
	p_attribute6			IN		varchar2	:= NULL,
	p_attribute7			IN		varchar2	:= NULL,
	p_attribute8			IN		varchar2	:= NULL,
	p_attribute9			IN		varchar2	:= NULL,
	p_attribute10			IN		varchar2	:= NULL,
	p_attribute11			IN		varchar2	:= NULL,
	p_attribute12			IN		varchar2	:= NULL,
	p_attribute13			IN		varchar2	:= NULL,
	p_attribute14			IN		varchar2	:= NULL,
	p_attribute15			IN		varchar2	:= NULL,
	x_return_status			OUT NOCOPY	varchar2,
	x_msg_count			OUT NOCOPY	number,
	x_msg_data			OUT NOCOPY	varchar2
)

IS

	l_eam_ops_quality_tbl		eam_asset_operation_txn_pub.eam_quality_tbl_type;
	l_eam_meter_reading_tbl		eam_asset_operation_txn_pub.meter_reading_rec_tbl_type;
	l_eam_counter_properties_tbl	eam_asset_operation_txn_pub.Ctr_Property_readings_Tbl;
	g_pkg_name			CONSTANT	varchar2(30)	:= 'EAM_ASSET_OPERATION_TXN_PVT';
	l_api_name			constant	 varchar2(30)		:= 'process_checkinout_txn';
	l_api_version			constant	 number		        := 1.0;



BEGIN

 -- Standard Start of API savepoint
      SAVEPOINT EAM_ASSET_OPERATION_TXN_PVT;

      -- Standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call(
            l_api_version
           ,p_api_version
           ,l_api_name
           ,g_pkg_name) THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF fnd_api.to_boolean(p_init_msg_list) THEN
         fnd_msg_pub.initialize;
      END IF;

      x_return_status := fnd_api.g_ret_sts_success;

	EAM_ASSET_OPERATION_TXN_PVT.insert_txn(
				p_txn_date			=>	p_txn_date,
				p_txn_type			=>	p_txn_type,
				p_instance_id			=>	p_instance_id,
				p_comments			=>	p_comments,
				p_qa_collection_id		=>	p_qa_collection_id,
				p_operable_flag			=>	p_operable_flag,
				p_employee_id			=>	p_employee_id,
				p_eam_ops_quality_tbl		=>	l_eam_ops_quality_tbl,
				p_meter_reading_rec_tbl		=>	l_eam_meter_reading_tbl,
				p_counter_properties_tbl	=>	l_eam_counter_properties_tbl,
				p_attribute_category		=>	p_attribute_category,
				p_attribute1			=>	p_attribute1,
				p_attribute2			=>	p_attribute2,
				p_attribute3			=>	p_attribute3,
				p_attribute4			=>	p_attribute4,
				p_attribute5			=>	p_attribute5,
				p_attribute6			=>	p_attribute6,
				p_attribute7			=>	p_attribute7,
				p_attribute8			=>	p_attribute8,
				p_attribute9			=>	p_attribute9,
				p_attribute10			=>	p_attribute10,
				p_attribute11			=>	p_attribute11,
				p_attribute12			=>	p_attribute12,
				p_attribute13			=>	p_attribute13,
				p_attribute14			=>	p_attribute14,
				p_attribute15			=>	p_attribute15,
				x_return_status			=>	x_return_status,
				x_msg_count			=>	x_msg_count,
				x_msg_data			=>	x_msg_data
				);

		IF x_return_status <> fnd_api.g_ret_sts_success THEN
		ROLLBACK TO EAM_ASSET_OPERATION_TXN_PVT;
		RETURN;
		END IF;

-- Standard check of p_commit.
      IF fnd_api.to_boolean(p_commit) THEN
         COMMIT WORK;
      END IF;
      fnd_msg_pub.count_and_get(
         p_count => x_msg_count
        ,p_data => x_msg_data);
   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO EAM_ASSET_OPERATION_TXN_PVT;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get(
            p_count => x_msg_count
           ,p_data => x_msg_data);
      WHEN fnd_api.g_exc_unexpected_error THEN
         ROLLBACK TO EAM_ASSET_OPERATION_TXN_PVT;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get(
            p_count => x_msg_count
           ,p_data => x_msg_data);
      WHEN OTHERS THEN
         ROLLBACK TO EAM_ASSET_OPERATION_TXN_PVT;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level(
               fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get(
            p_count => x_msg_count,
	    p_data => x_msg_data);


END process_checkinout_txn;


-- This Procedure calls the quality api to insert quality plans

PROCEDURE insert_quality_plans
(

        p_eam_ops_quality_tbl		IN		eam_asset_operation_txn_pub.eam_quality_tbl_type,
	p_instance_id			IN		number,
	p_txn_date			IN		date,
	p_comments			IN		varchar2,
	p_operable_flag			IN		number,
	p_organization_id		IN		number,
	p_employee_id			IN		number,
	p_asset_group_id		IN		number,
        p_asset_number			IN		varchar2,
	p_asset_instance_number		IN		varchar2,
	p_txn_number			IN		number,
        x_return_status			OUT NOCOPY	varchar2,
        x_msg_count			OUT NOCOPY	number,
	x_msg_data			OUT NOCOPY	varchar2
)

IS

	Type header_plan_id_tbl_type is table of NUMBER
			INDEX BY BINARY_INTEGER;

    TYPE num_table is TABLE OF NUMBER INDEX BY BINARY_INTEGER;

	l_header_plan_id_tbl		header_plan_id_tbl_type;
	l_flag				boolean;
	l_header_counter		NUMBER		 :=0;
	l_eam_ops_quality_rec		EAM_ASSET_OPERATION_TXN_PUB.eam_quality_tbl_type;
	l_elements			qa_validation_api.ElementsArray;
	l_org_id			NUMBER;
	l_collection_id  		NUMBER;
	l_temp_occurence		NUMBER;
	l_assetops_return_status	VARCHAR2(1);
	l_plan_name			VARCHAR2(255);
	l_error_array			qa_validation_api.ErrorArray;
	l_message_array			qa_validation_api.MessageArray;
	l_action_result			VARCHAR2(1);
	l_mandatory_qua_plan		VARCHAR2(1);
	l_context_values		VARCHAR2(2000);
	l_asset_group			VARCHAR2(2000);
	l_planid_tbl            num_table;
	l_count                 number :=1;
	l_list_of_plans         varchar2(1000);
	eaot_api_call_error		EXCEPTION;

	BEGIN


	SAVEPOINT eaot_insert_quality_plans;

	IF  (p_eam_ops_quality_tbl.count >0) THEN
		l_org_id	:= p_eam_ops_quality_tbl(p_eam_ops_quality_tbl.FIRST).organization_id;
	END IF;


	-- following loops gets the different plan ids that are in the data
	-- for 3 collection plans there will be 3 different plan ids
	-- after this loop header_id_tbl table will contain the list of plan ids
	IF (p_eam_ops_quality_tbl.count >0) THEN


		  FOR i_counter in p_eam_ops_quality_tbl.first..p_eam_ops_quality_tbl.last LOOP
			  l_flag:=TRUE;
			  l_eam_ops_quality_rec(0) := p_eam_ops_quality_tbl(i_counter);



			  IF l_header_plan_id_tbl.COUNT  > 0 THEN
				  FOR J in l_header_plan_id_tbl.FIRST..l_header_plan_id_tbl.LAST LOOP

					IF l_eam_ops_quality_rec(0).plan_id = l_header_plan_id_tbl(j) THEN
						l_flag := FALSE;

					END IF;

				  END LOOP;
			END IF;

			  IF l_flag = TRUE THEN
				IF l_header_plan_id_tbl.COUNT > 0 THEN
				   l_header_plan_id_tbl(l_header_plan_id_tbl.COUNT + 1) := l_eam_ops_quality_rec(0).plan_id;
				ELSE
				   l_header_plan_id_tbl(1) := l_eam_ops_quality_rec(0).plan_id;
				END IF;
			  END IF;

		  END LOOP;

	END IF;





	FOR plan_id IN l_header_plan_id_tbl.FIRST..l_header_plan_id_tbl.LAST loop

		l_elements.delete;

		FOR results in p_eam_ops_quality_tbl.first..p_eam_ops_quality_tbl.last LOOP
			IF p_eam_ops_quality_tbl(results).PLAN_ID = l_header_plan_id_tbl(plan_id)  THEN
				l_elements(p_eam_ops_quality_tbl(results).ELEMENT_ID).id := p_eam_ops_quality_tbl(results).ELEMENT_ID;
				l_elements(p_eam_ops_quality_tbl(results).ELEMENT_ID).value := p_eam_ops_quality_tbl(results).ELEMENT_VALUE;
				l_collection_id := p_eam_ops_quality_tbl(results).collection_id;
				IF (l_collection_id is null)
				THEN
				 select qa_collection_id_s.nextval into l_collection_id from dual;
				END IF;
			 END IF;
		END LOOP;


		qa_results_pub.insert_row(
			p_api_version => 1.0,
			p_init_msg_list => fnd_api.g_true,
			p_org_id => l_org_id,
			p_plan_id => l_header_plan_id_tbl(plan_id),
			p_spec_id => null,
			p_transaction_number =>p_eam_ops_quality_tbl(0).transaction_number ,
			p_transaction_id => null,
			p_enabled_flag => 1,
			p_commit =>  fnd_api.g_false,
			x_collection_id => l_collection_id,
			x_occurrence => l_temp_occurence,
			x_row_elements => l_elements,
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			x_error_array => l_error_array,
			x_message_array => l_message_array,
			x_return_status => x_return_status,
			x_action_result => l_action_result
			);

 IF
 x_return_status <> fnd_api.g_ret_sts_success
 THEN
 raise eaot_api_call_error;
 END IF;

	  BEGIN
		 select qp.name into l_plan_name
		    from qa_plans qp,
		    qa_results qr
		    where
		    qr.collection_id = l_collection_id
		    and
		    qr.plan_id = qp.plan_id;


		EAM_ASSET_LOG_PVT.INSERT_ROW(
		p_api_version		=>	1.0,
		p_init_msg_list		=>	fnd_api.g_true,
		p_commit		=>	fnd_api.g_false,
		p_event_date		=>	p_txn_date,
		p_event_type		=>	'EAM_SYSTEM_EVENTS',
		p_event_id		=>	12,
		p_instance_id		=>	p_instance_id,
		p_organization_id       =>      p_organization_id,
		p_employee_id           =>      p_employee_id,
		p_comments		=>	p_comments,
		p_reference		=>	l_plan_name,
		p_ref_id		=>	l_collection_id,
		p_operable_flag		=>	p_operable_flag,
		x_return_status		=>	l_assetops_return_status,
		x_msg_count		=>	x_msg_count,
		x_msg_data		=>	x_msg_data
				);
	  EXCEPTION
	  WHEN NO_DATA_FOUND THEN
	  null;
	  END;

 IF
 x_return_status <> fnd_api.g_ret_sts_success
 THEN
 raise eaot_api_call_error;
 END IF;

 END LOOP;

l_context_values := '162='||p_asset_group_id||'@163='
			     ||p_asset_number||'@2147483550='||
			     p_instance_id;

		  qa_web_txn_api.post_background_results
			       (
			p_txn_number	 =>    p_txn_number
		       ,p_org_id	 =>    p_organization_id
		       ,p_context_values =>    l_context_values
		       ,p_collection_id  =>    l_collection_id
			       );

		   qa_result_grp.enable_and_fire_action(
		       p_api_version         => 1.0  ,
		       p_collection_id       => l_collection_id,
		       x_return_status       => x_return_status,
		       x_msg_count           => x_msg_count    ,
		       x_msg_data            => x_msg_data
		       );

         SELECT distinct plan_id
         bulk collect into
         l_planid_tbl
         from
         QA_RESULTS
         where
         collection_id = l_collection_id;

        IF  l_planid_tbl.COUNT>0 THEN
		     l_list_of_plans := '@'|| l_planid_tbl(l_planid_tbl.FIRST)||'@';
		     FOR l_count in l_planid_tbl.FIRST+1..l_planid_tbl.LAST
		     LOOP
		     l_list_of_plans := l_list_of_plans||'@'||l_planid_tbl(l_count)||'@';
		     END LOOP;
           ELSE
		     l_list_of_plans := '@'||'@';
        END IF;

	         SELECT
                 DISTINCT concatenated_segments
                 INTO
                 l_asset_group
                 FROM mtl_system_items_kfv
                 WHERE
                 inventory_item_id = p_asset_group_id;

            l_mandatory_qua_plan := qa_web_txn_api.quality_mandatory_plans_remain
				 (
			  p_txn_number          =>     p_txn_number
			 ,p_organization_id	    =>     p_organization_id
			 ,pk1			        =>     l_asset_group
			 ,pk2			        =>     p_asset_number
			 ,pk6			        =>     p_asset_instance_number
			 ,p_collection_id	    =>     l_collection_id
			 ,p_list_of_plans       => l_list_of_plans
			         );
		   IF l_mandatory_qua_plan = 'Y' THEN
	               	fnd_message.set_name
				(  application  => 'EAM'
				 , name         => 'EAM_WC_QA_REMAIN'
				);

		       fnd_msg_pub.add;
		       x_return_status:= fnd_api.g_ret_sts_error;

			 fnd_msg_pub.count_and_get(
		 		 p_count => x_msg_count
		 		,p_data => x_msg_data
		 		);
			raise eaot_api_call_error;
		    END IF;

		 IF
		 x_return_status <> fnd_api.g_ret_sts_success
		 THEN
		 raise eaot_api_call_error;
		 END IF;



EXCEPTION
WHEN eaot_api_call_error THEN
ROLLBACK TO eaot_insert_quality_plans;

END insert_quality_plans;


-- This Procedure calls the meter reading api to insert meter readings

PROCEDURE insert_meter_readings
(
        p_eam_meter_reading_tbl		IN		eam_asset_operation_txn_pub.meter_reading_rec_tbl_type,
        p_counter_properties_tbl	IN		eam_asset_operation_txn_pub.Ctr_Property_readings_Tbl,
	p_instance_id			IN		number,
	p_txn_id			IN		number,
	x_return_status			OUT NOCOPY	varchar2,
        x_msg_count			OUT NOCOPY	number,
	x_msg_data			OUT NOCOPY	varchar2
)

IS
	l_counter_properties_tbl		EAM_MeterReading_PUB.Ctr_Property_readings_Tbl;
	l_meter_reading_rec			EAM_MeterReading_PUB.Meter_Reading_Rec_Type;
	x_meter_reading_id			number;
	l_count					number;
	eaot_api_call_error			EXCEPTION;
 BEGIN

	SAVEPOINT eaot_insert_meter_readings;


	    for meter_count in p_eam_meter_reading_tbl.FIRST..p_eam_meter_reading_tbl.LAST LOOP
	     IF p_eam_meter_reading_tbl(meter_count).instance_id = p_instance_id THEN
		l_meter_reading_rec.meter_id                :=		p_eam_meter_reading_tbl(meter_count).meter_id;
		l_meter_reading_rec.meter_reading_id        :=		p_eam_meter_reading_tbl(meter_count).meter_reading_id;
		l_meter_reading_rec.current_reading         :=		p_eam_meter_reading_tbl(meter_count).current_reading;
		l_meter_reading_rec.current_reading_date    :=		p_eam_meter_reading_tbl(meter_count).current_reading_date;
		l_meter_reading_rec.reset_flag              :=		p_eam_meter_reading_tbl(meter_count).reset_flag;
		l_meter_reading_rec.description             :=		p_eam_meter_reading_tbl(meter_count).description;
		l_meter_reading_rec.wip_entity_id           :=		p_eam_meter_reading_tbl(meter_count).wip_entity_id;
		l_meter_reading_rec.check_in_out_type       :=		p_eam_meter_reading_tbl(meter_count).check_in_out_type;
	        l_meter_reading_rec.check_in_out_txn_id     :=		p_txn_id;
		l_meter_reading_rec.instance_id             :=		p_eam_meter_reading_tbl(meter_count).instance_id;
		l_meter_reading_rec.source_line_id          :=		p_eam_meter_reading_tbl(meter_count).source_line_id;
		l_meter_reading_rec.source_code             :=		p_eam_meter_reading_tbl(meter_count).source_code;
		l_meter_reading_rec.wo_entry_fake_flag      :=		p_eam_meter_reading_tbl(meter_count).wo_entry_fake_flag;
		l_meter_reading_rec.adjustment_type         :=		p_eam_meter_reading_tbl(meter_count).adjustment_type;
		l_meter_reading_rec.adjustment_reading      :=		p_eam_meter_reading_tbl(meter_count).adjustment_reading;
		l_meter_reading_rec.net_reading             :=		p_eam_meter_reading_tbl(meter_count).net_reading;
		l_meter_reading_rec.reset_reason	    :=		p_eam_meter_reading_tbl(meter_count).reset_reason;
		l_meter_reading_rec.attribute_category      :=		p_eam_meter_reading_tbl(meter_count).attribute_category;
		l_meter_reading_rec.attribute1              :=		p_eam_meter_reading_tbl(meter_count).attribute1;
		l_meter_reading_rec.attribute2              :=		p_eam_meter_reading_tbl(meter_count).attribute2;
		l_meter_reading_rec.attribute3              :=		p_eam_meter_reading_tbl(meter_count).attribute3;
		l_meter_reading_rec.attribute4              :=		p_eam_meter_reading_tbl(meter_count).attribute4;
		l_meter_reading_rec.attribute5              :=		p_eam_meter_reading_tbl(meter_count).attribute5;
		l_meter_reading_rec.attribute6              :=		p_eam_meter_reading_tbl(meter_count).attribute6;
		l_meter_reading_rec.attribute7              :=		p_eam_meter_reading_tbl(meter_count).attribute7;
		l_meter_reading_rec.attribute8              :=		p_eam_meter_reading_tbl(meter_count).attribute8;
		l_meter_reading_rec.attribute9              :=		p_eam_meter_reading_tbl(meter_count).attribute9;
		l_meter_reading_rec.attribute10             :=		p_eam_meter_reading_tbl(meter_count).attribute10;
		l_meter_reading_rec.attribute11             :=		p_eam_meter_reading_tbl(meter_count).attribute11;
		l_meter_reading_rec.attribute12             :=		p_eam_meter_reading_tbl(meter_count).attribute12;
		l_meter_reading_rec.attribute13             :=		p_eam_meter_reading_tbl(meter_count).attribute13;
		l_meter_reading_rec.attribute14             :=		p_eam_meter_reading_tbl(meter_count).attribute14;
		l_meter_reading_rec.attribute15             :=		p_eam_meter_reading_tbl(meter_count).attribute15;
		l_meter_reading_rec.attribute16             :=		p_eam_meter_reading_tbl(meter_count).attribute16;
		l_meter_reading_rec.attribute17             :=		p_eam_meter_reading_tbl(meter_count).attribute17;
		l_meter_reading_rec.attribute18             :=		p_eam_meter_reading_tbl(meter_count).attribute18;
		l_meter_reading_rec.attribute19             :=		p_eam_meter_reading_tbl(meter_count).attribute19;
		l_meter_reading_rec.attribute20             :=		p_eam_meter_reading_tbl(meter_count).attribute20;
		l_meter_reading_rec.attribute21             :=		p_eam_meter_reading_tbl(meter_count).attribute21;
		l_meter_reading_rec.attribute22             :=		p_eam_meter_reading_tbl(meter_count).attribute22;
		l_meter_reading_rec.attribute23             :=		p_eam_meter_reading_tbl(meter_count).attribute23;
		l_meter_reading_rec.attribute24             :=		p_eam_meter_reading_tbl(meter_count).attribute24;
		l_meter_reading_rec.attribute25             :=		p_eam_meter_reading_tbl(meter_count).attribute25;
		l_meter_reading_rec.attribute26             :=		p_eam_meter_reading_tbl(meter_count).attribute26;
		l_meter_reading_rec.attribute27             :=		p_eam_meter_reading_tbl(meter_count).attribute27;
		l_meter_reading_rec.attribute28             :=		p_eam_meter_reading_tbl(meter_count).attribute28;
		l_meter_reading_rec.attribute29             :=		p_eam_meter_reading_tbl(meter_count).attribute29;
		l_meter_reading_rec.attribute30             :=		p_eam_meter_reading_tbl(meter_count).attribute30;

		l_count :=1;
		l_counter_properties_tbl.DELETE;

		IF p_counter_properties_tbl.COUNT > 0 THEN

				for prpr_count in p_counter_properties_tbl.FIRST..p_counter_properties_tbl.LAST LOOP
					IF l_meter_reading_rec.meter_id=p_counter_properties_tbl(prpr_count).counter_id THEN


					l_counter_properties_tbl(l_count).counter_property_id     :=	p_counter_properties_tbl(prpr_count).counter_property_id;
					l_counter_properties_tbl(l_count).property_value          :=	p_counter_properties_tbl(prpr_count).property_value;
					l_counter_properties_tbl(l_count).value_timestamp         :=	p_counter_properties_tbl(prpr_count).value_timestamp;
					l_counter_properties_tbl(l_count).attribute_category      :=	p_counter_properties_tbl(prpr_count).attribute_category;
					l_counter_properties_tbl(l_count).attribute1              :=	p_counter_properties_tbl(prpr_count).attribute1;
					l_counter_properties_tbl(l_count).attribute2              :=	p_counter_properties_tbl(prpr_count).attribute2;
					l_counter_properties_tbl(l_count).attribute3              :=	p_counter_properties_tbl(prpr_count).attribute3;
					l_counter_properties_tbl(l_count).attribute4              :=	p_counter_properties_tbl(prpr_count).attribute4;
					l_counter_properties_tbl(l_count).attribute5              :=	p_counter_properties_tbl(prpr_count).attribute5;
					l_counter_properties_tbl(l_count).attribute6              :=	p_counter_properties_tbl(prpr_count).attribute6;
					l_counter_properties_tbl(l_count).attribute7              :=	p_counter_properties_tbl(prpr_count).attribute7;
					l_counter_properties_tbl(l_count).attribute8              :=	p_counter_properties_tbl(prpr_count).attribute8;
					l_counter_properties_tbl(l_count).attribute9              :=	p_counter_properties_tbl(prpr_count).attribute9;
					l_counter_properties_tbl(l_count).attribute10             :=	p_counter_properties_tbl(prpr_count).attribute10;
					l_counter_properties_tbl(l_count).attribute11             :=	p_counter_properties_tbl(prpr_count).attribute11;
					l_counter_properties_tbl(l_count).attribute12             :=	p_counter_properties_tbl(prpr_count).attribute12;
					l_counter_properties_tbl(l_count).attribute13             :=	p_counter_properties_tbl(prpr_count).attribute13;
					l_counter_properties_tbl(l_count).attribute14             :=	p_counter_properties_tbl(prpr_count).attribute14;
					l_counter_properties_tbl(l_count).attribute15             :=	p_counter_properties_tbl(prpr_count).attribute15;
					l_counter_properties_tbl(l_count).migrated_flag           :=	p_counter_properties_tbl(prpr_count).migrated_flag;

					l_count:=l_count+1;
						END IF;
						END LOOP;
			 END IF;

			 /* call meter reading api to create meter readings */


			 EAM_METERREADING_PUB.create_meter_reading(

				p_api_version			 =>     1.0,
				x_msg_count			 =>	x_msg_count,
				x_msg_data			 =>     x_msg_data,
				x_return_status			 =>     x_return_status,
				x_meter_reading_id		 =>     x_meter_reading_id,
				p_meter_reading_rec		 =>     l_meter_reading_rec,
				p_value_before_reset		 =>     p_eam_meter_reading_tbl(meter_count).value_before_reset,
				p_ignore_warnings		 =>     p_eam_meter_reading_tbl(meter_count).p_ignore_warnings,
				p_ctr_property_readings_tbl	 =>     l_counter_properties_tbl
				);

		    END IF;
		    END LOOP;

				IF
				  x_return_status <> fnd_api.g_ret_sts_success
				THEN
				 raise eaot_api_call_error;
				END IF;
EXCEPTION
WHEN eaot_api_call_error THEN
ROLLBACK TO eaot_insert_meter_readings;

END insert_meter_readings;

-- This procedure validates the transaction details

PROCEDURE validate_txn(

	p_api_version			IN		number		:= 1.0,
	p_init_msg_list			IN		varchar2	:= fnd_api.g_false,
	p_validation_level		IN		number		:= fnd_api.g_valid_level_full,
	p_txn_date			IN		date		:= sysdate,
	p_txn_type			IN		number,
	p_instance_id			IN		number,
	p_operable_flag			IN		number,
	p_employee_id			IN		number,
	x_return_status			OUT NOCOPY      varchar2,
	x_msg_count			OUT NOCOPY      number,
	x_msg_data			OUT NOCOPY      varchar2
)

IS


		l_api_name		 constant	 varchar2(30)		:= 'validate_txn';
	        l_api_version		 constant	 number		        := 1.0;
		l_last_txn_date		 date;
		l_txn_type		 number;
		l_count			 number;
		g_pkg_name		 CONSTANT	 varchar2(30)	         := 'EAM_ASSET_OPERATION_TXN_PVT';


BEGIN


      -- Standard Start of API savepoint
      SAVEPOINT EAM_ASSET_OPERATION_TXN_PVT_SV;
      -- Standard call to check for call compatibility.

      IF NOT fnd_api.compatible_api_call(
            l_api_version
           ,p_api_version
           ,l_api_name
           ,g_pkg_name) THEN

         RAISE fnd_api.g_exc_unexpected_error;

       END IF;

      IF fnd_api.to_boolean(p_init_msg_list) THEN
         fnd_msg_pub.initialize;
      END IF;

      --  Initialize API return status to success

      x_return_status := fnd_api.g_ret_sts_success;


      -- API body

	-- transaction date validation


	SELECT  MAX(txn_date)
	INTO l_last_txn_date
	FROM eam_asset_operation_txn
	WHERE instance_id=p_instance_id;

	IF ((l_last_txn_date is not null  AND (p_txn_date <= l_last_txn_date)) OR p_txn_date>sysdate)
		THEN
			fnd_message.set_name
				(  application  => 'EAM'
				 , name         => 'EAM_EVENT_DATE_INVALID'
				);

		fnd_msg_pub.add;
		x_return_status:= fnd_api.g_ret_sts_error;

		fnd_msg_pub.count_and_get(
			 p_count => x_msg_count
			,p_data => x_msg_data
			);
		return;

	END IF;

	-- instance id validation

	SELECT
	count(*)
	INTO l_count
	FROM csi_item_instances
	WHERE instance_id=p_instance_id
	 AND
	p_txn_date BETWEEN nvl(active_start_date,sysdate) AND
	NVL(active_end_date, sysdate);

	    IF (l_count=0 OR l_count IS NULL)
		 THEN
			fnd_message.set_name
				(  application  => 'EAM'
				 , name         => 'EAM_INSTANCE_ID_INVALID'
				);

		fnd_msg_pub.add;
		x_return_status:= fnd_api.g_ret_sts_error;

		fnd_msg_pub.count_and_get(
			 p_count => x_msg_count
			,p_data => x_msg_data
			);
		return;
	    END IF;



	-- valid fnd_user validation

	SELECT
	count(*)
	INTO l_count
	FROM fnd_user
	WHERE p_employee_id=user_id;

	IF (l_count=0 OR l_count IS NULL)
	    THEN
		fnd_message.set_name
				(  application  => 'EAM'
				 , name         => 'EAM_USER_INVALID'
				);

				fnd_msg_pub.add;
				x_return_status:= fnd_api.g_ret_sts_error;

				fnd_msg_pub.count_and_get(
					 p_count => x_msg_count
					,p_data => x_msg_data
					);
				return;

	END IF;


	--txn_type validation

	IF l_last_txn_date IS NOT NULL  THEN
		SELECT
		txn_type
		INTO l_txn_type
		FROM eam_asset_operation_txn
		WHERE instance_id=p_instance_id
		AND txn_date=l_last_txn_date;
	END IF;

	IF p_txn_type IS NULL THEN
			fnd_message.set_name
				(  application  => 'EAM'
				  , name         => 'EAM_TXNTYPE_INVALID'
				 );

					fnd_msg_pub.add;
					x_return_status:= fnd_api.g_ret_sts_error;

				      fnd_msg_pub.count_and_get(
					 p_count => x_msg_count
					,p_data => x_msg_data
					);
					return;
	END IF;

	IF l_txn_type IS NOT NULL THEN
		IF(p_txn_type is NOT NULL) THEN
			IF((p_txn_type NOT IN (1,2)) OR (p_txn_type=l_txn_type) ) THEN
				fnd_message.set_name
					(  application  => 'EAM'
					, name         => 'EAM_TXNTYPE_INVALID'
					);

					fnd_msg_pub.add;
					x_return_status:= fnd_api.g_ret_sts_error;

				      fnd_msg_pub.count_and_get(
					 p_count => x_msg_count
					,p_data => x_msg_data
					);
					return;
			END IF;
		END IF;
	END IF;



	--p_operable_flag validation

	SELECT	count(*) INTO l_count
		FROM	mfg_lookups
		WHERE	lookup_type='SYS_YES_NO' AND
			enabled_flag='Y' AND
			p_txn_date BETWEEN NVL(start_date_active, p_txn_date) AND
			NVL(end_date_active,sysdate) AND
			lookup_code = p_operable_flag;

        IF
		l_count = 0 OR l_count is null
        THEN
		fnd_message.set_name
				(  application  => 'EAM'
				 , name         => 'EAM_OPERABLE_INVALID'
				);

		fnd_msg_pub.add;
		x_return_status:= fnd_api.g_ret_sts_error;

		fnd_msg_pub.count_and_get(
			 p_count => x_msg_count
			,p_data => x_msg_data
			);
		return;
	 END IF;


      -- End of API body.
      -- Standard check of p_commit.

      -- Standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get(
         p_count => x_msg_count
        ,p_data => x_msg_data);

EXCEPTION

	WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO EAM_ASSET_OPERATION_TXN_PVT_SV;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get(
            p_count => x_msg_count
           ,p_data => x_msg_data);

        WHEN fnd_api.g_exc_unexpected_error THEN
         ROLLBACK TO EAM_ASSET_OPERATION_TXN_PVT_SV;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get(
            p_count => x_msg_count
           ,p_data => x_msg_data);

        WHEN OTHERS THEN

         ROLLBACK TO EAM_ASSET_OPERATION_TXN_PVT_SV;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         IF fnd_msg_pub.check_msg_level(
		fnd_msg_pub.g_msg_lvl_unexp_error) THEN
		 fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
	 END IF;
         fnd_msg_pub.count_and_get(
         p_count => x_msg_count
        ,p_data => x_msg_data);

END validate_txn;

-- This procedure commits the transaction details into eam_asset_operation_txn

PROCEDURE insert_txn(

	p_api_version			IN		number		:= 1.0,
	p_init_msg_list			IN		varchar2	:= fnd_api.g_false,
	p_commit			IN		varchar2	:= fnd_api.g_false,
	p_validation_level		IN		number		:= fnd_api.g_valid_level_full,
	p_txn_date			IN		date		:= sysdate,
	p_txn_type			IN		number,
	p_instance_id			IN		number,
	p_comments			IN		varchar2	:= NULL,
	p_qa_collection_id		IN		number		:= NULL,
	p_operable_flag			IN		number,
	p_employee_id			IN		number,
	p_eam_ops_quality_tbl		IN		eam_asset_operation_txn_pub.eam_quality_tbl_type,
        p_meter_reading_rec_tbl		IN		eam_asset_operation_txn_pub.meter_reading_rec_tbl_type,
        p_counter_properties_tbl	IN		eam_asset_operation_txn_pub.Ctr_Property_readings_Tbl,
	p_attribute_category		IN		varchar2	:= NULL,
	p_attribute1			IN		varchar2	:= NULL,
	p_attribute2			IN		varchar2	:= NULL,
	p_attribute3			IN		varchar2	:= NULL,
	p_attribute4			IN		varchar2	:= NULL,
	p_attribute5			IN		varchar2	:= NULL,
	p_attribute6			IN		varchar2	:= NULL,
	p_attribute7			IN		varchar2	:= NULL,
	p_attribute8			IN		varchar2	:= NULL,
	p_attribute9			IN		varchar2	:= NULL,
	p_attribute10			IN		varchar2	:= NULL,
	p_attribute11			IN		varchar2	:= NULL,
	p_attribute12			IN		varchar2	:= NULL,
	p_attribute13			IN		varchar2	:= NULL,
	p_attribute14			IN		varchar2	:= NULL,
	p_attribute15			IN		varchar2	:= NULL,
	x_return_status			OUT NOCOPY	varchar2,
	x_msg_count			OUT NOCOPY	number,
	x_msg_data			OUT NOCOPY	varchar2
)

	IS

		l_api_name		constant	varchar2(30)	 := 'insert_txn';
		l_api_version		constant	number		 := 1.0;
	        l_desc_flex_name			varchar2(100)	 :='EAM_ASSET_CHECKINOUT';
		x_error_segments			number;
		x_error_message				varchar2(2000);
		l_reference				varchar2(100);
		l_txn_id				number;
		l_event_id				number;
		l_maint_org_id				number;
		l_asset_group_id			number;
		l_asset_group				varchar2(2000);
		l_asset_instance_number			varchar2(30);
		l_asset_number				varchar2(30);
		l_txn_number				number;
		l_context_values			varchar2(2000);
		l_instance_rec				CSI_DATASTRUCTURES_PUB.instance_rec;
		l_txn_rec				CSI_DATASTRUCTURES_PUB.transaction_rec;
		x_instance_id_lst			CSI_DATASTRUCTURES_PUB.id_tbl;
		l_ext_attrib_values_tbl			CSI_DATASTRUCTURES_PUB.extend_attrib_values_tbl;
		l_party_tbl				CSI_DATASTRUCTURES_PUB.party_tbl;
		l_account_tbl				CSI_DATASTRUCTURES_PUB.party_account_tbl;
		l_pricing_attrib_tbl			CSI_DATASTRUCTURES_PUB.pricing_attribs_tbl;
		l_org_assignments_tbl			CSI_DATASTRUCTURES_PUB.organization_units_tbl;
		l_asset_assignment_tbl			CSI_DATASTRUCTURES_PUB.instance_asset_tbl;
		t_output				varchar2(2000);
		t_msg_dummy				number;
		l_assetops_return_status		varchar2(2000);
		l_plan_name				varchar2(255);
		l_count                 number :=1;
		l_list_of_plans         varchar2(1000);
		l_validate				boolean;
		l_mandatory_qua_plan			varchar2(1);
		g_pkg_name		 CONSTANT	varchar2(30)	:= 'EAM_ASSET_OPERATION_TXN_PVT';
		l_object_version_number			number;
		eaot_api_call_error			EXCEPTION;
		eaot_api_desc_error			EXCEPTION;
		TYPE num_table is TABLE OF NUMBER INDEX BY BINARY_INTEGER;
		l_planid_tbl num_table;



		CURSOR get_plan_name(qa_collection_id IN NUMBER) IS
			   (select qp.name
			    from qa_plans qp,
			    qa_results qr
			    where
			    qr.collection_id = qa_collection_id
			    and
			    qr.plan_id = qp.plan_id);

        CURSOR get_plan_id(p_qa_collection_id IN NUMBER) IS
                (SELECT
                    distinct Plan_Id
                    from
                    QA_RESULTS
                    where
                    collection_id = p_qa_collection_id
                    );

 BEGIN

      -- Standard Start of API savepoint
      SAVEPOINT EAOT_INSERT_TXN;

      -- Standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call(
            l_api_version
           ,p_api_version
           ,l_api_name
           ,g_pkg_name) THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF fnd_api.to_boolean(p_init_msg_list) THEN
         fnd_msg_pub.initialize;
      END IF;

      x_return_status := fnd_api.g_ret_sts_success;

      --api body
      --generate txnid from sequence
      SELECT
	eam_asset_operation_txn_s.nextval
	INTO l_txn_id
	FROM dual;


      IF p_txn_type=1 THEN
	  l_event_id:=10;
	  l_txn_number:=2006;
	ELSIF p_txn_type=2
	  THEN
	  l_event_id:=11;
	  l_txn_number:=2007;
	  END IF;



      -- maintenance organization_id
      BEGIN

      SELECT
      mp.maint_organization_id,
      cii.instance_number,
      cii.inventory_item_id,
      cii.serial_number
      INTO
      l_maint_org_id,
      l_asset_instance_number,
      l_asset_group_id,
      l_asset_number
      FROM
      mtl_parameters mp, csi_item_instances cii
      where
      cii.last_vld_organization_id = mp.organization_id
      AND cii.instance_id = p_instance_id;

      EXCEPTION

      WHEN NO_DATA_FOUND THEN
	raise eaot_api_call_error;
      END;

      --call validate_txn to validate txn_details

        EAM_ASSET_OPERATION_TXN_PVT.validate_txn(
		p_api_version		=> 1.0,
		p_init_msg_list		=> p_init_msg_list,
		p_validation_level	=> p_validation_level,
		p_txn_date		=> p_txn_date,
		p_txn_type		=> p_txn_type,
		p_instance_id		=> p_instance_id,
		p_operable_flag		=> p_operable_flag,
		p_employee_id		=> p_employee_id,
		x_return_status		=> x_return_status,
		x_msg_count		=> x_msg_count,
		x_msg_data		=> x_msg_data);



IF
  x_return_status <> fnd_api.g_ret_sts_success

THEN
 raise eaot_api_call_error;
END IF;


	--Check whether the API is called from UI or from a public api

	IF p_eam_ops_quality_tbl.COUNT>0 THEN

		insert_quality_plans(
			p_eam_ops_quality_tbl	=>   p_eam_ops_quality_tbl
		       ,p_instance_id		=>   p_instance_id
		       ,p_txn_date		=>   p_txn_date
		       ,p_comments		=>   p_comments
		       ,p_operable_flag		=>   p_operable_flag
		       ,p_organization_id	=>   l_maint_org_id
		       ,p_asset_group_id	=>   l_asset_group_id
		       ,p_asset_instance_number =>   l_asset_instance_number
		       ,p_asset_number		=>   l_asset_number
		       ,p_txn_number		=>   l_txn_number
		       ,p_employee_id		=>   p_employee_id
		       ,x_return_status         =>   x_return_status
		       ,x_msg_count		=>   x_msg_count
		       ,x_msg_data		=>   x_msg_data

			);
			IF x_return_status <> fnd_api.g_ret_sts_success
			THEN
			 raise eaot_api_call_error;
			END IF;
	END IF;


	IF p_meter_reading_rec_tbl.COUNT>0 AND x_return_status = fnd_api.g_ret_sts_success THEN

		insert_meter_readings(
			p_eam_meter_reading_tbl	  =>   p_meter_reading_rec_tbl
		       ,p_counter_properties_tbl  =>   p_counter_properties_tbl
		       ,p_instance_id		  =>   p_instance_id
		       ,p_txn_id		  =>   l_txn_id
		       ,x_return_status		  =>   x_return_status
		       ,x_msg_count		  =>   x_msg_count
		       ,x_msg_data		  =>   x_msg_data
		        );

			IF x_return_status <> fnd_api.g_ret_sts_success
			THEN
			raise eaot_api_call_error;
			END IF;
	END  IF;





	--validate descriptive flex fields

        l_validate :=  EAM_COMMON_UTILITIES_PVT.validate_desc_flex_field(
			p_desc_flex_name		=>	l_desc_flex_name,
		        p_attribute_category		=>	p_attribute_category,
			p_attribute1			=>	p_attribute1,
			p_attribute2			=>	p_attribute2,
			p_attribute3			=>	p_attribute3,
			p_attribute4			=>	p_attribute4,
			p_attribute5			=>	p_attribute5,
			p_attribute6			=>	p_attribute6,
			p_attribute7			=>	p_attribute7,
			p_attribute8			=>	p_attribute8,
			p_attribute9			=>	p_attribute9,
			p_attribute10			=>	p_attribute10,
			p_attribute11			=>	p_attribute11,
			p_attribute12			=>	p_attribute12,
			p_attribute13			=>	p_attribute13,
			p_attribute14			=>	p_attribute14,
			p_attribute15			=>	p_attribute15,
			x_error_segments		=>	x_error_segments,
			x_error_message			=>	x_error_message
			);

			IF l_validate <> TRUE THEN
			   fnd_message.set_name
				(  application  => 'EAM'
				 , name         => 'EAM_DESC_INVALID'
				);

				fnd_msg_pub.add;

				fnd_msg_pub.count_and_get(
					 p_count => x_msg_count
					,p_data => x_msg_data
					);
			   raise eaot_api_desc_error;
			END IF;
	  --insert record in eam_asset_operation_txn table


	SELECT DISTINCT nvl(ppf.full_name,fu.user_name)
	INTO l_reference
	FROM fnd_user fu,per_people_f ppf
	WHERE fu.employee_id=ppf.person_id(+)
	AND fu.user_id=p_employee_id;


	insert into eam_asset_operation_txn(
			txn_id,
			txn_date,
			txn_type,
			instance_id,
			comments,
			user_id,
			operable,
			qa_collection_id,
			attribute_category,
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
			created_by,
			creation_date,
			last_updated_by,
			last_update_date,
			last_update_login
			)
			VALUES
			(
			l_txn_id,
			p_txn_date,
			p_txn_type,
			p_instance_id,
			p_comments,
			p_employee_id,
			p_operable_flag,
			p_qa_collection_id,
			p_attribute_category,
			p_attribute1,
			p_attribute2,
			p_attribute3,
			p_attribute4,
			p_attribute5,
			p_attribute6,
			p_attribute7,
			p_attribute8,
			p_attribute9,
			p_attribute10,
			p_attribute11,
			p_attribute12,
			p_attribute13,
			p_attribute14,
			p_attribute15,
			FND_GLOBAL.user_id,
			sysdate,
			FND_GLOBAL.user_id,
			sysdate,
			FND_GLOBAL.login_id
			);

--check whether mandatory plans have been entered and
--call qa_result_grp.enable_and_fire_action to commit quality results
--call post_background_results

              BEGIN
				OPEN get_plan_id(p_qa_collection_id);
                 LOOP
				 FETCH get_plan_id INTO l_planid_tbl(l_count);
				  EXIT WHEN get_plan_id%NOTFOUND;
				  l_count := l_count+1;

                 END LOOP;

			  EXCEPTION

			  WHEN NO_DATA_FOUND THEN
			  null;
			  END;

		IF p_eam_ops_quality_tbl.COUNT<=0 THEN

		   IF  l_planid_tbl.COUNT>0 THEN
		     l_list_of_plans := '@'|| l_planid_tbl(l_planid_tbl.FIRST)||'@';
		     FOR l_count in l_planid_tbl.FIRST+1..l_planid_tbl.LAST
		     LOOP
		     l_list_of_plans := l_list_of_plans||'@'||l_planid_tbl(l_count)||'@';
		     END LOOP;
           ELSE
		     l_list_of_plans := '@'||'@';
           END IF;

	   	 SELECT
                 DISTINCT concatenated_segments
                 INTO
                 l_asset_group
                 FROM mtl_system_items_kfv
                 WHERE
                 inventory_item_id = l_asset_group_id;

            l_mandatory_qua_plan := qa_web_txn_api.quality_mandatory_plans_remain
				 (
			  p_txn_number          =>     l_txn_number
			 ,p_organization_id	=>     l_maint_org_id
			 ,pk1			=>     l_asset_group
			 ,pk2			=>     l_asset_number
			 ,pk6			=>     l_asset_instance_number
			 ,p_collection_id	=>     p_qa_collection_id
			 ,p_list_of_plans  => l_list_of_plans
			         );
		   IF l_mandatory_qua_plan = 'Y' THEN
	               	fnd_message.set_name
				(  application  => 'EAM'
				 , name         => 'EAM_WC_QA_REMAIN'
				);

		       fnd_msg_pub.add;
		       x_return_status:= fnd_api.g_ret_sts_error;

			 fnd_msg_pub.count_and_get(
		 		 p_count => x_msg_count
		 		,p_data => x_msg_data
		 		);
			raise eaot_api_call_error;
		    END IF;


			 l_context_values := '162='||l_asset_group_id||'@163='
			                      ||l_asset_number||'@2147483550='||
					      p_instance_id;

			qa_web_txn_api.post_background_results
				   (
			     	p_txn_number =>    l_txn_number
			       ,p_org_id	 =>    l_maint_org_id
			       ,p_context_values =>    l_context_values
			       ,p_collection_id  =>    p_qa_collection_id
			           );

			qa_result_grp.enable_and_fire_action
			         (
			  p_api_version		=>     1.0
			 ,p_collection_id	=>     p_qa_collection_id
			 ,x_return_status	=>     x_return_status
			 ,x_msg_count		=>     x_msg_count
			 ,x_msg_data		=>	x_msg_data
				 );

--call the assetlog api to log the quality results entered event

			      BEGIN
				OPEN get_plan_name(p_qa_collection_id);
			       LOOP
				FETCH get_plan_name INTO l_plan_name;
				EXIT WHEN get_plan_name%NOTFOUND;

				EAM_ASSET_LOG_PVT.INSERT_ROW(
				p_api_version		=>	1.0,
				p_init_msg_list		=>	p_init_msg_list,
				p_commit		=>	p_commit,
				p_validation_level	=>	p_validation_level,
				p_event_date		=>	p_txn_date,
				p_event_type		=>	'EAM_SYSTEM_EVENTS',
				p_event_id		=>	12,
				p_instance_id		=>	p_instance_id,
				p_employee_id		=>	p_employee_id,
				p_organization_id	=>	l_maint_org_id,
				p_comments		=>	p_comments,
				p_reference		=>	l_plan_name,
				p_ref_id		=>	p_qa_collection_id,
				p_operable_flag		=>	p_operable_flag,
				x_return_status		=>	l_assetops_return_status,
				x_msg_count		=>	x_msg_count,
				x_msg_data		=>	x_msg_data
						);
			      END LOOP;

			  EXCEPTION

			  WHEN NO_DATA_FOUND THEN
			  null;
			  END;


		END IF;



		        IF x_return_status <> fnd_api.g_ret_sts_success
			THEN
			  raise eaot_api_call_error;
			END IF;
--call the assetlog api to log the checkin/out event



		EAM_ASSET_LOG_PVT.INSERT_ROW(
		p_api_version		=>	1.0,
		p_init_msg_list		=>	p_init_msg_list,
		p_commit		=>	p_commit,
		p_validation_level	=>	p_validation_level,
		p_event_date		=>	p_txn_date,
		p_event_type		=>	'EAM_SYSTEM_EVENTS',
		p_event_id		=>	l_event_id,
		p_employee_id		=>	p_employee_id,
		p_organization_id	=>	l_maint_org_id,
		p_instance_id		=>	p_instance_id,
		p_comments		=>	p_comments,
		p_reference		=>	l_reference,
		p_ref_id		=>	l_txn_id,
		p_operable_flag		=>	p_operable_flag,
		x_return_status		=>	l_assetops_return_status,
		x_msg_count		=>	x_msg_count,
		x_msg_data		=>	x_msg_data
				);
			IF x_return_status <> fnd_api.g_ret_sts_success
			THEN
			  raise eaot_api_call_error;
			END IF;
-- call csi update api to update checkin_status flag of the current instance


		l_instance_rec.instance_id := p_instance_id;

		 select object_version_number
			into l_object_version_number
                  from csi_item_instances
                  where instance_id = p_instance_id;

		  IF SQL%NOTFOUND THEN
		  l_object_version_number :=null;
		  END IF;

		l_instance_rec.object_version_number := l_object_version_number;

-- add checkin_status updated with txntype
		l_instance_rec.checkin_status :=p_txn_type;
		l_instance_rec.mfg_serial_number_flag := 'Y';


--fill the transaction record
		l_txn_rec.transaction_id			:= NULL;
		l_txn_rec.transaction_date			:= sysdate; --TO_DATE('');
		l_txn_rec.source_transaction_date		:= sysdate; --TO_DATE('');
		l_txn_rec.transaction_type_id			:= 1; --NULL;
		l_txn_rec.txn_sub_type_id			:= NULL;
		l_txn_rec.source_group_ref_id			:= NULL;
		l_txn_rec.source_group_ref			:= '';
		l_txn_rec.source_header_ref_id			:= NULL;
		l_txn_rec.source_header_ref			:= '';
		l_txn_rec.source_line_ref_id			:= NULL;
		l_txn_rec.source_line_ref			:= '';
		l_txn_rec.source_dist_ref_id1			:= NULL;
		l_txn_rec.source_dist_ref_id2			:= NULL;
		l_txn_rec.inv_material_transaction_id		:= NULL;
		l_txn_rec.transaction_quantity			:= NULL;
		l_txn_rec.transaction_uom_code			:= '';
		l_txn_rec.transacted_by				:= NULL;
		l_txn_rec.transaction_status_code		:= '';
		l_txn_rec.transaction_action_code		:= '';
		l_txn_rec.message_id				:= NULL;
		l_txn_rec.context				:= '';
		l_txn_rec.attribute1				:= '';
		l_txn_rec.attribute2				:= '';
		l_txn_rec.attribute3				:= '';
		l_txn_rec.attribute4				:= '';
		l_txn_rec.attribute5				:= '';
		l_txn_rec.attribute6				:= '';
		l_txn_rec.attribute7				:= '';
		l_txn_rec.attribute8				:= '';
		l_txn_rec.attribute9				:= '';
		l_txn_rec.attribute10				:= '';
		l_txn_rec.attribute11				:= '';
		l_txn_rec.attribute12				:= '';
		l_txn_rec.attribute13				:= '';
		l_txn_rec.attribute14				:= '';
		l_txn_rec.attribute15				:= '';
		l_txn_rec.object_version_number			:= NULL;
		l_txn_rec.split_reason_code := '';


-- call csi update api
			IF x_return_status <> fnd_api.g_ret_sts_success
			THEN
			  raise eaot_api_call_error;
			END IF;

		csi_item_instance_pub.update_item_instance
				(
			p_api_version           =>    1.0
		       ,p_commit                =>    fnd_api.g_false
		       ,p_init_msg_list         =>    fnd_api.g_false
		       ,p_validation_level      =>    fnd_api.g_valid_level_full
		       ,p_instance_rec          =>    l_instance_rec
	               ,p_ext_attrib_values_tbl =>    l_ext_attrib_values_tbl
                       ,p_party_tbl             =>    l_party_tbl
                       ,p_account_tbl           =>    l_account_tbl
                       ,p_pricing_attrib_tbl    =>    l_pricing_attrib_tbl
                       ,p_org_assignments_tbl   =>    l_org_assignments_tbl
                       ,p_asset_assignment_tbl  =>    l_asset_assignment_tbl
                       ,p_txn_rec               =>    l_txn_rec
                       ,x_instance_id_lst       =>    x_instance_id_lst
                       ,x_return_status         =>    x_return_status
                       ,x_msg_count             =>    x_msg_count
                       ,x_msg_data              =>    x_msg_data
				);


			IF x_return_status <> fnd_api.g_ret_sts_success
			THEN
			  raise eaot_api_call_error;
			END IF;
 -- End of API body.
      -- Standard check of p_commit.
      IF fnd_api.to_boolean(p_commit) THEN
         COMMIT WORK;
      END IF;
      fnd_msg_pub.count_and_get(
         p_count => x_msg_count
        ,p_data => x_msg_data);
   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO EAOT_INSERT_TXN;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get(
            p_count => x_msg_count
           ,p_data => x_msg_data);
      WHEN fnd_api.g_exc_unexpected_error THEN
         ROLLBACK TO EAOT_INSERT_TXN;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get(
            p_count => x_msg_count
           ,p_data => x_msg_data);
      WHEN eaot_api_call_error THEN
	ROLLBACK TO EAOT_INSERT_TXN;
      WHEN eaot_api_desc_error THEN
        ROLLBACK TO EAOT_INSERT_TXN;
        x_return_status := fnd_api.g_ret_sts_error;
      WHEN OTHERS THEN
         ROLLBACK TO EAOT_INSERT_TXN;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level(
               fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get(
            p_count => x_msg_count,
	    p_data => x_msg_data);

END insert_txn;

END EAM_ASSET_OPERATION_TXN_PVT;

/
