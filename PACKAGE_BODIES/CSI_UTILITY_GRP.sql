--------------------------------------------------------
--  DDL for Package Body CSI_UTILITY_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_UTILITY_GRP" AS
/* $Header: csigutlb.pls 120.13 2007/02/13 22:22:09 jpwilson ship $ */

   PROCEDURE debug_con_log(p_message IN varchar2) IS
   BEGIN
     FND_FILE.PUT_LINE (FND_FILE.LOG, p_message );
   END debug_con_log;

   -- g_pkg_name              VARCHAR2(30) := 'CSI_UTILITY_GRP';


   PROCEDURE debug(p_message IN varchar2) IS

   BEGIN
      csi_t_gen_utility_pvt.add(p_message);
   EXCEPTION
     WHEN others THEN
       null;
   END debug;

    -- This Function can be used to check if Oracle Installed Base
    -- Product is Installed and Active at an Implementation. This
    -- would check for a freeze_flag in Install Parameters.
    FUNCTION IB_ACTIVE RETURN BOOLEAN IS
      l_freeze_flag	VARCHAR2(1) := 'N';
    BEGIN
      BEGIN
        SELECT nvl(freeze_flag, 'N')
        INTO   l_freeze_flag
        FROM   csi_install_parameters
        WHERE  rownum = 1;
        IF l_freeze_flag = 'Y' THEN
          return TRUE;
        ELSE
          return FALSE;
        END IF;
      EXCEPTION
        WHEN others THEN
          return FALSE;
      END;
    END IB_ACTIVE;

    --
    -- This Function can be used to check if Oracle Installed Base
    -- Product is Installed and Active at an Implementation. This
    -- would check for a freeze_flag in Install Parameters.
    -- This function returns a VARCHAR2 in the form 'Y' or 'N'
    -- and can be used in a SQL statement in the predicate.
    --
    FUNCTION IB_ACTIVE_FLAG RETURN VARCHAR2 IS
      l_freeze_flag	VARCHAR2(1) := 'N';
    BEGIN
      BEGIN
        SELECT nvl(freeze_flag, 'N')
        INTO   l_freeze_flag
        FROM   csi_install_parameters
        WHERE  rownum = 1;
        IF l_freeze_flag = 'Y' THEN
          return 'Y';
        ELSE
          return 'N';
        END IF;
      EXCEPTION
        WHEN others THEN
          return 'N';
      END;
    END IB_ACTIVE_FLAG;

    --
    -- This function returns the version of the Installed Base
    -- This would be 1150 when it is on pre 1156
    --
    FUNCTION IB_VERSION RETURN NUMBER IS
    BEGIN
       If IB_ACTIVE Then
           RETURN 1156;
       Else
           RETURN 1150;
       End If;
    Exception
        When Others Then
            Return 1150;
    END IB_VERSION;

    --
    -- This procedure check if the installed base is active, If not active
    -- populates the error message in the message queue and raises the
    -- fnd_api.g_exc_error exception
    --

    PROCEDURE check_ib_active
    IS
    BEGIN
      -- srramakr modified to look at csi_gen_utility_pvt since ib_active in current package
      -- has Pragma restriction. (Cursor optimization)
      IF NOT csi_gen_utility_pvt.IB_ACTIVE THEN
        FND_MESSAGE.Set_Name('CSI', 'CSI_IB_NOT_ACTIVE');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_Exc_Error;
      END IF;
    EXCEPTION
      WHEN fnd_api.g_exc_error THEN

        RAISE fnd_api.g_exc_error;

      WHEN others THEN
        FND_MESSAGE.Set_Name('CSI', 'CSI_UNEXP_SQL_ERROR');
        FND_MESSAGE.Set_Token('API_NAME', 'Check_IB_Active');
        FND_MESSAGE.Set_Token('SQL_ERROR', sqlerrm);
        FND_MSG_PUB.Add;

        RAISE fnd_api.g_exc_error;
    END check_ib_active;


  --
  --
  --
  PROCEDURE get_config_key_for_om_line(
    p_line_id              IN  number,
    x_config_session_key   OUT NOCOPY config_session_key,
    x_return_status        OUT NOCOPY varchar2,
    x_return_message       OUT NOCOPY varchar2)
  IS
    l_return_status        varchar2(1) := fnd_api.g_ret_sts_success;
    l_session_key          config_session_key;

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    BEGIN
      SELECT config_header_id,
             config_rev_nbr,
             configuration_id
      INTO   l_session_key.session_hdr_id,
             l_session_key.session_rev_num,
             l_session_key.session_item_id
      FROM   oe_order_lines_all
      WHERE  line_id = p_line_id;

      IF csi_interface_pkg.check_macd_processing (
           p_config_session_key => l_session_key,
           x_return_status      => l_return_status)
      THEN
        x_config_session_key := l_session_key;
      END IF;

    EXCEPTION
      WHEN no_data_found THEN
        -- stack error message
        RAISE fnd_api.g_exc_error;
    END;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END get_config_key_for_om_line;

  --
  --
  --
  PROCEDURE get_config_inst_valid_status(
    p_instance_key         IN  config_instance_key,
    x_config_valid_status  OUT NOCOPY varchar2,
    x_return_status        OUT NOCOPY varchar2,
    x_return_message       OUT NOCOPY varchar2)
  IS
  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    BEGIN

      SELECT config_valid_status
      INTO   x_config_valid_status
      FROM   csi_t_transaction_lines ctl,
             csi_t_txn_line_details  ctd
      WHERE  ctd.config_inst_hdr_id = p_instance_key.inst_hdr_id
      AND    ctd.config_inst_rev_num = p_instance_key.inst_rev_num
      AND    ctd.config_inst_item_id = p_instance_key.inst_item_id
      AND    ctl.transaction_line_id = ctd.transaction_line_id;
    EXCEPTION
      WHEN no_data_found THEN
        RAISE fnd_api.g_exc_error;
    END;

    --x_config_valid_status := 'VALID';

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END get_config_inst_valid_status;

  FUNCTION is_network_component(
    p_order_line_id   IN number,
    x_return_status   OUT NOCOPY varchar2)
  RETURN boolean
  IS
    l_session_key     config_session_key;
    l_return_status   varchar2(1);
    l_macd_flag       boolean := FALSE;
  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    SELECT config_header_id,
           config_rev_nbr,
           configuration_id
    INTO   l_session_key.session_hdr_id,
           l_session_key.session_rev_num,
           l_session_key.session_item_id
    FROM   oe_order_lines_all
    WHERE  line_id = p_order_line_id;

    IF csi_interface_pkg.check_macd_processing(
         p_config_session_key => l_session_key,
         x_return_status      => l_return_status)
    THEN
      l_macd_flag := TRUE;
    END IF;

    return l_macd_flag;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END is_network_component;

  PROCEDURE vld_item_ctrl_changes (
     p_api_version           IN   NUMBER
    ,p_commit                IN   VARCHAR2 := fnd_api.g_false
    ,p_init_msg_list         IN   VARCHAR2 := fnd_api.g_false
    ,p_validation_level      IN   NUMBER   := fnd_api.g_valid_level_full
    ,p_inventory_item_id     IN   NUMBER
    ,p_organization_id       IN   NUMBER
    ,p_item_attr_name        IN   VARCHAR2
    ,p_new_item_attr_value   IN   VARCHAR2
    ,p_old_item_attr_value   IN   VARCHAR2
    ,x_return_status         OUT  NOCOPY VARCHAR2
    ,x_msg_count             OUT  NOCOPY NUMBER
    ,x_msg_data              OUT  NOCOPY VARCHAR2) IS

    l_master_org_id          NUMBER;
    sfm_event_error          EXCEPTION;
    csi_exist_txn_error      EXCEPTION;
    mtl_iface_error          EXCEPTION;
    mtl_temp_error           EXCEPTION;
    active_ib_inst_error     EXCEPTION;
    csi_exist_sfm_error      EXCEPTION;

  BEGIN

    BEGIN
      SELECT master_organization_id
      INTO l_master_org_id
      FROM mtl_parameters
      WHERE organization_id = p_organization_id;

    EXCEPTION
     WHEN OTHERS then
       l_master_org_id := NULL;
    END;

    IF csi_item_instance_vld_pvt.is_trackable(p_inv_item_id => p_inventory_item_id,
                                              p_org_id      => l_master_org_id) THEN
      -- Check for READY or ERROR SFM Messages
      IF csi_utility_grp.vld_exist_sfm_events(p_inventory_item_id) THEN
        raise sfm_event_error;
      END IF;

      -- Chcck for ERROR or PENDING CSI Errors
      IF csi_utility_grp.vld_exist_txn_errors(p_inventory_item_id) THEN
        raise csi_exist_txn_error;
      END IF;

      -- Check MTL Transaction Interface Table
      IF csi_utility_grp.vld_exist_mtl_iface_recs(p_inventory_item_id,
                                                  p_organization_id) THEN
        raise mtl_iface_error;
      END IF;

      -- Check MTL Transaction Temp Table
      IF csi_utility_grp.vld_exist_mtl_temp_recs(p_inventory_item_id,
                                                 p_organization_id) THEN
        raise mtl_temp_error;
      END IF;

      -- Check for Active IB Instances
      IF csi_utility_grp.vld_active_ib_inst(p_inventory_item_id) THEN
        raise active_ib_inst_error;
      END IF;
    END IF;

    x_msg_data := NULL;
    x_return_status := fnd_api.g_ret_sts_success;
    x_msg_count := NULL;

  EXCEPTION
    WHEN sfm_event_error THEN
      fnd_message.set_name('CSI','CSI_IM_EXIST_SFM_ERROR');
      x_return_status := fnd_api.g_ret_sts_error;
      x_msg_count     := 1;
      x_msg_data      := fnd_message.get;

    WHEN csi_exist_txn_error THEN
      fnd_message.set_name('CSI','CSI_IM_EXIST_ERROR');
      x_return_status := fnd_api.g_ret_sts_error;
      x_msg_count     := 1;
      x_msg_data      := fnd_message.get;

    WHEN mtl_iface_error THEN
      fnd_message.set_name('CSI','CSI_IM_MTL_IFACE_ERROR');
      x_return_status := fnd_api.g_ret_sts_error;
      x_msg_count     := 1;
      x_msg_data      := fnd_message.get;

    WHEN mtl_temp_error THEN
      fnd_message.set_name('CSI','CSI_IM_MTL_IFACE_TEMP');
      x_return_status := fnd_api.g_ret_sts_error;
      x_msg_count     := 1;
      x_msg_data      := fnd_message.get;

    WHEN active_ib_inst_error THEN
      fnd_message.set_name('CSI','CSI_IM_ACTIVE_IB_INST');
      x_return_status := fnd_api.g_ret_sts_error;
      x_msg_count     := 1;
      x_msg_data      := fnd_message.get;

  END vld_item_ctrl_changes;


  FUNCTION vld_exist_txn_errors (p_item_id IN NUMBER) RETURN BOOLEAN IS

  l_record_found     NUMBER  := NULL;

  BEGIN
    select 1
    into   l_record_found
    from   csi_txn_errors cte,
           mtl_material_transactions mmt
    where  mmt.transaction_id = cte.inv_material_transaction_id
    and    mmt.inventory_item_id = p_item_id
    and    cte.processed_flag in ('R','E','W')
    and    rownum < 2;

    RETURN(TRUE);

  EXCEPTION
    WHEN no_data_found THEN
      RETURN(FALSE);

  END vld_exist_txn_errors;

  FUNCTION vld_exist_mtl_iface_recs (p_item_id IN NUMBER,
                                     p_org_id  IN NUMBER) RETURN BOOLEAN IS

  l_record_found     NUMBER  := NULL;

  BEGIN
    select 1
    into   l_record_found
    from   mtl_transactions_interface mti
    where  mti.inventory_item_id = p_item_id
    and    mti.organization_id = p_org_id
    and    rownum < 2;

    RETURN(TRUE);

  EXCEPTION
    WHEN no_data_found THEN
      RETURN(FALSE);

  END vld_exist_mtl_iface_recs;

  FUNCTION vld_exist_mtl_temp_recs (p_item_id IN NUMBER,
                                    p_org_id  IN NUMBER) RETURN BOOLEAN IS

  l_record_found     NUMBER  := NULL;

  BEGIN
    select 1
    into   l_record_found
    from   mtl_material_transactions_temp mmtt
    where  mmtt.inventory_item_id = p_item_id
    and    mmtt.organization_id = p_org_id
    and    rownum < 2;

    RETURN(TRUE);

  EXCEPTION
    WHEN no_data_found THEN
      RETURN(FALSE);

  END vld_exist_mtl_temp_recs;

  FUNCTION vld_exist_sfm_events (p_item_id IN NUMBER) RETURN BOOLEAN IS

  l_freeze_date     DATE;

    CURSOR msg_cur(pc_freeze_date IN DATE) is
      SELECT msg_id,
             msg_code,
             msg_status,
             body_text,
             creation_date,
             description
      FROM   xnp_msgs
      WHERE  (msg_code like 'CSI%' OR msg_code like 'CSE%')
      AND    msg_status in ('READY','FAILED')
      AND    msg_creation_date > pc_freeze_date
    --  AND    nvl(msg_status, 'READY') <> 'PROCESSED' -- commented for Bug 3987286
      AND    recipient_name is null;

    l_amount        integer;
    l_msg_text      varchar2(32767);
    l_source_id     NUMBER;
    l_source_id1    NUMBER;
    l_item_id       number;

  BEGIN

    IF csi_datastructures_pub.g_install_param_rec.fetch_flag IS NULL THEN
       csi_gen_utility_pvt.populate_install_param_rec;
    END IF;

    IF csi_datastructures_pub.g_install_param_rec.freeze_date is NULL then
      SELECT freeze_date
      INTO l_freeze_date
      FROM csi_install_parameters
      WHERE rownum = 1;
    ELSE
      l_freeze_date := csi_datastructures_pub.g_install_param_rec.freeze_date;
    END IF;

    FOR msg_rec in msg_cur (l_freeze_date)
    LOOP
      l_amount := null;
      l_amount := dbms_lob.getlength(msg_rec.body_text);
      l_msg_text := null;
      l_item_id  := null;

      dbms_lob.read(
        lob_loc => msg_rec.body_text,
        amount  => l_amount,
        offset  => 1,
        buffer  => l_msg_text );

      l_source_id := null;

      IF msg_rec.msg_code in ('CSISOFUL', 'CSIRMAFL') THEN

        xnp_xml_utils.decode(l_msg_text, 'ORDER_LINE_ID', l_source_id);

        BEGIN
          select inventory_item_id
          into l_item_id
          from oe_order_lines_all
          where line_id = l_source_id;

          IF p_item_id = l_item_id THEN
            RETURN(TRUE);
          END IF;

        EXCEPTION
          WHEN no_data_found THEN
            -- Record could have been purged so do nothing
            null;
        END;

      ELSIF msg_rec.msg_code in ('CSICYCNT',
                                 'CSIINTDS',
                                 'CSIINTSR',
                                 'CSIINTSS',
                                 'CSIISUHZ',
                                 'CSIISUPT',
                                 'CSIMSIHZ',
                                 'CSIMSIPT',
                                 'CSIMSISU',
                                 'CSIMSRCV',
                                 'CSIMSRHZ',
                                 'CSIMSRPT',
                                 'CSIOKSHP',
                                 'CSIORGDS',
                                 'CSIORGTR',
                                 'CSIORGTS',
                                 'CSIPHYIN',
                                 'CSIPOINV',
                                 'CSIRMARC',
                                 'CSISOSHP',
                                 'CSISUBTR',
                                 'CSIWIPAC',
                                 'CSIWIPAR',
                                 'CSIWIPCI',
                                 'CSIWIPCR',
                                 'CSIWIPNI',
                                 'CSIWIPNR',
                                 'CSILOSHP',
                                 'CSIEAMRR',
                                 'CSIEAMWC',
                                 'CSIWIPBR',
                                 'CSIWIPBC') THEN

        xnp_xml_utils.decode(l_msg_text, 'MTL_TRANSACTION_ID', l_source_id);
        xnp_xml_utils.decode(l_msg_text, 'INVENTORY_ITEM_ID', l_source_id1);

        IF l_source_id1 IS NULL THEN
          BEGIN
            select inventory_item_id
            into l_item_id
            from mtl_material_transactions
            where transaction_id = l_source_id;

            IF p_item_id = l_item_id THEN
              RETURN(TRUE);
            END IF;

          EXCEPTION
            WHEN no_data_found THEN
              -- Record could have been purged so do nothing
              null;
          END;

       ELSE -- Inventory Item ID is in XML Message

         IF p_item_id = l_source_id1 THEN
           RETURN(TRUE);
         END IF;

      END IF;

      ELSIF msg_rec.msg_code = 'CSEPORCV' THEN
        xnp_xml_utils.decode(l_msg_text, 'RCV_TRANSACTION_ID', l_source_id);

        BEGIN
          select  pla.Item_Id
          into    l_item_id
          from    rcv_transactions        rt,
                  po_lines_all            pla
          where   rt.transaction_id = l_source_id
          and     rt.po_Line_Id = pla.po_Line_Id;

          IF p_item_id = l_item_id THEN
            RETURN(TRUE);
          END IF;

        EXCEPTION
          WHEN others THEN
            -- Record could have been purged so do nothing
            null;
        END;

      ELSIF msg_rec.msg_code in ('CSEOUTSV',
                                 'CSEITUNI',
                                 'CSEITSVS',
                                 'CSEITMVS',
                                 'CSEITINS',
                                 'CSEINSVS') THEN
        -- WFM Transactions for CSE
        xnp_xml_utils.decode(l_msg_text, 'ITEM_ID', l_source_id);

          IF p_item_id = l_source_id THEN
            RETURN(TRUE);
          END IF;

      END IF;

    END LOOP;

    RETURN(FALSE);

  END vld_exist_sfm_events;

  FUNCTION vld_active_ib_inst (p_item_id IN NUMBER) RETURN BOOLEAN IS

  l_record_found     NUMBER  := NULL;

  BEGIN
    select 1
    into   l_record_found
    from   csi_item_instances cii
    where  cii.inventory_item_id = p_item_id
    and    cii.active_end_date IS  NULL
    and    rownum < 2;

    RETURN(TRUE);

  EXCEPTION
    WHEN no_data_found THEN
      RETURN(FALSE);

  END vld_active_ib_inst;


  /********** Start New Functions for Inventory MACD validations **********/

  -- check_inv_serial_cz_keys will call the other 3 functions internally
  -- and will return either Y or N
  --
  -- N = Serial Number is NOT in a MACD Configuration
  --
  -- Y = Serial number IS in a MACD Configuration
  --
  --

  FUNCTION check_inv_serial_cz_keys (p_inventory_item_id IN   NUMBER,
                                     p_organization_id   IN   NUMBER,
                                     p_serial_number     IN   VARCHAR2) RETURN VARCHAR2 IS

  inv_inst_cz_keys    EXCEPTION;

  BEGIN
    -- Check to see if an instance exists and has the Config Keys on it.

    IF csi_utility_grp.check_inv_inst_cz_keys(p_inventory_item_id,
	                                      p_organization_id,
	                                      p_serial_number) THEN
      raise inv_inst_cz_keys;
    END IF;

    -- Check to see if an instance exists that has an error and has the Config Keys on it.

    IF csi_utility_grp.check_inv_error_cz_keys(p_inventory_item_id,
                                               p_organization_id,
                                               p_serial_number) THEN
      raise inv_inst_cz_keys;
    END IF;

    -- Check to see if an instance exists in a Pending or Failed in the
    -- Status in the SFM Queue and if it has Config Keys on it.

    IF csi_utility_grp.check_inv_sfm_cz_keys(p_inventory_item_id,
                                             p_organization_id,
                                             p_serial_number) THEN
      raise inv_inst_cz_keys;
    END IF;

    -- All functions did not return anything so there are no items that qualify to be
    -- In a MACD Configuration. So return 'N'

    Return 'N';

  EXCEPTION

  WHEN inv_inst_cz_keys THEN
    RETURN 'Y';

  WHEN others THEN
    RETURN 'Y';

  END; -- End of check_inv_serial_cz_keys

  FUNCTION check_inv_inst_cz_keys (p_inventory_item_id  IN   NUMBER,
                                   p_organization_id    IN   NUMBER,
                                   p_serial_number      IN  VARCHAR2) RETURN BOOLEAN IS

  l_record_found     NUMBER  := NULL;

  BEGIN
    SELECT 1
    INTO l_record_found
    FROM csi_item_instances
    WHERE inventory_item_id = p_inventory_item_id
    AND serial_number = p_serial_number
    AND config_inst_hdr_id is NOT NULL
    AND config_inst_rev_num is NOT NULL
    AND config_inst_item_id is NOT NULL;

    RETURN (TRUE);

    EXCEPTION
      WHEN no_data_found THEN
        RETURN(FALSE);

      WHEN others THEN
        RETURN(TRUE);
  END; -- check_inv_inst_cz_keys


  FUNCTION check_inv_error_cz_keys (p_inventory_item_id IN   NUMBER,
                                    p_organization_id   IN   NUMBER,
                                    p_serial_number     IN  VARCHAR2) RETURN BOOLEAN IS


  l_config_keys 		csi_utility_grp.config_session_key;
  l_return_status               VARCHAR2(1);

  BEGIN

  SELECT  ool.config_header_id    config_session_hdr_id,
          ool.config_rev_nbr      config_session_rev_num,
          ool.configuration_id    config_session_item_id
  INTO   l_config_keys.session_hdr_id,
         l_config_keys.session_rev_num,
         l_config_keys.session_item_id
  FROM	csi_txn_errors cte,
        mtl_material_transactions mmt,
        mtl_unit_transactions mut,
        oe_order_lines_all ool
  WHERE  mmt.transaction_id = mut.transaction_id
  AND    mmt.transaction_action_id = 1
  AND    mmt.transaction_source_type_id = 2
  AND    mut.transaction_id =  cte.inv_material_transaction_id
  AND    mut.inventory_item_id = p_inventory_item_id
  AND    mut.serial_number = p_serial_number
  AND    cte.processed_flag in ('R','E','W')
  AND    cte.transaction_type_id = 51
  AND    mmt.trx_source_line_id = ool.line_id;

  IF csi_interface_pkg.check_MACD_processing(l_config_keys,
	    			             l_return_status) THEN

  -- There are records that are errored but not processed to Install Base Yet
    RETURN (TRUE);
  ELSE
  -- There are no records that are errored just exit.
    RETURN (FALSE);
  END IF;

  EXCEPTION
    WHEN no_data_found THEN
    RETURN(FALSE);

  WHEN others THEN
    RETURN(TRUE);

  END; -- check_inv_error_cz_keys


  FUNCTION check_inv_sfm_cz_keys (p_inventory_item_id   IN   NUMBER,
                                  p_organization_id     IN   NUMBER,
                                  p_serial_number       IN  VARCHAR2) RETURN BOOLEAN IS


  l_freeze_date 	DATE;
  l_config_keys         csi_utility_grp.config_session_key;
  l_return_status       VARCHAR2(1);

  CURSOR msg_cur(pc_freeze_date IN DATE) is
    SELECT msg_id,
           msg_code,
           msg_status,
           body_text,
           creation_date,
           description
    FROM   xnp_msgs
    WHERE  msg_code = 'CSISOSHP'
    AND    msg_status in ('READY','FAILED')
    AND    msg_creation_date > pc_freeze_date
    AND    recipient_name is null;

  CURSOR c_config_keys (pc_item_id in NUMBER,
                        pc_serial_number in VARCHAR2,
                        pc_transaction_id in NUMBER) IS
    SELECT  ool.config_header_id    config_session_hdr_id,
            ool.config_rev_nbr      config_session_rev_num,
            ool.configuration_id    config_session_item_id
    FROM  mtl_material_transactions mmt,
          mtl_unit_transactions mut,
          oe_order_lines_all ool
    WHERE  mmt.transaction_id = mut.transaction_id
    AND    mmt.transaction_id = pc_transaction_id
    AND    mmt.transaction_action_id = 1
    AND    mmt.transaction_source_type_id = 2
    AND    mut.inventory_item_id = pc_item_id
    AND    mut.serial_number = pc_serial_number
    AND    mmt.trx_source_line_id = ool.line_id;

    r_config_keys    c_config_keys%rowtype;

    l_amount        integer;
    l_msg_text      varchar2(32767);
    l_source_id     varchar2(200);
    l_item_id       number;

  BEGIN

    SELECT freeze_date
    INTO l_freeze_date
    FROM csi_install_parameters
    WHERE rownum = 1;

    FOR msg_rec in msg_cur(l_freeze_date)
    LOOP
      l_amount := null;
      l_amount := dbms_lob.getlength(msg_rec.body_text);
      l_msg_text := null;
      l_item_id  := null;

      dbms_lob.read(
        lob_loc => msg_rec.body_text,
        amount  => l_amount,
        offset  => 1,
        buffer  => l_msg_text );

      l_source_id := null;

      xnp_xml_utils.decode(l_msg_text, 'MTL_TRANSACTION_ID', l_source_id);

     FOR r_config_keys in c_config_keys (p_inventory_item_id,
                                         p_serial_number,
                                         l_source_id) LOOP

       l_config_keys.session_hdr_id	:= r_config_keys.config_session_hdr_id;
       l_config_keys.session_rev_num	:= r_config_keys.config_session_rev_num;
       l_config_keys.session_item_id	:= r_config_keys.config_session_item_id;

       -- Call function again to see if this is in a MACD config or not

       IF csi_interface_pkg.check_MACD_processing(l_config_keys,
                                                  l_return_status) THEN

       -- There are records in the SFM Queue but not processed to Install Base Yet
         RETURN (TRUE);
       END IF;

     END LOOP; -- c_config_keys loop

    END LOOP; -- msg_rec loop

    RETURN (FALSE);

  EXCEPTION

    WHEN others THEN
      RETURN(TRUE);

  END; -- check_inv_sfm_cz_keys

  /********** End New Functions for Inventory MACD validations **********/

PROCEDURE get_impacted_item_instances( p_api_version           	IN     NUMBER,
                                       p_commit                	IN     VARCHAR2 := fnd_api.g_false,
                                       p_init_msg_list         	IN     VARCHAR2 := fnd_api.g_false,
                                       p_validation_level      	IN     NUMBER   := fnd_api.g_valid_level_full,
                                       x_txn_inst_tbl	        OUT    NOCOPY   TXN_INST_TBL,
                                       p_txn_oks_rec	        IN              TXN_OKS_REC,
                                       x_return_status          OUT    NOCOPY   VARCHAR2,
                                       x_msg_count              OUT    NOCOPY   NUMBER,
                                       x_msg_data	        OUT    NOCOPY   VARCHAR2) IS

l_api_name         CONSTANT VARCHAR2(30)   := 'GET_IMPACTED_ITEM_INSTANCES';
l_party_found      NUMBER;
j                  NUMBER := 1;
l_txn_inst_tbl     csi_utility_grp.TXN_INST_TBL;
l_txn_oks_rec      csi_utility_grp.txn_oks_rec;
l_return_status    VARCHAR2(1);
l_error_message    VARCHAR2(2000);
l_sql_error        VARCHAR2(2000);
l_msg_data         VARCHAR2(2000);
l_msg_count        NUMBER;

-- FTS on this cursor
CURSOR dummy_csr(pc_batch_id   IN NUMBER) IS
  SELECT cil.active_end_date              active_end_date
        ,cil.installation_date            installation_date
        ,cil.txn_line_detail_id           txn_line_detail_id
      FROM  csi_t_txn_line_details cil,
            csi_mass_edit_entries_b cmee
      WHERE cmee.entry_id = pc_batch_id
      AND   cmee.txn_line_id = cil.transaction_line_id
      AND   cil.instance_id IS NULL;

dummy_rec     dummy_csr%rowtype;

BEGIN

  debug('Start of get_impacted_instances...');

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF p_txn_oks_rec.batch_id IS NULL THEN -- Single Instance Usability

    l_txn_oks_rec := p_txn_oks_rec;

    -- Now build the txn_inst_tbl to be passed out with the impacted instances
    debug('  Single Instance Usability .. Calling get_instances');

    csi_utility_grp.get_instances (p_txn_oks_rec,
                                         l_txn_inst_tbl,
                                         l_return_status,
                                         l_msg_count,
                                         l_msg_data);
    x_txn_inst_tbl := l_txn_inst_tbl;

  ELSE -- Mass Update

    l_txn_oks_rec := p_txn_oks_rec;
/****
    FOR dummy_rec IN dummy_csr (p_txn_oks_rec.batch_id) LOOP

      IF dummy_rec.active_end_date IS NOT NULL THEN
        l_txn_oks_rec.transaction_type(j) := 'TRM';
        j := j + 1;
      END IF;

      IF dummy_rec.installation_date IS NOT NULL THEN
        l_txn_oks_rec.transaction_type(j) := 'IDC';
        j := j + 1;
      END IF;

      BEGIN
      --  SELECT 1
      --  INTO l_party_found
      --  FROM csi_t_party_details
      --  WHERE txn_line_detail_id = dummy_rec.txn_line_detail_id
      --  AND relationship_type_code = 'OWNER'
      --  AND party_source_table = 'HZ_PARTIES';
l_party_found := 1;
      IF l_party_found IS NOT NULL THEN
        l_txn_oks_rec.transaction_type(j) := 'TRF';
        j := j + 1;
      END IF;

      EXCEPTION
        WHEN no_data_found THEN
          NULL; -- No Party Change Do Nothing
      END;

    END LOOP; -- dummy_csr
****/
    -- Now build the txn_inst_tbl to be passed out with the impacted instances

    debug('  Mass Update Batch ('||l_txn_oks_rec.batch_id||') .. Calling get_instances');

    csi_utility_grp.get_instances (l_txn_oks_rec,
                                         l_txn_inst_tbl,
                                         l_return_status,
                                         l_msg_count,
                                         l_msg_data);

    x_txn_inst_tbl := l_txn_inst_tbl;

  END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count     := l_msg_count;
      x_msg_data      := l_msg_data;

    WHEN others THEN
      l_sql_error := SQLERRM;
      fnd_message.set_name('CSI','CSI_UNEXP_SQL_ERROR');
      fnd_message.set_token('API_NAME',l_api_name);
      fnd_message.set_token('SQL_ERROR',l_sql_error);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := 1;
      x_msg_data      := fnd_message.get;

END get_impacted_item_instances;


PROCEDURE get_instances (p_txn_oks_rec	         IN          TXN_OKS_REC,
                         x_txn_inst_tbl	         OUT  NOCOPY TXN_INST_TBL,
                         x_return_status         OUT  NOCOPY VARCHAR2,
                         x_msg_count             OUT  NOCOPY NUMBER,
                         x_msg_data              OUT  NOCOPY VARCHAR2) IS


l_api_name                      CONSTANT VARCHAR2(30)   := 'GET_INSTANCES';
l_relationship_query_rec        csi_datastructures_pub.relationship_query_rec;
l_rel_tbl                       csi_datastructures_pub.ii_relationship_tbl;
l_depth                         NUMBER;
l_active_relationship_only      VARCHAR2(1);
l_active_instances_only         VARCHAR2(1);
l_config_only                   VARCHAR2(1); -- if true will retrieve instances with config keys
l_time_stamp                    DATE;
l_get_dfs                       VARCHAR2(1) := FND_API.G_TRUE;
l_ii_relationship_level_tbl     csi_ii_relationships_pvt.ii_relationship_level_tbl;
l_return_status                 VARCHAR2(1);
l_error_message                 VARCHAR2(2000);
l_sql_error                     VARCHAR2(2000);
l_msg_data                      VARCHAR2(2000);
l_msg_count                     NUMBER;
l_msg_index                     NUMBER;
l_txn_instances_tbl             T_NUM;
l_txn_trf_instances_tbl         T_NUM;
l_txn_idc_instances_tbl         T_NUM;
l_dummy_owner_party             NUMBER;
l_owner_party_id                NUMBER;
l_child_owner_party_id          NUMBER;
l_parent_owner_party_id         NUMBER;
l_parent_install_date           DATE;
l_child_install_date            DATE;

trx1                            NUMBER := 1;
trx2                            NUMBER := 1;
trx10                           NUMBER := 1;
trx20                           NUMBER := 1;
dup                             NUMBER := 1;
rel                             NUMBER := 0;
rel1                            NUMBER := 0;
pty1                            NUMBER := 1;
pty2                            NUMBER := 1;
id                              NUMBER := 1;
id1                             NUMBER := 1;
dup_inst_found                  VARCHAR2(1) := 'N';
inst                            NUMBER := 0;
j                               NUMBER := 0;

-- FTS on this cursor
CURSOR inst_csr(pc_batch_id   IN NUMBER) IS
  SELECT cil.instance_id                  instance_id
      FROM  csi_t_txn_line_details cil,
            csi_mass_edit_entries_b cmee
      WHERE cmee.entry_id = pc_batch_id
      AND   cmee.txn_line_id = cil.transaction_line_id
      AND   cil.instance_id IS NOT NULL;

inst_rec     inst_csr%rowtype;

CURSOR dummy_csr(pc_batch_id   IN NUMBER) IS
  SELECT cil.active_end_date              active_end_date
        ,cil.installation_date            installation_date
        ,cil.txn_line_detail_id           txn_line_detail_id
      FROM  csi_t_txn_line_details cil,
            csi_mass_edit_entries_b cmee
      WHERE cmee.entry_id = pc_batch_id
      AND   cmee.txn_line_id = cil.transaction_line_id
      AND   cil.instance_id IS NULL;

dummy_rec     dummy_csr%rowtype;

CURSOR install_date_csr (pc_instance_id IN NUMBER) IS
  SELECT install_date
  FROM csi_item_instances
  WHERE instance_id = pc_instance_id;

install_date_rec    install_date_csr%rowtype;

CURSOR parent_child_party_csr (pc_instance_id IN NUMBER) IS
  SELECT owner_party_id
  FROM csi_item_instances
  WHERE instance_id = pc_instance_id;

parent_child_party_rec     parent_child_party_csr%rowtype;

BEGIN

  debug('    Start of get_instances ...');

  -- If this is a Mass Update Transaction then get all the instances in the Batch

  IF p_txn_oks_rec.batch_id IS NOT NULL THEN

      debug('    Start of get_instances ... Mass Update Batch Processing');

      OPEN dummy_csr(p_txn_oks_rec.batch_id);
      FETCH dummy_csr INTO dummy_rec;
      CLOSE dummy_csr;

      FOR inst_rec IN inst_csr(p_txn_oks_rec.batch_id) LOOP

          dup_inst_found := 'N';

        IF l_txn_instances_tbl.count > 0 THEN
          FOR dup IN l_txn_instances_tbl.FIRST .. l_txn_instances_tbl.LAST LOOP
            IF l_txn_instances_tbl(dup) = inst_rec.instance_id THEN
              dup_inst_found := 'Y';
              exit;
            END IF;
          END LOOP; -- Check if Instance is already in out table
        END IF; -- l_txn_instances_tbl.count

          IF dup_inst_found = 'N' THEN
            l_relationship_query_rec.object_id              := inst_rec.instance_id;
            l_relationship_query_rec.relationship_type_code := 'COMPONENT-OF';
            csi_ii_relationships_pvt.Get_Children (l_relationship_query_rec    ,
                                                   l_rel_tbl                   ,
                                                   NULL, --l_depth
                                                   fnd_api.g_true,           --l_active_relationship_only
                                                   fnd_api.g_true,           --l_active_instances_only
                                                   fnd_api.g_false,          --
                                                   NULL,
                                                   l_get_dfs                   ,
                                                   l_ii_relationship_level_tbl ,
                                                   x_return_status             ,
                                                   x_msg_count                 ,
                                                   x_msg_data                  );

            debug('      Does this instance have any children? ('||l_rel_tbl.count||')');

            IF NOT l_return_status = FND_API.G_RET_STS_SUCCESS THEN
              l_msg_index := 1;
              WHILE l_msg_count > 0 loop
                l_error_message := l_error_message || fnd_msg_pub.get(l_msg_index,FND_API.G_FALSE);
                l_msg_index := l_msg_index + 1;
                l_msg_count := l_msg_count - 1;
                END LOOP;
                RAISE fnd_api.g_exc_error;
            END IF;


            IF l_rel_tbl.count = 0 THEN
              debug('      No children so add Instance to the table');
              -- its a parent just add to the table
              inst := l_txn_instances_tbl.count + 1;
              l_txn_instances_tbl(inst) := inst_rec.instance_id;

            ELSE
              debug('      Children Exist so loop through the table and get the Owner Party of the Parent and Installation Date');

              BEGIN
	        SELECT owner_party_id,install_date
                INTO l_parent_owner_party_id,l_parent_install_date
                FROM csi_item_instances
                WHERE instance_id = inst_rec.instance_id;

                debug('      Parent Owner Party ('||l_parent_owner_party_id||')');
                debug('      Parent Installation Date ('||l_parent_install_date||')');

              EXCEPTION
                WHEN no_data_found THEN
                  l_parent_owner_party_id := NULL;
                  l_parent_install_date := NULL;
              END;

              FOR rel IN l_rel_tbl.FIRST .. l_rel_tbl.LAST LOOP
		-- Continue to build l_txn_instances_tbl
                inst := l_txn_instances_tbl.count + 1;
                l_txn_instances_tbl(inst) := l_rel_tbl(rel).subject_id;
              END LOOP; -- l_rel_tbl

              -- Insert Parent ID
              inst := l_txn_instances_tbl.count + 1;
              l_txn_instances_tbl(inst) := inst_rec.instance_id;

	      -- Check to see if this is TRF if so compare the owner parties
	      FOR trx_trf IN p_txn_oks_rec.transaction_type.FIRST .. p_txn_oks_rec.transaction_type.LAST LOOP
	        IF p_txn_oks_rec.transaction_type(trx_trf) = 'TRF' THEN
                  debug('      TRF Transaction Type');

                  l_txn_trf_instances_tbl := l_txn_instances_tbl;

                  FOR trf IN l_txn_trf_instances_tbl.FIRST .. l_txn_trf_instances_tbl.LAST LOOP
                    SELECT owner_party_id
                    INTO l_owner_party_id
                    FROM csi_item_instances
                    WHERE instance_id = l_txn_trf_instances_tbl(trf);

                    debug('      Owner Party: '||l_owner_party_id||' of Instance: '||l_txn_trf_instances_tbl(trf));

                    IF l_parent_owner_party_id <> l_owner_party_id THEN
                      debug('      Owner Parties do not match so remove this instance: '||l_txn_trf_instances_tbl(trf));
                      l_txn_trf_instances_tbl.delete(trf);
                    END IF;

                  END LOOP; -- trf index

	        END IF; -- 'TRF' IF
	      END LOOP; -- trx_trf index
            END IF; -- rel tbl

            END IF;      -- dup_inst_found
        END LOOP;        -- inst_csr

          -- Assign the table of instances to all of the Transaction Type Rows
          FOR trx10 IN p_txn_oks_rec.transaction_type.FIRST .. p_txn_oks_rec.transaction_type.LAST LOOP

            IF p_txn_oks_rec.transaction_type(trx10) = 'TRF' THEN

	      IF l_txn_trf_instances_tbl.count = 0 THEN
	        x_txn_inst_tbl(trx10).instance_tbl := l_txn_instances_tbl;
	        x_txn_inst_tbl(trx10).transaction_type  := p_txn_oks_rec.transaction_type(trx10);

	      ELSE
	        j := l_txn_trf_instances_tbl.count;

	        FOR i IN l_txn_instances_tbl.first .. l_txn_instances_tbl.last LOOP
	          l_txn_trf_instances_tbl(j) := l_txn_instances_tbl(i);
		  j := l_txn_trf_instances_tbl.count + 1;
		END LOOP;

	        x_txn_inst_tbl(trx10).instance_tbl := l_txn_trf_instances_tbl;
                x_txn_inst_tbl(trx10).transaction_type  := p_txn_oks_rec.transaction_type(trx10);

	      END IF;

            ELSIF p_txn_oks_rec.transaction_type(trx10) = 'IDC' THEN
              debug('      IDC Transaction Type');
              l_txn_idc_instances_tbl := l_txn_instances_tbl;

              FOR idc IN l_txn_idc_instances_tbl.FIRST .. l_txn_idc_instances_tbl.LAST LOOP

               OPEN install_date_csr(l_txn_idc_instances_tbl(idc));
               FETCH install_date_csr INTO install_date_rec;
               CLOSE install_date_csr;

               IF l_parent_install_date <> install_date_rec.install_date THEN
                 debug('      Installation Dates do not match so remove this instance: '||l_txn_idc_instances_tbl(id));
                 l_txn_idc_instances_tbl.delete(id);
               END IF;

               x_txn_inst_tbl(trx10).instance_tbl := l_txn_idc_instances_tbl;
               x_txn_inst_tbl(trx10).transaction_type  := p_txn_oks_rec.transaction_type(trx10);
             END LOOP; -- idc idx

             ELSIF p_txn_oks_rec.transaction_type(trx10) = 'TRM' THEN
               -- Pass out Parent and any Children
               debug('      TRM Transaction Type');
               x_txn_inst_tbl(trx10).instance_tbl := l_txn_instances_tbl;
               x_txn_inst_tbl(trx10).transaction_type  := p_txn_oks_rec.transaction_type(trx10);

             END IF;

            END LOOP;

    ELSE -- Single Instance

            debug('    Start of get_instances ... Single Instance Processing');
            l_relationship_query_rec.object_id              := p_txn_oks_rec.instance_id;
            l_relationship_query_rec.relationship_type_code := 'COMPONENT-OF';

            csi_ii_relationships_pvt.Get_Children (l_relationship_query_rec    ,
                                                   l_rel_tbl                   ,
                                                   NULL, --l_depth
                                                   fnd_api.g_true,           --l_active_relationship_only
                                                   fnd_api.g_true,           --l_active_instances_only
                                                   fnd_api.g_false,          --
                                                   NULL,
                                                   l_get_dfs                   ,
                                                   l_ii_relationship_level_tbl ,
                                                   x_return_status             ,
                                                   x_msg_count                 ,
                                                   x_msg_data                  );

            IF NOT l_return_status = FND_API.G_RET_STS_SUCCESS THEN
              l_msg_index := 1;
              WHILE l_msg_count > 0 loop
                l_error_message := l_error_message || fnd_msg_pub.get(l_msg_index,FND_API.G_FALSE);
                l_msg_index := l_msg_index + 1;
                l_msg_count := l_msg_count - 1;
                END LOOP;
                RAISE fnd_api.g_exc_error;
            END IF;

            IF l_rel_tbl.count = 0 THEN
              debug('      No Children so just add this instance to the out table');
              -- its a parent just add to the table
              inst := l_txn_instances_tbl.count + 1;
              l_txn_instances_tbl(inst) := inst_rec.instance_id;
            ELSE
              FOR rel IN l_rel_tbl.FIRST .. l_rel_tbl.LAST LOOP
                inst := l_txn_instances_tbl.count + 1;
                debug('      Children Found so add this instance to the out table: '||l_rel_tbl(rel).subject_id);
                l_txn_instances_tbl(inst) := l_rel_tbl(rel).subject_id;
              END LOOP; -- l_rel_tbl
            END IF;

          -- Assign the table of instances to all of the Transaction Type Rows
          FOR trx10 IN p_txn_oks_rec.transaction_type.FIRST .. p_txn_oks_rec.transaction_type.LAST LOOP
            IF p_txn_oks_rec.transaction_type(trx10) = 'TRF' THEN
              debug('      TRF Transaction Type');

              l_txn_trf_instances_tbl := l_txn_instances_tbl;

            FOR trf IN l_txn_trf_instances_tbl.FIRST .. l_txn_trf_instances_tbl.LAST LOOP

               -- Get the Parent Owner Party ID
               OPEN parent_child_party_csr(p_txn_oks_rec.instance_id);
               FETCH parent_child_party_csr INTO l_owner_party_id;
               CLOSE parent_child_party_csr;

               -- Get the Child Owner Party ID
               OPEN parent_child_party_csr(l_txn_trf_instances_tbl(trf));
               FETCH parent_child_party_csr INTO l_child_owner_party_id;
               CLOSE parent_child_party_csr;

               debug('      Parent Owner Party: '||l_owner_party_id);
               debug('      Child Owner Party: '||l_child_owner_party_id);
               IF l_owner_party_id <> l_child_owner_party_id THEN
                 l_txn_trf_instances_tbl.delete(trf);
               END IF;
            END LOOP; -- trf index

               x_txn_inst_tbl(trx10).instance_tbl := l_txn_trf_instances_tbl;
               x_txn_inst_tbl(trx10).transaction_type  := p_txn_oks_rec.transaction_type(trx10);

           ELSIF p_txn_oks_rec.transaction_type(trx10) = 'IDC' THEN
               debug('      IDC Transaction Type');

               l_txn_idc_instances_tbl := l_txn_instances_tbl;

           FOR idc IN l_txn_idc_instances_tbl.FIRST .. l_txn_idc_instances_tbl.LAST LOOP

               -- Get the Parent Install Date
               OPEN install_date_csr(p_txn_oks_rec.instance_id);
               FETCH install_date_csr INTO l_parent_install_date;
               CLOSE install_date_csr;

               -- Get the Child Install Date
               OPEN install_date_csr(l_txn_idc_instances_tbl(idc));
               FETCH install_date_csr INTO l_child_install_date;
               CLOSE install_date_csr;

               debug('      Parent Installation Date: '||l_parent_install_date);
               debug('      Child Installation Date: '||l_child_install_date);
               IF l_parent_install_date <> l_child_install_date THEN
                 l_txn_idc_instances_tbl.delete(id);
               END IF;
             END LOOP; -- idc idx

               x_txn_inst_tbl(trx10).instance_tbl := l_txn_idc_instances_tbl;
               x_txn_inst_tbl(trx10).transaction_type  := p_txn_oks_rec.transaction_type(trx10);

             ELSIF p_txn_oks_rec.transaction_type(trx10) in ('TRM','RIN') THEN
               debug('      '||p_txn_oks_rec.transaction_type(trx10)|| 'Transaction Type');
               -- Pass out Parent and any Children
               x_txn_inst_tbl(trx10).instance_tbl := l_txn_instances_tbl;
               x_txn_inst_tbl(trx10).transaction_type  := p_txn_oks_rec.transaction_type(trx10);

             ELSIF p_txn_oks_rec.transaction_type(trx10) in ('UPD','SPL') THEN
               -- Pass out Just the Parent
               debug('      '||p_txn_oks_rec.transaction_type(trx10)|| 'Transaction Type');
               x_txn_inst_tbl(trx10).instance_tbl(trx10) := p_txn_oks_rec.instance_id;
               x_txn_inst_tbl(trx10).transaction_type    := p_txn_oks_rec.transaction_type(trx10);
             END IF;

            END LOOP;

  END IF;            -- Batch ID

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count     := l_msg_count;
      x_msg_data      := l_msg_data;

    WHEN others THEN
      l_sql_error := SQLERRM;
      fnd_message.set_name('CSI','CSI_UNEXP_SQL_ERROR');
      fnd_message.set_token('API_NAME',l_api_name);
      fnd_message.set_token('SQL_ERROR',l_sql_error);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := 1;
      x_msg_data      := fnd_message.get;

END get_instances;

  -- Procedures for INV/OM Transaction Data Purge
  PROCEDURE inv_txn_data_purge(
    p_inv_period_from_date   IN DATE,
    p_inv_period_to_date     IN DATE,
    p_organization_id        IN NUMBER,
    x_return_status          OUT NOCOPY varchar2,
    x_return_message         OUT NOCOPY varchar2) IS

  l_freeze_date            DATE;
  inv_purge_not_allowed    EXCEPTION;
  inv_purge_allowed        EXCEPTION;

  TYPE NumTabType    is  varray(10000) of number;
  TYPE DateTabType   is  varray(10000) of date;

  l_transaction_id_tab            NumTabType;
  l_transaction_date_tab          DateTabType;

  MAX_BUFFER_SIZE                 NUMBER := 1000;

  CURSOR c_mtl_data (pc_from_date in DATE,
                     pc_to_date   in DATE) IS
    SELECT transaction_id,
           transaction_date
    FROM mtl_material_transactions
    WHERE transaction_date between pc_from_date and pc_to_date;

  CURSOR c_csi_txns (pc_transaction_id in NUMBER) IS
    SELECT 1
    FROM csi_transactions
    WHERE inv_material_transaction_id = pc_transaction_id;

  l_csi_txn_found     NUMBER := NULL;

  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Bulk Collect the Transaction Data and validate each transaction
    OPEN c_mtl_data (p_inv_period_from_date,p_inv_period_to_date);
    LOOP

      FETCH c_mtl_data BULK COLLECT
      INTO  l_transaction_id_tab,
            l_transaction_date_tab
      LIMIT MAX_BUFFER_SIZE;

      FOR ind IN 1 .. l_transaction_id_tab.COUNT LOOP

        -- Check for the Freeze Date Existance and If there is a data is that
        -- before the freeze date.

        IF csi_datastructures_pub.g_install_param_rec.fetch_flag IS NULL THEN
           csi_gen_utility_pvt.populate_install_param_rec;
        END IF;

        IF csi_datastructures_pub.g_install_param_rec.freeze_date is NULL then
          raise inv_purge_allowed;
        ELSE
          l_freeze_date := csi_datastructures_pub.g_install_param_rec.freeze_date;
        END IF;

        IF l_freeze_date > l_transaction_date_tab(ind) THEN
          RAISE inv_purge_allowed;
        END IF;

        --Check to see if this transaction is supported in Installed Base.

        IF NOT csi_inv_trxs_pkg.valid_ib_txn(l_transaction_id_tab(ind)) THEN
          raise inv_purge_allowed;
        END IF;

       --Check to see if a transaction for this material transaction exists in IB
       OPEN c_csi_txns (l_transaction_id_tab(ind));
       FETCH c_csi_txns into l_csi_txn_found;
       CLOSE c_csi_txns;

       IF l_csi_txn_found IS NULL THEN
         raise inv_purge_not_allowed;
       ELSE
         Raise inv_purge_allowed;
       END IF;
      END LOOP; -- Txn ID Loop

    END LOOP; -- Main Loop
    CLOSE c_mtl_data;

  EXCEPTION
    WHEN inv_purge_not_allowed THEN
      fnd_message.set_name('CSI','CSI_INV_NO_DATA_PURGE');
      x_return_status := fnd_api.g_ret_sts_error;
      x_return_message      := fnd_message.get;

    WHEN inv_purge_allowed THEN
      x_return_status := fnd_api.g_ret_sts_success;
      x_return_message := NULL;

    WHEN others THEN
      fnd_message.set_name('CSI','CSI_INV_NO_DATA_PURGE');
      x_return_status := fnd_api.g_ret_sts_error;
      x_return_message      := fnd_message.get;

  END inv_txn_data_purge;

  PROCEDURE om_txn_data_purge(
    p_om_txn_info            IN csi_utility_grp.om_txn_info_tbl,
    x_return_status          OUT NOCOPY varchar2,
    x_return_message         OUT NOCOPY varchar2) IS

  l_freeze_date            DATE;
  l_freeze_date_error      VARCHAR2(1) := 'N';
  j                        NUMBER;
  l_purge_allowed          VARCHAR2(1) := 'Y';
  om_purge_not_allowed     EXCEPTION;
  om_purge_allowed         EXCEPTION;

  CURSOR c_csi_txns (pc_line_id IN NUMBER,
                     pc_txn_id  IN NUMBER) IS
    SELECT transaction_id,source_header_ref
    FROM csi_transactions
    WHERE source_line_ref_id = pc_line_id
    AND   transaction_type_id = pc_txn_id;

  r_csi_txns    c_csi_txns%rowtype;

   CURSOR c_so_info (pc_line_id in NUMBER) is
     SELECT oeh.header_id,
            oel.line_id,
            oeh.order_number,
            oel.line_number
     FROM   oe_order_headers_all oeh,
            oe_order_lines_all oel
     WHERE oeh.header_id = oel.header_id
     AND   oel.line_id = pc_line_id;

  r_so_info     c_so_info%rowtype;

  BEGIN

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    j := 1;

    -- OM will pass a table of order lines that belong to 1 order. We need to loop
    -- and validate each line and if any line cannot be purged the entire order data
    -- will be retained.


    FOR j in p_om_txn_info.FIRST .. p_om_txn_info.LAST LOOP

      IF j = 1 THEN
        debug_con_log('***** Start of Install Base Purge Program for Order Header '||p_om_txn_info(1).header_id||' *****');
      END IF;

      -- Check for the Freeze Date Existance and If there is a data is that
      -- before the freeze date.

      IF csi_datastructures_pub.g_install_param_rec.fetch_flag IS NULL THEN
         csi_gen_utility_pvt.populate_install_param_rec;
      END IF;

      IF csi_datastructures_pub.g_install_param_rec.freeze_date is NOT NULL then
        l_freeze_date := csi_datastructures_pub.g_install_param_rec.freeze_date;
      ELSE
        l_freeze_date := p_om_txn_info(j).request_date + 1;
      END IF;

      IF l_freeze_date < trunc(p_om_txn_info(j).request_date) THEN

        OPEN c_so_info (p_om_txn_info(j).line_id);
        FETCH c_so_info into r_so_info;
        CLOSE c_so_info;

        debug_con_log('Order Number......'||r_so_info.order_number);
        debug_con_log('   Line Number.....'||r_so_info.line_number);
        debug_con_log('   Vld Org.........'||p_om_txn_info(j).inv_vld_organization_id);
        debug_con_log('   Item Id.........'||p_om_txn_info(j).inventory_item_id);
        debug_con_log('   Freeze Date.....'||l_freeze_date);
        debug_con_log('   Request Date....'||p_om_txn_info(j).request_date);
        debug_con_log('   Line ID.........'||p_om_txn_info(j).line_id);

        --Check if item is CSI trackable
        IF csi_item_instance_vld_pvt.is_trackable(
                           p_inv_item_id    => p_om_txn_info(j).inventory_item_id,
                           p_stack_err_msg  => FALSE,
                           p_org_id         => p_om_txn_info(j).inv_vld_organization_id) THEN


          --Check to see if a transaction for this material transaction exists in IB
          OPEN c_csi_txns (p_om_txn_info(j).line_id,51);
          FETCH c_csi_txns into r_csi_txns;
          CLOSE c_csi_txns;

          IF r_csi_txns.transaction_id IS NULL THEN
            fnd_message.set_name('CSI','CSI_OM_PURGE_LINE_ERROR');
            fnd_message.set_token('LINE_NUMBER',r_so_info.line_number);
            debug_con_log(fnd_message.get);
            l_purge_allowed := 'N';
          END IF;

        END IF; -- Trackable Item

      ELSE
        l_freeze_date_error := 'Y';
      END IF; -- Freeze/Request Date

    END LOOP; -- Main For Loop

    IF l_freeze_date_error = 'Y' THEN
      debug_con_log('This order does not need to be validated by Install Base because either the ordered date was before Install Base was being used or the item is not trackable.');
    END IF;

    IF l_purge_allowed = 'N' THEN
      RAISE om_purge_not_allowed;
    ELSE
      RAISE om_purge_allowed;
    END IF;

  EXCEPTION
    WHEN om_purge_not_allowed THEN
      fnd_message.set_name('CSI','CSI_OM_PURGE_ERROR');
      fnd_message.set_token('ORDER_NUMBER',r_so_info.order_number);
      x_return_status       := fnd_api.g_ret_sts_error;
      x_return_message      := fnd_message.get;
      debug_con_log('***** End of Install Base Purge Program for Order '||r_so_info.order_number||' *****');
      debug_con_log('');

    WHEN om_purge_allowed THEN
      x_return_status := fnd_api.g_ret_sts_success;
      x_return_message := NULL;
      debug_con_log('***** End of Install Base Purge Program for Order '||r_so_info.order_number||' *****');
      debug_con_log('');

    WHEN others THEN
      fnd_message.set_name('CSI','CSI_OM_PURGE_ERROR');
      fnd_message.set_token('ORDER_NUMBER',r_so_info.order_number);
      x_return_status       := fnd_api.g_ret_sts_error;
      x_return_message      := fnd_message.get;
      debug_con_log('***** End of Install Base Purge Program for Order '||r_so_info.order_number||' *****');
      debug_con_log('');

  END om_txn_data_purge;

   PROCEDURE purge_txn_detail_tables (
     errbuf                       OUT NOCOPY    VARCHAR2
    ,retcode                      OUT NOCOPY    NUMBER) IS


    l_order_status        VARCHAR2(25) := NULL;
    l_processed_recs      NUMBER;
    l_mass_update_recs    NUMBER;
    l_return_status       varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_count           NUMBER;
    l_msg_data            VARCHAR2(2000);

    purge_error           EXCEPTION;

    CURSOR c_mu (p_status IN VARCHAR2) IS
      SELECT txn_line_id
      FROM csi_mass_edit_entries_b
      WHERE status_code = p_status;

    CURSOR c_processed_recs (p_status IN VARCHAR2) IS
      SELECT transaction_line_id
      FROM csi_t_transaction_lines
      WHERE processing_status = p_status
      AND migrated_flag is NULL;

    CURSOR c_migrated_recs IS
      SELECT transaction_line_id,
             source_transaction_id
      FROM csi_t_transaction_lines
      WHERE migrated_flag = 'Y';

  BEGIN


    debug_con_log(' ********** Start of CSI_T Table Purge ********** ');
    debug_con_log('  ');
    debug_con_log(' Processing all Migrated Records ... ');

    savepoint csi_tdtl_purge;

    -- Process Migrated Records
    FOR r_migrated_recs in c_migrated_recs LOOP

    l_order_status := NULL;

    BEGIN
      debug_con_log('   Check to see if the Order is open for Source Transaction ID: '||r_migrated_recs.source_transaction_id);

      -- Check to see if the Order Status is closed for this line.
      SELECT oh.flow_status_code
      INTO l_order_status
      FROM oe_order_headers_all oh, oe_order_lines_all ol
      WHERE ol.line_id = r_migrated_recs.source_transaction_id
      AND ol.header_id = oh.header_id;

      -- Check OE to see if the Order that this Line is on is Closed. If so then remove the
      -- the Txn Details

      debug_con_log('   Order found and the Flow Status is: '||l_order_status);

      IF l_order_status in ('CLOSED','CANCELLED') THEN

        debug_con_log('   Before csi_t_txn_details_grp.delete_transaction_dtls to remove Txn Line Detail: '||r_migrated_recs.transaction_line_id);

        csi_t_txn_details_grp.delete_transaction_dtls (
         p_api_version             	=> 1.0
        ,p_commit                   	=> fnd_api.g_false
        ,p_init_msg_list            	=> fnd_api.g_false
        ,p_validation_level         	=> fnd_api.g_valid_level_full
        ,p_transaction_line_id    	=> r_migrated_recs.transaction_line_id
        ,p_api_caller_identity    	=> 'PURGE'
        ,x_return_status           	=> l_return_status
        ,x_msg_count                	=> l_msg_count
        ,x_msg_data                 	=> l_msg_data);

        debug_con_log('   After csi_t_txn_details_grp.delete_transaction_dtls to remove Txn Line Details');
        debug_con_log('   Return Status is :'||l_return_status||' for Txn Line '||r_migrated_recs.transaction_line_id);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          debug_con_log('   l_msg_data: '||l_msg_data);
          Raise purge_error;
        END IF;

      END IF;

      EXCEPTION
        WHEN no_data_found THEN
        -- No Order Data is found it must have been purged..Txn Details can be removed.
          debug_con_log('   No Order found so OM data must have been purged. Remove Txn Detail data');
          debug_con_log('   Before csi_t_txn_details_grp.delete_transaction_dtls to remove Txn Line Detail: '||r_migrated_recs.transaction_line_id);

          csi_t_txn_details_grp.delete_transaction_dtls (
            p_api_version             	=> 1.0
           ,p_commit                   	=> fnd_api.g_false
           ,p_init_msg_list            	=> fnd_api.g_false
           ,p_validation_level         	=> fnd_api.g_valid_level_full
           ,p_transaction_line_id    	=> r_migrated_recs.transaction_line_id
           ,p_api_caller_identity    	=> 'PURGE'
           ,x_return_status           	=> l_return_status
           ,x_msg_count                	=> l_msg_count
           ,x_msg_data                 	=> l_msg_data);

           debug_con_log('   After csi_t_txn_details_grp.delete_transaction_dtls to remove Txn Line Details');
           debug_con_log('   Return Status is :'||l_return_status||' for Txn Line '||r_migrated_recs.transaction_line_id);

           IF l_return_status <> fnd_api.g_ret_sts_success THEN
             debug_con_log('   l_msg_data: '||l_msg_data);
             Raise purge_error;
           END IF;

      END;

    END LOOP; -- c_migrated_records

    commit;

    debug_con_log(' Finished Processing all Migrated Records ... ');
    debug_con_log(' ');
    debug_con_log(' Processing all Processed Records ... ');

    savepoint csi_tdtl_purge;

    -- Process all Processed Records
    FOR r_processed_recs in c_processed_recs ('PROCESSED') LOOP

      l_processed_recs := 0;

      BEGIN
        debug_con_log('   Check to see if any of the Txn Lines are a Non Source Type for Txn Line ID: '||r_processed_recs.transaction_line_id);
        SELECT count(*)
        INTO l_processed_recs
        FROM csi_t_txn_line_details
        WHERE transaction_line_id = r_processed_recs.transaction_line_id
        AND source_transaction_flag = 'N';

      IF l_processed_recs = 0 THEN

        -- There are only source records so we can delete the Transaction Details for this
        -- Transaction Line

        debug_con_log('   There are no Non Source Lines so remove the Txn Detail: '||r_processed_recs.transaction_line_id);
        debug_con_log('   Before csi_t_txn_details_grp.delete_transaction_dtls');

  	csi_t_txn_details_grp.delete_transaction_dtls (
	   p_api_version             	=> 1.0
	  ,p_commit                   => fnd_api.g_false
	  ,p_init_msg_list            => fnd_api.g_false
    	  ,p_validation_level         => fnd_api.g_valid_level_full
	  ,p_transaction_line_id    	=> r_processed_recs.transaction_line_id
	  ,p_api_caller_identity    	=> 'PURGE'
	  ,x_return_status           	=> l_return_status
	  ,x_msg_count                => l_msg_count
	  ,x_msg_data                 => l_msg_data);

        debug_con_log('   After csi_t_txn_details_grp.delete_transaction_dtls');
        debug_con_log('   Return Status is :'||l_return_status||' for Txn Line '||r_processed_recs.transaction_line_id);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          debug_con_log('   l_msg_data: '||l_msg_data);
          Raise purge_error;
        END IF;

      ELSE
	-- There are non source records so do not do anything.
        debug_con_log('   There are Source Lines so do not remove the Txn Detail: '||r_processed_recs.transaction_line_id);
      END IF;


	EXCEPTION
	  WHEN others THEN
            -- Some unexpected error
            debug_con_log('   Unexpected Error for Processed Recs: '||SQLERRM);

	END;

    END LOOP; --c_processed_recs

    commit;

    debug_con_log(' Finished Processing all Processed Records ... ');
    debug_con_log(' ');
    debug_con_log(' Remove Mass Update Recs with no Txn Details ... ');

    -- Delete all Mass Update Batch Records because all the batch lines have been deleted.

    savepoint csi_tdtl_purge;

    FOR r_mu in c_mu ('SUCCESSFUL') LOOP

      l_mass_update_recs := 0;

      BEGIN
        debug_con_log('   Check to see if the Txn Line in Mass Update has any records in csi_t_transaction_lines: '||r_mu.txn_line_id);
        SELECT 1
        INTO l_mass_update_recs
        FROM csi_t_transaction_lines
        WHERE transaction_line_id = r_mu.txn_line_id;

      EXCEPTION
        WHEN no_data_found THEN
          debug_con_log('   No Records exist so remove the Mass Update data from csi_mass_edit_entries_b: '||r_mu.txn_line_id);

          DELETE from csi_mass_edit_entries_b
          WHERE txn_line_id = r_mu.txn_line_id;

    END;
    END LOOP; -- c_mu

    commit;

    debug_con_log(' Finished Processing Mass Update Recs with no Txn Details ... ');
    debug_con_log('  ');
    debug_con_log(' ********** End of CSI_T Table Purge ********** ');

    EXCEPTION

    WHEN purge_error THEN
      debug_con_log(' EXCEPTION:  Purge Error');
      rollback to csi_tdtl_purge;
      fnd_message.set_name('CSI','CSI_TXN_DTL_PURGE_ERROR');
      debug_con_log('Error: '||fnd_message.get);

    WHEN others THEN
      debug_con_log(' When OTHERS Exception: '||SQLERRM);
      rollback to csi_tdtl_purge;
      fnd_message.set_name('CSI','CSI_OTHERS_EXCEPTION');
      debug_con_log('Error: '||fnd_message.get);

  END; -- End of purge_txn_detail_tables

END CSI_UTILITY_GRP;

/
