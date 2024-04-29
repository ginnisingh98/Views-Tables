--------------------------------------------------------
--  DDL for Package Body GMP_DESPATCH_LOAD_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMP_DESPATCH_LOAD_RPT_PKG" as
/* $Header: GMPRDESB.pls 120.6.12010000.4 2009/03/30 22:34:54 rpatangy ship $ */

G_ret_code              BOOLEAN;
G_forg                  VARCHAR2(240);
G_torg                  VARCHAR2(240);
G_fres                  VARCHAR2(240);
G_tores                 VARCHAR2(240);
G_fres_instance         NUMBER;
G_tores_instance        NUMBER;
G_start_date            DATE;
G_to_date               DATE;
G_log_text              VARCHAR2(1000);
G_template              VARCHAR2(100);
G_template_locale       VARCHAR2(6);
G_inst                  VARCHAR2(3);
G_plan                  VARCHAR2(10);

f_org                   NUMBER;
t_org                   NUMBER;
inst_id                 NUMBER;
plan_id                 NUMBER;
f_res                   NUMBER;
t_res                   NUMBER;
v_dblink                VARCHAR2(128);

resdisp_rpt_id          NUMBER;

PROCEDURE LOG_MESSAGE(pBUFF  IN  VARCHAR2);

/*============================================================================+
|                                                                             |
| PROCEDURE NAME	print_res_desp                                        |
|                                                                             |
| DESCRIPTION		Procedure to submit the request for dispatch report   |
|                                                                             |
| CREATED BY            Sowmya - 28-Jun-2005                                  |
|                                                                             |
+============================================================================*/
PROCEDURE print_res_desp
                        (	errbuf              OUT NOCOPY VARCHAR2,
 				retcode             OUT NOCOPY VARCHAR2,
                                V_forg              IN NUMBER,
                                V_torg              IN NUMBER,
                                V_fres              IN VARCHAR2,
                                V_tores             IN VARCHAR2,
                                V_fres_instance     IN NUMBER,
                                V_tores_instance    IN NUMBER,
                                V_start_date        IN VARCHAR2,
                                V_to_date           IN VARCHAR2,
                                V_template          IN VARCHAR2,
                                V_template_locale   IN VARCHAR2
 			      ) IS

BEGIN

        --Initialising outpout values
        retcode          :=     -1;
        v_dblink         :=     NULL;
        f_org            :=     V_forg;
        t_org            :=     V_torg;

        --copying the parameter values into the global variables
        G_forg           :=       gmp_despatch_load_rpt_pkg.get_orgn_code(V_forg);
        G_torg           :=       gmp_despatch_load_rpt_pkg.get_orgn_code(V_torg);
        G_fres           :=       V_fres;
        G_tores          :=       V_tores;
        G_fres_instance  :=       V_fres_instance;
        G_tores_instance :=       V_tores_instance;
        G_start_date     :=       to_date(V_start_date,'yyyy/mm/dd hh24:mi:ss');
        G_to_date        :=       to_date(V_to_date,'yyyy/mm/dd hh24:mi:ss');
        G_template       :=       V_template;
        G_template_locale :=      V_template_locale;


   LOG_MESSAGE( 'Calling GMP_DESPATCH_LOAD_RPT_PKG.print_res_desp with values ');
   LOG_MESSAGE( ' G_forg  = '||G_forg);
   LOG_MESSAGE( ' G_torg  = '||G_torg);
   LOG_MESSAGE( ' G_fres  = '||G_fres);
   LOG_MESSAGE( ' G_tores = '||G_tores);
   LOG_MESSAGE( ' G_fres_instance = '||to_char(G_fres_instance));
   LOG_MESSAGE( ' G_tores_instance = '||to_char(G_tores_instance));
   LOG_MESSAGE( ' G_start_date = '||TO_CHAR(G_start_date,'DD-MON-YYYY HH24:MI:SS'));
   LOG_MESSAGE( ' G_to_date  = '||TO_CHAR(G_to_date,'DD-MON-YYYY HH24:MI:SS'));
   LOG_MESSAGE( ' G_template =  '||G_template);
   LOG_MESSAGE( ' G_template_locale '||G_template_locale);


        --generate the xml and insert into the gtmp table.
        gme_res_generate_xml;

        IF G_ret_code THEN
                retcode := 0;
                log_message('Successfully Completed!!');
        END IF;

        log_message('Return code = '|| retcode);

END print_res_desp;
/*============================================================================+
|                                                                             |
| PROCEDURE NAME	print_res_load                                        |
|                                                                             |
| DESCRIPTION		Procedure to submit the request for load report       |
|                                                                             |
| CREATED BY            Sowmya - 28-Jun-2005                                  |
|                                                                             |
+============================================================================*/
PROCEDURE print_res_load
                        (	errbuf              OUT NOCOPY VARCHAR2,
 				retcode             OUT NOCOPY VARCHAR2,
                                V_inst_id           IN NUMBER,
                                V_orgid             IN NUMBER,
                                V_plan_id           IN NUMBER,
                                V_forg              IN NUMBER,
                                V_torg              IN NUMBER,
                                V_fres              IN NUMBER,
                                V_tores             IN NUMBER,
                                V_fres_instance     IN NUMBER,
                                V_tores_instance    IN NUMBER,
                                V_start_date        IN VARCHAR2,
                                V_to_date           IN VARCHAR2,
                                V_template          IN VARCHAR2,
                                V_template_locale   IN VARCHAR2
 			      )IS
BEGIN
        --Initialising outpout values
	retcode          :=     -1;
        v_dblink         :=     NULL;
        f_org            :=     V_forg;
        t_org            :=     V_torg;
        inst_id          :=     V_inst_id;
        plan_id          :=     NVL(V_plan_id,0);

        SELECT DECODE( M2A_DBLINK,
                       NULL, ' ',
                      '@'||M2A_DBLINK) INTO v_dblink FROM MSC_APPS_INSTANCES
        WHERE INSTANCE_ID = V_inst_id ;

        log_message('Inside the procedure print_res_load');

        --copying the parameter values into the global variables
        G_forg           :=       gmp_despatch_load_rpt_pkg.get_orgn_code(V_forg);
        G_torg           :=       gmp_despatch_load_rpt_pkg.get_orgn_code(V_torg);
        G_inst           :=       gmp_despatch_load_rpt_pkg.get_inst_code(V_inst_id);
        G_plan           :=       gmp_despatch_load_rpt_pkg.get_plan_code(V_plan_id);

        IF V_fres IS NOT NULL THEN
           G_fres           :=     gmp_despatch_load_rpt_pkg.get_resource_desc(V_fres);
           f_res            :=     to_number(V_fres);
        ELSE
           G_fres           :=     NULL;
           f_res            :=     NULL;
        END IF;

        IF V_tores IS NOT NULL THEN
           G_tores          :=     gmp_despatch_load_rpt_pkg.get_resource_desc(V_tores);
           t_res            :=     to_number(V_tores);
        ELSE
           G_tores          :=     NULL;
           t_res            :=     NULL;
        END IF;

        G_fres_instance  :=       V_fres_instance;
        G_tores_instance :=       V_tores_instance;
        G_start_date     :=       to_date(V_start_date,'yyyy/mm/dd hh24:mi:ss');
        G_to_date        :=       to_date(V_to_date,'yyyy/mm/dd hh24:mi:ss');
        G_template       :=       V_template;
        G_template_locale :=      V_template_locale;

   LOG_MESSAGE( 'Calling GMP_DESPATCH_LOAD_RPT_PKG.print_res_load with values ');
   LOG_MESSAGE( ' v_inst_id = '||to_char(v_inst_id));
   LOG_MESSAGE( ' G_plan = '||G_plan);
   IF V_plan_id IS NULL THEN
    LOG_MESSAGE( ' No Plan Name, Please choose the plan name. Plan_id = '||to_char(plan_id));
   ELSE
    LOG_MESSAGE( ' V_plan_id = '||to_char(V_plan_id));
   END IF;
   LOG_MESSAGE( ' G_forg = '||G_forg);
   LOG_MESSAGE( ' G_torg = '||G_torg);
   LOG_MESSAGE( ' G_fres_instance = '||to_char(G_fres_instance));
   LOG_MESSAGE( ' G_tores_instance = '||to_char(G_tores_instance));
   LOG_MESSAGE( ' G_start_date = '||TO_CHAR(G_start_date,'DD-MON-YYYY HH24:MI:SS'));
   LOG_MESSAGE( ' G_to_date = '||TO_CHAR(G_to_date,'DD-MON-YYYY HH24:MI:SS'));
   LOG_MESSAGE( ' G_template = '||G_template);
   LOG_MESSAGE( ' G_template_locale = '||G_template_locale);

        --generate the xml and insert into the gtmp table.
        aps_res_generate_xml;

        IF G_ret_code THEN
                retcode := 0;
                log_message('Successfully Completed!!');
        END IF;

        log_message('Return code = '|| retcode);

END print_res_load;
/*============================================================================+
|                                                                             |
| PROCEDURE NAME	gme_res_generate_xml                                  |
|                                                                             |
| DESCRIPTION		Procedure used to Generate XML for GME resource batch |
|                       report.                                               |
|                                                                             |
| CREATED BY            Sowmya - 28-Jun-2005                                  |
|                                                                             |
+============================================================================*/
PROCEDURE gme_res_generate_xml IS

   qryCtx                 DBMS_XMLGEN.ctxHandle;
   result1                CLOB;
   x_stmt                 VARCHAR2(25000);
   seq_stmt               VARCHAR2(200);
   l_encoding             VARCHAR2(20);  /* B7481907 */
   l_xml_header           VARCHAR2(100); /* B7481907 */
   l_offset               PLS_INTEGER;   /* B7481907 */
   temp_clob              CLOB;          /* B7481907 */
   len                    PLS_INTEGER;   /* B7481907 */

BEGIN

    -- B7481907 Rajesh Patangya starts
    -- The following line of code ensures that XML data
    -- generated here uses the right encoding
        l_encoding       := fnd_profile.value('ICX_CLIENT_IANA_ENCODING');
        l_xml_header     := '<?xml version="1.0" encoding="'|| l_encoding ||'"?>';
        LOG_MESSAGE ('l_xml_header - '||l_xml_header);
    -- B7481907 Rajesh Patangya starts

x_stmt := ' SELECT ' ||
    ''''||G_forg||''''||' forg, ' ||
    ''''||G_torg||''''||' torg, ' ||
    ''''||G_fres||''''||' fres, ' ||
    ''''||G_tores||''''||' tores, ' ||
    ''''||G_fres_instance||''''||' fres_instance, ' ||
    ''''||G_tores_instance||''''||' tores_instance, ' ||
    ''''||G_start_date||''''||' fdate, ' ||
    ''''||G_to_date||''''||' tdate, ' ||
    ' CURSOR( ' ||
       ' SELECT  ' ||
          ' gmp_despatch_load_rpt_pkg.get_orgn_code(mp.organization_id) organzation_code, ' ||
          ' crd.resources resource_desc, ' ||
          ' crd.usage_uom uom, '||
          ' gi.instance_number instance_number, ' ||
          ' CURSOR(  ' ||
             ' SELECT h.batch_no batch_no, ' ||
             '        gs.batchstep_no operation, ' ||
             '        gsa.activity activity, ' ||
             '        to_char(t.start_date, '||''''||'dd-mon-yy hh24:mi:ss'||''''||')  start_date, '||
             '        to_char(t.end_date, '||''''||'dd-mon-yy hh24:mi:ss'||''''||')  end_date, '||
             '        msi.segment1 Item, ' ||
             '        round(t.resource_usage,3) resource_usage ' ||
             ' FROM  ' ||
             ' gme_batch_header h , '||
             ' gme_batch_steps	gs , '||
             ' gme_material_details gmt, '||
             ' gme_batch_step_activities gsa, '||
             ' gme_batch_step_resources gsr, '||
             ' gme_batch_step_items gsi, '||
             ' gme_resource_txns t, '||
             ' mtl_system_items msi, '||
             ' gmp_resource_instances gri '||
             ' WHERE  h.organization_id = mp.organization_id  '||
             ' and    h.batch_id = gs.batch_id '||
             ' and    h.batch_status in (1,2) '||
             ' and    gs.batch_id = gsa.batch_id '||
             ' and    gs.step_status in (1,2) '||
             ' and    gs.batchstep_id = gsa.batchstep_id '||
             ' and    gmt.batch_id = gs.batch_id '||
             ' and    gmt.batch_id = gsi.batch_id (+) '||
             ' and    gmt.material_detail_id = gsi.material_detail_id (+) '||
             ' and    gsi.batchstep_id = gs.batchstep_id (+) '||
             ' and    gsr.batch_id = gsa.batch_id '||
             ' and    gsr.batchstep_id = gsa.batchstep_id '||
             ' and    gsr.batchstep_activity_id = gsa.batchstep_activity_id '||
             ' and    gsr.resources = crd.resources '||
             ' and    gmt.organization_id = msi.organization_id '||
             ' and    gmt.inventory_item_id = msi.inventory_item_id '||
             ' and    gmt.batch_id = t.doc_id '||
             ' and    gsr.batchstep_resource_id = t.line_id '||
             ' and    t.completed_ind = 0 '||
             ' and    t.delete_mark = 0 '||
             ' and    t.start_date >= nvl( to_date('||''''||to_char(G_start_date, 'dd-mm-yy hh24:mi:ss' )||''''||','||''''||'dd-mm-yy hh24:mi:ss'||''''||'), t.start_date) '||
             ' and    t.end_date <= nvl( to_date('||''''||to_char(G_to_date, 'dd-mm-yy hh24:mi:ss')||''''||','||''''||'dd-mm-yy hh24:mi:ss'||''''||'), t.end_date) '||
             ' and    t.instance_id = gri.instance_id (+) '||
             ' and    nvl(gri.inactive_ind,0) = 0 '||
             ' and    gri.resource_id (+) = gi.resource_id  '||
             ' and    gri.instance_id (+) = gi.instance_id  '||
             ' order by 1,2,4 '||
          ' ) DETAIL ' ||
          ' FROM  ' ||
          ' mtl_parameters	mp, ' ||
          ' hr_organization_units hr, ' ||
          ' cr_rsrc_dtl crd, ' ||
          ' gmp_resource_instances gi '||
          ' WHERE  mp.organization_id = hr.organization_id '||
          ' and    mp.organization_id between  nvl('||''''||f_org||''''||', mp.organization_id)  and  nvl('||''''||t_org||''''||', mp.organization_id)'||
          ' and    crd.resources between nvl('||''''||G_fres||''''||', crd.resources)  and  nvl('||''''||G_tores||''''||', crd.resources)'||
          ' and    mp.process_enabled_flag = '||''''||'Y'||''''||
          ' and    nvl(hr.date_to,sysdate) >= sysdate '||
          ' and    crd.organization_id = mp.organization_id '||
          ' and    crd.resource_id = gi.resource_id (+) ';

        IF ( G_fres_instance IS NOT NULL ) OR ( G_tores_instance IS NOT NULL ) THEN
                x_stmt := x_stmt ||' and    gi.instance_number between nvl('||''''||G_fres_instance||''''||', gi.instance_number)  and  nvl('||''''||G_tores_instance||''''||', gi.instance_number)';
        END IF;

          x_stmt := x_stmt ||' order by 1,2,4 '||
    ' ) HEADER ' ||
' FROM DUAL ';

     -- LOG_MESSAGE(x_stmt);

     -- B7481907 Rajesh Patangya starts
         DBMS_LOB.createtemporary(temp_clob, TRUE);
         DBMS_LOB.createtemporary(result1, TRUE);

         qryctx := dbms_xmlgen.newcontext(x_stmt);

     -- generate XML data
         DBMS_XMLGEN.getXML (qryctx, temp_clob, DBMS_XMLGEN.none);
         l_offset := DBMS_LOB.INSTR (lob_loc => temp_clob,
                                     pattern => '>',
                                     offset  => 1,
                                     nth     => 1);
        LOG_MESSAGE('l_offset  - '||l_offset);

    -- Remove the header
        DBMS_LOB.erase (temp_clob, l_offset,1);

    -- The following line of code ensures that XML data
    -- generated here uses the right encoding
        DBMS_LOB.writeappend (result1, length(l_xml_header), l_xml_header);

    -- Append the rest to xml output
        DBMS_LOB.append (result1, temp_clob);

    -- close context and free memory
        DBMS_XMLGEN.closeContext(qryctx);
        DBMS_LOB.FREETEMPORARY (temp_clob);
     -- B7481907 Rajesh Patangya Ends

     seq_stmt := 'select gmp_matl_rep_id_s.nextval from dual ';
     EXECUTE IMMEDIATE seq_stmt INTO resdisp_rpt_id ;
     INSERT INTO GMP_RESDISP_XML_TEMP (RESDISP_XML_RPT_ID,RESULT) VALUES (resdisp_rpt_id, result1);
     DBMS_XMLGEN.closeContext(qryCtx);

     COMMIT;

     resdl_generate_output(resdisp_rpt_id);

     G_ret_code := TRUE;

EXCEPTION
WHEN OTHERS THEN
   LOG_MESSAGE ('Exception in procedure gme_res_generate_xml :'||SQLERRM);
   G_ret_code := FALSE;

END gme_res_generate_xml;
/*============================================================================+
|                                                                             |
| PROCEDURE NAME	aps_res_generate_xml                                  |
|                                                                             |
| DESCRIPTION		Procedure used to Generate XML for APS resource batch |
|                       report.                                               |
|                                                                             |
| CREATED BY            Sowmya - 28-Jun-2005                                  |
|                                                                             |
+============================================================================*/
PROCEDURE aps_res_generate_xml IS

   qryCtx                 DBMS_XMLGEN.ctxHandle;
   result1                CLOB;
   x_stmt1                VARCHAR2(25000);
   seq_stmt               VARCHAR2(200);
   l_encoding             VARCHAR2(20);  /* B7481907 */
   l_xml_header           VARCHAR2(100); /* B7481907 */
   l_offset               PLS_INTEGER;   /* B7481907 */
   temp_clob              CLOB;          /* B7481907 */
   len                    PLS_INTEGER;   /* B7481907 */

BEGIN

    -- B7481907 Rajesh Patangya starts
    -- The following line of code ensures that XML data
    -- generated here uses the right encoding
        l_encoding       := fnd_profile.value('ICX_CLIENT_IANA_ENCODING');
        l_xml_header     := '<?xml version="1.0" encoding="'|| l_encoding ||'"?>';
        LOG_MESSAGE ('l_xml_header - '||l_xml_header);
    -- B7481907 Rajesh Patangya starts

    -- B7669553 Select 40 characters for resource_description Rajesh Patangya

x_stmt1 := ' SELECT ' ||
    ''''||G_inst||''''||' Inst, ' ||
    ''''||G_plan||''''||' Plan, ' ||
    ''''||G_forg||''''||' forg, ' ||
    ''''||G_torg||''''||' torg, ' ||
    ''''||G_fres||''''||' fres, ' ||
    ''''||G_tores||''''||' tores, ' ||
    ''''||G_fres_instance||''''||' fres_instance, ' ||
    ''''||G_tores_instance||''''||' tores_instance, ' ||
    ''''||G_start_date||''''||' fdate, ' ||
    ''''||G_to_date||''''||' tdate, ' ||
    ' CURSOR( ' ||
       ' SELECT ' ||
          ' gmp_despatch_load_rpt_pkg.get_orgn_code(dr.organization_id)  organization_code, '||
          ' substr(dr.resource_description,1,40)  resource_desc,'||
          ' dr.unit_of_measure  UOM, '||
          ' mri.serial_number	Instance_number,'||
          ' CURSOR(  ' ||
             ' SELECT ms.transaction_id  Order_Id, '||
             '        decode(rr.routing_sequence_id,null,null,rt.routing_comment) routing_desc, '||
             '        decode(rr.operation_sequence_id,null,null,mr.operation_seq_num) oprseq_no, '||
             '        to_char(rr.start_date, '||''''||'dd-mon-yy hh24:mi:ss'||''''||')  St_date, '||
             '        to_char(rr.end_date, '||''''||'dd-mon-yy hh24:mi:ss'||''''||')  Edate, '||
             '        msi.item_name  Item, '||
             '        round(rr.resource_hours,3) resource_usage '||
             ' FROM  ' ||
             '  msc_resource_requirements rr, '||
             '  msc_supplies ms, '||
             '  msc_system_items msi, '||
             '  msc_operation_resources mor, '||
             '  msc_routing_operations mr, '||
             '  msc_routings rt '||
             ' WHERE	rr.sr_instance_id = ms.sr_instance_id  '||
             ' AND      rr.sr_instance_id = msi.sr_instance_id '||
             ' AND	rr.sr_instance_id = mor.sr_instance_id '||
             ' AND	rr.sr_instance_id = mr.sr_instance_id '||
             ' AND	rr.sr_instance_id = rt.sr_instance_id '||
             ' AND	rr.sr_instance_id = dr.sr_instance_id '||
             ' AND	rr.plan_id = ms.plan_id '||
             ' AND	rr.plan_id = msi.plan_id '||
             ' AND	rr.plan_id = mor.plan_id '||
             ' AND	rr.plan_id = mr.plan_id '||
             ' AND	rr.plan_id = rt.plan_id '||
             ' AND	rr.plan_id = dr.plan_id '||
             ' AND	rr.organization_id = ms.organization_id '||
             ' AND	rr.organization_id = msi.organization_id '||
             ' AND	rr.organization_id = mor.organization_id '||
--             ' AND	rr.organization_id = mr.organization_id '||
             ' AND	rr.organization_id = rt.organization_id '||
             ' AND	rr.organization_id = dr.organization_id '||
             ' AND	rr.supply_id = ms.transaction_id '||
             ' AND	ms.inventory_item_id = msi.inventory_item_id '||
             ' AND      rr.resource_id = mor.resource_id '||
             ' AND      rr.resource_id = dr.resource_id '||
             ' AND      rr.start_date >= nvl( to_date('||''''||to_char(G_start_date, 'dd-mm-yy hh24:mi:ss' )||''''||','||''''||'dd-mm-yy hh24:mi:ss'||''''||'), rr.start_date) '||
             ' AND      rr.end_date <= nvl( to_date('||''''||to_char(G_to_date, 'dd-mm-yy hh24:mi:ss')||''''||','||''''||'dd-mm-yy hh24:mi:ss'||''''||'), rr.end_date) '||
             ' AND	rr.resource_hours > 0 '||
             ' AND	rr.parent_id <> 2 ' ||
             ' AND      mor.routing_sequence_id = mr.routing_sequence_id '||
             ' AND      mor.operation_sequence_id = mr.operation_sequence_id '||
             ' AND      mr.routing_sequence_id = rt.routing_sequence_id '||
             ' AND	ms.order_type IN ( 5,17 ) '||
             ' UNION '||
             ' SELECT md.disposition_id   Order_Id, '||
             '        decode(rr.routing_sequence_id,null,null,rt.routing_comment) routing_desc, '||
             '        decode(rr.operation_sequence_id,null,null,mr.operation_seq_num) oprseq_no, '||
             '        to_char(rr.start_date, '||''''||'dd-mon-yy hh24:mi:ss'||''''||')  St_date, '||
             '        to_char(rr.end_date, '||''''||'dd-mon-yy hh24:mi:ss'||''''||')  Edate, '||
             '        msi.item_name  Item, '||
             '        round(rr.resource_hours,3) resource_usage '||
             ' FROM  ' ||
             '  msc_resource_requirements rr, '||
             '  msc_demands md, '||
             '  msc_system_items msi, '||
             '  msc_operation_resources mor, '||
             '  msc_routing_operations mr, '||
             '  msc_routings rt '||
             ' WHERE	rr.sr_instance_id = md.sr_instance_id  '||
             ' AND      rr.sr_instance_id = msi.sr_instance_id '||
             ' AND	rr.sr_instance_id = mor.sr_instance_id '||
             ' AND	rr.sr_instance_id = mr.sr_instance_id '||
             ' AND	rr.sr_instance_id = rt.sr_instance_id '||
             ' AND	rr.sr_instance_id = dr.sr_instance_id '||
             ' AND	rr.plan_id = md.plan_id '||
             ' AND	rr.plan_id = msi.plan_id '||
             ' AND	rr.plan_id = mor.plan_id '||
             ' AND	rr.plan_id = mr.plan_id '||
             ' AND	rr.plan_id = rt.plan_id '||
             ' AND	rr.plan_id = dr.plan_id '||
             ' AND	rr.organization_id = md.organization_id '||
             ' AND	rr.organization_id = msi.organization_id '||
             ' AND	rr.organization_id = mor.organization_id '||
--             ' AND	rr.organization_id = mr.organization_id '||
             ' AND	rr.organization_id = rt.organization_id '||
             ' AND	rr.organization_id = dr.organization_id '||
             ' AND	rr.supply_id = md.disposition_id '||
             ' AND	md.inventory_item_id = msi.inventory_item_id '||
             ' AND      rr.resource_id = mor.resource_id '||
             ' AND      rr.resource_id = dr.resource_id '||
             ' AND      rr.start_date >= nvl( to_date('||''''||to_char(G_start_date, 'dd-mm-yy hh24:mi:ss' )||''''||','||''''||'dd-mm-yy hh24:mi:ss'||''''||'), rr.start_date) '||
             ' AND      rr.end_date <= nvl( to_date('||''''||to_char(G_to_date, 'dd-mm-yy hh24:mi:ss')||''''||','||''''||'dd-mm-yy hh24:mi:ss'||''''||'), rr.end_date) '||
             ' AND	rr.resource_hours > 0 '||
             ' AND	rr.parent_id <> 2 ' ||
             ' AND      mor.routing_sequence_id = mr.routing_sequence_id '||
             ' AND      mor.operation_sequence_id = mr.operation_sequence_id '||
             ' AND      mr.routing_sequence_id = rt.routing_sequence_id '||
             ' AND	md.origination_type = 1 '||
             ' ORDER BY 1,4 '||
          ' ) DETAIL ' ||
          ' FROM  ' ||
          '     msc_dept_res_instances mri, '||
          '     msc_department_resources dr '||
          ' WHERE dr.sr_instance_id = '|| inst_id ||
          ' AND	dr.sr_instance_id = mri.sr_instance_id (+) '||
          ' AND	dr.plan_id = '|| plan_id ||
          ' AND	dr.plan_id = mri.plan_id (+)'||
          ' AND dr.organization_id between  nvl('||''''||f_org||''''||', dr.organization_id)  and  nvl('||''''||t_org||''''||', dr.organization_id)'||
          ' AND	dr.organization_id = mri.organization_id (+) '||
          ' AND dr.resource_id BETWEEN nvl('||''''||f_res||''''||', dr.resource_id)  and  nvl('||''''||t_res||''''||', dr.resource_id)'||
          ' AND dr.resource_id = mri.resource_id (+) ';

        IF ( G_fres_instance IS NOT NULL ) OR ( G_tores_instance IS NOT NULL ) THEN
                x_stmt1 := x_stmt1 ||' and    mri.res_instance_id between nvl('||''''||G_fres_instance||''''||', mri.res_instance_id)  and  nvl('||''''||G_tores_instance||''''||', mri.res_instance_id)';
        END IF;

          x_stmt1 := x_stmt1 ||' ORDER BY 1,2,4'||
    ' ) HEADER ' ||
' FROM DUAL ';

        LOG_MESSAGE(x_stmt1);

     -- B7481907 Rajesh Patangya starts
         DBMS_LOB.createtemporary(temp_clob, TRUE);
         DBMS_LOB.createtemporary(result1, TRUE);

         qryctx := dbms_xmlgen.newcontext(x_stmt1);

     -- generate XML data
         DBMS_XMLGEN.getXML (qryctx, temp_clob, DBMS_XMLGEN.none);
         l_offset := DBMS_LOB.INSTR (lob_loc => temp_clob,
                                     pattern => '>',
                                     offset  => 1,
                                     nth     => 1);
        LOG_MESSAGE('l_offset  - '||l_offset);

    -- Remove the header
        DBMS_LOB.erase (temp_clob, l_offset,1);

    -- The following line of code ensures that XML data
    -- generated here uses the right encoding
        DBMS_LOB.writeappend (result1, length(l_xml_header), l_xml_header);

    -- Append the rest to xml output
        DBMS_LOB.append (result1, temp_clob);

    -- close context and free memory
        DBMS_XMLGEN.closeContext(qryctx);
        DBMS_LOB.FREETEMPORARY (temp_clob);
     -- B7481907 Rajesh Patangya Ends

     seq_stmt := 'select gmp_matl_rep_id_s.nextval from dual ';
     EXECUTE IMMEDIATE seq_stmt INTO resdisp_rpt_id ;
     INSERT INTO GMP_RESDISP_XML_TEMP (RESDISP_XML_RPT_ID,RESULT) VALUES (resdisp_rpt_id, result1);
     DBMS_XMLGEN.closeContext(qryCtx);

     COMMIT;

     resdl_generate_output(resdisp_rpt_id);

     G_ret_code := TRUE;

EXCEPTION
WHEN OTHERS THEN
   LOG_MESSAGE ('Exception in procedure aps_res_generate_xml :'||SQLERRM);
   G_ret_code := FALSE;

END aps_res_generate_xml;
/*============================================================================+
|                                                                             |
| FUNCTION NAME	        get_orgn_code                                         |
|                                                                             |
| DESCRIPTION		Function to get the organization code                 |
|                                                                             |
| CREATED BY            Sowmya - 28-Jun-2005                                  |
|                                                                             |
+============================================================================*/
FUNCTION get_orgn_code( p_orgn_id  IN NUMBER) RETURN VARCHAR2  IS

TYPE ref_cursor_typ IS REF CURSOR;
cur_orgn_code 	ref_cursor_typ ;
l_orgn_code VARCHAR2(4);
v_sql_stmt  VARCHAR2(1000);

BEGIN
   l_orgn_code := NULL;
    /*    OPEN cur_orgn_code FOR
                SELECT organization_code FROM mtl_parameters
                WHERE organization_id = p_orgn_id;
    */

         v_sql_stmt :=
             'SELECT '
          || ' mp.organization_code '
          || 'FROM '
          || '  mtl_parameters' ||v_dblink|| ' mp '
          || 'WHERE '
          || '  mp.organization_id =:p1' ;

        OPEN cur_orgn_code FOR v_sql_stmt USING p_orgn_id;
        FETCH cur_orgn_code INTO l_orgn_code ;
        CLOSE cur_orgn_code ;

        RETURN l_orgn_code;

END get_orgn_code;

/*============================================================================+
|                                                                             |
| FUNCTION NAME	        get_inst_code                                         |
|                                                                             |
| DESCRIPTION		Function to get the Instance code                     |
|                                                                             |
| CREATED BY            Sowmya - 28-Jun-2005                                  |
|                                                                             |
+============================================================================*/
FUNCTION get_inst_code( p_inst_id IN NUMBER) RETURN VARCHAR2 IS

TYPE ref_cursor_typ IS REF CURSOR;
cur_inst_code 	ref_cursor_typ ;

l_inst_code VARCHAR2(4);

BEGIN
        OPEN cur_inst_code FOR
                SELECT instance_code FROM msc_apps_instances
                WHERE instance_id = p_inst_id;

        FETCH cur_inst_code INTO l_inst_code ;

        CLOSE cur_inst_code ;

        RETURN l_inst_code;

END get_inst_code;

/*============================================================================+
|                                                                             |
| FUNCTION NAME	        get_plan_code                                         |
|                                                                             |
| DESCRIPTION		Function to get the Plan name                         |
|                                                                             |
| CREATED BY            Sowmya - 28-Jun-2005                                  |
|                                                                             |
+============================================================================*/
FUNCTION get_plan_code( p_plan_id IN NUMBER) RETURN VARCHAR2 IS

TYPE ref_cursor_typ IS REF CURSOR;
cur_plan_code 	ref_cursor_typ ;

l_plan_name VARCHAR2(10);

BEGIN
        OPEN cur_plan_code FOR
                SELECT compile_designator FROM msc_plans
                WHERE plan_id = p_plan_id;

        FETCH cur_plan_code INTO l_plan_name ;

        CLOSE cur_plan_code ;

        RETURN l_plan_name;

END get_plan_code;

/*============================================================================+
|                                                                             |
| FUNCTION NAME	        get_resource_desc                                     |
|                                                                             |
| DESCRIPTION		Function to get the Resources                         |
|                                                                             |
| CREATED BY            Sowmya - 28-Jun-2005                                  |
|                                                                             |
+============================================================================*/
FUNCTION get_resource_desc( p_resource_id IN NUMBER) RETURN VARCHAR2 IS

TYPE ref_cursor_typ IS REF CURSOR;
cur_res_desc 	ref_cursor_typ ;

l_resource VARCHAR2(40);

BEGIN
    -- B7669553 Select 40 characters for resource_description Rajesh Patangya
        OPEN cur_res_desc FOR
                SELECT distinct substr(resource_description,1,40) FROM msc_department_resources
                WHERE  plan_id = plan_id
                AND    resource_id = p_resource_id
                AND    sr_instance_id = inst_id;

        FETCH cur_res_desc INTO l_resource ;

        CLOSE cur_res_desc ;

        RETURN l_resource;

END get_resource_desc;

/*============================================================================+
|                                                                             |
| PROCEDURE NAME        get_orgn_code                                         |
|                                                                             |
| DESCRIPTION		Procedure for logging messages in log file            |
|                                                                             |
| CREATED BY            Sowmya - 28-Jun-2005                                  |
|                                                                             |
+============================================================================*/
PROCEDURE LOG_MESSAGE(pBUFF  IN  VARCHAR2) IS

   BEGIN

     IF fnd_global.conc_request_id > 0  THEN
         FND_FILE.PUT_LINE( FND_FILE.LOG, pBUFF);
     ELSE
         NULL;
     END IF;

   EXCEPTION
     WHEN OTHERS THEN
        RETURN;

END LOG_MESSAGE;

/* ***************************************************************
* NAME
*	PROCEDURE - resdl_generate_output
*
* DESCRIPTION
*     Procedure used generate the final output.
*
*************************************************************** */

PROCEDURE resdl_generate_output (
   p_sequence_num    IN    NUMBER
)
IS

l_conc_id               NUMBER;
l_req_id                NUMBER;
l_phase			VARCHAR2(20);
l_status_code		VARCHAR2(20);
l_dev_phase		VARCHAR2(20);
l_dev_status		VARCHAR2(20);
l_message		VARCHAR2(20);
l_status		BOOLEAN;


BEGIN

  l_conc_id := FND_REQUEST.SUBMIT_REQUEST('GMP','GMPRESDP','', '',FALSE,
        	   p_sequence_num, chr(0),'','','','','','','','','','','',
		    '','','','','','','','','','','','','','','',
		    '','','','','','','','','','',
		    '','','','','','','','','','',
		    '','','','','','','','','','',
		    '','','','','','','','','','',
		    '','','','','','','','','','',
		    '','','','','','','','','','',
		    '','','','','','','','','','');

   IF l_conc_id = 0 THEN
      G_log_text := FND_MESSAGE.GET;
      FND_FILE.PUT_LINE ( FND_FILE.LOG,G_log_text);
   ELSE
      COMMIT ;
   END IF;

   IF l_conc_id <> 0 THEN

      l_status := fnd_concurrent.WAIT_FOR_REQUEST
            (
                REQUEST_ID    =>  l_conc_id,
                INTERVAL      =>  30,
                MAX_WAIT      =>  900,
                PHASE         =>  l_phase,
                STATUS        =>  l_status_code,
                DEV_PHASE     =>  l_dev_phase,
                DEV_STATUS    =>  l_dev_status,
                MESSAGE       =>  l_message
            );

      DELETE FROM GMP_RESDISP_XML_TEMP WHERE RESDISP_XML_RPT_ID = p_sequence_num;

     /* Bug: 6609251 Vpedarla added a NULL parameters for the submition of the FND request for XDOREPPB */
      l_req_id := FND_REQUEST.SUBMIT_REQUEST('XDO','XDOREPPB','', '',FALSE,'',
        	    l_conc_id,554,G_template,
		    G_template_locale,'N','','','','','','','','',
		    '','','','','','','','','','','','','','','',
		    '','','','','','','','','','',
		    '','','','','','','','','','',
		    '','','','','','','','','','',
		    '','','','','','','','','','',
		    '','','','','','','','','','',
		    '','','','','','','','','','',
		    '','','','','','','','','','');
   END IF;

EXCEPTION
   WHEN OTHERS THEN
   log_message('Exception in procedure resdl_generate_output '||SQLERRM);
END resdl_generate_output;

/* ***************************************************************
* NAME
*	PROCEDURE - rd_xml_transfer
*
* DESCRIPTION
*     Procedure used provide the XML as output of the concurrent program.
*
*************************************************************** */

PROCEDURE rd_xml_transfer (
errbuf              OUT NOCOPY VARCHAR2,
retcode             OUT NOCOPY VARCHAR2,
p_sequence_num      IN  NUMBER
)IS

l_file CLOB;
file_varchar2 VARCHAR2(32767);
m_file CLOB;
l_len NUMBER;
l_limit NUMBER;

BEGIN

   SELECT RESULT INTO l_file
   FROM GMP_RESDISP_XML_TEMP
   WHERE RESDISP_XML_RPT_ID = p_sequence_num;

   l_limit:= 1;
   l_len := DBMS_LOB.GETLENGTH (l_file);
   -- log_message (' l_len - '||l_len);

   LOOP
      IF l_len > l_limit THEN
--BUG 6646373 DBMS_LOB.SUBSTR was failing for multi byte character as l_file being CLOB type variable.
--Introduced another clob variable m_file and after trimming it assigned to the varchar type variable.
--       file_varchar2 := DBMS_LOB.SUBSTR (l_file,100,l_limit);
         M_FILE := DBMS_LOB.SUBSTR (l_file,100,l_limit);
	 file_varchar2:=trim(M_FILE);
         FND_FILE.PUT(FND_FILE.OUTPUT, file_varchar2);
         FND_FILE.PUT(FND_FILE.LOG,file_varchar2);
         file_varchar2 := NULL;
         m_file :=NULL;
         l_limit:= l_limit + 100;
      ELSE
  --       file_varchar2 := DBMS_LOB.SUBSTR (l_file,100,l_limit);
         M_FILE := DBMS_LOB.SUBSTR (l_file,100,l_limit);
         file_varchar2:=trim(M_FILE);
         FND_FILE.PUT(FND_FILE.OUTPUT, file_varchar2);
         FND_FILE.PUT(FND_FILE.LOG,file_varchar2);
         file_varchar2 := NULL;
         m_file :=NULL;
         EXIT;
      END IF;
   END LOOP;

EXCEPTION
   WHEN OTHERS THEN
   log_message ('Exception in procedure rd_xml_transfer '||SQLERRM);
END rd_xml_transfer;

END GMP_DESPATCH_LOAD_RPT_PKG;

/
