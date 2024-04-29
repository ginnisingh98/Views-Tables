--------------------------------------------------------
--  DDL for Package Body CST_PL_IMPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CST_PL_IMPORT" as
/* $Header: CSTPLIMB.pls 120.3 2006/03/21 11:50:38 vtkamath noship $ */

PROCEDURE START_PROCESS(ERRBUF                   OUT NOCOPY     VARCHAR2,
                        RETCODE                  OUT NOCOPY     NUMBER ,
                        p_pl_hdr_id              IN      NUMBER ,
                        p_range                  IN      NUMBER ,
                        p_item_dummy             IN      NUMBER ,
                        p_category_dummy         IN      NUMBER ,
                        p_specific_item_id       IN      NUMBER ,
                        p_category_set           IN      NUMBER ,
                        p_category_validate_flag IN      VARCHAR2,
                        p_category_structure     IN      NUMBER ,
                        p_specific_category_id   IN      NUMBER ,
                        p_organization_id        IN      NUMBER ,
                        p_item_price_eff_date    IN      VARCHAR2,
                        p_based_on_rollup        IN      NUMBER,
                        p_ad_qp_mult             IN      VARCHAR2,
                        p_conv_type              IN      VARCHAR2,
                        p_conv_date              IN      VARCHAR2,
                        p_def_mtl_subelement     IN      NUMBER ,
                        p_group_id_dummy         IN      NUMBER ,
                        p_group_id               IN      NUMBER
                        ) as

-- p_range values interpreted as below
--             1    All items
--             2    Specific item
--             5    category
--

 p_line_tbl                  	QP_PREQ_GRP.LINE_TBL_TYPE;
 p_qual_tbl                  	QP_PREQ_GRP.QUAL_TBL_TYPE;
 p_line_attr_tbl             	QP_PREQ_GRP.LINE_ATTR_TBL_TYPE;
 p_LINE_DETAIL_tbl           	QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE;
 p_LINE_DETAIL_qual_tbl      	QP_PREQ_GRP.LINE_DETAIL_QUAL_TBL_TYPE;
 p_LINE_DETAIL_attr_tbl      	QP_PREQ_GRP.LINE_DETAIL_ATTR_TBL_TYPE;
 p_related_lines_tbl         	QP_PREQ_GRP.RELATED_LINES_TBL_TYPE;
 p_control_rec               	QP_PREQ_GRP.CONTROL_RECORD_TYPE;
 x_line_tbl                  	QP_PREQ_GRP.LINE_TBL_TYPE;
 x_line_qual                 	QP_PREQ_GRP.QUAL_TBL_TYPE;
 x_line_attr_tbl             	QP_PREQ_GRP.LINE_ATTR_TBL_TYPE;
 x_line_detail_tbl           	QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE;
 x_line_detail_qual_tbl      	QP_PREQ_GRP.LINE_DETAIL_QUAL_TBL_TYPE;
 x_line_detail_attr_tbl      	QP_PREQ_GRP.LINE_DETAIL_ATTR_TBL_TYPE;
 x_related_lines_tbl         	QP_PREQ_GRP.RELATED_LINES_TBL_TYPE;
 x_return_status             	VARCHAR2(240);
 x_return_status_text        	VARCHAR2(240);
 qual_rec                    	QP_PREQ_GRP.QUAL_REC_TYPE;
 line_attr_rec               	QP_PREQ_GRP.LINE_ATTR_REC_TYPE;
 line_rec                    	QP_PREQ_GRP.LINE_REC_TYPE;
 rltd_rec                    	QP_PREQ_GRP.RELATED_LINES_REC_TYPE;

 I 				BINARY_INTEGER;
 J 				BINARY_INTEGER;
 l_version 			VARCHAR2(240);
 l_num	 		  	NUMBER ;


 l_stmt_num 		  	NUMBER ;
 l_cost_organization_id   	NUMBER ;
 l_org_currency_code      	VARCHAR2(15) ;
 l_price_list_name      	VARCHAR2(240) ; --changed to 240 for a bugfix
 l_product_attr_value     	VARCHAR2(240);
 l_primary_uom_code       	VARCHAR2(3);
 l_item_count             	NUMBER:= 0;
 l_num_rows             	NUMBER;
 l_precision              	NUMBER;
 l_extended_precision     	NUMBER ;
 l_item			  	NUMBER ;
 l_item_cost              	NUMBER ;
 l_req_groupid                  VARCHAR2(20);
 l_based_on_rollup              NUMBER;
 l_conversion_rate              NUMBER := 1;
 l_min_reqid                    NUMBER;
 l_base_count                   NUMBER;
 l_list_currency_code           VARCHAR2(30);
 l_ad_qp_mult                   VARCHAR2(30);
 Conc_request 			BOOLEAN;

 p_err_num 		  	NUMBER; --  pass back to calling program
 p_err_msg                	NUMBER;

 /* Skip Process Organizations Cost Manager Changes - Anand Thiyagarajan - 26-Oct-2004 Start */
 l_process_enabled_flag  mtl_parameters.process_enabled_flag%TYPE;
 l_organization_code     mtl_parameters.organization_code%TYPE;
 /* Skip Process Organizations Cost Manager Changes - Anand Thiyagarajan - 26-Oct-2004 End */

-- Asset Item list (Non-Serviceable) for which prices need to be imported
-- Active Check not required for header as already done at SRS and for
-- list line would be done by the engine

Cursor 	GET_PL_ITEMS(l_lst_hdr_id   	number,
                     l_org_id	 	number)
IS
select  distinct msi.inventory_item_id , msi.primary_uom_code
  from  qp_list_headers_vl qph ,
        qp_list_lines qpl ,
        qp_pricing_attributes qpa,
        mtl_system_items_b msi
  where qph.list_header_id 		= l_lst_hdr_id
    and qph.list_type_code 		= 'PRL'
    and qph.list_header_id 		= qpl.list_header_id
    and qpl.list_line_type_code 	= 'PLL'
    and qpa.list_line_id 		= qpl.list_line_id
    and qpa.product_attribute_context 	= 'ITEM'
    and qpa.product_attribute 		= 'PRICING_ATTRIBUTE1'
    and msi.organization_id 		= l_org_id
    and msi.inventory_item_id 		= qpa.product_attr_value
    and msi.inventory_asset_flag 	= 'Y'
/* Bug 4037114 .Servie items should be excluded and not servicable items
    and msi.serviceable_product_flag 	= 'N'  */
    and msi.service_item_flag = 'N'
    and  ( p_range = 1
               OR
            (    p_range = 2
              AND msi.inventory_item_id = p_specific_item_id
             )
               OR
            EXISTS
                  (SELECT NULL
                   FROM   mtl_item_categories   MIC
                   WHERE  MIC.organization_id   = p_organization_id
                   AND    MIC.category_id       = nvl(p_specific_category_id ,MIC.category_id)
                   AND    MIC.category_set_id   = nvl(p_category_set , -99999)
                   AND    MIC.inventory_item_id = msi.inventory_item_id
                   AND    p_range               = 5)
         );

Cursor 	GET_ITEM_COST IS
select /*+ ORDERED USE_NL(b) */
	adjusted_unit_price * nvl(priced_quantity,line_quantity),b.value_from
  from 	qp_preq_lines_tmp  a , qp_preq_line_attrs_tmp b
  where a.line_index 		=  b.line_index
    and a.pricing_status_code 	= 'UPDATED'
    and b.pricing_status_code 	= 'X'
    and b.context 		= 'ITEM'
    and b.attribute_type 	= 'PRODUCT'
    and b.attribute 		= 'PRICING_ATTRIBUTE1' ;


BEGIN

       /* Skip Process Organizations Cost Manager Changes - Anand Thiyagarajan - 26-Oct-2004 Start */
       BEGIN
	  SELECT   nvl(process_enabled_flag,'N')
		   , organization_code
	  INTO     l_process_enabled_flag
		   , l_organization_code
	  FROM     mtl_parameters
	  WHERE    organization_id = p_organization_id;

	  IF nvl(l_process_enabled_flag,'N') = 'Y' THEN
             FND_MESSAGE.set_name('GMF','GMF_PROCESS_ORG_ERROR');
             FND_MESSAGE.set_token('ORGCODE', l_organization_code);
             FND_FILE.put_line(fnd_file.log,fnd_message.get);
             Conc_request := FND_CONCURRENT.set_completion_status('ERROR',fnd_message.get);
	     RETURN;
	  END IF;

       EXCEPTION
	  WHEN no_data_found THEN
	     l_process_enabled_flag := 'N';
	     l_organization_code := NULL;
       END;
       /* Skip Process Organizations Cost Manager Changes - Anand Thiyagarajan - 26-Oct-2004 End */

	l_stmt_num := 10 ;
        Select  name
          into  l_price_list_name
          from  qp_list_headers_vl
          where list_header_id = p_pl_hdr_id ;

        /* set the values of QP install and Multi Currency Install */

        If p_ad_qp_mult IS NULL then
           l_ad_qp_mult := 'Yes';
        else
           l_ad_qp_mult := 'No';
        End If;

 	FND_FILE.put_line(fnd_file.log, 'Organization id      : ' || to_char(p_organization_id)) ;
 	FND_FILE.put_line(fnd_file.log, 'Price list name      : ' || l_price_list_name ) ;
 	FND_FILE.put_line(fnd_file.log, 'Price list id        : ' || to_char(p_pl_hdr_id) ) ;
 	FND_FILE.put_line(fnd_file.log, 'Range                : ' || to_char(p_range) ) ;
 	FND_FILE.put_line(fnd_file.log, 'Specific item        : ' || to_char(p_specific_item_id) ) ;
 	FND_FILE.put_line(fnd_file.log, 'Category set         : ' || to_char(p_category_set) ) ;
 	FND_FILE.put_line(fnd_file.log, 'Category id          : ' || to_char(p_specific_category_id) ) ;
	FND_FILE.put_line(fnd_file.log, 'Item price eff date  : ' ||
                                             to_char(to_date(p_item_price_eff_date , 'RR/MM/DD HH24:MI:SS'),'DD-MON-RR') );
        FND_FILE.put_line(fnd_file.log, 'Based on rollup      : ' || to_char(p_based_on_rollup));

        FND_FILE.put_line(fnd_file.log, 'QP:Multi Currency Installed : ' || l_ad_qp_mult);

        FND_FILE.put_line(fnd_file.log, 'Conversion Type      : '  || p_conv_type);

        FND_FILE.put_line(fnd_file.log, 'Conversion Date      : ' || to_char(to_date(p_conv_date,'RR/MM/DD HH24:MI:SS'),'DD-MON-RR'));
 	FND_FILE.put_line(fnd_file.log, 'Deflt matl subelement: ' || to_char(p_def_mtl_subelement) ) ;
 	FND_FILE.put_line(fnd_file.log, 'Group id             : ' || to_char(p_group_id) ) ;
	FND_FILE.put_line(fnd_file.log, '') ;

/* First check for multiple simultaneously running requests with the same group ID parameter*/

        l_stmt_num := 15;

        Select FCR.argument18 into l_req_groupid
        from FND_CONCURRENT_REQUESTS FCR
        where FCR.concurrent_program_id = FND_GLOBAL.CONC_PROGRAM_ID
              AND FCR.program_application_id = FND_GLOBAL.PROG_APPL_ID
              AND FCR.request_id = FND_GLOBAL.CONC_REQUEST_ID;

        Select min(FCR.request_id) into l_min_reqid
        from FND_CONCURRENT_REQUESTS FCR
        where FCR.concurrent_program_id = FND_GLOBAL.CONC_PROGRAM_ID
              AND FCR.program_application_id = FND_GLOBAL.prog_appl_id
              AND FCR.phase_code <> 'C'
              AND FCR.argument14 = l_req_groupid;

        l_base_count := 0;
        select count(*) into l_base_count
        from CST_ITEM_CST_DTLS_INTERFACE CICDI
        where CICDI.group_id = l_req_groupid;

 If ((NVL(l_min_reqid,FND_GLOBAL.CONC_REQUEST_ID) <> FND_GLOBAL.CONC_REQUEST_ID)OR (l_base_count <> 0)) then
  fnd_file.put_line(fnd_file.log,fnd_message.get_string('BOM','CST_REQ_ERROR'));
  Conc_request := fnd_concurrent.set_completion_status('ERROR',fnd_message.get_string('BOM','CST_REQ_ERROR'));
  return;
 end If;

        l_stmt_num := 17;
       /* check for NULL conversion date passed in */

        If (p_ad_qp_mult IS NOT NULL) AND (p_conv_date is NULL) then

          fnd_file.put_line(fnd_file.log,substrb(fnd_message.get_string('BOM','CST_NULL_CONV_DATE'),1,240));
          Conc_request := fnd_concurrent.set_completion_status('ERROR',fnd_message.get_string('BOM','CST_NULL_CONV_DATE'));
         return;

        End If;


	l_stmt_num := 20 ;
  	Select 	cost_organization_id
    	  into 	l_cost_organization_id
    	  from 	mtl_parameters MP
   	 where  MP.organization_id = p_organization_id;

   	If	p_organization_id  <> l_cost_organization_id
   	Then
		FND_FILE.put_line(fnd_file.log,(fnd_message.get_string('BOM','CST_NOT_COSTINGORG')));
          	RETURN ;
   	End if ;

  	l_stmt_num := 30 ;
        -- Bug 5023568 : Changing the query to improve performance
  	Select 	currency_code
          into 	l_org_currency_code
  	  from  cst_organization_definitions
  	 where 	organization_id = p_organization_id;

        /* Set the use multi Currency feature to yes */

       /* check for advanced pricing to be installed.If it is then set this
          multi currency use feature to yes.Otherwise just dont set it and
          get the price list currency. We then pass this price list currency
          and get the item cost from the pricing engine and then multiply this
          item cost with the conversion factor*/

        If p_ad_qp_mult IS NULL then
          p_control_rec.use_multi_currency := 'Y';
        else

          Select qph.currency_code into l_list_currency_code
                from qp_list_headers_vl qph
                where qph.list_header_id = p_pl_hdr_id
                and qph.list_type_code = 'PRL';

        End If;

        /* Check for the Organization's currency. If it is diferent than the
        price list's currency and the Advanced pricing is not installed , then
        we will have to do the currency conversion ourselves */

       l_stmt_num := 33;

       If ((UPPER(l_org_currency_code) <> UPPER(l_list_currency_code)) AND
              (p_ad_qp_mult IS NOT NULL )) then

          -- fnd_file.put_line(fnd_file.log,'list code : ' || l_list_currency_code);
          -- fnd_file.put_line(fnd_file.log,'org code :' || l_org_currency_code);

         /* Bail out the Exception    */

          Begin

           l_conversion_rate := gl_currency_api.get_rate
                                (
                                 l_list_currency_code,
                                 l_org_currency_code,
                                 to_date(p_conv_date ,'RR/MM/DD HH24:MI:SS'),
                                 p_conv_type);

          EXCEPTION
          WHEN OTHERS THEN
           fnd_file.put_line(fnd_file.log,substrb(fnd_message.get_string('BOM','CST_NO_VALID_CURRATE'),1,240));

           Conc_request := fnd_concurrent.set_completion_status('ERROR',substrb(fnd_message.get_string('BOM','CST_NO_VALID_CURRATE'),1,240));
           RETURN;

           End;

        else /* if the 2 currencies match or multi currency is enabled */
            IF l_ad_qp_mult = 'Yes' then
               l_conversion_rate := '' ;
            else
               l_conversion_rate := 1;
            END IF ;
        end if;

            FND_FILE.PUT_LINE(fnd_file.log,'Conversion rate is   : ' || to_char(l_conversion_rate) );
            FND_FILE.put_line(fnd_file.log, '') ;

 	p_control_rec.pricing_event	:= 'PRICE'; -- discounts considered only with 'LINE'
 	p_control_rec.calculate_flag 	:= 'Y';
 	p_control_rec.simulation_flag 	:= 'N';
 	p_control_rec.rounding_flag 	:= 'N';     -- rounding not needed


        l_stmt_num := 35 ;
        /* MOAC changes - Send the org_id for the pricing list from qp_list_headers_vl
        If Security is OFF, the orig_org_id will be null, pricing engine will ignore the OU checks. OK.
        If security is ON and orig_org_id is not null, it is valid for the OU passed.
        If the PL is global, orig_org_id will be null, it should still be OK. */

        Select  orig_org_id
        into  p_control_rec.org_id
        from  qp_list_headers_vl
        where list_header_id = p_pl_hdr_id ;

        l_stmt_num := 40 ;
	Open GET_PL_ITEMS( p_pl_hdr_id , p_organization_id );
	Loop
 	Fetch GET_PL_ITEMS into l_product_attr_value ,
                         	l_primary_uom_code ;
 	Exit  when GET_PL_ITEMS%NOTFOUND;

 	l_item_count   := l_item_count + 1 ;
--
 	l_stmt_num := 50 ;
 	line_rec.request_type_code		:= 'ONT'; -- May change to 'INV'in future
 	line_rec.line_id 			:= l_item_count;
 	line_rec.line_Index 			:= l_item_count;
 	line_rec.line_type_code			:= 'LINE';
-- ?
 	line_rec.pricing_effective_date		:= to_date(p_item_price_eff_date ,'RR/MM/DD HH24:MI:SS');
 	line_rec.line_quantity 			:= 1;
 	line_rec.line_uom_code 			:= l_primary_uom_code;
-- 	line_rec.rounding_factor 		:= -2; --  No rounding needed by us


        /* Check for the advanced pricing to be installed.If it is then pass the
       organization's currency code and get the item's cost.If it is not
       installed, then, pass the price list's currency and get the item cost */

        If p_ad_qp_mult IS NULL then
        line_rec.currency_code                  := l_org_currency_code ;
        else
        line_rec.currency_code                  := l_list_currency_code ;
        end If;

 	line_rec.price_flag 			:= 'Y';
 	p_line_tbl(l_item_count) 		:= line_rec;

 	line_attr_rec.LINE_INDEX 		:= l_item_count;
 	line_attr_rec.PRICING_CONTEXT 		:= 'ITEM';
 	line_attr_rec.PRICING_ATTRIBUTE 	:='PRICING_ATTRIBUTE1';
 	line_attr_rec.PRICING_ATTR_VALUE_FROM  	:= l_product_attr_value ;  --item_id
 	p_line_attr_tbl(l_item_count)		:= line_attr_rec;

 	qual_rec.LINE_INDEX 			:= l_item_count;
 	qual_rec.QUALIFIER_CONTEXT 		:='MODLIST';
 	qual_rec.QUALIFIER_ATTRIBUTE 		:='QUALIFIER_ATTRIBUTE4';
 	qual_rec.QUALIFIER_ATTR_VALUE_FROM 	:= p_pl_hdr_id; -- PL header id
-- Below 'Y' per suggestion from QP team , so that qualifiers are not checked
 	qual_rec.VALIDATED_FLAG 		:='Y';
 	p_qual_tbl(l_item_count)		:= qual_rec;

END LOOP ; -- get_pl_items
Close get_pl_items ;

IF 	l_item_count = 0 Then
   	FND_FILE.put_line(fnd_file.log,'No matching items found for specified parameters') ;
        RETURN;
End if ;

	l_version :=  QP_PREQ_GRP.GET_VERSION;
	FND_FILE.put_line( fnd_file.log , 'Testing version '|| l_version);

	l_stmt_num := 60 ;
	QP_PREQ_GRP.PRICE_REQUEST
       	       (p_line_tbl,
        	p_qual_tbl,
        	p_line_attr_tbl,
               	p_line_detail_tbl,
        	p_line_detail_qual_tbl,
        	p_line_detail_attr_tbl,
        	p_related_lines_tbl,
        	p_control_rec,
        	x_line_tbl,
        	x_line_qual,
        	x_line_attr_tbl,
        	x_line_detail_tbl,
        	x_line_detail_qual_tbl,
        	x_line_detail_attr_tbl,
        	x_related_lines_tbl,
        	x_return_status,
        	x_return_status_text);

	FND_FILE.put_line(fnd_file.log, 'Return status from pricing API ' || x_return_status) ;
   	FND_FILE.put_line(fnd_file.log, 'Return  text  from pricing API ' || x_return_status_text) ;

IF 	x_return_status <> 'S' Then
   	RETURN ;
End if ;

-- should we check line detl attr tbl or line attr table

	l_stmt_num := 70 ;

       /* Get the value of based on rollup flag depending on what the user has specifiedin the SRS parameter */

        If p_based_on_rollup = 1 OR p_based_on_rollup = 2 then
          l_based_on_rollup := p_based_on_rollup;
        Else
          l_based_on_rollup := to_number(NULL);
        End if;


	Open GET_ITEM_COST;
	Loop
 	Fetch GET_ITEM_COST into  l_item_cost,
                         	  l_item ;

 	Exit  when GET_ITEM_COST%NOTFOUND;
   	Insert into CST_ITEM_CST_DTLS_INTERFACE (
			Inventory_item_ID ,
        		Organization_id ,
        		Last_update_date ,
        		Last_updated_by ,
        		Creation_date ,
        		Created_by ,
        		Last_update_login ,
        		Program_id ,
        		Level_type ,
        		Cost_element_id ,
        		Resource_ID ,
			Rollup_source_type ,
			Request_ID ,
			Basis_type ,
			Usage_rate_or_amount,
			Basis_factor ,
                        Based_on_rollup_flag,
                        Group_id ,
                        Group_description ,
                        Process_flag )
   			Values
		     (
			l_item ,
        		p_organization_id,
        		sysdate ,
        		FND_GLOBAL.user_id,
        		sysdate ,
        		FND_GLOBAL.user_id,
        		FND_GLOBAL.user_id,
        		FND_GLOBAL.conc_program_id,
        		'1',  				-- This Level
        		'1',  				-- Material
        		p_def_mtl_subelement ,
        		'1', 				-- user defined
        		p_group_id ,
        		'1' , 				-- Item based
        		l_item_cost * nvl(l_conversion_rate, 1),
        		'1' ,
                        l_based_on_rollup,
                        p_group_id ,
                        l_price_list_name || ':'|| FND_GLOBAL.user_name
                              || ':' || to_char(sysdate , 'DD-MON-RR' ) ,
                        1
                      ) ;

     		If SQL%NOTFOUND then
   	   	   FND_FILE.put_line(fnd_file.log,'Insert into interface failed for Item '
					|| l_item ) ;
            	End if ;

	END LOOP;

-- Commit the changes
--
        COMMIT ;

       l_stmt_num := 80 ;
       select count(*) into l_num_rows
         from CST_ITEM_CST_DTLS_INTERFACE
        where group_id = p_group_id ;

	FND_FILE.put_line(fnd_file.log,
        'Sucessfully inserted ' || to_char(l_num_rows)|| ' rows into CST_ITEM_CST_DTLS_INTERFACE table');

EXCEPTION
    When Others then
         rollback ;
 	 fnd_file.put_line(fnd_file.log,'CSTPLIMB:'|| to_char(l_stmt_num) || ' '||
                           substr(SQLERRM,1,180));
--       CONC_REQUEST := fnd_concurrent.set_completion_status
--                         ('ERROR',(fnd_message.get_string('BOM','CST_EXCEPTION_OCCURED')) );

END START_PROCESS ;


-- The below function is to be used ONLY for generating
-- unique group id's for import cost from price list
-- SRS launch form.

FUNCTION GET_GROUP_ID Return integer  IS
--
  l_group_id 	integer ;
BEGIN
--
  select CST_LISTS_S.currval
    into l_group_id
    from dual ;
  return (l_group_id) ;

EXCEPTION
  when others then
    return 0 ;
    null ;
--  p_err_num := SQLCODE;
--  p_err_msg := 'CSTPLIMB:' || substrb(SQLERRM,1,150);
--  return -9999;
END GET_GROUP_ID;


END CST_PL_IMPORT;

/
