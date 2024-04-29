--------------------------------------------------------
--  DDL for Package Body XDP_INSTALL_BASE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XDP_INSTALL_BASE" AS
/* $Header: XDPIBINB.pls 120.2 2006/07/05 05:40:51 dputhiye noship $ */

PROCEDURE UPDATE_TXN(p_order_id     IN NUMBER,
                     p_line_id      IN NUMBER,
                     p_ib_source_id IN NUMBER,
                     p_line_source  IN VARCHAR2,
                     p_line_number  IN NUMBER,
                     p_error_code   OUT NOCOPY NUMBER,
                     p_error_description OUT NOCOPY VARCHAR2);


PROCEDURE UPDATE_CSI(p_order_id     IN NUMBER,
                     p_line_id      IN NUMBER,
                     p_ib_source_id IN NUMBER,
                     p_error_code   OUT NOCOPY NUMBER);


       cursor c_update_ib (p_order_id number,p_Line_id number) IS
        	select  c.parameter_name
               		,c.parameter_value
               		,c.txn_attrib_detail_id
               		,c.attrib_source_table
               		,c.attrib_source_id
        	from 	xdp_order_line_items a,
			xdp_fulfill_worklist b,
			xdp_worklist_details c
        	where   a.line_item_id         	= b.line_item_id and
               		b.workitem_instance_id 	= c.workitem_instance_id and
               		a.order_id	      	= p_order_id and
               		a.line_item_id         	= p_line_id and
                        a.ib_source             <> 'NONE' and
                        c.attrib_source_id       is not null and
               		c.modified_flag        	= 'Y';

FUNCTION GET_TXN_LINE_ID(p_txn_line_detail_id IN NUMBER) RETURN NUMBER;

PROCEDURE Log_Debug(p_debug_api   IN VARCHAR2,
                    p_debug_msg   IN VARCHAR2);

-- ====================================================
-- Update Installed Base
-- ====================================================

PROCEDURE UPDATE_IB(p_order_id  IN NUMBER,
                    p_line_id   IN NUMBER,
                    p_error_code IN OUT NOCOPY NUMBER,
                    p_error_description OUT NOCOPY VARCHAR2) IS


        lv_error_code  NUMBER := 0;
        lv_error_description VARCHAR2(2000);
        lv_line_number NUMBER;

	cursor c_check (p_order_id number,p_line_id number) is
        	select  a.ib_source
               	       ,a.ib_source_id
                       ,a.line_source
                       ,a.line_number
                       ,a.is_virtual_line_flag
               	       ,b.comms_nl_trackable_flag
        	from    xdp_order_line_items a,
                	mtl_system_items_b b
        	where   a.inventory_item_id 	= b.inventory_item_id
        	and     a.organization_id 	= b.organization_id
        	and     a.line_item_id 		= p_line_id
        	and     a.order_id     		= p_order_id
                and     a.ib_source is not null;

        cursor c_rel_line(p_line_id number) is
               select	a.line_number
               from     xdp_order_line_items a,
                        xdp_line_relationships b
               where    a.line_item_id = b.related_line_item_id
               and      b.line_item_id = p_line_id;


BEGIN

Log_debug(p_debug_api => 'xdp.plsql.XDP_INSTALL_BASE.UPDATE_IB',
          p_debug_msg => 'Updating Install Base For Order Id is : '||p_order_id|| ' and Line Id is : '||p_line_id);

  FOR v_check_rec IN c_check (p_order_id, p_line_id)  LOOP

    IF v_check_rec.comms_nl_trackable_flag = 'Y' THEN

       Log_debug(p_debug_api => 'xdp.plsql.XDP_INSTALL_BASE.UPDATE_IB',
                 p_debug_msg => ' Trackable Flag is : ' ||v_check_rec.comms_nl_trackable_flag);

       IF v_check_rec.ib_source = 'TXN' THEN

          Log_debug(p_debug_api => 'xdp.plsql.XDP_INSTALL_BASE.UPDATE_IB',
                    p_debug_msg => ' Ib Source is : ' ||v_check_rec.ib_source);

          IF v_check_rec.is_virtual_line_flag = 'Y' THEN

             Log_debug(p_debug_api => 'xdp.plsql.XDP_INSTALL_BASE.UPDATE_IB',
                       p_debug_msg => ' is_virtual_line_flag is : ' ||v_check_rec.is_virtual_line_flag);

             FOR v_rel_line in c_rel_line(p_line_id) LOOP

                 lv_line_number := v_rel_line.line_number;

             END LOOP;
          ELSE
             lv_line_number := v_check_rec.line_number;
          END IF;

          Log_debug(p_debug_api => 'xdp.plsql.XDP_INSTALL_BASE.UPDATE_IB',
                    p_debug_msg => ' lv_line_number : '||lv_line_number );

          Log_debug(p_debug_api => 'xdp.plsql.XDP_INSTALL_BASE.UPDATE_IB',
                    p_debug_msg => ' Calling UPDATE_TXN ');

          UPDATE_TXN(p_order_id,
                     p_line_id,
                     v_check_rec.ib_source_id,
                     v_check_rec.line_source,
                     lv_line_number,
                     lv_error_code,
                     lv_error_description);

          IF lv_error_code <> 0 THEN

             Log_debug(p_debug_api => 'xdp.plsql.XDP_INSTALL_BASE.UPDATE_IB',
                       p_debug_msg => ' Update_Txn Failed. Error Code : '||lv_error_code ||'-  Error Desc : '||lv_error_description );

             p_error_code := lv_error_code;
             p_error_description := lv_error_description ;
            RETURN;
          END IF;

       ELSIF v_check_rec.ib_source = 'CSI' THEN

             Log_debug(p_debug_api => 'xdp.plsql.XDP_INSTALL_BASE.UPDATE_IB',
                       p_debug_msg => 'Ib Source is : '||v_check_rec.ib_source );
             Log_debug(p_debug_api => 'xdp.plsql.XDP_INSTALL_BASE.UPDATE_IB',
                       p_debug_msg => ' Calling UPDATE_CSI');

              UPDATE_CSI(p_order_id,
                         p_line_id,
                         v_check_rec.ib_source_id,
                         lv_error_code);

          IF lv_error_code <>  0 THEN

             Log_debug(p_debug_api => 'xdp.plsql.XDP_INSTALL_BASE.UPDATE_IB',
                       p_debug_msg => ' Update_CSI Failed. Error Code : '||lv_error_code);

             p_error_code := lv_error_code;
            RETURN;
          END IF;

       ELSIF v_check_rec.ib_source = 'NONE' THEN
          NULL;
          lv_error_code := 0;
          RETURN;
       END IF;
    END IF;
  END LOOP;

EXCEPTION
     WHEN others THEN
          p_error_code := sqlcode ;
          p_error_description := substr(sqlerrm,1,1800);

          Log_debug(p_debug_api => 'xdp.plsql.XDP_INSTALL_BASE.UPDATE_IB',
                    p_debug_msg => ' Exception Occurred');
          Log_debug(p_debug_api => 'xdp.plsql.XDP_INSTALL_BASE.UPDATE_IB',
                    p_debug_msg => 'Error Code : ' ||p_error_code||' - Error Desc : '||p_error_description);

          RETURN;

END UPDATE_IB;


-- =======================================================
-- Update Transaction Details
-- =======================================================

PROCEDURE UPDATE_TXN (p_order_id     IN  NUMBER,
                      p_line_id      IN  NUMBER,
                      p_ib_source_id IN  NUMBER,
                      p_line_source  IN  VARCHAR2,
                      p_line_number  IN  NUMBER,
                      p_error_code   OUT NOCOPY NUMBER,
                      p_error_description OUT NOCOPY VARCHAR2) IS

  lv_index                      NUMBER;
  lv_index1                     NUMBER;
  l_return_status               VARCHAR2(1);
  lv_return_status              VARCHAR2(1);
  l_msg_count                   NUMBER;
  l_msg_data                    VARCHAR2(1000);
  lv_return_message             VARCHAR2(2000);
  t_msg_dummy                   VARCHAR2(4000);
  t_output                      VARCHAR2(2000);

  l_txn_line_rec                CSI_T_DATASTRUCTURES_GRP.TXN_LINE_REC;
  l_txn_line_detail_tbl		CSI_T_DATASTRUCTURES_GRP.TXN_LINE_DETAIL_TBL;
  l_txn_party_detail_tbl	CSI_T_DATASTRUCTURES_GRP.TXN_PARTY_DETAIL_TBL;
  l_txn_pty_acct_detail_tbl	CSI_T_DATASTRUCTURES_GRP.TXN_PTY_ACCT_DETAIL_TBL;
  l_txn_ii_rltns_tbl		CSI_T_DATASTRUCTURES_GRP.TXN_II_RLTNS_TBL;
  l_txn_org_assgn_tbl		CSI_T_DATASTRUCTURES_GRP.TXN_ORG_ASSGN_TBL;
  l_txn_ext_attrib_vals_tbl	CSI_T_DATASTRUCTURES_GRP.TXN_EXT_ATTRIB_VALS_TBL;
  lv_config_session_key         CSI_UTILITY_GRP.config_session_key ;

  e_update_txn_failed           EXCEPTION;

 BEGIN

Log_debug(p_debug_api => 'xdp.plsql.XDP_INSTALL_BASE.UPDATE_TXN',
          p_debug_msg => 'In UPDATE_TXN');

        lv_index	:= 1;
	lv_index1 	:= 0;

            -- This code is added as a part of MACD Service project to get tuple of a CTO item OR its component and
            -- pass to IB to update TXN dtls  -- spusegao/maya 07/29/2002

                Log_debug(p_debug_api => 'xdp.plsql.XDP_INSTALL_BASE.UPDATE_TXN',
                          p_debug_msg => 'Line Id is : '||p_line_number);

                Log_debug(p_debug_api => 'xdp.plsql.XDP_INSTALL_BASE.UPDATE_TXN',
                          p_debug_msg => 'Calling CSI_UTILITY_GRP.get_config_key_for_om_line ');

                CSI_UTILITY_GRP.get_config_key_for_om_line( p_line_id              => p_line_number ,
                                                            x_config_session_key   => lv_config_session_key ,
                                                            x_return_status        => lv_return_status ,
                                                            x_return_message       => lv_return_message   );



                IF lv_return_status ='S' AND (lv_config_session_key.session_hdr_id IS NOT NULL AND
                                              lv_config_session_key.session_rev_num IS NOT NULL AND
                                              lv_config_session_key.session_item_id IS NOT NULL ) THEN
                   l_txn_line_rec.config_session_hdr_id    := lv_config_session_key.session_hdr_id ;
                   l_txn_line_rec.config_session_rev_num   := lv_config_session_key.session_rev_num ;
                   l_txn_line_rec.config_session_item_id   := lv_config_session_key.session_item_id ;
                   l_txn_line_rec.api_caller_identity      := 'CONFIG' ;

                   Log_debug(p_debug_api => 'xdp.plsql.XDP_INSTALL_BASE.UPDATE_TXN',
                             p_debug_msg => 'Config Hdr Id : '||lv_config_session_key.session_hdr_id);

                   Log_debug(p_debug_api => 'xdp.plsql.XDP_INSTALL_BASE.UPDATE_TXN',
                             p_debug_msg => 'Config Rev Num : '||lv_config_session_key.session_rev_num);

                   Log_debug(p_debug_api => 'xdp.plsql.XDP_INSTALL_BASE.UPDATE_TXN',
                             p_debug_msg => 'Config item Id : '||lv_config_session_key.session_item_id);

                ELSIF lv_return_status ='S' AND (lv_config_session_key.session_hdr_id IS NULL AND
                                                lv_config_session_key.session_rev_num IS NULL AND
                                                lv_config_session_key.session_item_id IS NULL ) THEN
                     -- pass line_number and line_source in the transaction record to ib
                     l_txn_line_rec.source_transaction_id    := p_line_number;
                     l_txn_line_rec.source_transaction_table := p_line_source;

                     Log_debug(p_debug_api => 'xdp.plsql.XDP_INSTALL_BASE.UPDATE_TXN',
                               p_debug_msg => 'source_transaction_id : '||p_line_number);

                     Log_debug(p_debug_api => 'xdp.plsql.XDP_INSTALL_BASE.UPDATE_TXN',
                               p_debug_msg => 'source_transaction_table : '||p_line_source);


                ELSIF lv_return_status <> 'S' THEN

                      Log_debug(p_debug_api => 'xdp.plsql.XDP_INSTALL_BASE.UPDATE_TXN',
                                p_debug_msg => 'CSI_UTILITY_GRP.get_config_key_for_om_line Failed');

                      Log_debug(p_debug_api => 'xdp.plsql.XDP_INSTALL_BASE.UPDATE_TXN',
                                p_debug_msg => 'Error Code : '||lv_return_status||'-  Error Desc. : '||lv_return_message);

                END IF ;

            -- pass ib_source_id to the l_txn_line_detail_tbl

               IF p_ib_source_id IS NOT NULL THEN

                  Log_debug(p_debug_api => 'xdp.plsql.XDP_INSTALL_BASE.UPDATE_TXN',
                            p_debug_msg => 'Calling GET_TXN_LINE_ID ');

                  l_txn_line_rec.transaction_line_id := GET_TXN_LINE_ID(p_ib_source_id);

                  Log_debug(p_debug_api => 'xdp.plsql.XDP_INSTALL_BASE.UPDATE_TXN',
                            p_debug_msg => 'Transaction Line Id : '||l_txn_line_rec.transaction_line_id );

               END IF ;

            l_txn_line_detail_tbl(lv_index).txn_line_detail_id := p_ib_source_id;

            FOR v_update_ib in c_update_ib(p_order_id,p_line_id) LOOP
                lv_index1 := lv_index1 + 1;
                      -- pass values to the l_txn_ext_attrib_vals_tbl
                      l_txn_ext_attrib_vals_tbl(lv_index1).txn_attrib_detail_id  := v_update_ib.txn_attrib_detail_id;
                      l_txn_ext_attrib_vals_tbl(lv_index1).txn_line_detail_id    := p_ib_source_id;
                      l_txn_ext_attrib_vals_tbl(lv_index1).attrib_source_table   := v_update_ib.attrib_source_table;
                      l_txn_ext_attrib_vals_tbl(lv_index1).attribute_source_id   := v_update_ib.attrib_source_id;
                      l_txn_ext_attrib_vals_tbl(lv_index1).attribute_value       := v_update_ib.parameter_value;
                      l_txn_ext_attrib_vals_tbl(lv_index1).process_flag          := 'Y';

            END LOOP;

               IF l_txn_ext_attrib_vals_tbl.COUNT > 0 THEN

                  Log_debug(p_debug_api => 'xdp.plsql.XDP_INSTALL_BASE.UPDATE_TXN',
                            p_debug_msg => 'Txn Ext Attrib Val. Count > 0 ');

                  Log_debug(p_debug_api => 'xdp.plsql.XDP_INSTALL_BASE.UPDATE_TXN',
                            p_debug_msg => 'Calling csi_t_txn_details_grp.update_txn_line_dtls');


                  -- call transaction details API
                   csi_t_txn_details_grp.update_txn_line_dtls
                   	(
     			 p_api_version			=> 1.0
    			,p_commit                	=> null
    			,p_init_msg_list         	=> null
    			,p_validation_level         	=> null
    			,p_txn_line_rec             	=> l_txn_line_rec
    			,p_txn_line_detail_tbl   	=> l_txn_line_detail_tbl
    			,px_txn_party_detail_tbl    	=> l_txn_party_detail_tbl
    			,px_txn_pty_acct_detail_tbl 	=> l_txn_pty_acct_detail_tbl
    			,px_txn_ii_rltns_tbl        	=> l_txn_ii_rltns_tbl
    			,px_txn_org_assgn_tbl       	=> l_txn_org_assgn_tbl
    			,px_txn_ext_attrib_vals_tbl 	=> l_txn_ext_attrib_vals_tbl
    			,x_return_status         	=> l_return_status
    			,x_msg_count             	=> l_msg_count
    			,x_msg_data              	=> l_msg_data
			 );


               END IF;

               IF l_return_status <> 'S' THEN
                  p_error_code := -1 ;
                  p_error_description := l_msg_data ;

                  Log_debug(p_debug_api => 'xdp.plsql.XDP_INSTALL_BASE.UPDATE_TXN',
                            p_debug_msg => ' csi_t_txn_details_grp.update_txn_line_dtls Failed');
                  Log_debug(p_debug_api => 'xdp.plsql.XDP_INSTALL_BASE.UPDATE_TXN',
                            p_debug_msg => '  Error Desc : ' ||p_error_description);
                  RETURN;
               ELSE
                  Log_debug(p_debug_api => 'xdp.plsql.XDP_INSTALL_BASE.UPDATE_TXN',
                            p_debug_msg => ' csi_t_txn_details_grp.update_txn_line_dtls Completed ');

               END IF;

  p_error_code := 0;



 EXCEPTION

    WHEN OTHERS THEN
          p_error_code := sqlcode ;
          p_error_description := substr(sqlerrm,1,1800);

          Log_debug(p_debug_api => 'xdp.plsql.XDP_INSTALL_BASE.UPDATE_TXN',
                    p_debug_msg => ' Exception Occurred');
          Log_debug(p_debug_api => 'xdp.plsql.XDP_INSTALL_BASE.UPDATE_TXN',
                    p_debug_msg => 'Error Code : ' ||p_error_code||' - Error Desc : '||p_error_description);

          RETURN ;
/*
         xdp_utilities.generic_error('XDP_INSTALL_BASE.UPDATE_TXN'
                               ,p_order_id
                               , SQLCODE
                               , SQLERRM);
*/
 END UPDATE_TXN;


-- ============================================================
-- Update Install Base
-- ============================================================

PROCEDURE     UPDATE_CSI (p_order_id     IN  NUMBER,
                          p_line_id      IN  NUMBER,
                          p_ib_source_id IN  NUMBER,
                          p_error_code   OUT NOCOPY NUMBER) IS


 lv_index			NUMBER;
 l_return_status               	VARCHAR2(1);
 l_msg_count                   	NUMBER;
 l_msg_data                    	VARCHAR2(1000);
 l_instance_rec		       	CSI_DATASTRUCTURES_PUB.INSTANCE_REC;
 l_extend_attrib_values_tbl    	CSI_DATASTRUCTURES_PUB.EXTEND_ATTRIB_VALUES_TBL;
 l_party_tbl 		       	CSI_DATASTRUCTURES_PUB.PARTY_TBL;
 l_party_account_tbl		CSI_DATASTRUCTURES_PUB.PARTY_ACCOUNT_TBL;
 l_pricing_attribs_tbl		CSI_DATASTRUCTURES_PUB.PRICING_ATTRIBS_TBL;
 l_organization_units_tbl 	CSI_DATASTRUCTURES_PUB.ORGANIZATION_UNITS_TBL;
 l_transaction_rec		CSI_DATASTRUCTURES_PUB.TRANSACTION_REC;
 l_instance_asset_tbl 		CSI_DATASTRUCTURES_PUB.INSTANCE_ASSET_TBL;
 l_id_tbl 			CSI_DATASTRUCTURES_PUB.ID_TBL;
 e_update_csi_failed         	EXCEPTION;
 t_output                       VARCHAR2(2000);
 t_msg_dummy                    NUMBER;

 Cursor c_get_obj_num(p_att_val_id number) is
        select object_version_number
        from csi_iea_values
        where attribute_value_id = p_att_val_id;

 Cursor c_get_inst_obj_num(p_inst_id number) is
       select object_version_number
       from csi_item_instances
       where instance_id = p_inst_id;

  BEGIN

        Log_debug(p_debug_api => 'xdp.plsql.XDP_INSTALL_BASE.UPDATE_CSI',
                  p_debug_msg => 'In UPDATE_CSI');

	lv_index	:= 0;

            -- create record to pass to API
               l_instance_rec.instance_id := p_ib_source_id;

              FOR v_get_inst_obj_num in  c_get_inst_obj_num(p_ib_source_id) LOOP
                   l_instance_rec.object_version_number := v_get_inst_obj_num.object_version_number ;
              END LOOP;


            -- create record for transaction rec to pass to API
               l_transaction_rec.transaction_type_id := 57;
               l_transaction_rec.transaction_date := SYSDATE;
               l_transaction_rec.source_transaction_date := SYSDATE;

            FOR v_update_ib in c_update_ib(p_order_id,p_line_id) LOOP
               lv_index := lv_index + 1;

               l_extend_attrib_values_tbl(lv_index).instance_id    	 	:= p_ib_source_id;

               IF v_update_ib.attrib_source_table = 'CSI_IEA_VALUES' THEN
                   l_extend_attrib_values_tbl(lv_index).attribute_value_id   	:= v_update_ib.attrib_source_id;
                   l_extend_attrib_values_tbl(lv_index).attribute_value         := v_update_ib.parameter_value;

                   FOR v_get_obj_num in c_get_obj_num(v_update_ib.attrib_source_id) LOOP
                       l_extend_attrib_values_tbl(lv_index).object_version_number := v_get_obj_num.object_version_number;
                   END LOOP;

               ELSIF v_update_ib.attrib_source_table = 'CSI_I_EXTENDED_ATTRIBS' THEN
                   l_extend_attrib_values_tbl(lv_index).attribute_value_id   	:= null;
                   l_extend_attrib_values_tbl(lv_index).attribute_id   	:= v_update_ib.attrib_source_id;
                   l_extend_attrib_values_tbl(lv_index).attribute_value             := v_update_ib.parameter_value;

               END IF;

            END LOOP;

               IF l_extend_attrib_values_tbl.COUNT > 0 THEN

        Log_debug(p_debug_api => 'xdp.plsql.XDP_INSTALL_BASE.UPDATE_CSI',
                  p_debug_msg => 'Calling csi_item_instance_pub.update_item_instance ');

               csi_item_instance_pub.update_item_instance
 		(
     		 p_api_version 			=>  1.0
    		,p_commit               	=>  null
    		,p_init_msg_list         	=>  null
    		,p_validation_level     	=>  null
    		,p_instance_rec          	=>  l_instance_rec
    		,p_ext_attrib_values_tbl 	=>  l_extend_attrib_values_tbl
    		,p_party_tbl             	=>  l_party_tbl
    		,p_account_tbl           	=>  l_party_account_tbl
    		,p_pricing_attrib_tbl    	=>  l_pricing_attribs_tbl
    		,p_org_assignments_tbl   	=>  l_organization_units_tbl
                ,p_asset_assignment_tbl     	=>  l_instance_asset_tbl
    		,p_txn_rec               	=>  l_transaction_rec
     		,x_instance_id_lst       	=>  l_id_tbl
    		,x_return_status         	=>  l_return_status
    		,x_msg_count              	=>  l_msg_count
    		,x_msg_data              	=>  l_msg_data
 		);


                END IF;


                IF l_return_status <> 'S' THEN
                   p_error_code := -1;

                   Log_debug(p_debug_api => 'xdp.plsql.XDP_INSTALL_BASE.UPDATE_CSI',
                             p_debug_msg => 'csi_item_instance_pub.update_item_instance Failed');

                   Log_debug(p_debug_api => 'xdp.plsql.XDP_INSTALL_BASE.UPDATE_CSI',
                             p_debug_msg => 'Error Code : ' ||p_error_code || '-  Error Desc. : '||l_msg_data );

                   RETURN;
                END IF;

   p_error_code := 0;

EXCEPTION

    WHEN OTHERS THEN
    p_error_code := -1;
        Log_debug(p_debug_api => 'xdp.plsql.XDP_INSTALL_BASE.UPDATE_CSI',
                  p_debug_msg => 'When Others Exception Error Code : '||sqlcode||'-  Error Desc. : '||sqlerrm );

    xdp_utilities.generic_error('XDP_INSTALL_BASE.UPDATE_CSI'
                               ,p_order_id
                               , SQLCODE
                               , SQLERRM);
    RETURN;
END UPDATE_CSI;

-- Function to retrieve TXN Line Id for a given txn_line_detail_id
-- This is required for configured item while updating the attribute details in tXN detail.


FUNCTION GET_TXN_LINE_ID(p_txn_line_detail_id IN NUMBER) RETURN NUMBER IS

l_txn_line_id NUMBER;
			--Date: 05-JUL-2006, Author: DPUTHIYE, Bug#5370624/5222928
			--Description: Wrapped NO_DATA_FOUND errors from this API, since the error
			--code/text returned is misleading as it rolls up to the Workflow status monitor.
			--Dependencies: None. The wrapper error message will be thrown as a custom exception.
BEGIN

     SELECT transaction_line_id
     INTO l_txn_line_id
     FROM csi_t_txn_line_details
     WHERE txn_line_detail_id = p_txn_line_detail_id ;

     RETURN l_txn_line_id ;
EXCEPTION
     WHEN no_data_found THEN
        raise_application_error(-20001, 'IB Transaction Line Detail information not found. ' || SQLERRM);
     WHEN others THEN
	raise;
END GET_TXN_LINE_ID;

-- Procedure to create a debug message in fnd_log_messages to help debugging in case of issues
-- Being a private procedure this has been used within this package only.


PROCEDURE Log_Debug ( p_debug_api   IN VARCHAR2,
                      p_debug_msg   IN VARCHAR2) IS


BEGIN

     IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
            IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, p_debug_api)) THEN
		IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
               		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, p_debug_api , p_debug_msg );
		END IF;
            END IF;
     END IF;


END Log_Debug ;


END XDP_INSTALL_BASE;

/
