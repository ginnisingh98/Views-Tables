--------------------------------------------------------
--  DDL for Package Body MSC_CONFIG_FF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_CONFIG_FF" AS
/* $Header: MSCCONFB.pls 115.31 2003/10/29 19:59:02 jarora ship $ */


   PROCEDURE LOG_MESSAGE( pBUFF                     IN  VARCHAR2)
   IS
   BEGIN
     IF fnd_global.conc_request_id > 0 THEN   -- concurrent program
         FND_FILE.PUT_LINE( FND_FILE.LOG, pBUFF);
     ELSE
       --DBMS_OUTPUT.PUT_LINE( pBUFF);
       null;
     END IF;
   END LOG_MESSAGE;

 PROCEDURE Configure_forecast_flex(
 	ERRBUF      	OUT NOCOPY VARCHAR2,
 	RETCODE     	OUT NOCOPY NUMBER,
 	item_attr1		IN  NUMBER,
 	org_attr1		IN  NUMBER,
 	cust_attr1		IN  NUMBER)

 as

 	req_id 		NUMBER;
 	conc_failure 	EXCEPTION;
 --	abp_failure  	EXCEPTION;

 	msgbuf		VARCHAR2(2000);

 Begin

     	fnd_flex_dsc_api.debug_on;
     	fnd_flex_dsc_api.set_session_mode('seed_data');

 IF item_attr1 IS NOT NULL THEN

     fnd_flex_dsc_api.enable_context('INV',
                          'MTL_SYSTEM_ITEMS',
                          'Global Data Elements',
                          TRUE);

     IF fnd_flex_dsc_api.segment_exists(
 	p_appl_short_name=>'INV',
 	p_flexfield_name=>'MTL_SYSTEM_ITEMS',
 	p_context_code=>'Global Data Elements',
 	p_segment_name=>'Service Level') = TRUE THEN

         FND_MESSAGE.set_name('MSC','MSC_SEGMENT_EXISTS');
         FND_MESSAGE.set_token('SEGMENT','Service Level');
         FND_MESSAGE.set_token('TABLE','MTL_SYSTEM_ITEMS');
         msgbuf := FND_MESSAGE.get;
         LOG_MESSAGE(msgbuf);

     ELSE

         fnd_flex_dsc_api.create_segment(
         appl_short_name => 'INV',
         flexfield_name => 'MTL_SYSTEM_ITEMS',
         context_name => 'Global Data Elements',
         name => 'Service Level',
         column => 'ATTRIBUTE'|| to_char(item_attr1),
         description => 'Service Level',
         sequence_number => 150,
         enabled => 'Y',
         displayed => 'Y',
         value_set => 'FND_NUMBER',
         default_type => NULL,
         default_value => NULL,
         required => 'N',
         security_enabled => 'N',
         display_size => 25,
         description_size => 50,
         concatenated_description_size => 50,
         list_of_values_prompt => 'Service Level',
         window_prompt => 'Service Level',
         range => NULL,
         srw_parameter => NULL);

     END IF;

 END IF;  -- item_attr1 is not null


 IF org_attr1 IS NOT NULL THEN

         fnd_flex_dsc_api.enable_context('INV',
                          'MTL_PARAMETERS',
                          'Global Data Elements',
                          TRUE);

     IF fnd_flex_dsc_api.segment_exists(
 	p_appl_short_name=>'INV',
 	p_flexfield_name=>'MTL_PARAMETERS',
 	p_context_code=>'Global Data Elements',
 	p_segment_name=>'Service Level') = TRUE THEN

         FND_MESSAGE.set_name('MSC','MSC_SEGMENT_EXISTS');
         FND_MESSAGE.set_token('SEGMENT','Service Level');
         FND_MESSAGE.set_token('TABLE','MTL_PARAMETERS');
         msgbuf := FND_MESSAGE.get;
         LOG_MESSAGE(msgbuf);

 	ELSE

         fnd_flex_dsc_api.create_segment(
         appl_short_name => 'INV',
         flexfield_name => 'MTL_PARAMETERS',
         context_name => 'Global Data Elements',
         name => 'Service Level',
         column => 'ATTRIBUTE'|| to_char(org_attr1),
         description => 'Service Level',
         sequence_number => 150,
         enabled => 'Y',
         displayed => 'Y',
         value_set => 'FND_NUMBER',
         default_type => NULL,
         default_value => NULL,
         required => 'N',
         security_enabled => 'N',
         display_size => 25,
         description_size => 50,
         concatenated_description_size => 50,
         list_of_values_prompt => 'Service Level',
         window_prompt => 'Service Level',
         range => NULL,
         srw_parameter => NULL);

   END IF;


 END IF; -- org_attr1 is not null

 IF cust_attr1 IS NOT NULL THEN

         fnd_flex_dsc_api.enable_context('AR',
                          'RA_CUSTOMERS_HZ',
                          'Global Data Elements',
                          TRUE);

     IF fnd_flex_dsc_api.segment_exists(
 	p_appl_short_name=>'AR',
 	p_flexfield_name=>'RA_CUSTOMERS_HZ',
 	p_context_code=>'Global Data Elements',
 	p_segment_name=>'Service Level') = TRUE THEN

         FND_MESSAGE.set_name('MSC','MSC_SEGMENT_EXISTS');
         FND_MESSAGE.set_token('SEGMENT','Service Level');
         FND_MESSAGE.set_token('TABLE','HZ_CUST_ACCOUNTS');
         msgbuf := FND_MESSAGE.get;
         LOG_MESSAGE(msgbuf);

 	ELSE

         fnd_flex_dsc_api.create_segment(
         appl_short_name => 'AR',
         flexfield_name => 'RA_CUSTOMERS_HZ',
         context_name => 'Global Data Elements',
         name => 'Service Level',
         column => 'ATTRIBUTE'|| to_char(cust_attr1),
         description => 'Service Level',
         sequence_number => 150,
         enabled => 'Y',
         displayed => 'Y',
         value_set => 'FND_NUMBER',
         default_type => NULL,
         default_value => NULL,
         required => 'N',
         security_enabled => 'N',
         display_size => 25,
         description_size => 50,
         concatenated_description_size => 50,
         list_of_values_prompt => 'Service Level',
         window_prompt => 'Service Level',
         range => NULL,
         srw_parameter => NULL);

   END IF;

 END IF;  -- cust_attr1 is not null

 commit;

     req_id := fnd_request.submit_request(
                 'FND', 'FDFVGN', '', '', FALSE,
                 '3', 401,
                 'MTL_SYSTEM_ITEMS');
     IF (req_id = 0) THEN
       raise conc_failure;
     END IF;

     req_id := fnd_request.submit_request( 'FND', 'FDFVGN', '', '', FALSE,
                 '3', 401,
                 'MTL_PARAMETERS');
     IF (req_id = 0) THEN
       raise conc_failure;
     END IF;

     req_id := fnd_request.submit_request(
                 'FND', 'FDFVGN', '', '', FALSE,
                 '3', 222,
                 'RA_CUSTOMERS_HZ');
     IF (req_id = 0) THEN
       raise conc_failure;
     END IF;

     COMMIT;
     errbuf := 'Created flexfields - submitted requests to recompile flexfields';
     retcode := 0; -- success
 EXCEPTION
    WHEN conc_failure THEN
      errbuf := 'Error ' ||
                   substr(fnd_message.get,1,240);
      retcode := 2;
    WHEN OTHERS THEN
    rollback;
     if (fnd_flex_dsc_api.message is null) then
       errbuf := 'Sql Error:' || to_char(sqlcode);
     else
       errbuf := fnd_flex_dsc_api.message;
     end if;
     retcode := 2; -- failure

 END Configure_forecast_flex;


PROCEDURE Configure(
	ERRBUF      	OUT NOCOPY VARCHAR2,
	RETCODE     	OUT NOCOPY NUMBER,
	item_attr1		IN  NUMBER,
	item_attr2		IN  NUMBER,
	org_attr1		IN  NUMBER,
	org_attr2		IN  NUMBER,
	org_attr3		IN  NUMBER,
	org_attr4		IN  NUMBER,
	dept_attr1		IN  NUMBER,
	dept_attr2		IN  NUMBER,
	supp_attr1		IN  NUMBER,
	subst_attr1		IN  NUMBER,
	trans_attr1		IN  NUMBER,
	bom_attr1		IN  NUMBER,
	forecast_attr1	        IN  NUMBER,
	line_attr1		IN  NUMBER,
        schedule_attr1          IN  NUMBER
)
AS
	req_id 		NUMBER;
	conc_failure 	EXCEPTION;
--	abp_failure  	EXCEPTION;

	msgbuf		VARCHAR2(2000);

------------------------------

BEGIN

    fnd_flex_dsc_api.debug_on;
    fnd_flex_dsc_api.set_session_mode('seed_data');

 IF item_attr1 is NOT NULL THEN

    fnd_flex_dsc_api.enable_context('INV',
                         'MTL_SYSTEM_ITEMS',
                         'Global Data Elements',
                         TRUE);
    IF fnd_flex_dsc_api.is_column_used(
		p_application_id => '401',
		p_table_name => 'MTL_SYSTEM_ITEMS_B',
		p_column_name => 'ATTRIBUTE'||to_char(item_attr1),
		x_message => msgbuf) = TRUE THEN


        FND_MESSAGE.set_name('MSC','MSC_ATTRIBUTE_EXISTS');
        FND_MESSAGE.set_token('ATTRIBUTE','ATTRIBUTE'||to_char(item_attr1));
        FND_MESSAGE.set_token('TABLE','MTL_SYSTEM_ITEMS');
        msgbuf := FND_MESSAGE.get;
        LOG_MESSAGE(msgbuf);

    ELSIF fnd_flex_dsc_api.segment_exists(
	p_appl_short_name=>'INV',
	p_flexfield_name=>'MTL_SYSTEM_ITEMS',
	p_context_code=>'Global Data Elements',
	p_segment_name=>'Late Demands Penalty') = TRUE THEN

        FND_MESSAGE.set_name('MSC','MSC_SEGMENT_EXISTS');
        FND_MESSAGE.set_token('SEGMENT','Late Demands Penalty');
        FND_MESSAGE.set_token('TABLE','MTL_SYSTEM_ITEMS');
        msgbuf := FND_MESSAGE.get;
        LOG_MESSAGE(msgbuf);

    ELSE

        fnd_flex_dsc_api.create_segment(
        appl_short_name => 'INV',
        flexfield_name => 'MTL_SYSTEM_ITEMS',
        context_name => 'Global Data Elements',
        name => 'Late Demands Penalty',
        column => 'ATTRIBUTE'|| to_char(item_attr1),
        description => 'Penalty Cost Factor for Late Demands',
        sequence_number => 10,
        enabled => 'Y',
        displayed => 'Y',
        value_set => 'FND_NUMBER',
        default_type => NULL,
        default_value => NULL,
        required => 'N',
        security_enabled => 'N',
        display_size => 25,
        description_size => 50,
        concatenated_description_size => 50,
        list_of_values_prompt => 'Late Demands Penalty',
        window_prompt => 'Late Demands Penalty',
        range => NULL,
        srw_parameter => NULL);

    update fnd_profile_option_values
    set profile_option_value = to_char(item_attr1)
    where application_id = 723
    and level_id = 10001
    and profile_option_id = (select profile_option_id
		from fnd_profile_options
		where application_id = 723
		and  profile_option_name = 'MSO_ITEM_DMD_PENALTY');

   END IF;

 END IF; --item_attr1 is not null


 IF item_attr2 IS NOT NULL THEN

    IF fnd_flex_dsc_api.is_column_used(
		p_application_id => '401',
		p_table_name => 'MTL_SYSTEM_ITEMS_B',
		p_column_name => 'ATTRIBUTE'||to_char(item_attr2),
		x_message => msgbuf) = TRUE THEN

        FND_MESSAGE.set_name('MSC','MSC_ATTRIBUTE_EXISTS');
        FND_MESSAGE.set_token('ATTRIBUTE','ATTRIBUTE'||to_char(item_attr2));
        FND_MESSAGE.set_token('TABLE','MTL_SYSTEM_ITEMS');
        msgbuf := FND_MESSAGE.get;
        LOG_MESSAGE(msgbuf);

    ELSIF fnd_flex_dsc_api.segment_exists(
	p_appl_short_name=>'INV',
	p_flexfield_name=>'MTL_SYSTEM_ITEMS',
	p_context_code=>'Global Data Elements',
	p_segment_name=>'Material Over-Capacity Penalty') = TRUE THEN

        FND_MESSAGE.set_name('MSC','MSC_SEGMENT_EXISTS');
        FND_MESSAGE.set_token('SEGMENT','Material Over-Capacity Penalty');
        FND_MESSAGE.set_token('TABLE','MTL_SYSTEM_ITEMS');
        msgbuf := FND_MESSAGE.get;
        LOG_MESSAGE(msgbuf);

    ELSE

        fnd_flex_dsc_api.create_segment(
        appl_short_name => 'INV',
        flexfield_name => 'MTL_SYSTEM_ITEMS',
        context_name => 'Global Data Elements',
        name => 'Material Over-Capacity Penalty',
        column => 'ATTRIBUTE'|| to_char(item_attr2),
        description => 'Penalty Cost Factor for Exceeding Material Capacity',
        sequence_number => 20,
        enabled => 'Y',
        displayed => 'Y',
        value_set => 'FND_NUMBER',
        default_type => NULL,
        default_value => NULL,
        required => 'N',
        security_enabled => 'N',
        display_size => 25,
        description_size => 50,
        concatenated_description_size => 50,
        list_of_values_prompt => 'Material Over-Capacity Penalty',
        window_prompt => 'Material Over-Capacity Penalty',
        range => NULL,
        srw_parameter => NULL);

    update fnd_profile_option_values
    set profile_option_value = to_char(item_attr2)
    where application_id = 723
    and level_id = 10001
    and profile_option_id = (select profile_option_id
		from fnd_profile_options
		where application_id = 723
		and  profile_option_name = 'MSO_ITEM_CAP_PENALTY');

  END IF;

 END IF; -- item_attr2 is not null


 IF org_attr1 IS NOT NULL THEN

        fnd_flex_dsc_api.enable_context('INV',
                         'MTL_PARAMETERS',
                         'Global Data Elements',
                         TRUE);

    IF fnd_flex_dsc_api.is_column_used(
		p_application_id => '401',
		p_table_name => 'MTL_PARAMETERS',
		p_column_name => 'ATTRIBUTE'||to_char(org_attr1),
		x_message => msgbuf) = TRUE THEN

        FND_MESSAGE.set_name('MSC','MSC_ATTRIBUTE_EXISTS');
        FND_MESSAGE.set_token('ATTRIBUTE','ATTRIBUTE'||to_char(org_attr1));
        FND_MESSAGE.set_token('TABLE','MTL_PARAMETERS');
        msgbuf := FND_MESSAGE.get;
        LOG_MESSAGE(msgbuf);

    ELSIF fnd_flex_dsc_api.segment_exists(
	p_appl_short_name=>'INV',
	p_flexfield_name=>'MTL_PARAMETERS',
	p_context_code=>'Global Data Elements',
	p_segment_name=>'Late Demands Penalty') = TRUE THEN

        FND_MESSAGE.set_name('MSC','MSC_SEGMENT_EXISTS');
        FND_MESSAGE.set_token('SEGMENT','Late Demands Penalty');
        FND_MESSAGE.set_token('TABLE','MTL_PARAMETERS');
        msgbuf := FND_MESSAGE.get;
        LOG_MESSAGE(msgbuf);

    ELSE

        fnd_flex_dsc_api.create_segment(
        appl_short_name => 'INV',
        flexfield_name => 'MTL_PARAMETERS',
        context_name => 'Global Data Elements',
        name => 'Late Demands Penalty',
        column => 'ATTRIBUTE'|| to_char(org_attr1),
        description => 'Penalty Cost Factor for Late Demands',
        sequence_number => 10,
        enabled => 'Y',
        displayed => 'Y',
        value_set => 'FND_NUMBER',
        default_type => NULL,
        default_value => NULL,
        required => 'N',
        security_enabled => 'N',
        display_size => 25,
        description_size => 50,
        concatenated_description_size => 50,
        list_of_values_prompt => 'Late Demands Penalty',
        window_prompt => 'Late Demands Penalty',
        range => NULL,
        srw_parameter => NULL);

    update fnd_profile_option_values
    set profile_option_value = to_char(org_attr1)
    where application_id = 723
    and level_id = 10001
    and profile_option_id = (select profile_option_id
		from fnd_profile_options
		where application_id = 723
		and  profile_option_name = 'MSO_ORG_DMD_PENALTY');

   END IF;

 END IF;   -- org_attr1 is not null


 IF org_attr2 IS NOT NULL THEN

    IF fnd_flex_dsc_api.is_column_used(
		p_application_id => '401',
		p_table_name => 'MTL_PARAMETERS',
		p_column_name => 'ATTRIBUTE'||to_char(org_attr2),
		x_message => msgbuf) = TRUE THEN

        FND_MESSAGE.set_name('MSC','MSC_ATTRIBUTE_EXISTS');
        FND_MESSAGE.set_token('ATTRIBUTE','ATTRIBUTE'||to_char(org_attr2));
        FND_MESSAGE.set_token('TABLE','MTL_PARAMETERS');
        msgbuf := FND_MESSAGE.get;
        LOG_MESSAGE(msgbuf);

    ELSIF fnd_flex_dsc_api.segment_exists(
	p_appl_short_name=>'INV',
	p_flexfield_name=>'MTL_PARAMETERS',
	p_context_code=>'Global Data Elements',
	p_segment_name=>'Material Over-Capacity Penalty') = TRUE THEN

        FND_MESSAGE.set_name('MSC','MSC_SEGMENT_EXISTS');
        FND_MESSAGE.set_token('SEGMENT','Material Over-Capacity Penalty');
        FND_MESSAGE.set_token('TABLE','MTL_PARAMETERS');
        msgbuf := FND_MESSAGE.get;
        LOG_MESSAGE(msgbuf);

    ELSE

        fnd_flex_dsc_api.create_segment(
        appl_short_name => 'INV',
        flexfield_name => 'MTL_PARAMETERS',
        context_name => 'Global Data Elements',
        name => 'Material Over-Capacity Penalty',
        column => 'ATTRIBUTE'|| to_char(org_attr2),
        description => 'Penalty Cost Factor for Exceeding Material Capacity',
        sequence_number => 20,
        enabled => 'Y',
        displayed => 'Y',
        value_set => 'FND_NUMBER',
        default_type => NULL,
        default_value => NULL,
        required => 'N',
        security_enabled => 'N',
        display_size => 25,
        description_size => 50,
        concatenated_description_size => 50,
        list_of_values_prompt => 'Material Over-Capacity Penalty',
        window_prompt => 'Material Over-Capacity Penalty',
        range => NULL,
        srw_parameter => NULL);

    update fnd_profile_option_values
    set profile_option_value = to_char(org_attr2)
    where application_id = 723
    and level_id = 10001
    and profile_option_id = (select profile_option_id
		from fnd_profile_options
		where application_id = 723
		and  profile_option_name = 'MSO_ORG_ITEM_PENALTY');

   END IF;

 END IF;  -- org_attr2 is not null


 IF org_attr3 IS NOT NULL THEN

    IF fnd_flex_dsc_api.is_column_used(
		p_application_id => '401',
		p_table_name => 'MTL_PARAMETERS',
		p_column_name => 'ATTRIBUTE'||to_char(org_attr3),
		x_message => msgbuf) = TRUE THEN

        FND_MESSAGE.set_name('MSC','MSC_ATTRIBUTE_EXISTS');
        FND_MESSAGE.set_token('ATTRIBUTE','ATTRIBUTE'||to_char(org_attr3));
        FND_MESSAGE.set_token('TABLE','MTL_PARAMETERS');
        msgbuf := FND_MESSAGE.get;
        LOG_MESSAGE(msgbuf);

    ELSIF fnd_flex_dsc_api.segment_exists(
	p_appl_short_name=>'INV',
	p_flexfield_name=>'MTL_PARAMETERS',
	p_context_code=>'Global Data Elements',
	p_segment_name=>'Resource Over-Capacity Penalty') = TRUE THEN

        FND_MESSAGE.set_name('MSC','MSC_SEGMENT_EXISTS');
        FND_MESSAGE.set_token('SEGMENT','Resource Over-Capacity Penalty');
        FND_MESSAGE.set_token('TABLE','MTL_PARAMETERS');
        msgbuf := FND_MESSAGE.get;
        LOG_MESSAGE(msgbuf);

    ELSE


        fnd_flex_dsc_api.create_segment(
        appl_short_name => 'INV',
        flexfield_name => 'MTL_PARAMETERS',
        context_name => 'Global Data Elements',
        name => 'Resource Over-Capacity Penalty',
        column => 'ATTRIBUTE'|| to_char(org_attr3),
        description => 'Penalty Cost Factor for Exceeding Resource Capacity',
        sequence_number => 30,
        enabled => 'Y',
        displayed => 'Y',
        value_set => 'FND_NUMBER',
        default_type => NULL,
        default_value => NULL,
        required => 'N',
        security_enabled => 'N',
        display_size => 25,
        description_size => 50,
        concatenated_description_size => 50,
        list_of_values_prompt => 'Resource Over-Capacity Penalty',
        window_prompt => 'Resource Over-Capacity Penalty',
        range => NULL,
        srw_parameter => NULL);

    update fnd_profile_option_values
    set profile_option_value = to_char(org_attr3)
    where application_id = 723
    and level_id = 10001
    and profile_option_id = (select profile_option_id
		from fnd_profile_options
		where application_id = 723
		and  profile_option_name = 'MSO_ORG_RES_PENALTY');

     END IF;

  END IF;   -- org_attr3 is not null


  IF org_attr4 IS NOT NULL THEN

    IF fnd_flex_dsc_api.is_column_used(
		p_application_id => '401',
		p_table_name => 'MTL_PARAMETERS',
		p_column_name => 'ATTRIBUTE'||to_char(org_attr4),
		x_message => msgbuf) = TRUE THEN

        FND_MESSAGE.set_name('MSC','MSC_ATTRIBUTE_EXISTS');
        FND_MESSAGE.set_token('ATTRIBUTE','ATTRIBUTE'||to_char(org_attr4));
        FND_MESSAGE.set_token('TABLE','MTL_PARAMETERS');
        msgbuf := FND_MESSAGE.get;
        LOG_MESSAGE(msgbuf);

    ELSIF fnd_flex_dsc_api.segment_exists(
	p_appl_short_name=>'INV',
	p_flexfield_name=>'MTL_PARAMETERS',
	p_context_code=>'Global Data Elements',
	p_segment_name=>'Transport Over-Cap Penalty') = TRUE THEN

        FND_MESSAGE.set_name('MSC','MSC_SEGMENT_EXISTS');
        FND_MESSAGE.set_token('SEGMENT','Transport Over-Cap Penalty');
        FND_MESSAGE.set_token('TABLE','MTL_PARAMETERS');
        msgbuf := FND_MESSAGE.get;
        LOG_MESSAGE(msgbuf);

    ELSE


        fnd_flex_dsc_api.create_segment(
        appl_short_name => 'INV',
        flexfield_name => 'MTL_PARAMETERS',
        context_name => 'Global Data Elements',
        name => 'Transport Over-Cap Penalty',
        column => 'ATTRIBUTE'|| to_char(org_attr4),
        description => 'Penalty Cost Factor for Exceeding Transportation Capacity',
        sequence_number => 40,
        enabled => 'Y',
        displayed => 'Y',
        value_set => 'FND_NUMBER',
        default_type => NULL,
        default_value => NULL,
        required => 'N',
        security_enabled => 'N',
        display_size => 25,
        description_size => 50,
        concatenated_description_size => 50,
        list_of_values_prompt => 'Transport Over-Cap Penalty',
        window_prompt => 'Transport Over-Cap Penalty',
        range => NULL,
        srw_parameter => NULL);

    update fnd_profile_option_values
    set profile_option_value = to_char(org_attr4)
    where application_id = 723
    and level_id = 10001
    and profile_option_id = (select profile_option_id
		from fnd_profile_options
		where application_id = 723
		and  profile_option_name = 'MSO_ORG_TRSP_PENALTY');

     END IF;

  END IF;  -- org_attr4 is not null


  IF dept_attr1 IS NOT NULL THEN

        fnd_flex_dsc_api.enable_context('BOM',
                         'BOM_DEPARTMENT_RESOURCES',
                         'Global Data Elements',
                         TRUE);


    IF fnd_flex_dsc_api.is_column_used(
		p_application_id => '702',
		p_table_name => 'BOM_DEPARTMENT_RESOURCES',
		p_column_name => 'ATTRIBUTE'||to_char(dept_attr1),
		x_message => msgbuf) = TRUE THEN

        FND_MESSAGE.set_name('MSC','MSC_ATTRIBUTE_EXISTS');
        FND_MESSAGE.set_token('ATTRIBUTE','ATTRIBUTE'||to_char(dept_attr1));
        FND_MESSAGE.set_token('TABLE','BOM_DEPARTMENT_RESOURCES');
        msgbuf := FND_MESSAGE.get;
        LOG_MESSAGE(msgbuf);

    ELSIF fnd_flex_dsc_api.segment_exists(
	p_appl_short_name=>'BOM',
	p_flexfield_name=>'BOM_DEPARTMENT_RESOURCES',
	p_context_code=>'Global Data Elements',
	p_segment_name=>'Aggregate Resource') = TRUE THEN

        FND_MESSAGE.set_name('MSC','MSC_SEGMENT_EXISTS');
        FND_MESSAGE.set_token('SEGMENT','Aggregate Resource');
        FND_MESSAGE.set_token('TABLE','BOM_DEPARTMENT_RESOURCES');
        msgbuf := FND_MESSAGE.get;
        LOG_MESSAGE(msgbuf);

    ELSE

        fnd_flex_dsc_api.create_segment(
        appl_short_name => 'BOM',
        flexfield_name => 'BOM_DEPARTMENT_RESOURCES',
        context_name => 'Global Data Elements',
        name => 'Aggregate Resource',
        column => 'ATTRIBUTE'|| to_char(dept_attr1),
        description => 'Aggregate Resource Name',
        sequence_number => 10,
        enabled => 'Y',
        displayed => 'Y',
        value_set => 'MSC_AGGREGATE_RESOURCE',
        default_type => NULL,
        default_value => NULL,
        required => 'N',
        security_enabled => 'N',
        display_size => 25,
        description_size => 50,
        concatenated_description_size => 50,
        list_of_values_prompt => 'Aggregate Resource',
        window_prompt => 'Aggregate Resource',
        range => NULL,
        srw_parameter => NULL);

    update fnd_profile_option_values
    set profile_option_value = to_char(dept_attr1)
    where application_id = 724
    and level_id = 10001
    and profile_option_id = (select profile_option_id
		from fnd_profile_options
		where application_id = 724
		and  profile_option_name = 'MSC_AGGREG_RES_NAME');

     END IF;

  END IF; -- dept_attr1 is not null


/*	IF fnd_flex_dsc_api.segment_exists(
		p_appl_short_name => 'BOM',
		p_flexfield_name => 'BOM_DEPARTMENT_RESOURCES',
		p_context_code => 'Global Data Elements',
		p_segment_name => NULL,
		p_column_name => 'ATTRIBUTE'||to_char(dept_attr2)) = TRUE THEN
*/

  IF dept_attr2 IS NOT NULL THEN

    IF fnd_flex_dsc_api.is_column_used(
		p_application_id => '702',
		p_table_name => 'BOM_DEPARTMENT_RESOURCES',
		p_column_name => 'ATTRIBUTE'||to_char(dept_attr2),
		x_message => msgbuf) = TRUE THEN

        FND_MESSAGE.set_name('MSC','MSC_ATTRIBUTE_EXISTS');
        FND_MESSAGE.set_token('ATTRIBUTE','ATTRIBUTE'||to_char(dept_attr2));
        FND_MESSAGE.set_token('TABLE','BOM_DEPARTMENT_RESOURCES');
        msgbuf := FND_MESSAGE.get;
        LOG_MESSAGE(msgbuf);

    ELSIF fnd_flex_dsc_api.segment_exists(
	p_appl_short_name=>'BOM',
	p_flexfield_name=>'BOM_DEPARTMENT_RESOURCES',
	p_context_code=>'Global Data Elements',
	p_segment_name=>'Resource Over-Capacity Penalty') = TRUE THEN

        FND_MESSAGE.set_name('MSC','MSC_SEGMENT_EXISTS');
        FND_MESSAGE.set_token('SEGMENT','Resource Over-Capacity Penalty');
        FND_MESSAGE.set_token('TABLE','BOM_DEPARTMENT_RESOURCES');
        msgbuf := FND_MESSAGE.get;
        LOG_MESSAGE(msgbuf);

    ELSE

        fnd_flex_dsc_api.create_segment(
        appl_short_name => 'BOM',
        flexfield_name => 'BOM_DEPARTMENT_RESOURCES',
        context_name => 'Global Data Elements',
        name => 'Resource Over-Capacity Penalty',
        column => 'ATTRIBUTE'|| to_char(dept_attr2),
        description => 'Penalty Cost Factor for Exceeding Resource Capacity',
        sequence_number => 20,
        enabled => 'Y',
        displayed => 'Y',
        value_set => 'FND_NUMBER',
        default_type => NULL,
        default_value => NULL,
        required => 'N',
        security_enabled => 'N',
        display_size => 25,
        description_size => 50,
        concatenated_description_size => 50,
        list_of_values_prompt => 'Resource Over-Capacity Penalty',
        window_prompt => 'Resource Over-Capacity Penalty',
        range => NULL,
        srw_parameter => NULL);

    update fnd_profile_option_values
    set profile_option_value = to_char(dept_attr2)
    where application_id = 723
    and level_id = 10001
    and profile_option_id = (select profile_option_id
		from fnd_profile_options
		where application_id = 723
		and  profile_option_name = 'MSO_RES_PENALTY');

     END IF;

  END IF;  --  dept_attr2 is not null


  IF supp_attr1 IS NOT NULL THEN

	  fnd_flex_dsc_api.enable_context('PO',
                         'PO_ASL_ATTRIBUTES',
                         'Global Data Elements',
                         TRUE);

    IF fnd_flex_dsc_api.is_column_used(
		p_application_id => '201',
		p_table_name => 'PO_ASL_ATTRIBUTES',
		p_column_name => 'ATTRIBUTE'||to_char(supp_attr1),
		x_message => msgbuf) = TRUE THEN

        FND_MESSAGE.set_name('MSC','MSC_ATTRIBUTE_EXISTS');
        FND_MESSAGE.set_token('ATTRIBUTE','ATTRIBUTE'||to_char(supp_attr1));
        FND_MESSAGE.set_token('TABLE','PO_ASL_ATTRIBUTES');
        msgbuf := FND_MESSAGE.get;
        LOG_MESSAGE(msgbuf);

    ELSIF fnd_flex_dsc_api.segment_exists(
	p_appl_short_name=>'PO',
	p_flexfield_name=>'PO_ASL_ATTRIBUTES',
	p_context_code=>'Global Data Elements',
	p_segment_name=>'Material Over-Capacity Penalty') = TRUE THEN

        FND_MESSAGE.set_name('MSC','MSC_SEGMENT_EXISTS');
        FND_MESSAGE.set_token('SEGMENT','Material Over-Capacity Penalty');
        FND_MESSAGE.set_token('TABLE','PO_ASL_ATTRIBUTES');
        msgbuf := FND_MESSAGE.get;
        LOG_MESSAGE(msgbuf);

    ELSE

        fnd_flex_dsc_api.create_segment(
        appl_short_name => 'PO',
        flexfield_name => 'PO_ASL_ATTRIBUTES',
        context_name => 'Global Data Elements',
        name => 'Material Over-Capacity Penalty',
        column => 'ATTRIBUTE'|| to_char(supp_attr1),
        description => 'Penalty Cost Factor for Exceeding Material Capacity',
        sequence_number => 10,
        enabled => 'Y',
        displayed => 'Y',
        value_set => 'FND_NUMBER',
        default_type => NULL,
        default_value => NULL,
        required => 'N',
        security_enabled => 'N',
        display_size => 25,
        description_size => 50,
        concatenated_description_size => 50,
        list_of_values_prompt => 'Material Over-Capacity Penalty',
        window_prompt => 'Material Over-Capacity Penalty',
        range => NULL,
        srw_parameter => NULL);

    update fnd_profile_option_values
    set profile_option_value = to_char(supp_attr1)
    where application_id = 723
    and level_id = 10001
    and profile_option_id = (select profile_option_id
		from fnd_profile_options
		where application_id = 723
		and  profile_option_name = 'MSO_SUP_CAP_PENALTY');

     END IF;

  END IF; -- supp_attr1 is not null


  IF subst_attr1 IS NOT NULL THEN

        fnd_flex_dsc_api.enable_context('BOM',
                         'BOM_SUBSTITUTE_COMPONENTS',
                         'Global Data Elements',
                         TRUE);


    IF fnd_flex_dsc_api.is_column_used(
		p_application_id => '702',
		p_table_name => 'BOM_SUBSTITUTE_COMPONENTS',
		p_column_name => 'ATTRIBUTE'||to_char(subst_attr1),
		x_message => msgbuf) = TRUE THEN

        FND_MESSAGE.set_name('MSC','MSC_ATTRIBUTE_EXISTS');
        FND_MESSAGE.set_token('ATTRIBUTE','ATTRIBUTE'||to_char(subst_attr1));
        FND_MESSAGE.set_token('TABLE','BOM_SUBSTITUTE_COMPONENTS');
        msgbuf := FND_MESSAGE.get;
        LOG_MESSAGE(msgbuf);

    ELSIF fnd_flex_dsc_api.segment_exists(
	p_appl_short_name=>'BOM',
	p_flexfield_name=>'BOM_SUBSTITUTE_COMPONENTS',
	p_context_code=>'Global Data Elements',
	p_segment_name=>'Substitute Priority') = TRUE THEN

        FND_MESSAGE.set_name('MSC','MSC_SEGMENT_EXISTS');
        FND_MESSAGE.set_token('SEGMENT','Substitute Priority');
        FND_MESSAGE.set_token('TABLE','BOM_SUBSTITUTE_COMPONENTS');
        msgbuf := FND_MESSAGE.get;
        LOG_MESSAGE(msgbuf);

    ELSE

       fnd_flex_dsc_api.create_segment(
        appl_short_name => 'BOM',
        flexfield_name => 'BOM_SUBSTITUTE_COMPONENTS',
        context_name => 'Global Data Elements',
        name => 'Substitute Priority',
        column => 'ATTRIBUTE'|| to_char(subst_attr1),
        description => 'Priority for Substitute Items',
        sequence_number => 10,
        enabled => 'Y',
        displayed => 'Y',
        value_set => 'FND_NUMBER',
        default_type => NULL,
        default_value => NULL,
        required => 'N',
        security_enabled => 'N',
        display_size => 25,
        description_size => 50,
        concatenated_description_size => 50,
        list_of_values_prompt => 'Substitute Priority',
        window_prompt => 'Substitute Priority',
        range => NULL,
        srw_parameter => NULL);

    update fnd_profile_option_values
    set profile_option_value = to_char(subst_attr1)
    where application_id = 724
    and level_id = 10001
    and profile_option_id = (select profile_option_id
		from fnd_profile_options
		where application_id = 724
		and  profile_option_name = 'MSC_BOM_SUBST_PRIORITY');

     END IF;

  END IF;  -- subst_attr1 is not null


  IF trans_attr1 IS NOT NULL THEN

        fnd_flex_dsc_api.enable_context('INV',
                         'MTL_INTERORG_SHIP_METHODS',
                         'Global Data Elements',
                         TRUE);


    IF fnd_flex_dsc_api.is_column_used(
		p_application_id => '401',
		p_table_name => 'MTL_INTERORG_SHIP_METHODS',
		p_column_name => 'ATTRIBUTE'||to_char(trans_attr1),
		x_message => msgbuf) = TRUE THEN

        FND_MESSAGE.set_name('MSC','MSC_ATTRIBUTE_EXISTS');
        FND_MESSAGE.set_token('ATTRIBUTE','ATTRIBUTE'||to_char(trans_attr1));
        FND_MESSAGE.set_token('TABLE','MTL_INTERORG_SHIP_METHODS');
        msgbuf := FND_MESSAGE.get;
        LOG_MESSAGE(msgbuf);

    ELSIF fnd_flex_dsc_api.segment_exists(
	p_appl_short_name=>'INV',
	p_flexfield_name=>'MTL_INTERORG_SHIP_METHODS',
	p_context_code=>'Global Data Elements',
	p_segment_name=>'Transport Over-Cap Penalty') = TRUE THEN

        FND_MESSAGE.set_name('MSC','MSC_SEGMENT_EXISTS');
        FND_MESSAGE.set_token('SEGMENT','Transport Over-Cap Penalty');
        FND_MESSAGE.set_token('TABLE','MTL_INTERORG_SHIP_METHODS');
        msgbuf := FND_MESSAGE.get;
        LOG_MESSAGE(msgbuf);

    ELSE

        fnd_flex_dsc_api.create_segment(
        appl_short_name => 'INV',
        flexfield_name => 'MTL_INTERORG_SHIP_METHODS',
        context_name => 'Global Data Elements',
        name => 'Transport Over-Cap Penalty',
        column => 'ATTRIBUTE'|| to_char(trans_attr1),
        description => 'Penalty Cost Factor for Exceeding Transportation Capacity',
        sequence_number => 10,
        enabled => 'Y',
        displayed => 'Y',
        value_set => 'FND_NUMBER',
        default_type => NULL,
        default_value => NULL,
        required => 'N',
        security_enabled => 'N',
        display_size => 25,
        description_size => 50,
        concatenated_description_size => 50,
        list_of_values_prompt => 'Transport Over-Cap Penalty',
        window_prompt => 'Transport Over-Cap Penalty',
        range => NULL,
        srw_parameter => NULL);

    update fnd_profile_option_values
    set profile_option_value = to_char(trans_attr1)
    where application_id = 723
    and level_id = 10001
    and profile_option_id = (select profile_option_id
		from fnd_profile_options
		where application_id = 723
		and  profile_option_name = 'MSO_TRSP_PENALTY');

     END IF;

  END IF;  -- trans_attr1 is not null


  IF bom_attr1 IS NOT NULL THEN

        fnd_flex_dsc_api.enable_context('BOM',
                         'BOM_BILL_OF_MATERIALS',
                         'Global Data Elements',
                         TRUE);


    IF fnd_flex_dsc_api.is_column_used(
		p_application_id => '702',
		p_table_name => 'BOM_BILL_OF_MATERIALS',
		p_column_name => 'ATTRIBUTE'||to_char(bom_attr1),
		x_message => msgbuf) = TRUE THEN

        FND_MESSAGE.set_name('MSC','MSC_ATTRIBUTE_EXISTS');
        FND_MESSAGE.set_token('ATTRIBUTE','ATTRIBUTE'||to_char(bom_attr1));
        FND_MESSAGE.set_token('TABLE','BOM_BILL_OF_MATERIALS');
        msgbuf := FND_MESSAGE.get;
        LOG_MESSAGE(msgbuf);

    ELSIF fnd_flex_dsc_api.segment_exists(
	p_appl_short_name=>'BOM',
	p_flexfield_name=>'BOM_BILL_OF_MATERIALS',
	p_context_code=>'Global Data Elements',
	p_segment_name=>'Cost of Using a BOM/Routing') = TRUE THEN

        FND_MESSAGE.set_name('MSC','MSC_SEGMENT_EXISTS');
        FND_MESSAGE.set_token('SEGMENT','Cost of Using a BOM/Routing');
        FND_MESSAGE.set_token('TABLE','BOM_BILL_OF_MATERIALS');
        msgbuf := FND_MESSAGE.get;
        LOG_MESSAGE(msgbuf);

    ELSE

        fnd_flex_dsc_api.create_segment(
        appl_short_name => 'BOM',
        flexfield_name => 'BOM_BILL_OF_MATERIALS',
        context_name => 'Global Data Elements',
        name => 'Cost of Using a BOM/Routing',
        column => 'ATTRIBUTE'|| to_char(bom_attr1),
        description => 'Cost of Using a BOM/Routing',
        sequence_number => 10,
        enabled => 'Y',
        displayed => 'Y',
        value_set => 'FND_NUMBER',
        default_type => NULL,
        default_value => NULL,
        required => 'N',
        security_enabled => 'N',
        display_size => 25,
        description_size => 50,
        concatenated_description_size => 50,
        list_of_values_prompt => 'Cost of Using a BOM/Routing',
        window_prompt => 'Cost of Using a BOM/Routing',
        range => NULL,
        srw_parameter => NULL);

    update fnd_profile_option_values
    set profile_option_value = to_char(bom_attr1)
    where application_id = 724
    and level_id = 10001
    and profile_option_id = (select profile_option_id
		from fnd_profile_options
		where application_id = 724
		and  profile_option_name = 'MSC_ALT_BOM_COST');

     END IF;

  END IF;  --bom_attr1 is not null


  IF forecast_attr1 IS NOT NULL THEN

        fnd_flex_dsc_api.enable_context('MRP',
                         'MRP_FORECAST_DATES',
                         'Global Data Elements',
                         TRUE);


    IF fnd_flex_dsc_api.is_column_used(
		p_application_id => '704',
		p_table_name => 'MRP_FORECAST_DATES',
		p_column_name => 'ATTRIBUTE'||to_char(forecast_attr1),
		x_message => msgbuf) = TRUE THEN

        FND_MESSAGE.set_name('MSC','MSC_ATTRIBUTE_EXISTS');
        FND_MESSAGE.set_token('ATTRIBUTE','ATTRIBUTE'||to_char(forecast_attr1));
        FND_MESSAGE.set_token('TABLE','MRP_FORECAST_DATES');
        msgbuf := FND_MESSAGE.get;
        LOG_MESSAGE(msgbuf);

    ELSIF fnd_flex_dsc_api.segment_exists(
	p_appl_short_name=>'MRP',
	p_flexfield_name=>'MRP_FORECAST_DATES',
	p_context_code=>'Global Data Elements',
	p_segment_name=>'Late Forecasts Penalty') = TRUE THEN

        FND_MESSAGE.set_name('MSC','MSC_SEGMENT_EXISTS');
        FND_MESSAGE.set_token('SEGMENT','Late Forecasts Penalty');
        FND_MESSAGE.set_token('TABLE','MRP_FORECAST_DATES');
        msgbuf := FND_MESSAGE.get;
        LOG_MESSAGE(msgbuf);

    ELSE

       fnd_flex_dsc_api.create_segment(
        appl_short_name => 'MRP',
        flexfield_name => 'MRP_FORECAST_DATES',
        context_name => 'Global Data Elements',
        name => 'Late Forecasts Penalty',
        column => 'ATTRIBUTE'|| to_char(forecast_attr1),
        description => 'Penalty Cost Factor for Late Forecasts',
        sequence_number => 10,
        enabled => 'Y',
        displayed => 'Y',
        value_set => 'FND_NUMBER',
        default_type => NULL,
        default_value => NULL,
        required => 'N',
        security_enabled => 'N',
        display_size => 25,
        description_size => 50,
        concatenated_description_size => 50,
        list_of_values_prompt => 'Late Forecasts Penalty',
        window_prompt => 'Late Forecasts Penalty',
        range => NULL,
        srw_parameter => NULL);

    update fnd_profile_option_values
    set profile_option_value = to_char(forecast_attr1)
    where application_id = 723
    and level_id = 10001
    and profile_option_id = (select profile_option_id
		from fnd_profile_options
		where application_id = 723
		and  profile_option_name = 'MSO_FCST_PENALTY');

     END IF;

  END IF;   -- forecast_attr1 is not null


  IF line_attr1 IS NOT NULL THEN

     fnd_flex_dsc_api.enable_context('WIP',
                         'WIP_LINES',
                         'Global Data Elements',
                         TRUE);

    IF fnd_flex_dsc_api.is_column_used(
		p_application_id => '706',
		p_table_name => 'WIP_LINES',
		p_column_name => 'ATTRIBUTE'||to_char(line_attr1),
		x_message => msgbuf) = TRUE THEN

        FND_MESSAGE.set_name('MSC','MSC_ATTRIBUTE_EXISTS');
        FND_MESSAGE.set_token('ATTRIBUTE','ATTRIBUTE'||to_char(line_attr1));
        FND_MESSAGE.set_token('TABLE','WIP_LINES');
        msgbuf := FND_MESSAGE.get;
        LOG_MESSAGE(msgbuf);

    ELSIF fnd_flex_dsc_api.segment_exists(
	p_appl_short_name=>'WIP',
	p_flexfield_name=>'WIP_LINES',
	p_context_code=>'Global Data Elements',
	p_segment_name=>'Resource Group') = TRUE THEN

        FND_MESSAGE.set_name('MSC','MSC_SEGMENT_EXISTS');
        FND_MESSAGE.set_token('SEGMENT','Resource Group');
        FND_MESSAGE.set_token('TABLE','WIP_LINES');
        msgbuf := FND_MESSAGE.get;
        LOG_MESSAGE(msgbuf);

    ELSE

        fnd_flex_dsc_api.create_segment(
        appl_short_name => 'WIP',
        flexfield_name => 'WIP_LINES',
        context_name => 'Global Data Elements',
        name => 'Resource Group',
        column => 'ATTRIBUTE'|| to_char(line_attr1),
        description => 'Resource Group',
        sequence_number => 30,
        enabled => 'Y',
        displayed => 'Y',
        value_set => 'FND_NUMBER',
        default_type => NULL,
        default_value => NULL,
        required => 'N',
        security_enabled => 'N',
        display_size => 25,
        description_size => 50,
        concatenated_description_size => 50,
        list_of_values_prompt => 'Resource Group',
        window_prompt => 'Resource Group',
        range => NULL,
        srw_parameter => NULL);

    update fnd_profile_option_values
    set profile_option_value = to_char(line_attr1)
    where application_id = 724
    and level_id = 10001
    and profile_option_id = (select profile_option_id
		from fnd_profile_options
		where application_id = 724
		and  profile_option_name = 'MSC_LINE_RES_GROUP');

     END IF;

  END IF;  --line_attr1 is not null

  if schedule_attr1 is not null then
    fnd_flex_dsc_api.enable_context('MRP',
                         'MRP_SCHEDULE_DATES',
                         'Global Data Elements',
                         TRUE);
    IF fnd_flex_dsc_api.is_column_used(
		p_application_id => '704',
		p_table_name => 'MRP_SCHEDULE_DATES',
		p_column_name => 'ATTRIBUTE'||to_char(schedule_attr1),
		x_message => msgbuf) = TRUE THEN

        FND_MESSAGE.set_name('MSC','MSC_ATTRIBUTE_EXISTS');
        FND_MESSAGE.set_token('ATTRIBUTE','ATTRIBUTE'||to_char(schedule_attr1));
        FND_MESSAGE.set_token('TABLE','MRP_SCHEDULE_DATES');
        msgbuf := FND_MESSAGE.get;
        LOG_MESSAGE(msgbuf);
    ELSIF fnd_flex_dsc_api.segment_exists(
	p_appl_short_name=>'MRP',
	p_flexfield_name=>'MRP_SCHEDULE_DATES',
	p_context_code=>'Global Data Elements',
	p_segment_name=>'Demand Priority') = TRUE THEN

        FND_MESSAGE.set_name('MSC','MSC_SEGMENT_EXISTS');
        FND_MESSAGE.set_token('SEGMENT','Demand Priority');
        FND_MESSAGE.set_token('TABLE','MRP_SCHEDULE_DATES');
        msgbuf := FND_MESSAGE.get;
        LOG_MESSAGE(msgbuf);

    ELSE
        fnd_flex_dsc_api.create_segment(
        appl_short_name => 'MRP',
        flexfield_name => 'MRP_SCHEDULE_DATES',
        context_name => 'Global Data Elements',
        name => 'Demand Priority',
        column => 'ATTRIBUTE'|| to_char(schedule_attr1),
        description => 'Demand Priority',
        sequence_number => 10,
        enabled => 'Y',
        displayed => 'Y',
        value_set => 'FND_NUMBER',
        default_type => NULL,
        default_value => NULL,
        required => 'N',
        security_enabled => 'N',
        display_size => 25,
        description_size => 50,
        concatenated_description_size => 50,
        list_of_values_prompt => 'Demand Priority',
        window_prompt => 'Demand Priority',
        range => NULL,
        srw_parameter => NULL);

        update fnd_profile_option_values
           set profile_option_value = to_char(schedule_attr1)
           where application_id = 704
           and level_id = 10001
           and profile_option_id = (select profile_option_id
		from fnd_profile_options
		where application_id = 704
		and  profile_option_name = 'MRP_DMD_PRIORITY_FLEX_NUM');

    END IF;
  end if; --schedule_attr1 is not null

    COMMIT;
    -- this commit is required so that the conc requests will see this data
    -- we need to submit concurrent requests to recompile flex views

    req_id := fnd_request.submit_request(
                'FND', 'FDFVGN', '', '', FALSE,
                '3', 401,
                'MTL_SYSTEM_ITEMS');
    IF (req_id = 0) THEN
      raise conc_failure;
    END IF;

    req_id := fnd_request.submit_request(
                'FND', 'FDFVGN', '', '', FALSE,
                '3', 401,
                'MTL_PARAMETERS');
    IF (req_id = 0) THEN
      raise conc_failure;
    END IF;

    req_id := fnd_request.submit_request(
                'FND', 'FDFVGN', '', '', FALSE,
                '3', 702,
                'BOM_DEPARTMENT_RESOURCES');
    IF (req_id = 0) THEN
      raise conc_failure;
    END IF;

    req_id := fnd_request.submit_request(
                'FND', 'FDFVGN', '', '', FALSE,
                '3', 201,
                'PO_ASL_ATTRIBUTES');
    IF (req_id = 0) THEN
      raise conc_failure;
    END IF;

    req_id := fnd_request.submit_request(
                'FND', 'FDFVGN', '', '', FALSE,
                '3', 702,
                'BOM_SUBSTITUTE_COMPONENTS');
    IF (req_id = 0) THEN
      raise conc_failure;
    END IF;


    req_id := fnd_request.submit_request(
                'FND', 'FDFVGN', '', '', FALSE,
                '3', 401,
                'MTL_INTERORG_SHIP_METHODS');
    IF (req_id = 0) THEN
      raise conc_failure;
    END IF;


    req_id := fnd_request.submit_request(
                'FND', 'FDFVGN', '', '', FALSE,
                '3', 702,
                'BOM_BILL_OF_MATERIALS');
    IF (req_id = 0) THEN
      raise conc_failure;
    END IF;


    req_id := fnd_request.submit_request(
                'FND', 'FDFVGN', '', '', FALSE,
                '3', 704,
                'MRP_FORECAST_DATES');
    IF (req_id = 0) THEN
      raise conc_failure;
    END IF;

    req_id := fnd_request.submit_request(
                'FND', 'FDFVGN', '', '', FALSE,
                '3', 706,
                'WIP_LINES');
    IF (req_id = 0) THEN
      raise conc_failure;
    END IF;


    req_id := fnd_request.submit_request(
                'FND', 'FDFVGN', '', '', FALSE,
                '3', 704,
                'MRP_SCHEDULE_DATES');
    IF (req_id = 0) THEN
      raise conc_failure;
    END IF;

    COMMIT;
    errbuf := 'Created flexfields, updates profile values and submitted requests to recompile flexfields';
    retcode := 0; -- success
EXCEPTION
   WHEN conc_failure THEN
     errbuf := 'Error ' ||
                  substr(fnd_message.get,1,240);
     retcode := 2;
   WHEN OTHERS THEN
   rollback;
    if (fnd_flex_dsc_api.message is null) then
      errbuf := 'Sql Error:' || to_char(sqlcode);
    else
      errbuf := fnd_flex_dsc_api.message;
    end if;
    retcode := 2; -- failure
END Configure;

PROCEDURE Configure_strn_flex(
	ERRBUF      	OUT NOCOPY VARCHAR2,
	RETCODE     	OUT NOCOPY NUMBER,
	oper_attr1      IN  NUMBER)
AS

	req_id 		NUMBER;
	conc_failure 	EXCEPTION;

	msgbuf		VARCHAR2(2000);

BEGIN

   fnd_flex_dsc_api.debug_on;
   fnd_flex_dsc_api.set_session_mode('seed_data');

   fnd_flex_dsc_api.enable_context('BOM',
                         'OPERATION_RESOURCES',
                         'Global Data Elements',
                         TRUE);

    IF
       fnd_flex_dsc_api.is_column_used(
                        p_application_id => '702',
                        p_table_name => 'OPERATION_RESOURCES',
                        p_column_name => 'ATTRIBUTE'||to_char(oper_attr1),
                        x_message => msgbuf) = TRUE THEN

        FND_MESSAGE.set_name('MSC','MSC_ATTRIBUTE_EXISTS');
        FND_MESSAGE.set_token('ATTRIBUTE','ATTRIBUTE'||to_char(oper_attr1));
        FND_MESSAGE.set_token('TABLE','OPERATION_RESOURCES');
        msgbuf := FND_MESSAGE.get;
        LOG_MESSAGE(msgbuf);
    ELSIF
       fnd_flex_dsc_api.segment_exists(
	p_appl_short_name=>'BOM',
	p_flexfield_name=>'OPERATION_RESOURCES',
	p_context_code=>'Global Data Elements',
	p_segment_name=>'Activity Group Id') = TRUE THEN
        FND_MESSAGE.set_name('MSC','MSC_SEGMENT_EXISTS');
        FND_MESSAGE.set_token('SEGMENT','Activity Group Id');
        FND_MESSAGE.set_token('TABLE','OPERATION_RESOURCES');
        msgbuf := FND_MESSAGE.get;
        LOG_MESSAGE(msgbuf);
    ELSE
        fnd_flex_dsc_api.create_segment(
        appl_short_name => 'BOM',
        flexfield_name => 'OPERATION_RESOURCES',
        context_name => 'Global Data Elements',
        name => 'Activity Group Id',
        column => 'ATTRIBUTE'|| to_char(oper_attr1),
        description => 'Activity Group Id for Setup and Run Operation',
        sequence_number => 150,
        enabled => 'Y',
        displayed => 'Y',
        value_set => 'FND_NUMBER',
        default_type => NULL,
        default_value => NULL,
        required => 'N',
        security_enabled => 'N',
        display_size => 25,
        description_size => 50,
        concatenated_description_size => 50,
        list_of_values_prompt => 'Activity Group Id',
        window_prompt => 'Activity Group Id',
        range => NULL,
        srw_parameter => NULL);
     END IF;


    fnd_flex_dsc_api.enable_context('BOM',
                         'SUB_OPERATION_RESOURCES',
                         'Global Data Elements',
                         TRUE);
 -- fix for Bug 2748600
    IF
       fnd_flex_dsc_api.segment_exists(
        p_appl_short_name=>'BOM',
        p_flexfield_name=>'SUB_OPERATION_RESOURCES',
        p_context_code=>'Global Data Elements',
        p_segment_name=>'Activity Grp Id - Alt Resource') = TRUE THEN
        fnd_flex_dsc_api.delete_segment(
        appl_short_name => 'BOM',
        flexfield_name => 'SUB_OPERATION_RESOURCES',
        context => 'Global Data Elements',
        segment => 'Activity Grp Id - Alt Resource');
     END IF;


   COMMIT;

    req_id := fnd_request.submit_request(
                'FND', 'FDFVGN', '', '', FALSE,
                '3', 702,
                'OPERATION_RESOURCES');

/*
    req_id := fnd_request.submit_request(
                'FND', 'FDFVGN', '', '', FALSE,
                '3', 702,
                'SUB_OPERATION_RESOURCES');
*/

    IF (req_id = 0) THEN
      raise conc_failure;
    END IF;

    COMMIT;
    errbuf := 'Created flexfields - submitted requests to recompile flexfields';
    retcode := 0; -- success

EXCEPTION

   WHEN conc_failure THEN
     errbuf := 'Error ' ||
                  substr(fnd_message.get,1,240);
     retcode := 2;

   WHEN OTHERS THEN
   rollback;
    if (fnd_flex_dsc_api.message is null) then
      errbuf := 'Sql Error:' || to_char(sqlcode);
    else
      errbuf := fnd_flex_dsc_api.message;
    end if;
    retcode := 2; -- failure

END Configure_strn_flex;

PROCEDURE Configure_reba_flex(
        ERRBUF          OUT NOCOPY VARCHAR2,
        RETCODE         OUT NOCOPY NUMBER,
        bom_attr1       IN NUMBER,
	bom_attr2       IN NUMBER,
 	bom_attr3	IN NUMBER,
	bom_attr4	IN NUMBER,
	bom_attr5	IN NUMBER)

as

        req_id          NUMBER;
        conc_failure    EXCEPTION;

        msgbuf          VARCHAR2(2000);

Begin

   fnd_flex_dsc_api.debug_on;
   fnd_flex_dsc_api.set_session_mode('seed_data');

   fnd_flex_dsc_api.enable_context('BOM',
                         'BOM_DEPARTMENT_RESOURCES',
                         'Global Data Elements',
                         TRUE);

    IF
       fnd_flex_dsc_api.is_column_used(
                        p_application_id => '702',
                        p_table_name => 'BOM_DEPARTMENT_RESOURCES',
                        p_column_name => 'ATTRIBUTE'||to_char(bom_attr1),
                        x_message => msgbuf) = TRUE THEN

        FND_MESSAGE.set_name('MSC','MSC_ATTRIBUTE_EXISTS');
        FND_MESSAGE.set_token('ATTRIBUTE','ATTRIBUTE'||to_char(bom_attr1));
        FND_MESSAGE.set_token('TABLE','BOM_DEPARTMENT_RESOURCES');
        msgbuf := FND_MESSAGE.get;
        LOG_MESSAGE(msgbuf);
    ELSIF
       fnd_flex_dsc_api.segment_exists(
        p_appl_short_name=>'BOM',
        p_flexfield_name=>'BOM_DEPARTMENT_RESOURCES',
        p_context_code=>'Global Data Elements',
        p_segment_name=>'Batchable Flag') = TRUE THEN
        FND_MESSAGE.set_name('MSC','MSC_SEGMENT_EXISTS');
        FND_MESSAGE.set_token('SEGMENT','Batchable Flag');
        FND_MESSAGE.set_token('TABLE','BOM_DEPARTMENT_RESOURCES');
        msgbuf := FND_MESSAGE.get;
        LOG_MESSAGE(msgbuf);
    ELSE
        fnd_flex_dsc_api.create_segment(
        appl_short_name => 'BOM',
        flexfield_name => 'BOM_DEPARTMENT_RESOURCES',
        context_name => 'Global Data Elements',
        name => 'Batchable Flag',
        column => 'ATTRIBUTE'|| to_char(bom_attr1),
        description => 'Batchable Flag',
        sequence_number => 150,
        enabled => 'Y',
        displayed => 'Y',
        value_set => 'MSC_SRS_SYS_YES_NO',
        default_type => NULL,
        default_value => NULL,
        required => 'N',
        security_enabled => 'N',
        display_size => 25,
        description_size => 50,
        concatenated_description_size => 50,
        list_of_values_prompt => 'Batchable Flag',
        window_prompt => 'Batchable Flag',
        range => NULL,
        srw_parameter => NULL);

	update fnd_profile_option_values
           set profile_option_value = to_char(bom_attr1)
           where application_id = 724
           and level_id = 10001
           and profile_option_id = (select profile_option_id
                from fnd_profile_options
                where application_id = 724
                and  profile_option_name = 'MSC_BATCHABLE_FLAG');

    END IF;

    COMMIT;


    IF
       fnd_flex_dsc_api.is_column_used(
                        p_application_id => '702',
                        p_table_name => 'BOM_DEPARTMENT_RESOURCES',
                        p_column_name => 'ATTRIBUTE'||to_char(bom_attr2),
                        x_message => msgbuf) = TRUE THEN

        FND_MESSAGE.set_name('MSC','MSC_ATTRIBUTE_EXISTS');
        FND_MESSAGE.set_token('ATTRIBUTE','ATTRIBUTE'||to_char(bom_attr2));
        FND_MESSAGE.set_token('TABLE','BOM_DEPARTMENT_RESOURCES');
        msgbuf := FND_MESSAGE.get;
        LOG_MESSAGE(msgbuf);
    ELSIF
       fnd_flex_dsc_api.segment_exists(
        p_appl_short_name=>'BOM',
        p_flexfield_name=>'BOM_DEPARTMENT_RESOURCES',
        p_context_code=>'Global Data Elements',
        p_segment_name=>'Batching Window') = TRUE THEN
        FND_MESSAGE.set_name('MSC','MSC_SEGMENT_EXISTS');
        FND_MESSAGE.set_token('SEGMENT','Batching Window');
        FND_MESSAGE.set_token('TABLE','BOM_DEPARTMENT_RESOURCES');
        msgbuf := FND_MESSAGE.get;
        LOG_MESSAGE(msgbuf);
    ELSE
        fnd_flex_dsc_api.create_segment(
        appl_short_name => 'BOM',
        flexfield_name => 'BOM_DEPARTMENT_RESOURCES',
        context_name => 'Global Data Elements',
        name => 'Batching Window',
        column => 'ATTRIBUTE'||to_char(bom_attr2),
        description => 'Batching Window',
        sequence_number => 160,
        enabled => 'Y',
        displayed => 'Y',
        value_set => 'MSC_SRS_DECIMAL',
        default_type => NULL,
        default_value => NULL,
        required => 'N',
        security_enabled => 'N',
        display_size => 25,
        description_size => 50,
        concatenated_description_size => 50,
        list_of_values_prompt => 'Batching Window',
        window_prompt => 'Batching Window',
        range => NULL,
        srw_parameter => NULL);

      update fnd_profile_option_values
           set profile_option_value = to_char(bom_attr2)
           where application_id = 724
           and level_id = 10001
           and profile_option_id = (select profile_option_id
                from fnd_profile_options
                where application_id = 724
                and  profile_option_name = 'MSC_BATCHING_WINDOW');

    END IF;
    COMMIT;

    IF
       fnd_flex_dsc_api.is_column_used(
                        p_application_id => '702',
                        p_table_name => 'BOM_DEPARTMENT_RESOURCES',
                        p_column_name => 'ATTRIBUTE'||to_char(bom_attr3),
                        x_message => msgbuf) = TRUE THEN

        FND_MESSAGE.set_name('MSC','MSC_ATTRIBUTE_EXISTS');
        FND_MESSAGE.set_token('ATTRIBUTE','ATTRIBUTE'||to_char(bom_attr3));
        FND_MESSAGE.set_token('TABLE','BOM_DEPARTMENT_RESOURCES');
        msgbuf := FND_MESSAGE.get;
        LOG_MESSAGE(msgbuf);
    ELSIF
       fnd_flex_dsc_api.segment_exists(
        p_appl_short_name=>'BOM',
        p_flexfield_name=>'BOM_DEPARTMENT_RESOURCES',
        p_context_code=>'Global Data Elements',
        p_segment_name=>'Minimum Batch Capacity') = TRUE THEN
        FND_MESSAGE.set_name('MSC','MSC_SEGMENT_EXISTS');
        FND_MESSAGE.set_token('SEGMENT','Minimum Batch Capacity');
        FND_MESSAGE.set_token('TABLE','BOM_DEPARTMENT_RESOURCES');
        msgbuf := FND_MESSAGE.get;
        LOG_MESSAGE(msgbuf);
    ELSE
        fnd_flex_dsc_api.create_segment(
        appl_short_name => 'BOM',
        flexfield_name => 'BOM_DEPARTMENT_RESOURCES',
        context_name => 'Global Data Elements',
        name => 'Minimum Batch Capacity',
        column => 'ATTRIBUTE'||to_char(bom_attr3),
        description => 'Minimum Batch Capacity',
        sequence_number => 170,
        enabled => 'Y',
        displayed => 'Y',
        value_set => 'MSC_SRS_DECIMAL',
        default_type => NULL,
        default_value => NULL,
        required => 'N',
        security_enabled => 'N',
        display_size => 25,
        description_size => 50,
        concatenated_description_size => 50,
        list_of_values_prompt => 'Minimum Batch Capacity',
        window_prompt => 'Minimum Batch Capacity',
        range => NULL,
        srw_parameter => NULL);

      update fnd_profile_option_values
           set profile_option_value = to_char(bom_attr3)
           where application_id = 724
           and level_id = 10001
           and profile_option_id = (select profile_option_id
                from fnd_profile_options
                where application_id = 724
                and  profile_option_name = 'MSC_MIN_CAPACITY');

    END IF;
    COMMIT;

    IF
       fnd_flex_dsc_api.is_column_used(
                        p_application_id => '702',
                        p_table_name => 'BOM_DEPARTMENT_RESOURCES',
                        p_column_name => 'ATTRIBUTE'||to_char(bom_attr4),
                        x_message => msgbuf) = TRUE THEN

        FND_MESSAGE.set_name('MSC','MSC_ATTRIBUTE_EXISTS');
        FND_MESSAGE.set_token('ATTRIBUTE','ATTRIBUTE'||to_char(bom_attr4));
        FND_MESSAGE.set_token('TABLE','BOM_DEPARTMENT_RESOURCES');
        msgbuf := FND_MESSAGE.get;
        LOG_MESSAGE(msgbuf);
    ELSIF
       fnd_flex_dsc_api.segment_exists(
        p_appl_short_name=>'BOM',
        p_flexfield_name=>'BOM_DEPARTMENT_RESOURCES',
        p_context_code=>'Global Data Elements',
        p_segment_name=>'Maximum Batch Capacity') = TRUE THEN
        FND_MESSAGE.set_name('MSC','MSC_SEGMENT_EXISTS');
        FND_MESSAGE.set_token('SEGMENT','Maximum Batch Capacity');
        FND_MESSAGE.set_token('TABLE','BOM_DEPARTMENT_RESOURCES');
        msgbuf := FND_MESSAGE.get;
        LOG_MESSAGE(msgbuf);
    ELSE
        fnd_flex_dsc_api.create_segment(
        appl_short_name => 'BOM',
        flexfield_name => 'BOM_DEPARTMENT_RESOURCES',
        context_name => 'Global Data Elements',
        name => 'Maximum Batch Capacity',
        column => 'ATTRIBUTE'||to_char(bom_attr4),
        description => 'Maximum Capacity',
        sequence_number => 180,
        enabled => 'Y',
        displayed => 'Y',
        value_set => 'MSC_SRS_DECIMAL',
        default_type => NULL,
        default_value => NULL,
        required => 'N',
        security_enabled => 'N',
        display_size => 25,
        description_size => 50,
        concatenated_description_size => 50,
        list_of_values_prompt => 'Maximum Batch Capacity',
        window_prompt => 'Maximum Batch Capacity',
        range => NULL,
        srw_parameter => NULL);

     update fnd_profile_option_values
           set profile_option_value = to_char(bom_attr4)
           where application_id = 724
           and level_id = 10001
           and profile_option_id = (select profile_option_id
                from fnd_profile_options
                where application_id = 724
                and  profile_option_name = 'MSC_MAX_CAPACITY');

    END IF;
    COMMIT;

    IF
       fnd_flex_dsc_api.is_column_used(
                        p_application_id => '702',
                        p_table_name => 'BOM_DEPARTMENT_RESOURCES',
                        p_column_name => 'ATTRIBUTE'||to_char(bom_attr5),
                        x_message => msgbuf) = TRUE THEN

        FND_MESSAGE.set_name('MSC','MSC_ATTRIBUTE_EXISTS');
        FND_MESSAGE.set_token('ATTRIBUTE','ATTRIBUTE'||to_char(bom_attr5));
        FND_MESSAGE.set_token('TABLE','BOM_DEPARTMENT_RESOURCES');
        msgbuf := FND_MESSAGE.get;
        LOG_MESSAGE(msgbuf);
    ELSIF
       fnd_flex_dsc_api.segment_exists(
        p_appl_short_name=>'BOM',
        p_flexfield_name=>'BOM_DEPARTMENT_RESOURCES',
        p_context_code=>'Global Data Elements',
        p_segment_name=>'Batchable Unit of Measure') = TRUE THEN
        FND_MESSAGE.set_name('MSC','MSC_SEGMENT_EXISTS');
        FND_MESSAGE.set_token('SEGMENT','Batchable Unit of Measure');
        FND_MESSAGE.set_token('TABLE','BOM_DEPARTMENT_RESOURCES');
        msgbuf := FND_MESSAGE.get;
        LOG_MESSAGE(msgbuf);
    ELSE
        fnd_flex_dsc_api.create_segment(
        appl_short_name => 'BOM',
        flexfield_name => 'BOM_DEPARTMENT_RESOURCES',
        context_name => 'Global Data Elements',
        name => 'Batchable Unit of Measure',
        column => 'ATTRIBUTE'||to_char(bom_attr5),
        description => 'Batchable Unit of Measure',
        sequence_number => 190,
        enabled => 'Y',
        displayed => 'Y',
        value_set => 'MSC_SRS_UNIT_OF_MEASURE',
        default_type => NULL,
        default_value => NULL,
        required => 'N',
        security_enabled => 'N',
        display_size => 25,
        description_size => 50,
        concatenated_description_size => 50,
        list_of_values_prompt => 'Batchable Unit Of Measure',
        window_prompt => 'Batchable Unit of Measure',
        range => NULL,
        srw_parameter => NULL);

     update fnd_profile_option_values
           set profile_option_value = to_char(bom_attr5)
           where application_id = 724
           and level_id = 10001
           and profile_option_id = (select profile_option_id
                from fnd_profile_options
                where application_id = 724
                and  profile_option_name = 'MSC_UNIT_OF_MEASURE');

    END IF;
    COMMIT;

  req_id := fnd_request.submit_request(
                'FND', 'FDFVGN', '', '', FALSE,
                '3', 702,
                'BOM_DEPARTMENT_RESOURCES');

    IF (req_id = 0) THEN
      raise conc_failure;
    END IF;

    COMMIT;

    errbuf := 'Created flexfields - submitted requests to recompile flexfields';
    retcode := 0; -- success

  EXCEPTION
     WHEN conc_failure THEN
        errbuf := 'Error ' ||
                  substr(fnd_message.get,1,240);
        retcode := 2;

     WHEN OTHERS THEN
        rollback;
    if (fnd_flex_dsc_api.message is null) then
      errbuf := 'Sql Error:' || to_char(sqlcode);
    else
      errbuf := fnd_flex_dsc_api.message;
    end if;
    retcode := 2; -- failure

END Configure_reba_flex;

PROCEDURE Configure_fcst_flex(
        ERRBUF          OUT NOCOPY VARCHAR2,
        RETCODE         OUT NOCOPY NUMBER,
        fcst_attr1 IN NUMBER)
 AS
        req_id          NUMBER;
        conc_failure    EXCEPTION;

        msgbuf          VARCHAR2(2000);

 BEGIN

   fnd_flex_dsc_api.debug_on;
   fnd_flex_dsc_api.set_session_mode('seed_data');

   fnd_flex_dsc_api.enable_context('MRP',
                         'MRP_FORECAST_DATES',
                         'Global Data Elements',
                         TRUE);

   IF fnd_flex_dsc_api.is_column_used(
                p_application_id => '704',
                p_table_name => 'MRP_FORECAST_DATES',
                p_column_name => 'ATTRIBUTE'||to_char(fcst_attr1),
                x_message => msgbuf) = TRUE THEN

        FND_MESSAGE.set_name('MSC','MSC_ATTRIBUTE_EXISTS');
        FND_MESSAGE.set_token('ATTRIBUTE','ATTRIBUTE'||to_char(fcst_attr1));
        FND_MESSAGE.set_token('TABLE','MRP_FORECAST_DATES');
        msgbuf := FND_MESSAGE.get;
        LOG_MESSAGE(msgbuf);

   ELSIF fnd_flex_dsc_api.segment_exists(
        p_appl_short_name=>'MRP',
        p_flexfield_name=>'MRP_FORECAST_DATES',
        p_context_code=>'Global Data Elements',
        p_segment_name=>'Forecast Priority') = TRUE THEN

        FND_MESSAGE.set_name('MSC','MSC_SEGMENT_EXISTS');
        FND_MESSAGE.set_token('SEGMENT','Forecast Priority');
        FND_MESSAGE.set_token('TABLE','MRP_FORECAST_DATES');
        msgbuf := FND_MESSAGE.get;
        LOG_MESSAGE(msgbuf);

    ELSE
        fnd_flex_dsc_api.create_segment(
        appl_short_name => 'MRP',
        flexfield_name => 'MRP_FORECAST_DATES',
        context_name => 'Global Data Elements',
        name => 'Forecast Priority',
        column => 'ATTRIBUTE'|| to_char(fcst_attr1),
        description => 'Forecast Priority',
        sequence_number => 20,
        enabled => 'Y',
        displayed => 'Y',
        value_set => 'FND_NUMBER',
        default_type => NULL,
        default_value => NULL,
        required => 'N',
        security_enabled => 'N',
        display_size => 25,
        description_size => 50,
        concatenated_description_size => 50,
        list_of_values_prompt => 'Forecast Priority',
        window_prompt => 'Forecast Priority',
        range => NULL,
        srw_parameter => NULL);

    update fnd_profile_option_values
    set profile_option_value = to_char(fcst_attr1)
    where application_id = 724
    and level_id = 10001
    and profile_option_id = (select profile_option_id
                from fnd_profile_options
                where application_id = 724
                and  profile_option_name = 'MSC_FCST_PRIORITY_FLEX_NUM');

    END IF;
    COMMIT;

  req_id := fnd_request.submit_request(
                'FND', 'FDFVGN', '', '', FALSE,
                '3', 704,
                'MRP_FORECAST_DATES');
    IF (req_id = 0) THEN
      raise conc_failure;
    END IF;

    COMMIT;

    errbuf := 'Created flexfields - submitted requests to recompile flexfields';
    retcode := 0; -- success

  EXCEPTION
   WHEN conc_failure THEN
     errbuf := 'Error ' ||
                  substr(fnd_message.get,1,240);
     retcode := 2;
   WHEN OTHERS THEN
   rollback;
    if (fnd_flex_dsc_api.message is null) then
      errbuf := 'Sql Error:' || to_char(sqlcode);
    else
      errbuf := fnd_flex_dsc_api.message;
    end if;
    retcode := 2; -- failure

 END Configure_fcst_flex;

PROCEDURE Configure_regions_flex(
	ERRBUF      	OUT NOCOPY VARCHAR2,
	RETCODE     	OUT NOCOPY NUMBER,
	oper_attr1      IN  NUMBER)
AS

	req_id 		NUMBER;
	conc_failure 	EXCEPTION;

	msgbuf		VARCHAR2(2000);

BEGIN

   fnd_flex_dsc_api.debug_on;
   fnd_flex_dsc_api.set_session_mode('seed_data');

   fnd_flex_dsc_api.enable_context('WSH',
                         'WSH_REGIONS',
                         'ZONES_DFF',
                         TRUE);

    IF
       fnd_flex_dsc_api.is_column_used(
                        p_application_id => '665',
                        p_table_name => 'WSH_REGIONS',
                        p_column_name => 'ATTRIBUTE'||to_char(oper_attr1),
                        x_message => msgbuf) = TRUE THEN

        FND_MESSAGE.set_name('MSC','MSC_ATTRIBUTE_EXISTS');
        FND_MESSAGE.set_token('ATTRIBUTE','ATTRIBUTE'||to_char(oper_attr1));
        FND_MESSAGE.set_token('TABLE','WSH_REGIONS');
        msgbuf := FND_MESSAGE.get;
        LOG_MESSAGE(msgbuf);
    ELSIF
       fnd_flex_dsc_api.segment_exists(
	p_appl_short_name=>'WSH',
	p_flexfield_name=>'WSH_REGIONS',
	p_context_code=>'ZONES_DFF',
	p_segment_name=>'Zone Usage') = TRUE THEN
        FND_MESSAGE.set_name('MSC','MSC_SEGMENT_EXISTS');
        FND_MESSAGE.set_token('SEGMENT','Zone Usage');
        FND_MESSAGE.set_token('TABLE','WSH_REGIONS');
        msgbuf := FND_MESSAGE.get;
        LOG_MESSAGE(msgbuf);
    ELSE
        fnd_flex_dsc_api.create_segment(
        appl_short_name => 'WSH',
        flexfield_name => 'WSH_REGIONS',
        context_name => 'ZONES_DFF',
        name => 'Zone Usage',
        column => 'ATTRIBUTE'|| to_char(oper_attr1),
        description => 'Zone Usage for Global Forecasting',
        sequence_number => 10,
        enabled => 'Y',
        displayed => 'Y',
        value_set => 'MSC_DP_ZONE_USAGE_SET',
        default_type => NULL,
        default_value => NULL,
        required => 'N',
        security_enabled => 'N',
        display_size => 25,
        description_size => 50,
        concatenated_description_size => 50,
        list_of_values_prompt => 'Zone Usage',
        window_prompt => 'Zone Usage',
        range => NULL,
        srw_parameter => NULL);
     END IF;


   COMMIT;

    req_id := fnd_request.submit_request(
                'FND', 'FDFVGN', '', '', FALSE,
                '3', 665,
                'WSH_REGIONS');

    IF (req_id = 0) THEN
      raise conc_failure;
    END IF;

    COMMIT;
    errbuf := 'Created flexfields - submitted requests to recompile flexfields';
    retcode := 0; -- success

EXCEPTION

   WHEN conc_failure THEN
     errbuf := 'Error ' ||
                  substr(fnd_message.get,1,240);
     retcode := 2;

   WHEN OTHERS THEN
   rollback;
    if (fnd_flex_dsc_api.message is null) then
      errbuf := 'Sql Error:' || to_char(sqlcode);
    else
      errbuf := fnd_flex_dsc_api.message;
    end if;
    retcode := 2; -- failure

END Configure_regions_flex;

END MSC_CONFIG_FF;

/
