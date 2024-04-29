--------------------------------------------------------
--  DDL for Package Body CSI_ITEM_INSTANCE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_ITEM_INSTANCE_GRP" AS
/* $Header: csigiib.pls 120.24.12010000.7 2010/01/22 23:41:49 hyonlee ship $ */

-- --------------------------------------------------------
-- Define global variables
-- --------------------------------------------------------

G_PKG_NAME CONSTANT VARCHAR2(30)  := 'CSI_ITEM_INSTANCE_GRP';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csigiib.pls';

/*----------------------------------------------------*/
/* Procedure name: Update_Interface_table             */
/* Description :   procedure for Updating the error   */
/*                 text in the Interface Table        */
/*----------------------------------------------------*/

PROCEDURE Update_Interface_Table
                     ( p_intf_id       NUMBER,
                       p_intf_table    VARCHAR2,
                       p_intf_col_name VARCHAR2,
                       p_error_text    VARCHAR2,
                       p_status        VARCHAR2,
                       p_instance_id   NUMBER
                      )
IS
--
   v_upd_stmt         VARCHAR2(2000);
   v_cursor_handle    INTEGER := dbms_sql.open_cursor;
   v_num_of_rows      NUMBER;
BEGIN
   v_upd_stmt := 'UPDATE '||p_intf_table||' SET ERROR_TEXT = :l_error_text'
                          ||' ,PROCESS_STATUS = :l_status'
                          ||' ,INSTANCE_ID = :l_instance_id'
        		  ||' WHERE '||p_intf_col_name||' = :l_intf_id';
   dbms_sql.parse(v_cursor_handle,v_upd_stmt,dbms_sql.NATIVE);
   dbms_sql.bind_variable(v_cursor_handle,':l_error_text',p_error_text);
   dbms_sql.bind_variable(v_cursor_handle,':l_status',p_status);
   dbms_sql.bind_variable(v_cursor_handle,':l_instance_id',p_instance_id);
   dbms_sql.bind_variable(v_cursor_handle,':l_intf_id',p_intf_id);
   v_num_of_rows := dbms_sql.execute(v_cursor_handle);
   dbms_sql.close_cursor(v_cursor_handle);
EXCEPTION
   WHEN OTHERS THEN
      NULL;
END Update_Interface_Table;
--
FUNCTION Valid_Lot_Number
   ( p_instance_rec      IN csi_datastructures_pub.instance_rec,
     p_instance_tbl      IN OUT NOCOPY csi_datastructures_pub.instance_tbl
   ) RETURN BOOLEAN IS
   --
   l_lot_type           NUMBER;
   l_temp               VARCHAR2(1);
   l_return_value       BOOLEAN;
BEGIN
   l_return_value := TRUE;
   --
   -- Lot Number uniqueness
   ------------------------
   -- 1 - Across Items
   -- 2 - None
   BEGIN
      SELECT lot_number_uniqueness -- Lot number uniqueness
      INTO   l_lot_type
      FROM   mtl_parameters
      WHERE  organization_id = p_instance_rec.vld_organization_id;
   EXCEPTION
      WHEN no_data_found THEN
         l_return_value  := FALSE;
         fnd_message.set_name('CSI','CSI_NO_ORG_SET');
         fnd_message.set_token('ORGANIZATION_ID',p_instance_rec.vld_organization_id);
         fnd_msg_pub.add;
         RETURN l_return_value;
   END;
   --
   l_temp := NULL;
   --
   IF l_lot_type = 1 THEN
      -- Check some other item in this batch has the same lot number
      FOR j IN p_instance_tbl.FIRST .. p_instance_tbl.LAST LOOP
         IF p_instance_tbl.EXISTS(j) THEN
            IF p_instance_rec.inventory_item_id <> p_instance_tbl(j).inventory_item_id AND
               p_instance_rec.lot_number = p_instance_tbl(j).lot_number AND
               nvl(p_instance_tbl(j).processed_flag,'N') <> 'E' AND
               p_instance_rec.interface_id <> p_instance_tbl(j).interface_id THEN
               l_temp := 'x';
               exit;
            END IF;
         END IF;
      END LOOP;
      --
      IF l_temp IS NOT NULL THEN
         l_return_value  := FALSE;
         fnd_message.set_name('CSI','CSI_LOT_CASE2');
         fnd_message.set_token('LOT_NUMBER',p_instance_rec.lot_number);
         fnd_msg_pub.add;
         RETURN l_return_value;
      END IF;
   END IF;
   --
   RETURN l_return_value;
END Valid_Lot_Number;
--
FUNCTION Valid_Serial_Number
   ( p_instance_rec      IN csi_datastructures_pub.instance_rec,
     p_instance_tbl      IN OUT NOCOPY csi_datastructures_pub.instance_tbl,
     p_inst_tab_row      IN NUMBER := -1  --bug 9227016
   ) RETURN BOOLEAN IS
   --
   l_serial_type        NUMBER;
   l_temp               VARCHAR2(1);
   l_base_item_id       NUMBER;
   l_return_value       BOOLEAN;
   l_count              NUMBER;
   --
BEGIN
   l_return_value := TRUE;
   --
   BEGIN
      SELECT serial_number_type -- serial number uniqueness control
      INTO   l_serial_type
      FROM   mtl_parameters
      WHERE  organization_id = p_instance_rec.vld_organization_id;
   EXCEPTION
      WHEN no_data_found THEN
         l_return_value  := FALSE;
         fnd_message.set_name('CSI','CSI_NO_ORG_SET');
         fnd_message.set_token('ORGANIZATION_ID',p_instance_rec.vld_organization_id);
         fnd_msg_pub.add;
         RETURN l_return_value;
   END;
   --
   l_temp := NULL;
   --
   IF l_serial_type = 1 THEN
      l_base_item_id := NULL;
      Begin
         select base_item_id
         into l_base_item_id
         from MTL_SYSTEM_ITEMS_B
         where inventory_item_id = p_instance_rec.inventory_item_id
         and   organization_id = p_instance_rec.vld_organization_id;
      Exception
         when no_data_found then
            l_return_value  := FALSE;
            FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_ITEM');
            FND_MESSAGE.SET_TOKEN('INVENTORY_ITEM_ID',p_instance_rec.inventory_item_id);
            FND_MESSAGE.SET_TOKEN('INVENTORY_ORGANIZATION_ID',p_instance_rec.vld_organization_id);
            FND_MSG_PUB.Add;
            RETURN l_return_value;
      End;
      --
      FOR j IN p_instance_tbl.FIRST .. p_instance_tbl.LAST LOOP
         IF p_instance_tbl.EXISTS(j) THEN
            IF p_instance_tbl(j).interface_id <> p_instance_rec.interface_id
	    OR  j <> p_inst_tab_row -- bug 9227016
	    THEN -- ignoring the current
               IF p_instance_tbl(j).serial_number = p_instance_rec.serial_number AND
                  nvl(p_instance_tbl(j).processed_flag,'N') <> 'E' THEN
                  IF p_instance_tbl(j).inventory_item_id = p_instance_rec.inventory_item_id THEN
                     l_temp := '1'; -- Fundamental uniqueness violated
                     exit;
                  ELSE -- Uniqueness within Model
                     l_count := 0;
                     IF l_base_item_id IS NOT NULL THEN
                        Begin
                           select 1
                           into l_count
                           from dual
                           where exists (select 'x' from mtl_system_items_b msi
                                         where msi.base_item_id = l_base_item_id
                                         and   msi.inventory_item_id = p_instance_tbl(j).inventory_item_id);
                        Exception
                           when no_data_found then
                              l_count := 0;
                           when too_many_rows then
                              l_count := 1;
                        End;
                        IF nvl(l_count,0) > 0 THEN
                           l_temp := '4';
                           exit;
                        END IF;
                     END IF; -- Base Model exists
                  END IF;
               END IF; -- Same srl# check
            END IF; -- current check
         END IF; -- exists
      END LOOP;
      --
      IF nvl(l_temp,'0') = '1' THEN
         l_return_value  := FALSE;
         fnd_message.set_name('CSI','CSI_SER_CASE1');
         fnd_message.set_token('SERIAL_NUMBER',p_instance_rec.serial_number);
         fnd_msg_pub.add;
         RETURN l_return_value;
      ELSIF nvl(l_temp,'0') = '4' THEN
         l_return_value  := FALSE;
         fnd_message.set_name('CSI','CSI_SER_CASE4');
         fnd_message.set_token('SERIAL_NUMBER',p_instance_rec.serial_number);
         fnd_msg_pub.add;
         RETURN l_return_value;
      END IF;
   END IF; -- Serial Type 1
   --
   IF l_serial_type = 4 THEN
      FOR j IN p_instance_tbl.FIRST .. p_instance_tbl.LAST LOOP
         IF p_instance_tbl.EXISTS(j) THEN
            IF p_instance_rec.inventory_item_id = p_instance_tbl(j).inventory_item_id AND
               p_instance_rec.serial_number = p_instance_tbl(j).serial_number AND
               nvl(p_instance_tbl(j).processed_flag,'N') <> 'E' AND
               p_instance_rec.interface_id <> p_instance_tbl(j).interface_id THEN
               l_temp := 'x';
               exit;
            END IF;
         END IF;
      END LOOP;
      IF l_temp IS NOT NULL THEN
         l_return_value  := FALSE;
         fnd_message.set_name('CSI','CSI_SER_CASE1');
         fnd_message.set_token('SERIAL_NUMBER',p_instance_rec.serial_number);
         fnd_msg_pub.add;
         RETURN l_return_value;
      END IF;
   END IF; -- serial_type 4
   --
   IF l_serial_type = 2 THEN
      FOR j IN p_instance_tbl.FIRST .. p_instance_tbl.LAST LOOP
         IF p_instance_tbl.EXISTS(j) THEN
            IF p_instance_rec.serial_number = p_instance_tbl(j).serial_number AND
               p_instance_rec.vld_organization_id = p_instance_tbl(j).vld_organization_id AND
               nvl(p_instance_tbl(j).processed_flag,'N') <> 'E' AND
               p_instance_rec.interface_id <> p_instance_tbl(j).interface_id THEN
               l_temp := 'x';
               exit;
            END IF;
         END IF;
      END LOOP;
      IF l_temp IS NOT NULL THEN
         l_return_value  := FALSE;
         fnd_message.set_name('CSI','CSI_SER_CASE2');
         fnd_message.set_token('SERIAL_NUMBER',p_instance_rec.serial_number);
         fnd_msg_pub.add;
         RETURN l_return_value;
      END IF;
      --
      -- Also check if it has been already defined as
      -- unique serial number accross organizations i.e entire system
      BEGIN
         SELECT 'x'
         INTO   l_temp
         FROM   mtl_serial_numbers s,
                mtl_parameters p
         WHERE  s.current_organization_id = p.organization_id
         AND    s.serial_number = p_instance_rec.serial_number
         AND    p.serial_number_type = 3
         AND    ROWNUM = 1;
         IF l_temp IS NOT NULL THEN
            l_return_value  := FALSE;
            fnd_message.set_name('CSI','CSI_SER_CASE21');
            fnd_message.set_token('SERIAL_NUMBER',p_instance_rec.serial_number);
            fnd_msg_pub.add;
            RETURN l_return_value;
         END IF;
      EXCEPTION
         WHEN OTHERS THEN
            l_return_value  := TRUE;
      END;
   END IF; -- serial_type 2
   --
   IF l_serial_type = 3 THEN
      FOR j IN p_instance_tbl.FIRST .. p_instance_tbl.LAST LOOP
         IF p_instance_tbl.EXISTS(j) THEN
            IF p_instance_rec.serial_number = p_instance_tbl(j).serial_number AND
               nvl(p_instance_tbl(j).processed_flag,'N') <> 'E' AND
               p_instance_rec.interface_id <> p_instance_tbl(j).interface_id THEN
               l_temp := 'x';
               exit;
            END IF;
         END IF;
      END LOOP;
      IF l_temp IS NOT NULL THEN
         l_return_value  := FALSE;
         fnd_message.set_name('CSI','CSI_SER_CASE3');
         fnd_message.set_token('SERIAL_NUMBER',p_instance_rec.serial_number);
         fnd_msg_pub.add;
         RETURN l_return_value;
      END IF;
   END IF; -- serial_type 3
   --
   RETURN l_return_value;
END Valid_Serial_Number;
--
FUNCTION Check_Inst_Party_Rules
   (
     p_party_tbl         IN csi_datastructures_pub.party_tbl
    ,p_party_rec         IN csi_datastructures_pub.party_rec
    ,p_start_date        IN DATE  -- Instance start date
    ,p_end_date          IN DATE  -- Instance end date
   ) RETURN BOOLEAN IS
   --
   l_party_rec         csi_datastructures_pub.party_rec := p_party_rec;
   l_party_tbl         csi_datastructures_pub.party_tbl := p_party_tbl;
   l_count             NUMBER := 0;
   l_primary_pty_count NUMBER := 0;
   l_primary_con_count NUMBER := 0;
   l_return_status BOOLEAN;
BEGIN
   l_return_status := TRUE;
   --
   IF l_party_rec.active_end_date IS NOT NULL AND
      l_party_rec.active_end_date <> FND_API.G_MISS_DATE THEN
      IF To_Date(l_party_rec.active_start_date,'DD-MM-YY HH24:MI')  > To_Date(l_party_rec.active_end_date,'DD-MM-YY HH24:MI') THEN
         l_return_status  := FALSE;
         FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_PTY_START_DATE');
         FND_MESSAGE.SET_TOKEN('ACTIVE_START_DATE',l_party_rec.active_start_date);
         FND_MSG_PUB.ADD;
         RETURN l_return_status;
      END IF;
      --
      IF ( (to_date(l_party_rec.active_end_date,'DD-MM-YY HH24:MI') < to_date(SYSDATE,'DD-MM-YY HH24:MI')) OR
           (p_end_date IS NOT NULL AND to_date(l_party_rec.active_end_date,'DD-MM-YY HH24:MI') > to_date(p_end_date,'DD-MM-YY HH24:MI'))) THEN
         l_return_status  := FALSE;
         FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_PTY_END_DATE');
         FND_MESSAGE.SET_TOKEN('ACTIVE_END_DATE',l_party_rec.active_end_date);
         FND_MSG_PUB.ADD;
         RETURN l_return_status;
      END IF;
   END IF;
   --
   IF ( (to_date(l_party_rec.active_start_date,'DD-MM-YY HH24:MI') < to_date( p_start_date,'DD-MM-YY HH24:MI')) OR
        (p_end_date IS NOT NULL AND p_end_date <> FND_API.G_MISS_DATE AND to_date(l_party_rec.active_start_date,'DD-MM-YY HH24:MI') > to_date(p_end_date,'DD-MM-YY HH24:MI')) ) THEN
         l_return_status  := FALSE;
         FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_PTY_START_DATE');
         FND_MESSAGE.SET_TOKEN('ACTIVE_START_DATE',l_party_rec.active_start_date);
         FND_MSG_PUB.ADD;
         RETURN l_return_status;
   END IF;
   IF l_party_tbl.count < 2 THEN
      l_return_status := TRUE;
      RETURN l_return_status;
   END IF;
   --
   IF l_party_rec.contact_flag IS NULL OR
      l_party_rec.contact_flag = FND_API.G_MISS_CHAR THEN
      l_party_rec.contact_flag := 'N';
   END IF;
   --
   IF l_party_rec.contact_ip_id IS NULL OR
      l_party_rec.contact_ip_id = FND_API.G_MISS_NUM THEN
      l_party_rec.contact_ip_id := -9999;
   END IF;
   --
   IF l_party_rec.PREFERRED_FLAG = 'Y' THEN
      IF l_party_rec.CONTACT_FLAG <> 'Y' THEN
         IF l_party_rec.PARTY_SOURCE_TABLE NOT IN ('GROUP','TEAM') THEN
            l_return_status := FALSE;
            FND_MESSAGE.SET_NAME('CSI','CSI_PREFERRED_PTY_TYPE');
            FND_MESSAGE.SET_TOKEN('PARTY_TYPE',l_party_rec.PARTY_SOURCE_TABLE);
            FND_MESSAGE.SET_TOKEN('INSTANCE_ID',l_party_rec.INSTANCE_ID);
            FND_MSG_PUB.ADD;
            RETURN l_return_status;
         END IF;
      END IF;
   END IF;
   --
   FOR pty_row in l_party_tbl.FIRST .. l_party_tbl.LAST LOOP
      IF l_party_tbl(pty_row).contact_flag IS NULL OR
         l_party_tbl(pty_row).contact_flag = FND_API.G_MISS_CHAR THEN
         l_party_tbl(pty_row).contact_flag := 'N';
      END IF;
      --
      IF l_party_tbl(pty_row).contact_ip_id IS NULL OR
         l_party_tbl(pty_row).contact_ip_id = FND_API.G_MISS_NUM THEN
         l_party_tbl(pty_row).contact_ip_id := -9999;
      END IF;
      --
      IF l_party_tbl(pty_row).party_source_table = l_party_rec.party_source_table AND
         l_party_tbl(pty_row).party_id = l_party_rec.party_id AND
         l_party_tbl(pty_row).relationship_type_code = l_party_rec.relationship_type_code AND
         l_party_tbl(pty_row).contact_flag = l_party_rec.contact_flag AND
         l_party_tbl(pty_row).contact_parent_tbl_index = l_party_rec.contact_parent_tbl_index THEN
         l_count := l_count + 1;
      END IF;
      --
      IF l_party_rec.primary_flag = 'Y' THEN
         IF l_party_rec.contact_flag <> 'Y' THEN
            IF l_party_rec.party_source_table NOT IN ('GROUP','TEAM') THEN
               l_return_status := FALSE;
               FND_MESSAGE.SET_NAME('CSI','CSI_PRIMARY_PTY_TYPE');
               FND_MESSAGE.SET_TOKEN('PARTY_TYPE',l_party_rec.PARTY_SOURCE_TABLE);
               FND_MESSAGE.SET_TOKEN('INSTANCE_ID',l_party_rec.INSTANCE_ID);
               FND_MSG_PUB.ADD;
               exit;
            ELSE
              -- Check for Primary Party
              IF l_party_tbl(pty_row).primary_flag = 'Y' AND
                 l_party_tbl(pty_row).contact_flag <>'Y' AND
                 l_party_tbl(pty_row).relationship_type_code = l_party_rec.relationship_type_code THEN
                 l_primary_pty_count := l_primary_pty_count + 1;
              END IF;
            END IF;
         ELSE
            -- check for Primary contact party
            IF l_party_tbl(pty_row).primary_flag = 'Y' AND
               l_party_tbl(pty_row).contact_flag = 'Y' AND
               l_party_tbl(pty_row).contact_parent_tbl_index = l_party_rec.contact_parent_tbl_index AND
               l_party_tbl(pty_row).relationship_type_code = l_party_rec.relationship_type_code THEN
               l_primary_con_count := l_primary_con_count + 1;
            END IF;
         END IF;
      END IF;
   END LOOP;
   --
   IF l_count > 1 THEN
      l_return_status := FALSE;
      FND_MESSAGE.SET_NAME('CSI','CSI_API_MANY_PTY_REL_COM_EXIST');
      FND_MESSAGE.SET_TOKEN('PARTY_REL_COMB',to_char(l_party_rec.INSTANCE_ID)||','||l_party_rec.PARTY_SOURCE_TABLE||','||to_char(l_party_rec.party_id)||','||l_party_rec.relationship_type_code);
      FND_MSG_PUB.ADD;
      RETURN l_return_status;
   END IF;
   --
   IF l_primary_pty_count > 1 OR
      l_primary_con_count > 1 THEN
      l_return_status := FALSE;
      FND_MESSAGE.SET_NAME('CSI','CSI_API_PRIMARY_PTY_EXISTS');
      FND_MESSAGE.SET_TOKEN('INSTANCE_ID',l_party_rec.INSTANCE_ID);
      FND_MESSAGE.SET_TOKEN('RELATIONSHIP_TYPE',l_party_rec.relationship_type_code);
      FND_MSG_PUB.ADD;
      RETURN l_return_status;
   END IF;
   --
   RETURN l_return_status;
END Check_Inst_Party_Rules;
--
FUNCTION Check_Party_Acct_Rules
   (
     p_account_tbl           IN csi_datastructures_pub.party_account_tbl
    ,p_account_rec           IN csi_datastructures_pub.party_account_rec
    ,p_pty_src_table         IN VARCHAR2
    ,p_party_id              IN NUMBER
    ,p_acct_id_tbl           IN OUT NOCOPY  csi_party_relationships_pvt.acct_id_tbl
    ,p_start_date            IN DATE -- Instance Party Start Date
    ,p_end_date              IN DATE -- Instance Party End Date
   ) RETURN BOOLEAN IS
   --
   l_return_status       BOOLEAN;
   l_count               NUMBER := 0;
   l_rel_count           NUMBER := 0;
   l_exists              VARCHAR2(1);
   l_exists_flag         VARCHAR2(1);
   l_valid_flag          VARCHAR2(1);
   l_ctr                 NUMBER;
BEGIN
   l_return_status := TRUE;
   --
   IF p_account_rec.active_end_date IS NOT NULL AND
      p_account_rec.active_end_date <> FND_API.G_MISS_DATE THEN
      IF to_date(p_account_rec.active_start_date,'DD-MM-YY HH24:MI') > to_date(p_account_rec.active_end_date,'DD-MM-YY HH24:MI') THEN
         l_return_status := FALSE;
         FND_MESSAGE.SET_NAME('CSI','CSI_API_INV_ACCT_START_DATE');
         FND_MESSAGE.SET_TOKEN('ACTIVE_START_DATE',p_account_rec.active_start_date);
         FND_MSG_PUB.ADD;
         RETURN l_return_status;
      END IF;
      --
      IF ( (to_date(p_account_rec.active_end_date,'DD-MM-YY HH24:MI') < to_date(SYSDATE,'DD-MM-YY HH24:MI')) OR
           (p_end_date IS NOT NULL AND to_date(p_account_rec.active_end_date,'DD-MM-YY HH24:MI') > to_date(p_end_date,'DD-MM-YY HH24:MI')) ) THEN
         l_return_status  := FALSE;
         FND_MESSAGE.SET_NAME('CSI','CSI_API_INV_ACCT_END_DATE');
         FND_MESSAGE.SET_TOKEN('ACTIVE_END_DATE',p_account_rec.active_end_date);
         FND_MSG_PUB.ADD;
         RETURN l_return_status;
      END IF;
   END IF;
   --
   IF ( (to_date(p_account_rec.active_start_date,'DD-MM-YY HH24:MI') < to_date(p_start_date,'DD-MM-YY HH24:MI')) OR
        (p_end_date IS NOT NULL AND p_end_date <> FND_API.G_MISS_DATE AND to_date(p_account_rec.active_start_date,'DD-MM-YY HH24:MI') > to_date(p_end_date,'DD-MM-YY HH24:MI')) ) THEN
      l_return_status := FALSE;
      FND_MESSAGE.SET_NAME('CSI','CSI_API_INV_ACCT_START_DATE');
      FND_MESSAGE.SET_TOKEN('ACTIVE_START_DATE',p_account_rec.active_start_date);
      FND_MSG_PUB.ADD;
      RETURN l_return_status;
   END IF;
   --
 /****  IF p_pty_src_table = 'HZ_PARTIES' AND
      p_account_rec.relationship_type_code = 'OWNER' THEN
      Begin
         select 'x'
         into l_exists
         from HZ_PARTIES hzp
             ,HZ_CUST_ACCOUNTS hzc
         where hzc.cust_account_id = p_account_rec.party_account_id
         and   hzc.party_id = p_party_id
         and   hzc.party_id = hzp.party_id;
      Exception
         when others then
            l_return_status := FALSE;
            FND_MESSAGE.SET_NAME('CSI','CSI_API_PTY_ACCT_HZ_PTY');
            FND_MESSAGE.SET_TOKEN('PARTY_ACCOUNT_ID',p_account_rec.party_account_id);
            FND_MESSAGE.SET_TOKEN('PARTY_ID',p_party_id);
            RETURN l_return_status;
      End;
   ELSE
      Begin
         select 'x'
         into l_exists
         from HZ_CUST_ACCOUNTS hzc
         where hzc.cust_account_id = p_account_rec.party_account_id;
      Exception
         when others then
            l_return_status := FALSE;
            FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_PTY_ACCT_ID');
            FND_MESSAGE.SET_TOKEN('PARTY_ACCOUNT_ID',p_account_rec.party_account_id);
            RETURN l_return_status;
      End;
   END IF;   ***/
   --
   l_exists_flag := 'N';
   l_valid_flag := 'Y';
   IF p_account_rec.party_account_id IS NOT NULL AND
      p_account_rec.party_account_id <> FND_API.G_MISS_NUM THEN
      IF p_acct_id_tbl.count > 0 THEN
         FOR acct_row in p_acct_id_tbl.FIRST .. p_acct_id_tbl.LAST LOOP
            IF p_acct_id_tbl(acct_row).account_id = p_account_rec.party_account_id THEN
               l_valid_flag := p_acct_id_tbl(acct_row).valid_flag;
               l_exists_flag := 'Y';
               exit;
            END IF;
         END LOOP;
         --
         IF l_valid_flag <> 'Y' THEN
            l_return_status := FALSE;
            FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_PTY_ACCT_ID');
            FND_MESSAGE.SET_TOKEN('PARTY_ACCOUNT_ID',p_account_rec.party_account_id);
            FND_MSG_PUB.ADD;
            RETURN l_return_status;
         END IF;
      END IF;
      --
      IF l_exists_flag <> 'Y' THEN
         l_ctr := p_acct_id_tbl.count + 1;
         p_acct_id_tbl(l_ctr).account_id := p_account_rec.party_account_id;
	 Begin
	    select 'x'
	    into l_exists
	    from HZ_CUST_ACCOUNTS hzc
	    where hzc.cust_account_id = p_account_rec.party_account_id;
            p_acct_id_tbl(l_ctr).valid_flag := 'Y';
	 Exception
	    when others then
               p_acct_id_tbl(l_ctr).valid_flag := 'N';
	       l_return_status := FALSE;
	       FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_PTY_ACCT_ID');
	       FND_MESSAGE.SET_TOKEN('PARTY_ACCOUNT_ID',p_account_rec.party_account_id);
               FND_MSG_PUB.ADD;
	       RETURN l_return_status;
	 End;
      END IF;
   END IF;
   --
   IF p_account_tbl.count < 2 THEN
      l_return_status := TRUE;
      RETURN l_return_status;
   END IF;
   --
   FOR acct_row in p_account_tbl.FIRST .. p_account_tbl.LAST LOOP
      IF p_account_tbl(acct_row).party_account_id = p_account_rec.party_account_id AND
         p_account_tbl(acct_row).relationship_type_code = p_account_rec.relationship_type_code THEN
         l_count := l_count + 1;
      END IF;
      --
      IF p_account_tbl(acct_row).relationship_type_code = p_account_rec.relationship_type_code THEN
         l_rel_count := l_rel_count + 1;
      END IF;
   END LOOP;
   --
   IF l_count > 1 THEN
      l_return_status := FALSE;
      FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_PARTY_ACCT_COM');
      FND_MESSAGE.SET_TOKEN('ACCT_COMBINATION',to_char(p_account_rec.instance_party_id) ||', '
                      ||to_char(p_account_rec.party_account_id) ||','||p_account_rec.relationship_type_code);
      FND_MSG_PUB.ADD;
      RETURN l_return_status;
   END IF;
   --
   IF l_rel_count > 1 THEN
      l_return_status := FALSE;
      FND_MESSAGE.SET_NAME('CSI','CSI_API_DUP_ACCT_TYPE');
      FND_MESSAGE.SET_TOKEN('RELATIONSHIP_TYPE_CODE',p_account_rec.relationship_type_code);
      FND_MSG_PUB.ADD;
      RETURN l_return_status;
   END IF;
   --
   RETURN l_return_status;
END Check_Party_Acct_Rules;
--
FUNCTION Check_Org_Rules
   ( p_org_units_tbl  IN csi_datastructures_pub.organization_units_tbl
    ,p_org_units_rec  IN csi_datastructures_pub.organization_units_rec
    ,p_start_date     IN DATE
    ,p_end_date       IN DATE
   ) RETURN BOOLEAN IS
   --
   l_count               NUMBER := 0;
   l_return_status       BOOLEAN;
BEGIN
   l_return_status := TRUE;
   --
   IF p_org_units_rec.active_end_date IS NOT NULL AND
      p_org_units_rec.active_end_date <> FND_API.G_MISS_DATE THEN
      IF p_org_units_rec.active_start_date > p_org_units_rec.active_end_date THEN
         l_return_status := FALSE;
         FND_MESSAGE.SET_NAME('CSI','CSI_API_INVAL_ORG_START_DATE');
         FND_MESSAGE.SET_TOKEN('START_DATE',p_org_units_rec.active_start_date);
         FND_MSG_PUB.ADD;
         RETURN l_return_status;
      END IF;
      --
      IF ( (p_org_units_rec.active_end_date < SYSDATE) OR
           (p_end_date IS NOT NULL AND p_org_units_rec.active_end_date > p_end_date) ) THEN
         l_return_status  := FALSE;
         FND_MESSAGE.SET_NAME('CSI','CSI_API_INVAL_ORG_END_DATE');
         FND_MESSAGE.SET_TOKEN('END_DATE',p_org_units_rec.active_end_date);
         FND_MSG_PUB.ADD;
         RETURN l_return_status;
      END IF;
   END IF;
   --
   IF ( (p_org_units_rec.active_start_date < p_start_date) OR
        (p_end_date IS NOT NULL AND p_end_date <> FND_API.G_MISS_DATE AND p_org_units_rec.active_start_date > p_end_date) ) THEN
      l_return_status := FALSE;
      FND_MESSAGE.SET_NAME('CSI','CSI_API_INVAL_ORG_START_DATE');
      FND_MESSAGE.SET_TOKEN('START_DATE',p_org_units_rec.active_start_date);
      FND_MSG_PUB.ADD;
      RETURN l_return_status;
   END IF;
   --
   IF p_org_units_tbl.count < 2 THEN
      l_return_status := TRUE;
      RETURN l_return_status;
   END IF;
   --
   FOR org_row in p_org_units_tbl.FIRST .. p_org_units_tbl.LAST LOOP
      IF p_org_units_tbl(org_row).relationship_type_code = p_org_units_rec.relationship_type_code THEN
         l_count := l_count + 1;
      END IF;
   END LOOP;
   --
   IF l_count > 1 THEN
      l_return_status := FALSE;
      FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_ALTERNATE_PK');
      FND_MESSAGE.SET_TOKEN('ALTERNATE_PK',to_char(p_org_units_rec.instance_id)||'  '||p_org_units_rec.relationship_type_code);
      FND_MSG_PUB.ADD;
      RETURN l_return_status;
   END IF;
   --
   RETURN l_return_status;
END Check_Org_Rules;
--
FUNCTION Check_Pricing_Rules
   (
     p_pricing_rec    IN csi_datastructures_pub.pricing_attribs_rec
    ,p_start_date     IN DATE
    ,p_end_date       IN DATE
   ) RETURN BOOLEAN IS
   --
   l_return_status       BOOLEAN;
BEGIN
   l_return_status := TRUE;
   --
   IF p_pricing_rec.active_end_date IS NOT NULL AND
      p_pricing_rec.active_end_date <> FND_API.G_MISS_DATE THEN
      IF p_pricing_rec.active_start_date > p_pricing_rec.active_end_date THEN
         l_return_status := FALSE;
         FND_MESSAGE.SET_NAME('CSI','CSI_API_INVAL_PRI_START_DATE');
         FND_MESSAGE.SET_TOKEN('START_DATE',p_pricing_rec.active_start_date);
         FND_MSG_PUB.ADD;
         RETURN l_return_status;
      END IF;
      --
      IF ( (p_pricing_rec.active_end_date < SYSDATE) OR
           (p_end_date IS NOT NULL AND p_pricing_rec.active_end_date > p_end_date) ) THEN
         l_return_status  := FALSE;
         FND_MESSAGE.SET_NAME('CSI','CSI_API_INVAL_PRI_END_DATE');
         FND_MESSAGE.SET_TOKEN('END_DATE',p_pricing_rec.active_end_date);
         FND_MSG_PUB.ADD;
         RETURN l_return_status;
      END IF;
   END IF;
   --
   IF ( (p_pricing_rec.active_start_date < p_start_date) OR
        (p_end_date IS NOT NULL AND p_end_date <> FND_API.G_MISS_DATE AND p_pricing_rec.active_start_date > p_end_date) ) THEN
      l_return_status := FALSE;
      FND_MESSAGE.SET_NAME('CSI','CSI_API_INVAL_PRI_START_DATE');
      FND_MESSAGE.SET_TOKEN('START_DATE',p_pricing_rec.active_start_date);
      FND_MSG_PUB.ADD;
      RETURN l_return_status;
   END IF;
   --
   RETURN l_return_status;
END Check_Pricing_Rules;
--
FUNCTION Check_Ext_Rules
   (
     p_ext_tbl       IN csi_datastructures_pub.extend_attrib_values_tbl
    ,p_ext_rec       IN csi_datastructures_pub.extend_attrib_values_rec
    ,p_start_date     IN DATE
    ,p_end_date       IN DATE
   ) RETURN BOOLEAN IS
   --
   l_count               NUMBER := 0;
   l_return_status       BOOLEAN;
BEGIN
   l_return_status := TRUE;
   --
   IF p_ext_rec.active_end_date IS NOT NULL AND
      p_ext_rec.active_end_date <> FND_API.G_MISS_DATE THEN
      IF p_ext_rec.active_start_date > p_ext_rec.active_end_date THEN
         l_return_status := FALSE;
         FND_MESSAGE.SET_NAME('CSI','CSI_API_INVAL_EXT_START_DATE');
         FND_MESSAGE.SET_TOKEN('START_DATE',p_ext_rec.active_start_date);
         FND_MSG_PUB.ADD;
         RETURN l_return_status;
      END IF;
      --
      IF ( (p_ext_rec.active_end_date < SYSDATE) OR
           (p_end_date IS NOT NULL AND p_ext_rec.active_end_date > p_end_date) ) THEN
         l_return_status  := FALSE;
         FND_MESSAGE.SET_NAME('CSI','CSI_API_INVAL_EXT_END_DATE');
         FND_MESSAGE.SET_TOKEN('END_DATE',p_ext_rec.active_end_date);
         FND_MSG_PUB.ADD;
         RETURN l_return_status;
      END IF;
   END IF;
   --
   IF ( (p_ext_rec.active_start_date < p_start_date) OR
        (p_end_date IS NOT NULL AND p_end_date <> FND_API.G_MISS_DATE AND p_ext_rec.active_start_date > p_end_date) ) THEN
      l_return_status := FALSE;
      FND_MESSAGE.SET_NAME('CSI','CSI_API_INVAL_EXT_START_DATE');
      FND_MESSAGE.SET_TOKEN('START_DATE',p_ext_rec.active_start_date);
      FND_MSG_PUB.ADD;
      RETURN l_return_status;
   END IF;
   --
   IF p_ext_tbl.count < 2 THEN
      l_return_status := TRUE;
      RETURN l_return_status;
   END IF;
   --
   FOR ext_row in p_ext_tbl.FIRST .. p_ext_tbl.LAST LOOP
      IF p_ext_tbl(ext_row).attribute_id = p_ext_rec.attribute_id THEN
         l_count := l_count + 1;
      END IF;
   END LOOP;
   --
   IF l_count > 1 THEN
      l_return_status := FALSE;
      FND_MESSAGE.SET_NAME('CSI','CSI_EXT_INVALID_ALTERNATE_PK');
      FND_MESSAGE.SET_TOKEN('ALTERNATE_PK',to_char(p_ext_rec.instance_id)||','||to_char(p_ext_rec.attribute_id));
      FND_MSG_PUB.ADD;
      RETURN l_return_status;
   END IF;
   --
   RETURN l_return_status;
END Check_Ext_Rules;
--
FUNCTION Check_Asset_Rules
   (
     p_asset_rec    IN csi_datastructures_pub.instance_asset_rec
    ,p_start_date   IN DATE
    ,p_end_date     IN DATE
   ) RETURN BOOLEAN IS
   --
   l_return_status       BOOLEAN;
BEGIN
   l_return_status := TRUE;
   --
   IF p_asset_rec.active_end_date IS NOT NULL AND
      p_asset_rec.active_end_date <> FND_API.G_MISS_DATE THEN
      IF p_asset_rec.active_start_date > p_asset_rec.active_end_date THEN
         l_return_status := FALSE;
         FND_MESSAGE.SET_NAME('CSI','CSI_API_INVAL_AST_START_DATE');
         FND_MESSAGE.SET_TOKEN('START_DATE',p_asset_rec.active_start_date);
         FND_MSG_PUB.ADD;
         RETURN l_return_status;
      END IF;
      --
      IF ( (p_asset_rec.active_end_date < SYSDATE) OR
           (p_end_date IS NOT NULL AND p_asset_rec.active_end_date > p_end_date) ) THEN
         l_return_status  := FALSE;
         FND_MESSAGE.SET_NAME('CSI','CSI_API_INVAL_AST_END_DATE');
         FND_MESSAGE.SET_TOKEN('END_DATE',p_asset_rec.active_end_date);
         FND_MSG_PUB.ADD;
         RETURN l_return_status;
      END IF;
   END IF;
   --
   IF ( (p_asset_rec.active_start_date < p_start_date) OR
        (p_end_date IS NOT NULL AND p_end_date <> FND_API.G_MISS_DATE AND p_asset_rec.active_start_date > p_end_date) ) THEN
      l_return_status := FALSE;
      FND_MESSAGE.SET_NAME('CSI','CSI_API_INVAL_AST_START_DATE');
      FND_MESSAGE.SET_TOKEN('START_DATE',p_asset_rec.active_start_date);
      FND_MSG_PUB.ADD;
      RETURN l_return_status;
   END IF;
   --
   RETURN l_return_status;
END Check_Asset_Rules;
--
PROCEDURE Build_Instance_History
  (
    p_inst_hist_tbl  IN OUT NOCOPY  csi_datastructures_pub.instance_history_tbl
   ,p_inst_rec       IN     csi_datastructures_pub.instance_rec
   ,p_txn_id         IN     NUMBER
  ) IS
  --
  l_count NUMBER;
  l_hist_id NUMBER;
BEGIN
   l_count := p_inst_hist_tbl.count + 1;
   select CSI_ITEM_INSTANCES_H_S.nextval
   into l_hist_id
   from sys.dual;
   p_inst_hist_tbl(l_count).instance_id := p_inst_rec.instance_id;
   p_inst_hist_tbl(l_count).instance_history_id := l_hist_id;
   p_inst_hist_tbl(l_count).transaction_id := p_txn_id;
   p_inst_hist_tbl(l_count).old_instance_number := null;
   p_inst_hist_tbl(l_count).new_instance_number := p_inst_rec.instance_number;
   p_inst_hist_tbl(l_count).old_external_reference := null;
   p_inst_hist_tbl(l_count).new_external_reference := p_inst_rec.external_reference;
   p_inst_hist_tbl(l_count).old_inventory_item_id := null;
   p_inst_hist_tbl(l_count).new_inventory_item_id := p_inst_rec.inventory_item_id;
   p_inst_hist_tbl(l_count).old_inventory_revision := null;
   p_inst_hist_tbl(l_count).new_inventory_revision := p_inst_rec.inventory_revision;
   p_inst_hist_tbl(l_count).old_inv_master_org_id := null;
   p_inst_hist_tbl(l_count).new_inv_master_org_id := p_inst_rec.inv_master_organization_id;
   p_inst_hist_tbl(l_count).old_serial_number := null;
   p_inst_hist_tbl(l_count).new_serial_number  := p_inst_rec.serial_number;
   p_inst_hist_tbl(l_count).old_mfg_serial_number_flag := null;
   p_inst_hist_tbl(l_count).new_mfg_serial_number_flag := p_inst_rec.mfg_serial_number_flag ;
   p_inst_hist_tbl(l_count).old_lot_number := null;
   p_inst_hist_tbl(l_count).new_lot_number := p_inst_rec.lot_number;
   p_inst_hist_tbl(l_count).old_quantity := null;
   p_inst_hist_tbl(l_count).new_quantity := p_inst_rec.quantity;
   p_inst_hist_tbl(l_count).old_unit_of_measure := null;
   p_inst_hist_tbl(l_count).new_unit_of_measure := p_inst_rec.unit_of_measure;
   p_inst_hist_tbl(l_count).old_accounting_class_code := null;
   p_inst_hist_tbl(l_count).new_accounting_class_code := p_inst_rec.accounting_class_code;
   p_inst_hist_tbl(l_count).old_instance_condition_id := null;
   p_inst_hist_tbl(l_count).new_instance_condition_id := p_inst_rec.instance_condition_id;
   p_inst_hist_tbl(l_count).old_instance_status_id := null;
   p_inst_hist_tbl(l_count).new_instance_status_id := p_inst_rec.instance_status_id;
   p_inst_hist_tbl(l_count).old_customer_view_flag := null;
   p_inst_hist_tbl(l_count).new_customer_view_flag := p_inst_rec.customer_view_flag;
   p_inst_hist_tbl(l_count).old_merchant_view_flag := null;
   p_inst_hist_tbl(l_count).new_merchant_view_flag := p_inst_rec.merchant_view_flag;
   p_inst_hist_tbl(l_count).old_sellable_flag := null;
   p_inst_hist_tbl(l_count).new_sellable_flag := p_inst_rec.sellable_flag ;
   p_inst_hist_tbl(l_count).old_system_id := null;
   p_inst_hist_tbl(l_count).new_system_id := p_inst_rec.system_id;
   p_inst_hist_tbl(l_count).old_instance_type_code := null;
   p_inst_hist_tbl(l_count).new_instance_type_code := p_inst_rec.instance_type_code;
   p_inst_hist_tbl(l_count).old_active_start_date := null;
   p_inst_hist_tbl(l_count).new_active_start_date := p_inst_rec.active_start_date;
   p_inst_hist_tbl(l_count).old_active_end_date := null;
   p_inst_hist_tbl(l_count).new_active_end_date := p_inst_rec.active_end_date;
   p_inst_hist_tbl(l_count).old_location_type_code := null;
   p_inst_hist_tbl(l_count).new_location_type_code := p_inst_rec.location_type_code;
   p_inst_hist_tbl(l_count).old_location_id := null;
   p_inst_hist_tbl(l_count).new_location_id := p_inst_rec.location_id;
   p_inst_hist_tbl(l_count).old_inv_organization_id := null;
   p_inst_hist_tbl(l_count).new_inv_organization_id := p_inst_rec.inv_organization_id;
   p_inst_hist_tbl(l_count).old_inv_subinventory_name := null;
   p_inst_hist_tbl(l_count).new_inv_subinventory_name := p_inst_rec.inv_subinventory_name;
   p_inst_hist_tbl(l_count).old_inv_locator_id := null;
   p_inst_hist_tbl(l_count).new_inv_locator_id := p_inst_rec.inv_locator_id;
   p_inst_hist_tbl(l_count).old_pa_project_id := null;
   p_inst_hist_tbl(l_count).new_pa_project_id := p_inst_rec.pa_project_id;
   p_inst_hist_tbl(l_count).old_pa_project_task_id := null;
   p_inst_hist_tbl(l_count).new_pa_project_task_id := p_inst_rec.pa_project_task_id;
   p_inst_hist_tbl(l_count).old_in_transit_order_line_id := null;
   p_inst_hist_tbl(l_count).new_in_transit_order_line_id := p_inst_rec.in_transit_order_line_id;
   p_inst_hist_tbl(l_count).old_wip_job_id := null;
   p_inst_hist_tbl(l_count).new_wip_job_id := p_inst_rec.wip_job_id;
   p_inst_hist_tbl(l_count).old_po_order_line_id := null;
   p_inst_hist_tbl(l_count).new_po_order_line_id := p_inst_rec.po_order_line_id;
   p_inst_hist_tbl(l_count).old_completeness_flag := null;
   p_inst_hist_tbl(l_count).new_completeness_flag := p_inst_rec.completeness_flag;
   p_inst_hist_tbl(l_count).old_context := null;
   p_inst_hist_tbl(l_count).new_context := p_inst_rec.context;
   p_inst_hist_tbl(l_count).old_attribute1 := null;
   p_inst_hist_tbl(l_count).new_attribute1 := p_inst_rec.attribute1;
   p_inst_hist_tbl(l_count).old_attribute2 := null;
   p_inst_hist_tbl(l_count).new_attribute2 := p_inst_rec.attribute2;
   p_inst_hist_tbl(l_count).old_attribute3 := null;
   p_inst_hist_tbl(l_count).new_attribute3 := p_inst_rec.attribute3;
   p_inst_hist_tbl(l_count).old_attribute4 := null;
   p_inst_hist_tbl(l_count).new_attribute4 := p_inst_rec.attribute4;
   p_inst_hist_tbl(l_count).old_attribute5 := null;
   p_inst_hist_tbl(l_count).new_attribute5 := p_inst_rec.attribute5;
   p_inst_hist_tbl(l_count).old_attribute6 := null;
   p_inst_hist_tbl(l_count).new_attribute6 := p_inst_rec.attribute6;
   p_inst_hist_tbl(l_count).old_attribute7 := null;
   p_inst_hist_tbl(l_count).new_attribute7 := p_inst_rec.attribute7;
   p_inst_hist_tbl(l_count).old_attribute8 := null;
   p_inst_hist_tbl(l_count).new_attribute8 := p_inst_rec.attribute8;
   p_inst_hist_tbl(l_count).old_attribute9 := null;
   p_inst_hist_tbl(l_count).new_attribute9 := p_inst_rec.attribute9;
   p_inst_hist_tbl(l_count).old_attribute10 := null;
   p_inst_hist_tbl(l_count).new_attribute10 := p_inst_rec.attribute10;
   p_inst_hist_tbl(l_count).old_attribute11 := null;
   p_inst_hist_tbl(l_count).new_attribute11 := p_inst_rec.attribute11;
   p_inst_hist_tbl(l_count).old_attribute12 := null;
   p_inst_hist_tbl(l_count).new_attribute12 := p_inst_rec.attribute12;
   p_inst_hist_tbl(l_count).old_attribute13 := null;
   p_inst_hist_tbl(l_count).new_attribute13 := p_inst_rec.attribute13;
   p_inst_hist_tbl(l_count).old_attribute14 := null;
   p_inst_hist_tbl(l_count).new_attribute14 := p_inst_rec.attribute14;
   p_inst_hist_tbl(l_count).old_attribute15 := null;
   p_inst_hist_tbl(l_count).new_attribute15 := p_inst_rec.attribute15;
   p_inst_hist_tbl(l_count).old_install_location_type_code := null;
   p_inst_hist_tbl(l_count).new_install_location_type_code := p_inst_rec.install_location_type_code;
   p_inst_hist_tbl(l_count).old_install_location_id := null;
   p_inst_hist_tbl(l_count).new_install_location_id := p_inst_rec.install_location_id;
   p_inst_hist_tbl(l_count).old_instance_usage_code := null;
   p_inst_hist_tbl(l_count).new_instance_usage_code := p_inst_rec.instance_usage_code;
   p_inst_hist_tbl(l_count).old_last_vld_organization_id := null;
   p_inst_hist_tbl(l_count).new_last_vld_organization_id := p_inst_rec.vld_organization_id;
   p_inst_hist_tbl(l_count).old_config_inst_rev_num := null;
   p_inst_hist_tbl(l_count).new_config_inst_rev_num := p_inst_rec.config_inst_rev_num;
   p_inst_hist_tbl(l_count).old_config_valid_status := null;
   p_inst_hist_tbl(l_count).new_config_valid_status := p_inst_rec.config_valid_status;
   p_inst_hist_tbl(l_count).old_instance_description := null;
   p_inst_hist_tbl(l_count).new_instance_description := p_inst_rec.instance_description;
   p_inst_hist_tbl(l_count).old_last_oe_agreement_id := null;
   p_inst_hist_tbl(l_count).new_last_oe_agreement_id := p_inst_rec.last_oe_agreement_id;
   p_inst_hist_tbl(l_count).old_install_date := null;
   p_inst_hist_tbl(l_count).new_install_date := p_inst_rec.install_date;
   p_inst_hist_tbl(l_count).old_return_by_date := null;
   p_inst_hist_tbl(l_count).new_return_by_date := p_inst_rec.return_by_date;
   p_inst_hist_tbl(l_count).old_actual_return_date := null;
   p_inst_hist_tbl(l_count).new_actual_return_date := p_inst_rec.actual_return_date;
   p_inst_hist_tbl(l_count).old_last_oe_order_line_id := null;
   p_inst_hist_tbl(l_count).new_last_oe_order_line_id := p_inst_rec.last_oe_order_line_id;
   p_inst_hist_tbl(l_count).old_last_oe_rma_line_id := null;
   p_inst_hist_tbl(l_count).new_last_oe_rma_line_id := p_inst_rec.last_oe_rma_line_id;
   p_inst_hist_tbl(l_count).old_last_wip_job_id := null;
   p_inst_hist_tbl(l_count).new_last_wip_job_id := p_inst_rec.last_wip_job_id;
   p_inst_hist_tbl(l_count).old_last_po_po_line_id := null;
   p_inst_hist_tbl(l_count).new_last_po_po_line_id := p_inst_rec.last_po_po_line_id;
   p_inst_hist_tbl(l_count).old_last_pa_project_id := null;
   p_inst_hist_tbl(l_count).new_last_pa_project_id := p_inst_rec.last_pa_project_id;
   p_inst_hist_tbl(l_count).old_last_pa_task_id := null;
   p_inst_hist_tbl(l_count).new_last_pa_task_id := p_inst_rec.last_pa_task_id;
   p_inst_hist_tbl(l_count).old_last_txn_line_detail_id := null;
   p_inst_hist_tbl(l_count).new_last_txn_line_detail_id := p_inst_rec.last_txn_line_detail_id;
   p_inst_hist_tbl(l_count).old_last_oe_po_number := null;
   p_inst_hist_tbl(l_count).new_last_oe_po_number := p_inst_rec.last_oe_po_number;

   p_inst_hist_tbl(l_count).old_network_asset_flag       := null;
   p_inst_hist_tbl(l_count).new_network_asset_flag       := p_inst_rec.network_asset_flag;
   p_inst_hist_tbl(l_count).old_maintainable_flag        := null;
   p_inst_hist_tbl(l_count).new_maintainable_flag        := p_inst_rec.maintainable_flag;
   p_inst_hist_tbl(l_count).old_asset_criticality_code   := null;
   p_inst_hist_tbl(l_count).new_asset_criticality_code   := p_inst_rec.asset_criticality_code;
   p_inst_hist_tbl(l_count).old_category_id              := null;
   p_inst_hist_tbl(l_count).new_category_id              := p_inst_rec.category_id ;
   p_inst_hist_tbl(l_count).old_equipment_gen_object_id  := null;
   p_inst_hist_tbl(l_count).new_equipment_gen_object_id  := p_inst_rec.equipment_gen_object_id ;
   p_inst_hist_tbl(l_count).old_instantiation_flag       := null;
   p_inst_hist_tbl(l_count).new_instantiation_flag       := p_inst_rec.instantiation_flag;
   p_inst_hist_tbl(l_count).old_operational_log_flag     := null;
   p_inst_hist_tbl(l_count).new_operational_log_flag     := p_inst_rec.operational_log_flag ;
   p_inst_hist_tbl(l_count).old_supplier_warranty_exp_date := null;
   p_inst_hist_tbl(l_count).new_supplier_warranty_exp_date := p_inst_rec.supplier_warranty_exp_date ;
   p_inst_hist_tbl(l_count).old_attribute16              := null;
   p_inst_hist_tbl(l_count).new_attribute16              := p_inst_rec.attribute16;
   p_inst_hist_tbl(l_count).old_attribute17              := null;
   p_inst_hist_tbl(l_count).new_attribute17              := p_inst_rec.attribute17;
   p_inst_hist_tbl(l_count).old_attribute18              := null;
   p_inst_hist_tbl(l_count).new_attribute18              := p_inst_rec.attribute18;
   p_inst_hist_tbl(l_count).old_attribute19              := null;
   p_inst_hist_tbl(l_count).new_attribute19              := p_inst_rec.attribute19;
   p_inst_hist_tbl(l_count).old_attribute20              := null;
   p_inst_hist_tbl(l_count).new_attribute20              := p_inst_rec.attribute20;
   p_inst_hist_tbl(l_count).old_attribute21              := null;
   p_inst_hist_tbl(l_count).new_attribute21              := p_inst_rec.attribute21;
   p_inst_hist_tbl(l_count).old_attribute22              := null;
   p_inst_hist_tbl(l_count).new_attribute22              := p_inst_rec.attribute22;
   p_inst_hist_tbl(l_count).old_attribute23              := null;
   p_inst_hist_tbl(l_count).new_attribute23              := p_inst_rec.attribute23;
   p_inst_hist_tbl(l_count).old_attribute24              := null;
   p_inst_hist_tbl(l_count).new_attribute24              := p_inst_rec.attribute24;
   p_inst_hist_tbl(l_count).old_attribute25              := null;
   p_inst_hist_tbl(l_count).new_attribute25              := p_inst_rec.attribute25;
   p_inst_hist_tbl(l_count).old_attribute26              := null;
   p_inst_hist_tbl(l_count).new_attribute26              := p_inst_rec.attribute26;
   p_inst_hist_tbl(l_count).old_attribute27              := null;
   p_inst_hist_tbl(l_count).new_attribute27              := p_inst_rec.attribute27;
   p_inst_hist_tbl(l_count).old_attribute28              := null;
   p_inst_hist_tbl(l_count).new_attribute28              := p_inst_rec.attribute28;
   p_inst_hist_tbl(l_count).old_attribute29              := null;
   p_inst_hist_tbl(l_count).new_attribute29              := p_inst_rec.attribute29;
   p_inst_hist_tbl(l_count).old_attribute30              := null;
   p_inst_hist_tbl(l_count).new_attribute30              := p_inst_rec.attribute30;
   --
   p_inst_hist_tbl(l_count).old_payables_currency_code   := null;
   p_inst_hist_tbl(l_count).new_payables_currency_code   := p_inst_rec.payables_currency_code;
   p_inst_hist_tbl(l_count).old_purchase_unit_price      := null;
   p_inst_hist_tbl(l_count).new_purchase_unit_price      := p_inst_rec.purchase_unit_price;
   p_inst_hist_tbl(l_count).old_purchase_currency_code   := null;
   p_inst_hist_tbl(l_count).new_purchase_currency_code   := p_inst_rec.purchase_currency_code;
   p_inst_hist_tbl(l_count).old_payables_unit_price      := null;
   p_inst_hist_tbl(l_count).new_payables_unit_price      := p_inst_rec.payables_unit_price;
   p_inst_hist_tbl(l_count).old_sales_unit_price         := null;
   p_inst_hist_tbl(l_count).new_sales_unit_price         := p_inst_rec.sales_unit_price;
   p_inst_hist_tbl(l_count).old_sales_currency_code      := null;
   p_inst_hist_tbl(l_count).new_sales_currency_code      := p_inst_rec.sales_currency_code;
   p_inst_hist_tbl(l_count).old_operational_status_code  := null;
   p_inst_hist_tbl(l_count).new_operational_status_code  := p_inst_rec.operational_status_code;

END Build_Instance_History;
--
PROCEDURE Build_Ver_Label_History
   (
     p_ver_label_history_tbl    IN OUT NOCOPY  csi_datastructures_pub.version_label_history_tbl
    ,p_version_label_rec        IN     csi_datastructures_pub.version_label_rec
    ,p_txn_id                   IN     NUMBER
   ) IS
  --
  l_count NUMBER;
  l_hist_id NUMBER;
BEGIN
   l_count := p_ver_label_history_tbl.count + 1;
   select CSI_I_VERSION_LABELS_H_S.nextval
   into l_hist_id
   from sys.dual;
   --
   p_ver_label_history_tbl(l_count).VERSION_LABEL_HISTORY_ID	 := l_hist_id;
   p_ver_label_history_tbl(l_count).VERSION_LABEL_ID	 := p_version_label_rec.VERSION_LABEL_ID;
   p_ver_label_history_tbl(l_count).TRANSACTION_ID	 := p_txn_id;
   p_ver_label_history_tbl(l_count).OLD_VERSION_LABEL	 := NULL;
   p_ver_label_history_tbl(l_count).NEW_VERSION_LABEL	 := p_version_label_rec.VERSION_LABEL;
   p_ver_label_history_tbl(l_count).OLD_DESCRIPTION	 := NULL;
   p_ver_label_history_tbl(l_count).NEW_DESCRIPTION	 := p_version_label_rec.DESCRIPTION;
   p_ver_label_history_tbl(l_count).OLD_DATE_TIME_STAMP	 := NULL;
   p_ver_label_history_tbl(l_count).NEW_DATE_TIME_STAMP	 := p_version_label_rec.DATE_TIME_STAMP;
   p_ver_label_history_tbl(l_count).OLD_ACTIVE_START_DATE	 := NULL;
   p_ver_label_history_tbl(l_count).NEW_ACTIVE_START_DATE	 := p_version_label_rec.ACTIVE_START_DATE;
   p_ver_label_history_tbl(l_count).OLD_ACTIVE_END_DATE	 := NULL;
   p_ver_label_history_tbl(l_count).NEW_ACTIVE_END_DATE	 := p_version_label_rec.ACTIVE_END_DATE;
   p_ver_label_history_tbl(l_count).OLD_CONTEXT	 := NULL;
   p_ver_label_history_tbl(l_count).NEW_CONTEXT	 := p_version_label_rec.CONTEXT;
   p_ver_label_history_tbl(l_count).OLD_ATTRIBUTE1	 := NULL;
   p_ver_label_history_tbl(l_count).NEW_ATTRIBUTE1	 := p_version_label_rec.ATTRIBUTE1;
   p_ver_label_history_tbl(l_count).OLD_ATTRIBUTE2	 := NULL;
   p_ver_label_history_tbl(l_count).NEW_ATTRIBUTE2	 := p_version_label_rec.ATTRIBUTE2;
   p_ver_label_history_tbl(l_count).OLD_ATTRIBUTE3	 := NULL;
   p_ver_label_history_tbl(l_count).NEW_ATTRIBUTE3	 := p_version_label_rec.ATTRIBUTE3;
   p_ver_label_history_tbl(l_count).OLD_ATTRIBUTE4	 := NULL;
   p_ver_label_history_tbl(l_count).NEW_ATTRIBUTE4	 := p_version_label_rec.ATTRIBUTE4;
   p_ver_label_history_tbl(l_count).OLD_ATTRIBUTE5	 := NULL;
   p_ver_label_history_tbl(l_count).NEW_ATTRIBUTE5	 := p_version_label_rec.ATTRIBUTE5;
   p_ver_label_history_tbl(l_count).OLD_ATTRIBUTE6	 := NULL;
   p_ver_label_history_tbl(l_count).NEW_ATTRIBUTE6	 := p_version_label_rec.ATTRIBUTE6;
   p_ver_label_history_tbl(l_count).OLD_ATTRIBUTE7	 := NULL;
   p_ver_label_history_tbl(l_count).NEW_ATTRIBUTE7	 := p_version_label_rec.ATTRIBUTE7;
   p_ver_label_history_tbl(l_count).OLD_ATTRIBUTE8	 := NULL;
   p_ver_label_history_tbl(l_count).NEW_ATTRIBUTE8	 := p_version_label_rec.ATTRIBUTE8;
   p_ver_label_history_tbl(l_count).OLD_ATTRIBUTE9	 := NULL;
   p_ver_label_history_tbl(l_count).NEW_ATTRIBUTE9	 := p_version_label_rec.ATTRIBUTE9;
   p_ver_label_history_tbl(l_count).OLD_ATTRIBUTE10	 := NULL;
   p_ver_label_history_tbl(l_count).NEW_ATTRIBUTE10	 := p_version_label_rec.ATTRIBUTE10;
   p_ver_label_history_tbl(l_count).OLD_ATTRIBUTE11	 := NULL;
   p_ver_label_history_tbl(l_count).NEW_ATTRIBUTE11	 := p_version_label_rec.ATTRIBUTE11;
   p_ver_label_history_tbl(l_count).OLD_ATTRIBUTE12	 := NULL;
   p_ver_label_history_tbl(l_count).NEW_ATTRIBUTE12	 := p_version_label_rec.ATTRIBUTE12;
   p_ver_label_history_tbl(l_count).OLD_ATTRIBUTE13	 := NULL;
   p_ver_label_history_tbl(l_count).NEW_ATTRIBUTE13	 := p_version_label_rec.ATTRIBUTE13;
   p_ver_label_history_tbl(l_count).OLD_ATTRIBUTE14	 := NULL;
   p_ver_label_history_tbl(l_count).NEW_ATTRIBUTE14	 := p_version_label_rec.ATTRIBUTE14;
   p_ver_label_history_tbl(l_count).OLD_ATTRIBUTE15	 := NULL;
   p_ver_label_history_tbl(l_count).NEW_ATTRIBUTE15	 := p_version_label_rec.ATTRIBUTE15;
END Build_Ver_Label_History;
--
PROCEDURE Build_Party_History
    ( p_party_hist_tbl     IN OUT NOCOPY  csi_datastructures_pub.party_history_tbl
     ,p_party_rec          IN     csi_datastructures_pub.party_rec
     ,p_txn_id             IN     NUMBER
    ) IS
    l_count    NUMBER;
    l_hist_id  NUMBER;
BEGIN
   l_count := p_party_hist_tbl.count + 1;
   select CSI_I_PARTIES_H_S.nextval
   into l_hist_id
   from sys.dual;
   --
   p_party_hist_tbl(l_count).INSTANCE_PARTY_HISTORY_ID := l_hist_id;
   p_party_hist_tbl(l_count).INSTANCE_PARTY_ID := p_party_rec.INSTANCE_PARTY_ID;
   p_party_hist_tbl(l_count).TRANSACTION_ID := p_txn_id;
   p_party_hist_tbl(l_count).OLD_PARTY_SOURCE_TABLE := NULL;
   p_party_hist_tbl(l_count).NEW_PARTY_SOURCE_TABLE := p_party_rec.PARTY_SOURCE_TABLE;
   p_party_hist_tbl(l_count).OLD_PARTY_ID := NULL;
   p_party_hist_tbl(l_count).NEW_PARTY_ID := p_party_rec.PARTY_ID;
   p_party_hist_tbl(l_count).OLD_RELATIONSHIP_TYPE_CODE := NULL;
   p_party_hist_tbl(l_count).NEW_RELATIONSHIP_TYPE_CODE := p_party_rec.RELATIONSHIP_TYPE_CODE;
   p_party_hist_tbl(l_count).OLD_CONTACT_FLAG := NULL;
   p_party_hist_tbl(l_count).NEW_CONTACT_FLAG := p_party_rec.CONTACT_FLAG;
   p_party_hist_tbl(l_count).OLD_CONTACT_IP_ID := NULL;
   p_party_hist_tbl(l_count).NEW_CONTACT_IP_ID := p_party_rec.CONTACT_IP_ID;
   p_party_hist_tbl(l_count).OLD_ACTIVE_START_DATE := NULL;
   p_party_hist_tbl(l_count).NEW_ACTIVE_START_DATE := p_party_rec.ACTIVE_START_DATE;
   p_party_hist_tbl(l_count).OLD_ACTIVE_END_DATE := NULL;
   p_party_hist_tbl(l_count).NEW_ACTIVE_END_DATE := p_party_rec.ACTIVE_END_DATE;
   p_party_hist_tbl(l_count).OLD_CONTEXT := NULL;
   p_party_hist_tbl(l_count).NEW_CONTEXT := p_party_rec.CONTEXT;
   p_party_hist_tbl(l_count).OLD_ATTRIBUTE1 := NULL;
   p_party_hist_tbl(l_count).NEW_ATTRIBUTE1 := p_party_rec.ATTRIBUTE1;
   p_party_hist_tbl(l_count).OLD_ATTRIBUTE2 := NULL;
   p_party_hist_tbl(l_count).NEW_ATTRIBUTE2 := p_party_rec.ATTRIBUTE2;
   p_party_hist_tbl(l_count).OLD_ATTRIBUTE3 := NULL;
   p_party_hist_tbl(l_count).NEW_ATTRIBUTE3 := p_party_rec.ATTRIBUTE3;
   p_party_hist_tbl(l_count).OLD_ATTRIBUTE4 := NULL;
   p_party_hist_tbl(l_count).NEW_ATTRIBUTE4 := p_party_rec.ATTRIBUTE4;
   p_party_hist_tbl(l_count).OLD_ATTRIBUTE5 := NULL;
   p_party_hist_tbl(l_count).NEW_ATTRIBUTE5 := p_party_rec.ATTRIBUTE5;
   p_party_hist_tbl(l_count).OLD_ATTRIBUTE6 := NULL;
   p_party_hist_tbl(l_count).NEW_ATTRIBUTE6 := p_party_rec.ATTRIBUTE6;
   p_party_hist_tbl(l_count).OLD_ATTRIBUTE7 := NULL;
   p_party_hist_tbl(l_count).NEW_ATTRIBUTE7 := p_party_rec.ATTRIBUTE7;
   p_party_hist_tbl(l_count).OLD_ATTRIBUTE8 := NULL;
   p_party_hist_tbl(l_count).NEW_ATTRIBUTE8 := p_party_rec.ATTRIBUTE8;
   p_party_hist_tbl(l_count).OLD_ATTRIBUTE9 := NULL;
   p_party_hist_tbl(l_count).NEW_ATTRIBUTE9 := p_party_rec.ATTRIBUTE9;
   p_party_hist_tbl(l_count).OLD_ATTRIBUTE10 := NULL;
   p_party_hist_tbl(l_count).NEW_ATTRIBUTE10 := p_party_rec.ATTRIBUTE10;
   p_party_hist_tbl(l_count).OLD_ATTRIBUTE11 := NULL;
   p_party_hist_tbl(l_count).NEW_ATTRIBUTE11 := p_party_rec.ATTRIBUTE11;
   p_party_hist_tbl(l_count).OLD_ATTRIBUTE12 := NULL;
   p_party_hist_tbl(l_count).NEW_ATTRIBUTE12 := p_party_rec.ATTRIBUTE12;
   p_party_hist_tbl(l_count).OLD_ATTRIBUTE13 := NULL;
   p_party_hist_tbl(l_count).NEW_ATTRIBUTE13 := p_party_rec.ATTRIBUTE13;
   p_party_hist_tbl(l_count).OLD_ATTRIBUTE14 := NULL;
   p_party_hist_tbl(l_count).NEW_ATTRIBUTE14 := p_party_rec.ATTRIBUTE14;
   p_party_hist_tbl(l_count).OLD_ATTRIBUTE15 := NULL;
   p_party_hist_tbl(l_count).NEW_ATTRIBUTE15 := p_party_rec.ATTRIBUTE15;
   p_party_hist_tbl(l_count).OLD_PRIMARY_FLAG := NULL;
   p_party_hist_tbl(l_count).NEW_PRIMARY_FLAG := p_party_rec.PRIMARY_FLAG;
   p_party_hist_tbl(l_count).OLD_PREFERRED_FLAG := NULL;
   p_party_hist_tbl(l_count).NEW_PREFERRED_FLAG := p_party_rec.PREFERRED_FLAG;
END Build_Party_History;
--
PROCEDURE Build_Account_History
    ( p_acct_hist_tbl      IN OUT NOCOPY  csi_datastructures_pub.account_history_tbl
     ,p_acct_rec           IN     csi_datastructures_pub.party_account_rec
     ,p_txn_id             IN     NUMBER
    ) IS
--
   l_count    NUMBER;
   l_hist_id  NUMBER;
BEGIN
   l_count := p_acct_hist_tbl.count + 1;
   select CSI_IP_ACCOUNTS_H_S.nextval
   into l_hist_id
   from sys.dual;
   --
   p_acct_hist_tbl(l_count).IP_ACCOUNT_HISTORY_ID := l_hist_id;
   p_acct_hist_tbl(l_count).IP_ACCOUNT_ID := p_acct_rec.IP_ACCOUNT_ID;
   p_acct_hist_tbl(l_count).TRANSACTION_ID := p_txn_id;
   p_acct_hist_tbl(l_count).OLD_PARTY_ACCOUNT_ID := NULL;
   p_acct_hist_tbl(l_count).NEW_PARTY_ACCOUNT_ID := p_acct_rec.PARTY_ACCOUNT_ID;
   p_acct_hist_tbl(l_count).OLD_RELATIONSHIP_TYPE_CODE := NULL;
   p_acct_hist_tbl(l_count).NEW_RELATIONSHIP_TYPE_CODE := p_acct_rec.RELATIONSHIP_TYPE_CODE;
   p_acct_hist_tbl(l_count).OLD_ACTIVE_START_DATE := NULL;
   p_acct_hist_tbl(l_count).NEW_ACTIVE_START_DATE := p_acct_rec.ACTIVE_START_DATE;
   p_acct_hist_tbl(l_count).OLD_ACTIVE_END_DATE := NULL;
   p_acct_hist_tbl(l_count).NEW_ACTIVE_END_DATE := p_acct_rec.ACTIVE_END_DATE;
   p_acct_hist_tbl(l_count).OLD_CONTEXT := NULL;
   p_acct_hist_tbl(l_count).NEW_CONTEXT := p_acct_rec.CONTEXT;
   p_acct_hist_tbl(l_count).OLD_ATTRIBUTE1 := NULL;
   p_acct_hist_tbl(l_count).NEW_ATTRIBUTE1 := p_acct_rec.ATTRIBUTE1;
   p_acct_hist_tbl(l_count).OLD_ATTRIBUTE2 := NULL;
   p_acct_hist_tbl(l_count).NEW_ATTRIBUTE2 := p_acct_rec.ATTRIBUTE2;
   p_acct_hist_tbl(l_count).OLD_ATTRIBUTE3 := NULL;
   p_acct_hist_tbl(l_count).NEW_ATTRIBUTE3 := p_acct_rec.ATTRIBUTE3;
   p_acct_hist_tbl(l_count).OLD_ATTRIBUTE4 := NULL;
   p_acct_hist_tbl(l_count).NEW_ATTRIBUTE4 := p_acct_rec.ATTRIBUTE4;
   p_acct_hist_tbl(l_count).OLD_ATTRIBUTE5 := NULL;
   p_acct_hist_tbl(l_count).NEW_ATTRIBUTE5 := p_acct_rec.ATTRIBUTE5;
   p_acct_hist_tbl(l_count).OLD_ATTRIBUTE6 := NULL;
   p_acct_hist_tbl(l_count).NEW_ATTRIBUTE6 := p_acct_rec.ATTRIBUTE6;
   p_acct_hist_tbl(l_count).OLD_ATTRIBUTE7 := NULL;
   p_acct_hist_tbl(l_count).NEW_ATTRIBUTE7 := p_acct_rec.ATTRIBUTE7;
   p_acct_hist_tbl(l_count).OLD_ATTRIBUTE8 := NULL;
   p_acct_hist_tbl(l_count).NEW_ATTRIBUTE8 := p_acct_rec.ATTRIBUTE8;
   p_acct_hist_tbl(l_count).OLD_ATTRIBUTE9 := NULL;
   p_acct_hist_tbl(l_count).NEW_ATTRIBUTE9 := p_acct_rec.ATTRIBUTE9;
   p_acct_hist_tbl(l_count).OLD_ATTRIBUTE10 := NULL;
   p_acct_hist_tbl(l_count).NEW_ATTRIBUTE10 := p_acct_rec.ATTRIBUTE10;
   p_acct_hist_tbl(l_count).OLD_ATTRIBUTE11 := NULL;
   p_acct_hist_tbl(l_count).NEW_ATTRIBUTE11 := p_acct_rec.ATTRIBUTE11;
   p_acct_hist_tbl(l_count).OLD_ATTRIBUTE12 := NULL;
   p_acct_hist_tbl(l_count).NEW_ATTRIBUTE12 := p_acct_rec.ATTRIBUTE12;
   p_acct_hist_tbl(l_count).OLD_ATTRIBUTE13 := NULL;
   p_acct_hist_tbl(l_count).NEW_ATTRIBUTE13 := p_acct_rec.ATTRIBUTE13;
   p_acct_hist_tbl(l_count).OLD_ATTRIBUTE14 := NULL;
   p_acct_hist_tbl(l_count).NEW_ATTRIBUTE14 := p_acct_rec.ATTRIBUTE14;
   p_acct_hist_tbl(l_count).OLD_ATTRIBUTE15 := NULL;
   p_acct_hist_tbl(l_count).NEW_ATTRIBUTE15 := p_acct_rec.ATTRIBUTE15;
   p_acct_hist_tbl(l_count).OLD_BILL_TO_ADDRESS := NULL;
   p_acct_hist_tbl(l_count).NEW_BILL_TO_ADDRESS := p_acct_rec.BILL_TO_ADDRESS;
   p_acct_hist_tbl(l_count).OLD_SHIP_TO_ADDRESS := NULL;
   p_acct_hist_tbl(l_count).NEW_SHIP_TO_ADDRESS := p_acct_rec.SHIP_TO_ADDRESS;
END Build_Account_History;
--
PROCEDURE Build_Org_History
  (
    p_org_hist_tbl  IN OUT NOCOPY  csi_datastructures_pub.org_units_history_tbl
   ,p_org_rec       IN     csi_datastructures_pub.organization_units_rec
   ,p_txn_id        IN     NUMBER
  ) IS
  --
  l_count NUMBER;
  l_hist_id NUMBER;
BEGIN
   l_count := p_org_hist_tbl.count + 1;
   select CSI_I_ORG_ASSIGNMENTS_H_S.nextval
   into l_hist_id
   from sys.dual;

   p_org_hist_tbl(l_count).instance_ou_history_id      := l_hist_id;
   p_org_hist_tbl(l_count).instance_ou_id              := p_org_rec.instance_ou_id;
   p_org_hist_tbl(l_count).transaction_id              := p_txn_id;
   p_org_hist_tbl(l_count).old_operating_unit_id       := NULL;
   p_org_hist_tbl(l_count).new_operating_unit_id       := p_org_rec.operating_unit_id;
   p_org_hist_tbl(l_count).old_relationship_type_code  := NULL;
   p_org_hist_tbl(l_count).new_relationship_type_code  := p_org_rec.relationship_type_code;
   p_org_hist_tbl(l_count).old_active_start_date       := NULL;
   p_org_hist_tbl(l_count).new_active_start_date       := p_org_rec.active_start_date;
   p_org_hist_tbl(l_count).old_active_end_date         := NULL;
   p_org_hist_tbl(l_count).new_active_end_date         := p_org_rec.active_end_date;
   p_org_hist_tbl(l_count).old_context                 := NULL;
   p_org_hist_tbl(l_count).new_context                 := p_org_rec.context;
   p_org_hist_tbl(l_count).old_attribute1              := NULL;
   p_org_hist_tbl(l_count).new_attribute1              := p_org_rec.attribute1;
   p_org_hist_tbl(l_count).old_attribute2              := NULL;
   p_org_hist_tbl(l_count).new_attribute2              := p_org_rec.attribute2;
   p_org_hist_tbl(l_count).old_attribute3              := NULL;
   p_org_hist_tbl(l_count).new_attribute3              := p_org_rec.attribute3;
   p_org_hist_tbl(l_count).old_attribute4              := NULL;
   p_org_hist_tbl(l_count).new_attribute4              := p_org_rec.attribute4;
   p_org_hist_tbl(l_count).old_attribute5              := NULL;
   p_org_hist_tbl(l_count).new_attribute5              := p_org_rec.attribute5;
   p_org_hist_tbl(l_count).old_attribute6              := NULL;
   p_org_hist_tbl(l_count).new_attribute6              := p_org_rec.attribute6;
   p_org_hist_tbl(l_count).old_attribute7              := NULL;
   p_org_hist_tbl(l_count).new_attribute7              := p_org_rec.attribute7;
   p_org_hist_tbl(l_count).old_attribute8              := NULL;
   p_org_hist_tbl(l_count).new_attribute8              := p_org_rec.attribute8;
   p_org_hist_tbl(l_count).old_attribute9              := NULL;
   p_org_hist_tbl(l_count).new_attribute9              := p_org_rec.attribute9;
   p_org_hist_tbl(l_count).old_attribute10             := NULL;
   p_org_hist_tbl(l_count).new_attribute10             := p_org_rec.attribute10;
   p_org_hist_tbl(l_count).old_attribute11             := NULL;
   p_org_hist_tbl(l_count).new_attribute11             := p_org_rec.attribute11;
   p_org_hist_tbl(l_count).old_attribute12             := NULL;
   p_org_hist_tbl(l_count).new_attribute12             := p_org_rec.attribute12;
   p_org_hist_tbl(l_count).old_attribute13             := NULL;
   p_org_hist_tbl(l_count).new_attribute13             := p_org_rec.attribute13;
   p_org_hist_tbl(l_count).old_attribute14             := NULL;
   p_org_hist_tbl(l_count).new_attribute14             := p_org_rec.attribute14;
   p_org_hist_tbl(l_count).old_attribute15             := NULL;
   p_org_hist_tbl(l_count).new_attribute15             := p_org_rec.attribute15;
END Build_Org_History;
--
PROCEDURE Build_Pricing_History
  (
    p_pricing_hist_tbl  IN OUT NOCOPY  csi_datastructures_pub.pricing_history_tbl
   ,p_pricing_rec       IN     csi_datastructures_pub.pricing_attribs_rec
   ,p_txn_id            IN     NUMBER
  ) IS
  --
  l_count NUMBER;
  l_hist_id NUMBER;
BEGIN
   l_count := p_pricing_hist_tbl.count + 1;
   select CSI_I_PRICING_ATTRIBS_H_S.nextval
   into l_hist_id
   from sys.dual;

   p_pricing_hist_tbl(l_count).PRICE_ATTRIB_HISTORY_ID         := l_hist_id;
   p_pricing_hist_tbl(l_count).PRICING_ATTRIBUTE_ID            := p_pricing_rec.pricing_attribute_id;
   p_pricing_hist_tbl(l_count).TRANSACTION_ID                  := p_txn_id;
   p_pricing_hist_tbl(l_count).OLD_PRICING_CONTEXT             := NULL;
   p_pricing_hist_tbl(l_count).NEW_PRICING_CONTEXT             := p_pricing_rec.pricing_context;
   p_pricing_hist_tbl(l_count).OLD_PRICING_ATTRIBUTE1          := NULL;
   p_pricing_hist_tbl(l_count).NEW_PRICING_ATTRIBUTE1          := p_pricing_rec.pricing_attribute1;
   p_pricing_hist_tbl(l_count).OLD_PRICING_ATTRIBUTE2          := NULL;
   p_pricing_hist_tbl(l_count).NEW_PRICING_ATTRIBUTE2          := p_pricing_rec.pricing_attribute2;
   p_pricing_hist_tbl(l_count).OLD_PRICING_ATTRIBUTE3          := NULL;
   p_pricing_hist_tbl(l_count).NEW_PRICING_ATTRIBUTE3          := p_pricing_rec.pricing_attribute3;
   p_pricing_hist_tbl(l_count).OLD_PRICING_ATTRIBUTE4          := NULL;
   p_pricing_hist_tbl(l_count).NEW_PRICING_ATTRIBUTE4          := p_pricing_rec.pricing_attribute4;
   p_pricing_hist_tbl(l_count).OLD_PRICING_ATTRIBUTE5          := NULL;
   p_pricing_hist_tbl(l_count).NEW_PRICING_ATTRIBUTE5          := p_pricing_rec.pricing_attribute5;
   p_pricing_hist_tbl(l_count).OLD_PRICING_ATTRIBUTE6          := NULL;
   p_pricing_hist_tbl(l_count).NEW_PRICING_ATTRIBUTE6          := p_pricing_rec.pricing_attribute6;
   p_pricing_hist_tbl(l_count).OLD_PRICING_ATTRIBUTE7          := NULL;
   p_pricing_hist_tbl(l_count).NEW_PRICING_ATTRIBUTE7          := p_pricing_rec.pricing_attribute7;
   p_pricing_hist_tbl(l_count).OLD_PRICING_ATTRIBUTE8          := NULL;
   p_pricing_hist_tbl(l_count).NEW_PRICING_ATTRIBUTE8          := p_pricing_rec.pricing_attribute8;
   p_pricing_hist_tbl(l_count).OLD_PRICING_ATTRIBUTE9          := NULL;
   p_pricing_hist_tbl(l_count).NEW_PRICING_ATTRIBUTE9          := p_pricing_rec.pricing_attribute9;
   p_pricing_hist_tbl(l_count).OLD_PRICING_ATTRIBUTE10         := NULL;
   p_pricing_hist_tbl(l_count).NEW_PRICING_ATTRIBUTE10         := p_pricing_rec.pricing_attribute10;
   p_pricing_hist_tbl(l_count).OLD_PRICING_ATTRIBUTE11         := NULL;
   p_pricing_hist_tbl(l_count).NEW_PRICING_ATTRIBUTE11         := p_pricing_rec.pricing_attribute11;
   p_pricing_hist_tbl(l_count).OLD_PRICING_ATTRIBUTE12         := NULL;
   p_pricing_hist_tbl(l_count).NEW_PRICING_ATTRIBUTE12         := p_pricing_rec.pricing_attribute12;
   p_pricing_hist_tbl(l_count).OLD_PRICING_ATTRIBUTE13         := NULL;
   p_pricing_hist_tbl(l_count).NEW_PRICING_ATTRIBUTE13         := p_pricing_rec.pricing_attribute13;
   p_pricing_hist_tbl(l_count).OLD_PRICING_ATTRIBUTE14         := NULL;
   p_pricing_hist_tbl(l_count).NEW_PRICING_ATTRIBUTE14         := p_pricing_rec.pricing_attribute14;
   p_pricing_hist_tbl(l_count).OLD_PRICING_ATTRIBUTE15         := NULL;
   p_pricing_hist_tbl(l_count).NEW_PRICING_ATTRIBUTE15         := p_pricing_rec.pricing_attribute15;
   p_pricing_hist_tbl(l_count).OLD_PRICING_ATTRIBUTE16         := NULL;
   p_pricing_hist_tbl(l_count).NEW_PRICING_ATTRIBUTE16         := p_pricing_rec.pricing_attribute16;
   p_pricing_hist_tbl(l_count).OLD_PRICING_ATTRIBUTE17         := NULL;
   p_pricing_hist_tbl(l_count).NEW_PRICING_ATTRIBUTE17         := p_pricing_rec.pricing_attribute17;
   p_pricing_hist_tbl(l_count).OLD_PRICING_ATTRIBUTE18         := NULL;
   p_pricing_hist_tbl(l_count).NEW_PRICING_ATTRIBUTE18         := p_pricing_rec.pricing_attribute18;
   p_pricing_hist_tbl(l_count).OLD_PRICING_ATTRIBUTE19         := NULL;
   p_pricing_hist_tbl(l_count).NEW_PRICING_ATTRIBUTE19         := p_pricing_rec.pricing_attribute19;
   p_pricing_hist_tbl(l_count).OLD_PRICING_ATTRIBUTE20         := NULL;
   p_pricing_hist_tbl(l_count).NEW_PRICING_ATTRIBUTE20         := p_pricing_rec.pricing_attribute20;
   p_pricing_hist_tbl(l_count).OLD_PRICING_ATTRIBUTE21         := NULL;
   p_pricing_hist_tbl(l_count).NEW_PRICING_ATTRIBUTE21         := p_pricing_rec.pricing_attribute21;
   p_pricing_hist_tbl(l_count).OLD_PRICING_ATTRIBUTE22         := NULL;
   p_pricing_hist_tbl(l_count).NEW_PRICING_ATTRIBUTE22         := p_pricing_rec.pricing_attribute22;
   p_pricing_hist_tbl(l_count).OLD_PRICING_ATTRIBUTE23         := NULL;
   p_pricing_hist_tbl(l_count).NEW_PRICING_ATTRIBUTE23         := p_pricing_rec.pricing_attribute23;
   p_pricing_hist_tbl(l_count).OLD_PRICING_ATTRIBUTE24         := NULL;
   p_pricing_hist_tbl(l_count).NEW_PRICING_ATTRIBUTE24         := p_pricing_rec.pricing_attribute24;
   p_pricing_hist_tbl(l_count).NEW_PRICING_ATTRIBUTE25         := NULL;
   p_pricing_hist_tbl(l_count).OLD_PRICING_ATTRIBUTE25         := p_pricing_rec.pricing_attribute25;
   p_pricing_hist_tbl(l_count).OLD_PRICING_ATTRIBUTE26         := NULL;
   p_pricing_hist_tbl(l_count).NEW_PRICING_ATTRIBUTE26         := p_pricing_rec.pricing_attribute26;
   p_pricing_hist_tbl(l_count).OLD_PRICING_ATTRIBUTE27         := NULL;
   p_pricing_hist_tbl(l_count).NEW_PRICING_ATTRIBUTE27         := p_pricing_rec.pricing_attribute27;
   p_pricing_hist_tbl(l_count).OLD_PRICING_ATTRIBUTE28         := NULL;
   p_pricing_hist_tbl(l_count).NEW_PRICING_ATTRIBUTE28         := p_pricing_rec.pricing_attribute28;
   p_pricing_hist_tbl(l_count).OLD_PRICING_ATTRIBUTE29         := NULL;
   p_pricing_hist_tbl(l_count).NEW_PRICING_ATTRIBUTE29         := p_pricing_rec.pricing_attribute29;
   p_pricing_hist_tbl(l_count).OLD_PRICING_ATTRIBUTE30         := NULL;
   p_pricing_hist_tbl(l_count).NEW_PRICING_ATTRIBUTE30         := p_pricing_rec.pricing_attribute30;
   p_pricing_hist_tbl(l_count).OLD_PRICING_ATTRIBUTE31         := NULL;
   p_pricing_hist_tbl(l_count).NEW_PRICING_ATTRIBUTE31         := p_pricing_rec.pricing_attribute31;
   p_pricing_hist_tbl(l_count).OLD_PRICING_ATTRIBUTE32         := NULL;
   p_pricing_hist_tbl(l_count).NEW_PRICING_ATTRIBUTE32         := p_pricing_rec.pricing_attribute32;
   p_pricing_hist_tbl(l_count).OLD_PRICING_ATTRIBUTE33         := NULL;
   p_pricing_hist_tbl(l_count).NEW_PRICING_ATTRIBUTE33         := p_pricing_rec.pricing_attribute33;
   p_pricing_hist_tbl(l_count).OLD_PRICING_ATTRIBUTE34         := NULL;
   p_pricing_hist_tbl(l_count).NEW_PRICING_ATTRIBUTE34         := p_pricing_rec.pricing_attribute34;
   p_pricing_hist_tbl(l_count).OLD_PRICING_ATTRIBUTE35         := NULL;
   p_pricing_hist_tbl(l_count).NEW_PRICING_ATTRIBUTE35         := p_pricing_rec.pricing_attribute35;
   p_pricing_hist_tbl(l_count).OLD_PRICING_ATTRIBUTE36         := NULL;
   p_pricing_hist_tbl(l_count).NEW_PRICING_ATTRIBUTE36         := p_pricing_rec.pricing_attribute36;
   p_pricing_hist_tbl(l_count).OLD_PRICING_ATTRIBUTE37         := NULL;
   p_pricing_hist_tbl(l_count).NEW_PRICING_ATTRIBUTE37         := p_pricing_rec.pricing_attribute37;
   p_pricing_hist_tbl(l_count).OLD_PRICING_ATTRIBUTE38         := NULL;
   p_pricing_hist_tbl(l_count).NEW_PRICING_ATTRIBUTE38         := p_pricing_rec.pricing_attribute38;
   p_pricing_hist_tbl(l_count).OLD_PRICING_ATTRIBUTE39         := NULL;
   p_pricing_hist_tbl(l_count).NEW_PRICING_ATTRIBUTE39         := p_pricing_rec.pricing_attribute39;
   p_pricing_hist_tbl(l_count).OLD_PRICING_ATTRIBUTE40         := NULL;
   p_pricing_hist_tbl(l_count).NEW_PRICING_ATTRIBUTE40         := p_pricing_rec.pricing_attribute40;
   p_pricing_hist_tbl(l_count).OLD_PRICING_ATTRIBUTE41         := NULL;
   p_pricing_hist_tbl(l_count).NEW_PRICING_ATTRIBUTE41         := p_pricing_rec.pricing_attribute41;
   p_pricing_hist_tbl(l_count).OLD_PRICING_ATTRIBUTE42         := NULL;
   p_pricing_hist_tbl(l_count).NEW_PRICING_ATTRIBUTE42         := p_pricing_rec.pricing_attribute42;
   p_pricing_hist_tbl(l_count).OLD_PRICING_ATTRIBUTE43         := NULL;
   p_pricing_hist_tbl(l_count).NEW_PRICING_ATTRIBUTE43         := p_pricing_rec.pricing_attribute43;
   p_pricing_hist_tbl(l_count).OLD_PRICING_ATTRIBUTE44         := NULL;
   p_pricing_hist_tbl(l_count).NEW_PRICING_ATTRIBUTE44         := p_pricing_rec.pricing_attribute44;
   p_pricing_hist_tbl(l_count).OLD_PRICING_ATTRIBUTE45         := NULL;
   p_pricing_hist_tbl(l_count).NEW_PRICING_ATTRIBUTE45         := p_pricing_rec.pricing_attribute45;
   p_pricing_hist_tbl(l_count).OLD_PRICING_ATTRIBUTE46         := NULL;
   p_pricing_hist_tbl(l_count).NEW_PRICING_ATTRIBUTE46         := p_pricing_rec.pricing_attribute46;
   p_pricing_hist_tbl(l_count).OLD_PRICING_ATTRIBUTE47         := NULL;
   p_pricing_hist_tbl(l_count).NEW_PRICING_ATTRIBUTE47         := p_pricing_rec.pricing_attribute47;
   p_pricing_hist_tbl(l_count).OLD_PRICING_ATTRIBUTE48         := NULL;
   p_pricing_hist_tbl(l_count).NEW_PRICING_ATTRIBUTE48         := p_pricing_rec.pricing_attribute48;
   p_pricing_hist_tbl(l_count).OLD_PRICING_ATTRIBUTE49         := NULL;
   p_pricing_hist_tbl(l_count).NEW_PRICING_ATTRIBUTE49         := p_pricing_rec.pricing_attribute49;
   p_pricing_hist_tbl(l_count).OLD_PRICING_ATTRIBUTE50         := NULL;
   p_pricing_hist_tbl(l_count).NEW_PRICING_ATTRIBUTE50         := p_pricing_rec.pricing_attribute50;
   p_pricing_hist_tbl(l_count).OLD_PRICING_ATTRIBUTE51         := NULL;
   p_pricing_hist_tbl(l_count).NEW_PRICING_ATTRIBUTE51         := p_pricing_rec.pricing_attribute51;
   p_pricing_hist_tbl(l_count).OLD_PRICING_ATTRIBUTE52         := NULL;
   p_pricing_hist_tbl(l_count).NEW_PRICING_ATTRIBUTE52         := p_pricing_rec.pricing_attribute52;
   p_pricing_hist_tbl(l_count).OLD_PRICING_ATTRIBUTE53         := NULL;
   p_pricing_hist_tbl(l_count).NEW_PRICING_ATTRIBUTE53         := p_pricing_rec.pricing_attribute53;
   p_pricing_hist_tbl(l_count).OLD_PRICING_ATTRIBUTE54         := NULL;
   p_pricing_hist_tbl(l_count).NEW_PRICING_ATTRIBUTE54         := p_pricing_rec.pricing_attribute54;
   p_pricing_hist_tbl(l_count).OLD_PRICING_ATTRIBUTE55         := NULL;
   p_pricing_hist_tbl(l_count).NEW_PRICING_ATTRIBUTE55         := p_pricing_rec.pricing_attribute55;
   p_pricing_hist_tbl(l_count).OLD_PRICING_ATTRIBUTE56         := NULL;
   p_pricing_hist_tbl(l_count).NEW_PRICING_ATTRIBUTE56         := p_pricing_rec.pricing_attribute56;
   p_pricing_hist_tbl(l_count).OLD_PRICING_ATTRIBUTE57         := NULL;
   p_pricing_hist_tbl(l_count).NEW_PRICING_ATTRIBUTE57         := p_pricing_rec.pricing_attribute57;
   p_pricing_hist_tbl(l_count).OLD_PRICING_ATTRIBUTE58         := NULL;
   p_pricing_hist_tbl(l_count).NEW_PRICING_ATTRIBUTE58         := p_pricing_rec.pricing_attribute58;
   p_pricing_hist_tbl(l_count).OLD_PRICING_ATTRIBUTE59         := NULL;
   p_pricing_hist_tbl(l_count).NEW_PRICING_ATTRIBUTE59         := p_pricing_rec.pricing_attribute59;
   p_pricing_hist_tbl(l_count).OLD_PRICING_ATTRIBUTE60         := NULL;
   p_pricing_hist_tbl(l_count).NEW_PRICING_ATTRIBUTE60         := p_pricing_rec.pricing_attribute60;
   p_pricing_hist_tbl(l_count).OLD_PRICING_ATTRIBUTE61         := NULL;
   p_pricing_hist_tbl(l_count).NEW_PRICING_ATTRIBUTE61         := p_pricing_rec.pricing_attribute61;
   p_pricing_hist_tbl(l_count).OLD_PRICING_ATTRIBUTE62         := NULL;
   p_pricing_hist_tbl(l_count).NEW_PRICING_ATTRIBUTE62         := p_pricing_rec.pricing_attribute62;
   p_pricing_hist_tbl(l_count).OLD_PRICING_ATTRIBUTE63         := NULL;
   p_pricing_hist_tbl(l_count).NEW_PRICING_ATTRIBUTE63         := p_pricing_rec.pricing_attribute63;
   p_pricing_hist_tbl(l_count).OLD_PRICING_ATTRIBUTE64         := NULL;
   p_pricing_hist_tbl(l_count).NEW_PRICING_ATTRIBUTE64         := p_pricing_rec.pricing_attribute64;
   p_pricing_hist_tbl(l_count).OLD_PRICING_ATTRIBUTE65         := NULL;
   p_pricing_hist_tbl(l_count).NEW_PRICING_ATTRIBUTE65         := p_pricing_rec.pricing_attribute65;
   p_pricing_hist_tbl(l_count).OLD_PRICING_ATTRIBUTE66         := NULL;
   p_pricing_hist_tbl(l_count).NEW_PRICING_ATTRIBUTE66         := p_pricing_rec.pricing_attribute66;
   p_pricing_hist_tbl(l_count).OLD_PRICING_ATTRIBUTE67         := NULL;
   p_pricing_hist_tbl(l_count).NEW_PRICING_ATTRIBUTE67         := p_pricing_rec.pricing_attribute67;
   p_pricing_hist_tbl(l_count).OLD_PRICING_ATTRIBUTE68         := NULL;
   p_pricing_hist_tbl(l_count).NEW_PRICING_ATTRIBUTE68         := p_pricing_rec.pricing_attribute68;
   p_pricing_hist_tbl(l_count).OLD_PRICING_ATTRIBUTE69         := NULL;
   p_pricing_hist_tbl(l_count).NEW_PRICING_ATTRIBUTE69         := p_pricing_rec.pricing_attribute69;
   p_pricing_hist_tbl(l_count).OLD_PRICING_ATTRIBUTE70         := NULL;
   p_pricing_hist_tbl(l_count).NEW_PRICING_ATTRIBUTE70         := p_pricing_rec.pricing_attribute70;
   p_pricing_hist_tbl(l_count).OLD_PRICING_ATTRIBUTE71         := NULL;
   p_pricing_hist_tbl(l_count).NEW_PRICING_ATTRIBUTE71         := p_pricing_rec.pricing_attribute71;
   p_pricing_hist_tbl(l_count).OLD_PRICING_ATTRIBUTE72         := NULL;
   p_pricing_hist_tbl(l_count).NEW_PRICING_ATTRIBUTE72         := p_pricing_rec.pricing_attribute72;
   p_pricing_hist_tbl(l_count).OLD_PRICING_ATTRIBUTE73         := NULL;
   p_pricing_hist_tbl(l_count).NEW_PRICING_ATTRIBUTE73         := p_pricing_rec.pricing_attribute73;
   p_pricing_hist_tbl(l_count).OLD_PRICING_ATTRIBUTE74         := NULL;
   p_pricing_hist_tbl(l_count).NEW_PRICING_ATTRIBUTE74         := p_pricing_rec.pricing_attribute74;
   p_pricing_hist_tbl(l_count).OLD_PRICING_ATTRIBUTE75         := NULL;
   p_pricing_hist_tbl(l_count).NEW_PRICING_ATTRIBUTE75         := p_pricing_rec.pricing_attribute75;
   p_pricing_hist_tbl(l_count).OLD_PRICING_ATTRIBUTE76         := NULL;
   p_pricing_hist_tbl(l_count).NEW_PRICING_ATTRIBUTE76         := p_pricing_rec.pricing_attribute76;
   p_pricing_hist_tbl(l_count).OLD_PRICING_ATTRIBUTE77         := NULL;
   p_pricing_hist_tbl(l_count).NEW_PRICING_ATTRIBUTE77         := p_pricing_rec.pricing_attribute77;
   p_pricing_hist_tbl(l_count).OLD_PRICING_ATTRIBUTE78         := NULL;
   p_pricing_hist_tbl(l_count).NEW_PRICING_ATTRIBUTE78         := p_pricing_rec.pricing_attribute78;
   p_pricing_hist_tbl(l_count).OLD_PRICING_ATTRIBUTE79         := NULL;
   p_pricing_hist_tbl(l_count).NEW_PRICING_ATTRIBUTE79         := p_pricing_rec.pricing_attribute79;
   p_pricing_hist_tbl(l_count).OLD_PRICING_ATTRIBUTE80         := NULL;
   p_pricing_hist_tbl(l_count).NEW_PRICING_ATTRIBUTE80         := p_pricing_rec.pricing_attribute80;
   p_pricing_hist_tbl(l_count).OLD_PRICING_ATTRIBUTE81         := NULL;
   p_pricing_hist_tbl(l_count).NEW_PRICING_ATTRIBUTE81         := p_pricing_rec.pricing_attribute81;
   p_pricing_hist_tbl(l_count).OLD_PRICING_ATTRIBUTE82         := NULL;
   p_pricing_hist_tbl(l_count).NEW_PRICING_ATTRIBUTE82         := p_pricing_rec.pricing_attribute82;
   p_pricing_hist_tbl(l_count).OLD_PRICING_ATTRIBUTE83         := NULL;
   p_pricing_hist_tbl(l_count).NEW_PRICING_ATTRIBUTE83         := p_pricing_rec.pricing_attribute83;
   p_pricing_hist_tbl(l_count).OLD_PRICING_ATTRIBUTE84         := NULL;
   p_pricing_hist_tbl(l_count).NEW_PRICING_ATTRIBUTE84         := p_pricing_rec.pricing_attribute84;
   p_pricing_hist_tbl(l_count).OLD_PRICING_ATTRIBUTE85         := NULL;
   p_pricing_hist_tbl(l_count).NEW_PRICING_ATTRIBUTE85         := p_pricing_rec.pricing_attribute85;
   p_pricing_hist_tbl(l_count).OLD_PRICING_ATTRIBUTE86         := NULL;
   p_pricing_hist_tbl(l_count).NEW_PRICING_ATTRIBUTE86         := p_pricing_rec.pricing_attribute86;
   p_pricing_hist_tbl(l_count).OLD_PRICING_ATTRIBUTE87         := NULL;
   p_pricing_hist_tbl(l_count).NEW_PRICING_ATTRIBUTE87         := p_pricing_rec.pricing_attribute87;
   p_pricing_hist_tbl(l_count).OLD_PRICING_ATTRIBUTE88         := NULL;
   p_pricing_hist_tbl(l_count).NEW_PRICING_ATTRIBUTE88         := p_pricing_rec.pricing_attribute88;
   p_pricing_hist_tbl(l_count).OLD_PRICING_ATTRIBUTE89         := NULL;
   p_pricing_hist_tbl(l_count).NEW_PRICING_ATTRIBUTE89         := p_pricing_rec.pricing_attribute89;
   p_pricing_hist_tbl(l_count).OLD_PRICING_ATTRIBUTE90         := NULL;
   p_pricing_hist_tbl(l_count).NEW_PRICING_ATTRIBUTE90         := p_pricing_rec.pricing_attribute90;
   p_pricing_hist_tbl(l_count).OLD_PRICING_ATTRIBUTE91         := NULL;
   p_pricing_hist_tbl(l_count).NEW_PRICING_ATTRIBUTE91         := p_pricing_rec.pricing_attribute91;
   p_pricing_hist_tbl(l_count).OLD_PRICING_ATTRIBUTE92         := NULL;
   p_pricing_hist_tbl(l_count).NEW_PRICING_ATTRIBUTE92         := p_pricing_rec.pricing_attribute92;
   p_pricing_hist_tbl(l_count).OLD_PRICING_ATTRIBUTE93         := NULL;
   p_pricing_hist_tbl(l_count).NEW_PRICING_ATTRIBUTE93         := p_pricing_rec.pricing_attribute93;
   p_pricing_hist_tbl(l_count).OLD_PRICING_ATTRIBUTE94         := NULL;
   p_pricing_hist_tbl(l_count).NEW_PRICING_ATTRIBUTE94         := p_pricing_rec.pricing_attribute94;
   p_pricing_hist_tbl(l_count).OLD_PRICING_ATTRIBUTE95         := NULL;
   p_pricing_hist_tbl(l_count).NEW_PRICING_ATTRIBUTE95         := p_pricing_rec.pricing_attribute95;
   p_pricing_hist_tbl(l_count).OLD_PRICING_ATTRIBUTE96         := NULL;
   p_pricing_hist_tbl(l_count).NEW_PRICING_ATTRIBUTE96         := p_pricing_rec.pricing_attribute96;
   p_pricing_hist_tbl(l_count).OLD_PRICING_ATTRIBUTE97         := NULL;
   p_pricing_hist_tbl(l_count).NEW_PRICING_ATTRIBUTE97         := p_pricing_rec.pricing_attribute97;
   p_pricing_hist_tbl(l_count).OLD_PRICING_ATTRIBUTE98         := NULL;
   p_pricing_hist_tbl(l_count).NEW_PRICING_ATTRIBUTE98         := p_pricing_rec.pricing_attribute98;
   p_pricing_hist_tbl(l_count).OLD_PRICING_ATTRIBUTE99         := NULL;
   p_pricing_hist_tbl(l_count).NEW_PRICING_ATTRIBUTE99         := p_pricing_rec.pricing_attribute99;
   p_pricing_hist_tbl(l_count).OLD_PRICING_ATTRIBUTE100        := NULL;
   p_pricing_hist_tbl(l_count).NEW_PRICING_ATTRIBUTE100        := p_pricing_rec.pricing_attribute100;
   p_pricing_hist_tbl(l_count).OLD_ACTIVE_START_DATE           := NULL;
   p_pricing_hist_tbl(l_count).NEW_ACTIVE_START_DATE           :=  p_pricing_rec.active_start_date;
   p_pricing_hist_tbl(l_count).OLD_ACTIVE_END_DATE             := NULL;
   p_pricing_hist_tbl(l_count).NEW_ACTIVE_END_DATE             :=  p_pricing_rec.active_end_date;
   p_pricing_hist_tbl(l_count).OLD_CONTEXT                     := NULL;
   p_pricing_hist_tbl(l_count).NEW_CONTEXT                     := p_pricing_rec.context;
   p_pricing_hist_tbl(l_count).OLD_ATTRIBUTE1                  := NULL;
   p_pricing_hist_tbl(l_count).NEW_ATTRIBUTE1                  := p_pricing_rec.ATTRIBUTE1;
   p_pricing_hist_tbl(l_count).OLD_ATTRIBUTE2                  := NULL;
   p_pricing_hist_tbl(l_count).NEW_ATTRIBUTE2                  := p_pricing_rec.ATTRIBUTE2;
   p_pricing_hist_tbl(l_count).OLD_ATTRIBUTE3                  := NULL;
   p_pricing_hist_tbl(l_count).NEW_ATTRIBUTE3                  := p_pricing_rec.ATTRIBUTE3;
   p_pricing_hist_tbl(l_count).OLD_ATTRIBUTE4                  := NULL;
   p_pricing_hist_tbl(l_count).NEW_ATTRIBUTE4                  := p_pricing_rec.ATTRIBUTE4;
   p_pricing_hist_tbl(l_count).OLD_ATTRIBUTE5                  := NULL;
   p_pricing_hist_tbl(l_count).NEW_ATTRIBUTE5                  := p_pricing_rec.ATTRIBUTE5;
   p_pricing_hist_tbl(l_count).OLD_ATTRIBUTE6                  := NULL;
   p_pricing_hist_tbl(l_count).NEW_ATTRIBUTE6                  := p_pricing_rec.ATTRIBUTE6;
   p_pricing_hist_tbl(l_count).OLD_ATTRIBUTE7                  := NULL;
   p_pricing_hist_tbl(l_count).NEW_ATTRIBUTE7                  := p_pricing_rec.ATTRIBUTE7;
   p_pricing_hist_tbl(l_count).OLD_ATTRIBUTE8                  := NULL;
   p_pricing_hist_tbl(l_count).NEW_ATTRIBUTE8                  := p_pricing_rec.ATTRIBUTE8;
   p_pricing_hist_tbl(l_count).OLD_ATTRIBUTE9                  := NULL;
   p_pricing_hist_tbl(l_count).NEW_ATTRIBUTE9                  := p_pricing_rec.ATTRIBUTE9;
   p_pricing_hist_tbl(l_count).OLD_ATTRIBUTE10                 := NULL;
   p_pricing_hist_tbl(l_count).NEW_ATTRIBUTE10                 := p_pricing_rec.ATTRIBUTE10;
   p_pricing_hist_tbl(l_count).OLD_ATTRIBUTE11                 := NULL;
   p_pricing_hist_tbl(l_count).NEW_ATTRIBUTE11                 := p_pricing_rec.ATTRIBUTE11;
   p_pricing_hist_tbl(l_count).OLD_ATTRIBUTE12                 := NULL;
   p_pricing_hist_tbl(l_count).NEW_ATTRIBUTE12                 := p_pricing_rec.ATTRIBUTE12;
   p_pricing_hist_tbl(l_count).OLD_ATTRIBUTE13                 := NULL;
   p_pricing_hist_tbl(l_count).NEW_ATTRIBUTE13                 := p_pricing_rec.ATTRIBUTE13;
   p_pricing_hist_tbl(l_count).OLD_ATTRIBUTE14                 := NULL;
   p_pricing_hist_tbl(l_count).NEW_ATTRIBUTE14                 := p_pricing_rec.ATTRIBUTE14;
   p_pricing_hist_tbl(l_count).OLD_ATTRIBUTE15                 := NULL;
   p_pricing_hist_tbl(l_count).NEW_ATTRIBUTE15                 := p_pricing_rec.ATTRIBUTE15;
END Build_Pricing_History;
--
PROCEDURE Build_Ext_Attr_History
  (
    p_ext_attr_hist_tbl IN OUT NOCOPY  csi_datastructures_pub.ext_attrib_val_history_tbl
   ,p_ext_attr_rec      IN     csi_datastructures_pub.extend_attrib_values_rec
   ,p_txn_id            IN     NUMBER
  ) IS
  --
  l_count NUMBER;
  l_hist_id NUMBER;
BEGIN
   l_count := p_ext_attr_hist_tbl.count + 1;
   select CSI_IEA_VALUES_H_S.nextval
   into l_hist_id
   from sys.dual;

   p_ext_attr_hist_tbl(l_count).attribute_value_history_id := l_hist_id;
   p_ext_attr_hist_tbl(l_count).attribute_value_id := p_ext_attr_rec.attribute_value_id;
   p_ext_attr_hist_tbl(l_count).transaction_id := p_txn_id;
   p_ext_attr_hist_tbl(l_count).old_attribute_value   := NULL;
   p_ext_attr_hist_tbl(l_count).new_attribute_value   := p_ext_attr_rec.attribute_value;
   p_ext_attr_hist_tbl(l_count).old_active_start_date := NULL;
   p_ext_attr_hist_tbl(l_count).new_active_start_date := p_ext_attr_rec.active_start_date;
   p_ext_attr_hist_tbl(l_count).old_active_end_date   := NULL;
   p_ext_attr_hist_tbl(l_count).new_active_end_date := p_ext_attr_rec.active_end_date;
   p_ext_attr_hist_tbl(l_count).old_context           := NULL;
   p_ext_attr_hist_tbl(l_count).new_context           := p_ext_attr_rec.context;
   p_ext_attr_hist_tbl(l_count).old_attribute1        := NULL;
   p_ext_attr_hist_tbl(l_count).new_attribute1        := p_ext_attr_rec.attribute1;
   p_ext_attr_hist_tbl(l_count).old_attribute2        := NULL;
   p_ext_attr_hist_tbl(l_count).new_attribute2        := p_ext_attr_rec.attribute2;
   p_ext_attr_hist_tbl(l_count).old_attribute3        := NULL;
   p_ext_attr_hist_tbl(l_count).new_attribute3        := p_ext_attr_rec.attribute3;
   p_ext_attr_hist_tbl(l_count).old_attribute4        := NULL;
   p_ext_attr_hist_tbl(l_count).new_attribute4        := p_ext_attr_rec.attribute4;
   p_ext_attr_hist_tbl(l_count).old_attribute5        := NULL;
   p_ext_attr_hist_tbl(l_count).new_attribute5        := p_ext_attr_rec.attribute5;
   p_ext_attr_hist_tbl(l_count).old_attribute6        := NULL;
   p_ext_attr_hist_tbl(l_count).new_attribute6        := p_ext_attr_rec.attribute6;
   p_ext_attr_hist_tbl(l_count).old_attribute7        := NULL;
   p_ext_attr_hist_tbl(l_count).new_attribute7        := p_ext_attr_rec.attribute7;
   p_ext_attr_hist_tbl(l_count).old_attribute8        := NULL;
   p_ext_attr_hist_tbl(l_count).new_attribute8        := p_ext_attr_rec.attribute8;
   p_ext_attr_hist_tbl(l_count).old_attribute9        := NULL;
   p_ext_attr_hist_tbl(l_count).new_attribute9        := p_ext_attr_rec.attribute9;
   p_ext_attr_hist_tbl(l_count).old_attribute10       := NULL;
   p_ext_attr_hist_tbl(l_count).new_attribute10       := p_ext_attr_rec.attribute10;
   p_ext_attr_hist_tbl(l_count).old_attribute11       := NULL;
   p_ext_attr_hist_tbl(l_count).new_attribute11       := p_ext_attr_rec.attribute11;
   p_ext_attr_hist_tbl(l_count).old_attribute12       := NULL;
   p_ext_attr_hist_tbl(l_count).new_attribute12       := p_ext_attr_rec.attribute12;
   p_ext_attr_hist_tbl(l_count).old_attribute13       := NULL;
   p_ext_attr_hist_tbl(l_count).new_attribute13       := p_ext_attr_rec.attribute13;
   p_ext_attr_hist_tbl(l_count).old_attribute14       := NULL;
   p_ext_attr_hist_tbl(l_count).new_attribute14       := p_ext_attr_rec.attribute14;
   p_ext_attr_hist_tbl(l_count).old_attribute15       := NULL;
   p_ext_attr_hist_tbl(l_count).new_attribute15       := p_ext_attr_rec.attribute15;
   p_ext_attr_hist_tbl(l_count).attribute_code        := p_ext_attr_rec.attribute_code;

END Build_Ext_Attr_History;
--
PROCEDURE Build_Asset_History
  (
    p_asset_hist_tbl IN OUT NOCOPY  csi_datastructures_pub.ins_asset_history_tbl
   ,p_asset_rec      IN     csi_datastructures_pub.instance_asset_rec
   ,p_txn_id         IN     NUMBER
  ) IS
  --
  l_count NUMBER;
  l_hist_id NUMBER;
BEGIN
   l_count := p_asset_hist_tbl.count + 1;
   select CSI_I_ASSETS_H_S.nextval
   into l_hist_id
   from sys.dual;

   p_asset_hist_tbl(l_count).instance_asset_history_id := l_hist_id;
   p_asset_hist_tbl(l_count).transaction_id            := p_txn_id;
   p_asset_hist_tbl(l_count).instance_asset_id         := p_asset_rec.instance_asset_id;
   p_asset_hist_tbl(l_count).old_instance_id           := NULL;
   p_asset_hist_tbl(l_count).new_instance_id           := p_asset_rec.instance_id;
   p_asset_hist_tbl(l_count).old_fa_asset_id           := NULL;
   p_asset_hist_tbl(l_count).new_fa_asset_id           := p_asset_rec.fa_asset_id;
   p_asset_hist_tbl(l_count).old_fa_book_type_code     := NULL;
   p_asset_hist_tbl(l_count).new_fa_book_type_code     := p_asset_rec.fa_book_type_code;
   p_asset_hist_tbl(l_count).old_fa_location_id        := NULL;
   p_asset_hist_tbl(l_count).new_fa_location_id        := p_asset_rec.fa_location_id;
   p_asset_hist_tbl(l_count).old_asset_quantity        := NULL;
   p_asset_hist_tbl(l_count).new_asset_quantity        := p_asset_rec.asset_quantity;
   p_asset_hist_tbl(l_count).old_update_status         := NULL;
   p_asset_hist_tbl(l_count).new_update_status         := p_asset_rec.update_status;
   p_asset_hist_tbl(l_count).old_active_start_date     := NULL;
   p_asset_hist_tbl(l_count).new_active_start_date     := p_asset_rec.active_start_date;
   p_asset_hist_tbl(l_count).old_active_end_date       := NULL;
   p_asset_hist_tbl(l_count).new_active_end_date       := p_asset_rec.active_end_date;

END Build_Asset_History;
--
PROCEDURE Build_Inst_Rec_of_Table
   (
     p_inst_tbl           IN      csi_datastructures_pub.instance_tbl
    ,p_inst_rec_tab       IN OUT NOCOPY   csi_item_instance_grp.instance_rec_tab
   ) IS
BEGIN
   FOR i in p_inst_tbl.FIRST .. p_inst_tbl.LAST LOOP
      p_inst_rec_tab.INSTANCE_ID(i)           :=	p_inst_tbl(i).INSTANCE_ID;
      p_inst_rec_tab.instance_number(i)       :=	p_inst_tbl(i).instance_number;
      p_inst_rec_tab.external_reference(i)       :=	p_inst_tbl(i).external_reference;
      p_inst_rec_tab.inventory_item_id(i)       :=	p_inst_tbl(i).inventory_item_id;
      p_inst_rec_tab.vld_organization_id(i)       :=	p_inst_tbl(i).vld_organization_id;
      p_inst_rec_tab.inventory_revision(i)       :=	p_inst_tbl(i).inventory_revision;
      p_inst_rec_tab.inv_master_organization_id(i)       :=	p_inst_tbl(i).inv_master_organization_id;
      p_inst_rec_tab.serial_number(i)       :=	p_inst_tbl(i).serial_number;
      p_inst_rec_tab.mfg_serial_number_flag(i)       :=	p_inst_tbl(i).mfg_serial_number_flag;
      p_inst_rec_tab.lot_number(i)       :=	p_inst_tbl(i).lot_number;
      p_inst_rec_tab.quantity(i)       :=	p_inst_tbl(i).quantity;
      p_inst_rec_tab.unit_of_measure(i)       :=	p_inst_tbl(i).unit_of_measure;
      p_inst_rec_tab.accounting_class_code(i)       :=	p_inst_tbl(i).accounting_class_code;
      p_inst_rec_tab.instance_condition_id(i)       :=	p_inst_tbl(i).instance_condition_id;
      p_inst_rec_tab.instance_status_id(i)       :=	p_inst_tbl(i).instance_status_id;
      p_inst_rec_tab.customer_view_flag(i)       :=	p_inst_tbl(i).customer_view_flag;
      p_inst_rec_tab.merchant_view_flag(i)       :=	p_inst_tbl(i).merchant_view_flag;
      p_inst_rec_tab.sellable_flag(i)       :=	p_inst_tbl(i).sellable_flag;
      p_inst_rec_tab.system_id(i)       :=	p_inst_tbl(i).system_id;
      p_inst_rec_tab.instance_type_code(i)       :=	p_inst_tbl(i).instance_type_code;
      p_inst_rec_tab.active_start_date(i)       :=	p_inst_tbl(i).active_start_date;
      p_inst_rec_tab.active_end_date(i)       :=	p_inst_tbl(i).active_end_date;
      p_inst_rec_tab.location_type_code(i)       :=	p_inst_tbl(i).location_type_code;
      p_inst_rec_tab.location_id(i)       :=	p_inst_tbl(i).location_id;
      p_inst_rec_tab.inv_organization_id(i)       :=	p_inst_tbl(i).inv_organization_id;
      p_inst_rec_tab.inv_subinventory_name(i)       :=	p_inst_tbl(i).inv_subinventory_name;
      p_inst_rec_tab.inv_locator_id(i)       :=	p_inst_tbl(i).inv_locator_id;
      p_inst_rec_tab.pa_project_id(i)       :=	p_inst_tbl(i).pa_project_id;
      p_inst_rec_tab.pa_project_task_id(i)       :=	p_inst_tbl(i).pa_project_task_id;
      p_inst_rec_tab.in_transit_order_line_id(i)       :=	p_inst_tbl(i).in_transit_order_line_id;
      p_inst_rec_tab.wip_job_id(i)       :=	p_inst_tbl(i).wip_job_id;
      p_inst_rec_tab.po_order_line_id(i)       :=	p_inst_tbl(i).po_order_line_id;
      p_inst_rec_tab.last_oe_order_line_id(i)       :=	p_inst_tbl(i).last_oe_order_line_id;
      p_inst_rec_tab.last_oe_rma_line_id(i)       :=	p_inst_tbl(i).last_oe_rma_line_id;
      p_inst_rec_tab.last_po_po_line_id(i)       :=	p_inst_tbl(i).last_po_po_line_id;
      p_inst_rec_tab.last_oe_po_number(i)       :=	p_inst_tbl(i).last_oe_po_number;
      p_inst_rec_tab.last_wip_job_id(i)       :=	p_inst_tbl(i).last_wip_job_id;
      p_inst_rec_tab.last_pa_project_id(i)       :=	p_inst_tbl(i).last_pa_project_id;
      p_inst_rec_tab.last_pa_task_id(i)       :=	p_inst_tbl(i).last_pa_task_id;
      p_inst_rec_tab.last_oe_agreement_id(i)       :=	p_inst_tbl(i).last_oe_agreement_id;
      p_inst_rec_tab.install_date(i)       :=	p_inst_tbl(i).install_date;
      p_inst_rec_tab.manually_created_flag(i)       :=	p_inst_tbl(i).manually_created_flag;
      p_inst_rec_tab.return_by_date(i)       :=	p_inst_tbl(i).return_by_date;
      p_inst_rec_tab.actual_return_date(i)       :=	p_inst_tbl(i).actual_return_date;
      p_inst_rec_tab.creation_complete_flag(i)       :=	p_inst_tbl(i).creation_complete_flag;
      p_inst_rec_tab.completeness_flag(i)       :=	p_inst_tbl(i).completeness_flag;
      p_inst_rec_tab.version_label(i)       :=	p_inst_tbl(i).version_label;
      p_inst_rec_tab.version_label_description(i)       :=	p_inst_tbl(i).version_label_description;
      p_inst_rec_tab.context(i)       :=	p_inst_tbl(i).context;
      p_inst_rec_tab.attribute1(i)       :=	p_inst_tbl(i).attribute1;
      p_inst_rec_tab.attribute2(i)       :=	p_inst_tbl(i).attribute2;
      p_inst_rec_tab.attribute3(i)       :=	p_inst_tbl(i).attribute3;
      p_inst_rec_tab.attribute4(i)       :=	p_inst_tbl(i).attribute4;
      p_inst_rec_tab.attribute5(i)       :=	p_inst_tbl(i).attribute5;
      p_inst_rec_tab.attribute6(i)       :=	p_inst_tbl(i).attribute6;
      p_inst_rec_tab.attribute7(i)       :=	p_inst_tbl(i).attribute7;
      p_inst_rec_tab.attribute8(i)       :=	p_inst_tbl(i).attribute8;
      p_inst_rec_tab.attribute9(i)       :=	p_inst_tbl(i).attribute9;
      p_inst_rec_tab.attribute10(i)       :=	p_inst_tbl(i).attribute10;
      p_inst_rec_tab.attribute11(i)       :=	p_inst_tbl(i).attribute11;
      p_inst_rec_tab.attribute12(i)       :=	p_inst_tbl(i).attribute12;
      p_inst_rec_tab.attribute13(i)       :=	p_inst_tbl(i).attribute13;
      p_inst_rec_tab.attribute14(i)       :=	p_inst_tbl(i).attribute14;
      p_inst_rec_tab.attribute15(i)       :=	p_inst_tbl(i).attribute15;
      p_inst_rec_tab.object_version_number(i)       :=	p_inst_tbl(i).object_version_number;
      p_inst_rec_tab.last_txn_line_detail_id(i)       :=	p_inst_tbl(i).last_txn_line_detail_id;
      p_inst_rec_tab.install_location_type_code(i)       :=	p_inst_tbl(i).install_location_type_code;
      p_inst_rec_tab.install_location_id(i)       :=	p_inst_tbl(i).install_location_id;
      p_inst_rec_tab.instance_usage_code(i)       :=	p_inst_tbl(i).instance_usage_code;
      p_inst_rec_tab.check_for_instance_expiry(i)       :=	p_inst_tbl(i).check_for_instance_expiry;
      p_inst_rec_tab.call_contracts(i)       :=	p_inst_tbl(i).call_contracts;
      p_inst_rec_tab.grp_call_contracts(i)       :=	p_inst_tbl(i).grp_call_contracts;
      p_inst_rec_tab.config_inst_hdr_id(i)       :=	p_inst_tbl(i).config_inst_hdr_id;
      p_inst_rec_tab.config_inst_rev_num(i)       :=	p_inst_tbl(i).config_inst_rev_num;
      p_inst_rec_tab.config_inst_item_id(i)       :=	p_inst_tbl(i).config_inst_item_id;
      p_inst_rec_tab.config_valid_status(i)       :=	p_inst_tbl(i).config_valid_status;
      p_inst_rec_tab.instance_description(i)       :=	p_inst_tbl(i).instance_description;

      p_inst_rec_tab.network_asset_flag(i)       := p_inst_tbl(i).network_asset_flag;
      p_inst_rec_tab.maintainable_flag(i)        := p_inst_tbl(i).maintainable_flag;
      p_inst_rec_tab.asset_criticality_code(i)   := p_inst_tbl(i).asset_criticality_code;
      p_inst_rec_tab.category_id(i)              := p_inst_tbl(i).category_id ;
      p_inst_rec_tab.equipment_gen_object_id(i)  := p_inst_tbl(i).equipment_gen_object_id ;
      p_inst_rec_tab.instantiation_flag(i)       := p_inst_tbl(i).instantiation_flag;
      p_inst_rec_tab.operational_log_flag(i)     := p_inst_tbl(i).operational_log_flag ;
      p_inst_rec_tab.supplier_warranty_exp_date(i) := p_inst_tbl(i).supplier_warranty_exp_date ;
      p_inst_rec_tab.attribute16(i)               := p_inst_tbl(i).attribute16;
      p_inst_rec_tab.attribute17(i)               := p_inst_tbl(i).attribute17;
      p_inst_rec_tab.attribute18(i)               := p_inst_tbl(i).attribute18;
      p_inst_rec_tab.attribute19(i)               := p_inst_tbl(i).attribute19;
      p_inst_rec_tab.attribute20(i)               := p_inst_tbl(i).attribute20;
      p_inst_rec_tab.attribute21(i)               := p_inst_tbl(i).attribute21;
      p_inst_rec_tab.attribute22(i)               := p_inst_tbl(i).attribute22;
      p_inst_rec_tab.attribute23(i)               := p_inst_tbl(i).attribute23;
      p_inst_rec_tab.attribute24(i)               := p_inst_tbl(i).attribute24;
      p_inst_rec_tab.attribute25(i)               := p_inst_tbl(i).attribute25;
      p_inst_rec_tab.attribute26(i)               := p_inst_tbl(i).attribute26;
      p_inst_rec_tab.attribute27(i)               := p_inst_tbl(i).attribute27;
      p_inst_rec_tab.attribute28(i)               := p_inst_tbl(i).attribute28;
      p_inst_rec_tab.attribute29(i)               := p_inst_tbl(i).attribute29;
      p_inst_rec_tab.attribute30(i)               := p_inst_tbl(i).attribute30;

      p_inst_rec_tab.purchase_unit_price(i)       := p_inst_tbl(i).purchase_unit_price;
      p_inst_rec_tab.purchase_currency_code(i)    := p_inst_tbl(i).purchase_currency_code;
      p_inst_rec_tab.payables_unit_price(i)       := p_inst_tbl(i).payables_unit_price;
      p_inst_rec_tab.payables_currency_code(i)    := p_inst_tbl(i).payables_currency_code;
      p_inst_rec_tab.sales_unit_price(i)          := p_inst_tbl(i).sales_unit_price;
      p_inst_rec_tab.sales_currency_code(i)       := p_inst_tbl(i).sales_currency_code;
      p_inst_rec_tab.operational_status_code(i)   := p_inst_tbl(i).operational_status_code;

   END LOOP;
END Build_Inst_Rec_of_Table;
--
PROCEDURE Build_Inst_Hist_Rec_of_Table
  ( p_inst_hist_tbl       IN     csi_datastructures_pub.instance_history_tbl
   ,p_inst_hist_rec_tab   IN OUT NOCOPY  csi_item_instance_grp.instance_history_rec_tab
  ) IS
BEGIN
   FOR i in p_inst_hist_tbl.FIRST .. p_inst_hist_tbl.LAST LOOP
      p_inst_hist_rec_tab.instance_id(i)	   :=  p_inst_hist_tbl(i).instance_id;
      p_inst_hist_rec_tab.old_instance_number(i)	   :=  p_inst_hist_tbl(i).old_instance_number;
      p_inst_hist_rec_tab.new_instance_number(i)	   :=  p_inst_hist_tbl(i).new_instance_number;
      p_inst_hist_rec_tab.old_external_reference(i)	   :=  p_inst_hist_tbl(i).old_external_reference;
      p_inst_hist_rec_tab.new_external_reference(i)	   :=  p_inst_hist_tbl(i).new_external_reference;
      p_inst_hist_rec_tab.old_inventory_item_id(i)	   :=  p_inst_hist_tbl(i).old_inventory_item_id;
      p_inst_hist_rec_tab.new_inventory_item_id(i)	   :=  p_inst_hist_tbl(i).new_inventory_item_id;
      p_inst_hist_rec_tab.old_inventory_revision(i)	   :=  p_inst_hist_tbl(i).old_inventory_revision;
      p_inst_hist_rec_tab.new_inventory_revision(i)	   :=  p_inst_hist_tbl(i).new_inventory_revision;
      p_inst_hist_rec_tab.old_inv_master_org_id(i)	   :=  p_inst_hist_tbl(i).old_inv_master_org_id;
      p_inst_hist_rec_tab.new_inv_master_org_id(i)	   :=  p_inst_hist_tbl(i).new_inv_master_org_id;
      p_inst_hist_rec_tab.old_serial_number(i)	   :=  p_inst_hist_tbl(i).old_serial_number;
      p_inst_hist_rec_tab.new_serial_number(i)	   :=  p_inst_hist_tbl(i).new_serial_number;
      p_inst_hist_rec_tab.old_mfg_serial_number_flag(i)   :=  p_inst_hist_tbl(i).old_mfg_serial_number_flag;
      p_inst_hist_rec_tab.new_mfg_serial_number_flag(i)   :=  p_inst_hist_tbl(i).new_mfg_serial_number_flag;
      p_inst_hist_rec_tab.old_lot_number(i)	   :=  p_inst_hist_tbl(i).old_lot_number;
      p_inst_hist_rec_tab.new_lot_number(i)	   :=  p_inst_hist_tbl(i).new_lot_number;
      p_inst_hist_rec_tab.old_quantity(i)	   :=  p_inst_hist_tbl(i).old_quantity;
      p_inst_hist_rec_tab.new_quantity(i)	   :=  p_inst_hist_tbl(i).new_quantity;
      p_inst_hist_rec_tab.old_unit_of_measure_name(i)	   :=  p_inst_hist_tbl(i).old_unit_of_measure_name;
      p_inst_hist_rec_tab.new_unit_of_measure_name(i)	   :=  p_inst_hist_tbl(i).new_unit_of_measure_name;
      p_inst_hist_rec_tab.old_unit_of_measure(i)	   :=  p_inst_hist_tbl(i).old_unit_of_measure;
      p_inst_hist_rec_tab.new_unit_of_measure(i)	   :=  p_inst_hist_tbl(i).new_unit_of_measure;
      p_inst_hist_rec_tab.old_accounting_class(i)	   :=  p_inst_hist_tbl(i).old_accounting_class;
      p_inst_hist_rec_tab.new_accounting_class(i)	   :=  p_inst_hist_tbl(i).new_accounting_class;
      p_inst_hist_rec_tab.old_accounting_class_code(i)   :=  p_inst_hist_tbl(i).old_accounting_class_code;
      p_inst_hist_rec_tab.new_accounting_class_code(i)   :=  p_inst_hist_tbl(i).new_accounting_class_code;
      p_inst_hist_rec_tab.old_instance_condition(i)	   :=  p_inst_hist_tbl(i).old_instance_condition;
      p_inst_hist_rec_tab.new_instance_condition(i)	   :=  p_inst_hist_tbl(i).new_instance_condition;
      p_inst_hist_rec_tab.old_instance_condition_id(i)   :=  p_inst_hist_tbl(i).old_instance_condition_id;
      p_inst_hist_rec_tab.new_instance_condition_id(i)   :=  p_inst_hist_tbl(i).new_instance_condition_id;
      p_inst_hist_rec_tab.old_instance_status(i)	   :=  p_inst_hist_tbl(i).old_instance_status;
      p_inst_hist_rec_tab.new_instance_status(i)	   :=  p_inst_hist_tbl(i).new_instance_status;
      p_inst_hist_rec_tab.old_instance_status_id(i)	   :=  p_inst_hist_tbl(i).old_instance_status_id;
      p_inst_hist_rec_tab.new_instance_status_id(i)	   :=  p_inst_hist_tbl(i).new_instance_status_id;
      p_inst_hist_rec_tab.old_customer_view_flag(i)	   :=  p_inst_hist_tbl(i).old_customer_view_flag;
      p_inst_hist_rec_tab.new_customer_view_flag(i)	   :=  p_inst_hist_tbl(i).new_customer_view_flag;
      p_inst_hist_rec_tab.old_merchant_view_flag(i)	   :=  p_inst_hist_tbl(i).old_merchant_view_flag;
      p_inst_hist_rec_tab.new_merchant_view_flag(i)	   :=  p_inst_hist_tbl(i).new_merchant_view_flag;
      p_inst_hist_rec_tab.old_sellable_flag(i)	   :=  p_inst_hist_tbl(i).old_sellable_flag;
      p_inst_hist_rec_tab.new_sellable_flag(i)	   :=  p_inst_hist_tbl(i).new_sellable_flag;
      p_inst_hist_rec_tab.old_system_id(i)	   :=  p_inst_hist_tbl(i).old_system_id;
      p_inst_hist_rec_tab.new_system_id(i)	   :=  p_inst_hist_tbl(i).new_system_id;
      p_inst_hist_rec_tab.old_system_name(i)	   :=  p_inst_hist_tbl(i).old_system_name;
      p_inst_hist_rec_tab.new_system_name(i)	   :=  p_inst_hist_tbl(i).new_system_name;
      p_inst_hist_rec_tab.old_instance_type_code(i)	   :=  p_inst_hist_tbl(i).old_instance_type_code;
      p_inst_hist_rec_tab.new_instance_type_code(i)	   :=  p_inst_hist_tbl(i).new_instance_type_code;
      p_inst_hist_rec_tab.old_instance_type_name(i)	   :=  p_inst_hist_tbl(i).old_instance_type_name;
      p_inst_hist_rec_tab.new_instance_type_name(i)	   :=  p_inst_hist_tbl(i).new_instance_type_name;
      p_inst_hist_rec_tab.old_active_start_date(i)	   :=  p_inst_hist_tbl(i).old_active_start_date;
      p_inst_hist_rec_tab.new_active_start_date(i)	   :=  p_inst_hist_tbl(i).new_active_start_date;
      p_inst_hist_rec_tab.old_active_end_date(i)	   :=  p_inst_hist_tbl(i).old_active_end_date;
      p_inst_hist_rec_tab.new_active_end_date(i)	   :=  p_inst_hist_tbl(i).new_active_end_date;
      p_inst_hist_rec_tab.old_location_type_code(i)	   :=  p_inst_hist_tbl(i).old_location_type_code;
      p_inst_hist_rec_tab.new_location_type_code(i)	   :=  p_inst_hist_tbl(i).new_location_type_code;
      p_inst_hist_rec_tab.old_location_id(i)	   :=  p_inst_hist_tbl(i).old_location_id;
      p_inst_hist_rec_tab.new_location_id(i)	   :=  p_inst_hist_tbl(i).new_location_id;
      p_inst_hist_rec_tab.old_inv_organization_id(i)	   :=  p_inst_hist_tbl(i).old_inv_organization_id;
      p_inst_hist_rec_tab.new_inv_organization_id(i)	   :=  p_inst_hist_tbl(i).new_inv_organization_id;
      p_inst_hist_rec_tab.old_inv_organization_name(i)   :=  p_inst_hist_tbl(i).old_inv_organization_name;
      p_inst_hist_rec_tab.new_inv_organization_name(i)   :=  p_inst_hist_tbl(i).new_inv_organization_name;
      p_inst_hist_rec_tab.old_inv_subinventory_name(i)   :=  p_inst_hist_tbl(i).old_inv_subinventory_name;
      p_inst_hist_rec_tab.new_inv_subinventory_name(i)   :=  p_inst_hist_tbl(i).new_inv_subinventory_name;
      p_inst_hist_rec_tab.old_inv_locator_id(i)	   :=  p_inst_hist_tbl(i).old_inv_locator_id;
      p_inst_hist_rec_tab.new_inv_locator_id(i)	   :=  p_inst_hist_tbl(i).new_inv_locator_id;
      p_inst_hist_rec_tab.old_pa_project_id(i)	   :=  p_inst_hist_tbl(i).old_pa_project_id;
      p_inst_hist_rec_tab.new_pa_project_id(i)	   :=  p_inst_hist_tbl(i).new_pa_project_id;
      p_inst_hist_rec_tab.old_pa_project_task_id(i)	   :=  p_inst_hist_tbl(i).old_pa_project_task_id;
      p_inst_hist_rec_tab.new_pa_project_task_id(i)	   :=  p_inst_hist_tbl(i).new_pa_project_task_id;
      p_inst_hist_rec_tab.old_pa_project_name(i)	   :=  p_inst_hist_tbl(i).old_pa_project_name;
      p_inst_hist_rec_tab.new_pa_project_name(i)	   :=  p_inst_hist_tbl(i).new_pa_project_name;
      p_inst_hist_rec_tab.old_pa_project_number(i)	   :=  p_inst_hist_tbl(i).old_pa_project_number;
      p_inst_hist_rec_tab.new_pa_project_number(i)	   :=  p_inst_hist_tbl(i).new_pa_project_number;
      p_inst_hist_rec_tab.old_pa_task_name(i)	   :=  p_inst_hist_tbl(i).old_pa_task_name;
      p_inst_hist_rec_tab.new_pa_task_name(i)	   :=  p_inst_hist_tbl(i).new_pa_task_name;
      p_inst_hist_rec_tab.old_pa_task_number(i)	   :=  p_inst_hist_tbl(i).old_pa_task_number;
      p_inst_hist_rec_tab.new_pa_task_number(i)	   :=  p_inst_hist_tbl(i).new_pa_task_number;
      p_inst_hist_rec_tab.old_in_transit_order_line_id(i) := p_inst_hist_tbl(i).old_in_transit_order_line_id;
      p_inst_hist_rec_tab.new_in_transit_order_line_id(i) := p_inst_hist_tbl(i).new_in_transit_order_line_id;
      p_inst_hist_rec_tab.old_in_transit_order_line_num(i) := p_inst_hist_tbl(i).old_in_transit_order_line_num;
      p_inst_hist_rec_tab.new_in_transit_order_line_num(i) := p_inst_hist_tbl(i).new_in_transit_order_line_num;
      p_inst_hist_rec_tab.old_in_transit_order_number(i)  :=  p_inst_hist_tbl(i).old_in_transit_order_number;
      p_inst_hist_rec_tab.new_in_transit_order_number(i)  :=  p_inst_hist_tbl(i).new_in_transit_order_number;
      p_inst_hist_rec_tab.old_wip_job_id(i)	   :=  p_inst_hist_tbl(i).old_wip_job_id;
      p_inst_hist_rec_tab.new_wip_job_id(i)	   :=  p_inst_hist_tbl(i).new_wip_job_id;
      p_inst_hist_rec_tab.old_wip_entity_name(i)   :=  p_inst_hist_tbl(i).old_wip_entity_name;
      p_inst_hist_rec_tab.new_wip_entity_name(i)   :=  p_inst_hist_tbl(i).new_wip_entity_name;
      p_inst_hist_rec_tab.old_po_order_line_id(i)   :=  p_inst_hist_tbl(i).old_po_order_line_id;
      p_inst_hist_rec_tab.new_po_order_line_id(i) :=  p_inst_hist_tbl(i).new_po_order_line_id;
      p_inst_hist_rec_tab.old_last_oe_order_line_id(i)   :=  p_inst_hist_tbl(i).old_last_oe_order_line_id;
      p_inst_hist_rec_tab.new_last_oe_order_line_id(i)   :=  p_inst_hist_tbl(i).new_last_oe_order_line_id;
      p_inst_hist_rec_tab.old_last_oe_rma_line_id(i)	   :=  p_inst_hist_tbl(i).old_last_oe_rma_line_id;
      p_inst_hist_rec_tab.new_last_oe_rma_line_id(i)	   :=  p_inst_hist_tbl(i).new_last_oe_rma_line_id;
      p_inst_hist_rec_tab.old_last_po_po_line_id(i)	   :=  p_inst_hist_tbl(i).old_last_po_po_line_id;
      p_inst_hist_rec_tab.new_last_po_po_line_id(i)	   :=  p_inst_hist_tbl(i).new_last_po_po_line_id;
      p_inst_hist_rec_tab.old_last_oe_po_number(i)	   :=  p_inst_hist_tbl(i).old_last_oe_po_number;
      p_inst_hist_rec_tab.new_last_oe_po_number(i)	   :=  p_inst_hist_tbl(i).new_last_oe_po_number;
      p_inst_hist_rec_tab.old_last_wip_job_id(i)	   :=  p_inst_hist_tbl(i).old_last_wip_job_id;
      p_inst_hist_rec_tab.new_last_wip_job_id(i)	   :=  p_inst_hist_tbl(i).new_last_wip_job_id;
      p_inst_hist_rec_tab.old_last_pa_project_id(i)	   :=  p_inst_hist_tbl(i).old_last_pa_project_id;
      p_inst_hist_rec_tab.new_last_pa_project_id(i)	   :=  p_inst_hist_tbl(i).new_last_pa_project_id;
      p_inst_hist_rec_tab.old_last_pa_task_id(i)	   :=  p_inst_hist_tbl(i).old_last_pa_task_id;
      p_inst_hist_rec_tab.new_last_pa_task_id(i)	   :=  p_inst_hist_tbl(i).new_last_pa_task_id;
      p_inst_hist_rec_tab.old_last_oe_agreement_id(i)	   :=  p_inst_hist_tbl(i).old_last_oe_agreement_id;
      p_inst_hist_rec_tab.new_last_oe_agreement_id(i)	   :=  p_inst_hist_tbl(i).new_last_oe_agreement_id;
      p_inst_hist_rec_tab.old_install_date(i)	   :=  p_inst_hist_tbl(i).old_install_date;
      p_inst_hist_rec_tab.new_install_date(i)	   :=  p_inst_hist_tbl(i).new_install_date;
      p_inst_hist_rec_tab.old_manually_created_flag(i)   :=  p_inst_hist_tbl(i).old_manually_created_flag;
      p_inst_hist_rec_tab.new_manually_created_flag(i)   :=  p_inst_hist_tbl(i).new_manually_created_flag;
      p_inst_hist_rec_tab.old_return_by_date(i)	   :=  p_inst_hist_tbl(i).old_return_by_date;
      p_inst_hist_rec_tab.new_return_by_date(i)	   :=  p_inst_hist_tbl(i).new_return_by_date;
      p_inst_hist_rec_tab.old_actual_return_date(i)	   :=  p_inst_hist_tbl(i).old_actual_return_date;
      p_inst_hist_rec_tab.new_actual_return_date(i)	   :=  p_inst_hist_tbl(i).new_actual_return_date;
      p_inst_hist_rec_tab.old_creation_complete_flag(i)  :=  p_inst_hist_tbl(i).old_creation_complete_flag;
      p_inst_hist_rec_tab.new_creation_complete_flag(i)   :=  p_inst_hist_tbl(i).new_creation_complete_flag;
      p_inst_hist_rec_tab.old_completeness_flag(i)	   :=  p_inst_hist_tbl(i).old_completeness_flag;
      p_inst_hist_rec_tab.new_completeness_flag(i)	   :=  p_inst_hist_tbl(i).new_completeness_flag;
      p_inst_hist_rec_tab.old_context(i)	   :=  p_inst_hist_tbl(i).old_context;
      p_inst_hist_rec_tab.new_context(i)	   :=  p_inst_hist_tbl(i).new_context;
      p_inst_hist_rec_tab.old_attribute1(i)	   :=  p_inst_hist_tbl(i).old_attribute1;
      p_inst_hist_rec_tab.new_attribute1(i)	   :=  p_inst_hist_tbl(i).new_attribute1;
      p_inst_hist_rec_tab.old_attribute2(i)	   :=  p_inst_hist_tbl(i).old_attribute2;
      p_inst_hist_rec_tab.new_attribute2(i)	   :=  p_inst_hist_tbl(i).new_attribute2;
      p_inst_hist_rec_tab.old_attribute3(i)	   :=  p_inst_hist_tbl(i).old_attribute3;
      p_inst_hist_rec_tab.new_attribute3(i)	   :=  p_inst_hist_tbl(i).new_attribute3;
      p_inst_hist_rec_tab.old_attribute4(i)	   :=  p_inst_hist_tbl(i).old_attribute4;
      p_inst_hist_rec_tab.new_attribute4(i)	   :=  p_inst_hist_tbl(i).new_attribute4;
      p_inst_hist_rec_tab.old_attribute5(i)	   :=  p_inst_hist_tbl(i).old_attribute5;
      p_inst_hist_rec_tab.new_attribute5(i)	   :=  p_inst_hist_tbl(i).new_attribute5;
      p_inst_hist_rec_tab.old_attribute6(i)	   :=  p_inst_hist_tbl(i).old_attribute6;
      p_inst_hist_rec_tab.new_attribute6(i)	   :=  p_inst_hist_tbl(i).new_attribute6;
      p_inst_hist_rec_tab.old_attribute7(i)	   :=  p_inst_hist_tbl(i).old_attribute7;
      p_inst_hist_rec_tab.new_attribute7(i)	   :=  p_inst_hist_tbl(i).new_attribute7;
      p_inst_hist_rec_tab.old_attribute8(i)	   :=  p_inst_hist_tbl(i).old_attribute8;
      p_inst_hist_rec_tab.new_attribute8(i)	   :=  p_inst_hist_tbl(i).new_attribute8;
      p_inst_hist_rec_tab.old_attribute9(i)	   :=  p_inst_hist_tbl(i).old_attribute9;
      p_inst_hist_rec_tab.new_attribute9(i)	   :=  p_inst_hist_tbl(i).new_attribute9;
      p_inst_hist_rec_tab.old_attribute10(i)	   :=  p_inst_hist_tbl(i).old_attribute10;
      p_inst_hist_rec_tab.new_attribute10(i)	   :=  p_inst_hist_tbl(i).new_attribute10;
      p_inst_hist_rec_tab.old_attribute11(i)	   :=  p_inst_hist_tbl(i).old_attribute11;
      p_inst_hist_rec_tab.new_attribute11(i)	   :=  p_inst_hist_tbl(i).new_attribute11;
      p_inst_hist_rec_tab.old_attribute12(i)	   :=  p_inst_hist_tbl(i).old_attribute12;
      p_inst_hist_rec_tab.new_attribute12(i)	   :=  p_inst_hist_tbl(i).new_attribute12;
      p_inst_hist_rec_tab.old_attribute13(i)	   :=  p_inst_hist_tbl(i).old_attribute13;
      p_inst_hist_rec_tab.new_attribute13(i)	   :=  p_inst_hist_tbl(i).new_attribute13;
      p_inst_hist_rec_tab.old_attribute14(i)	   :=  p_inst_hist_tbl(i).old_attribute14;
      p_inst_hist_rec_tab.new_attribute14(i)	   :=  p_inst_hist_tbl(i).new_attribute14;
      p_inst_hist_rec_tab.old_attribute15(i)	   :=  p_inst_hist_tbl(i).old_attribute15;
      p_inst_hist_rec_tab.new_attribute15(i)	   :=  p_inst_hist_tbl(i).new_attribute15;
      p_inst_hist_rec_tab.old_last_txn_line_detail_id(i)   :=  p_inst_hist_tbl(i).old_last_txn_line_detail_id;
      p_inst_hist_rec_tab.new_last_txn_line_detail_id(i)   :=  p_inst_hist_tbl(i).new_last_txn_line_detail_id;
      p_inst_hist_rec_tab.old_install_location_type_code(i) :=  p_inst_hist_tbl(i).old_install_location_type_code;
      p_inst_hist_rec_tab.new_install_location_type_code(i) :=  p_inst_hist_tbl(i).new_install_location_type_code;
      p_inst_hist_rec_tab.old_install_location_id(i)	   :=  p_inst_hist_tbl(i).old_install_location_id;
      p_inst_hist_rec_tab.new_install_location_id(i)	   :=  p_inst_hist_tbl(i).new_install_location_id;
      p_inst_hist_rec_tab.old_instance_usage_code(i)	   :=  p_inst_hist_tbl(i).old_instance_usage_code;
      p_inst_hist_rec_tab.new_instance_usage_code(i)	   :=  p_inst_hist_tbl(i).new_instance_usage_code;
      p_inst_hist_rec_tab.old_current_loc_address1(i)	   :=  p_inst_hist_tbl(i).old_current_loc_address1;
      p_inst_hist_rec_tab.new_current_loc_address1(i)	   :=  p_inst_hist_tbl(i).new_current_loc_address1;
      p_inst_hist_rec_tab.old_current_loc_address2(i)	   :=  p_inst_hist_tbl(i).old_current_loc_address2;
      p_inst_hist_rec_tab.new_current_loc_address2(i)	   :=  p_inst_hist_tbl(i).new_current_loc_address2;
      p_inst_hist_rec_tab.old_current_loc_address3(i)	   :=  p_inst_hist_tbl(i).old_current_loc_address3;
      p_inst_hist_rec_tab.new_current_loc_address3(i)	   :=  p_inst_hist_tbl(i).new_current_loc_address3;
      p_inst_hist_rec_tab.old_current_loc_address4(i)	   :=  p_inst_hist_tbl(i).old_current_loc_address4;
      p_inst_hist_rec_tab.new_current_loc_address4(i)	   :=  p_inst_hist_tbl(i).new_current_loc_address4;
      p_inst_hist_rec_tab.old_current_loc_city(i)	   :=  p_inst_hist_tbl(i).old_current_loc_city;
      p_inst_hist_rec_tab.new_current_loc_city(i)	   :=  p_inst_hist_tbl(i).new_current_loc_city;
      p_inst_hist_rec_tab.old_current_loc_postal_code(i)  :=  p_inst_hist_tbl(i).old_current_loc_postal_code;
      p_inst_hist_rec_tab.new_current_loc_postal_code(i)  :=  p_inst_hist_tbl(i).new_current_loc_postal_code;
      p_inst_hist_rec_tab.old_current_loc_country(i)	   :=  p_inst_hist_tbl(i).old_current_loc_country;
      p_inst_hist_rec_tab.new_current_loc_country(i)	   :=  p_inst_hist_tbl(i).new_current_loc_country;
      p_inst_hist_rec_tab.old_sales_order_number(i)	   :=  p_inst_hist_tbl(i).old_sales_order_number;
      p_inst_hist_rec_tab.new_sales_order_number(i)	   :=  p_inst_hist_tbl(i).new_sales_order_number;
      p_inst_hist_rec_tab.old_sales_order_line_number(i)  :=  p_inst_hist_tbl(i).old_sales_order_line_number;
      p_inst_hist_rec_tab.new_sales_order_line_number(i)  :=  p_inst_hist_tbl(i).new_sales_order_line_number;
      p_inst_hist_rec_tab.old_sales_order_date(i)	   :=  p_inst_hist_tbl(i).old_sales_order_date;
      p_inst_hist_rec_tab.new_sales_order_date(i)	   :=  p_inst_hist_tbl(i).new_sales_order_date;
      p_inst_hist_rec_tab.old_purchase_order_number(i)   :=  p_inst_hist_tbl(i).old_purchase_order_number;
      p_inst_hist_rec_tab.new_purchase_order_number(i)   :=  p_inst_hist_tbl(i).new_purchase_order_number;
      p_inst_hist_rec_tab.old_instance_usage_name(i)	   :=  p_inst_hist_tbl(i).old_instance_usage_name;
      p_inst_hist_rec_tab.new_instance_usage_name(i)	   :=  p_inst_hist_tbl(i).new_instance_usage_name;
      p_inst_hist_rec_tab.old_current_loc_state(i)	   :=  p_inst_hist_tbl(i).old_current_loc_state;
      p_inst_hist_rec_tab.new_current_loc_state(i)	   :=  p_inst_hist_tbl(i).new_current_loc_state;
      p_inst_hist_rec_tab.old_install_loc_address1(i)	   :=  p_inst_hist_tbl(i).old_install_loc_address1;
      p_inst_hist_rec_tab.new_install_loc_address1(i)	   :=  p_inst_hist_tbl(i).new_install_loc_address1;
      p_inst_hist_rec_tab.old_install_loc_address2(i)	   :=  p_inst_hist_tbl(i).old_install_loc_address2;
      p_inst_hist_rec_tab.new_install_loc_address2(i)	   :=  p_inst_hist_tbl(i).new_install_loc_address2;
      p_inst_hist_rec_tab.old_install_loc_address3(i)	   :=  p_inst_hist_tbl(i).old_install_loc_address3;
      p_inst_hist_rec_tab.new_install_loc_address3(i)	   :=  p_inst_hist_tbl(i).new_install_loc_address3;
      p_inst_hist_rec_tab.old_install_loc_address4(i)	   :=  p_inst_hist_tbl(i).old_install_loc_address4;
      p_inst_hist_rec_tab.new_install_loc_address4(i)	   :=  p_inst_hist_tbl(i).new_install_loc_address4;
      p_inst_hist_rec_tab.old_install_loc_city(i)	   :=  p_inst_hist_tbl(i).old_install_loc_city;
      p_inst_hist_rec_tab.new_install_loc_city(i)	   :=  p_inst_hist_tbl(i).new_install_loc_city;
      p_inst_hist_rec_tab.old_install_loc_state(i)	   :=  p_inst_hist_tbl(i).old_install_loc_state;
      p_inst_hist_rec_tab.new_install_loc_state(i)	   :=  p_inst_hist_tbl(i).new_install_loc_state;
      p_inst_hist_rec_tab.old_install_loc_postal_code(i) :=  p_inst_hist_tbl(i).old_install_loc_postal_code;
      p_inst_hist_rec_tab.new_install_loc_postal_code(i) :=  p_inst_hist_tbl(i).new_install_loc_postal_code;
      p_inst_hist_rec_tab.old_install_loc_country(i)	   :=  p_inst_hist_tbl(i).old_install_loc_country;
      p_inst_hist_rec_tab.new_install_loc_country(i)	   :=  p_inst_hist_tbl(i).new_install_loc_country;
      p_inst_hist_rec_tab.old_config_inst_rev_num(i)	   :=  p_inst_hist_tbl(i).old_config_inst_rev_num;
      p_inst_hist_rec_tab.new_config_inst_rev_num(i)	   :=  p_inst_hist_tbl(i).new_config_inst_rev_num;
      p_inst_hist_rec_tab.old_config_valid_status(i)	   :=  p_inst_hist_tbl(i).old_config_valid_status;
      p_inst_hist_rec_tab.new_config_valid_status(i)	   :=  p_inst_hist_tbl(i).new_config_valid_status;
      p_inst_hist_rec_tab.old_instance_description(i)	   :=  p_inst_hist_tbl(i).old_instance_description;
      p_inst_hist_rec_tab.new_instance_description(i)	   :=  p_inst_hist_tbl(i).new_instance_description;
      p_inst_hist_rec_tab.instance_history_id(i)	   :=  p_inst_hist_tbl(i).instance_history_id;
      p_inst_hist_rec_tab.transaction_id(i)	           :=  p_inst_hist_tbl(i).transaction_id;
      p_inst_hist_rec_tab.old_last_vld_organization_id(i)  :=  p_inst_hist_tbl(i).old_last_vld_organization_id;
      p_inst_hist_rec_tab.new_last_vld_organization_id(i)  :=  p_inst_hist_tbl(i).new_last_vld_organization_id;

      p_inst_hist_rec_tab.old_network_asset_flag(i)       := p_inst_hist_tbl(i).old_network_asset_flag;
      p_inst_hist_rec_tab.new_network_asset_flag(i)       := p_inst_hist_tbl(i).new_network_asset_flag;
      p_inst_hist_rec_tab.old_maintainable_flag(i)        := p_inst_hist_tbl(i).old_maintainable_flag;
      p_inst_hist_rec_tab.new_maintainable_flag(i)        := p_inst_hist_tbl(i).new_maintainable_flag;
      p_inst_hist_rec_tab.old_asset_criticality_code(i)   := p_inst_hist_tbl(i).old_asset_criticality_code;
      p_inst_hist_rec_tab.new_asset_criticality_code(i)   := p_inst_hist_tbl(i).new_asset_criticality_code;
      p_inst_hist_rec_tab.old_category_id(i)              := p_inst_hist_tbl(i).old_category_id ;
      p_inst_hist_rec_tab.new_category_id(i)              := p_inst_hist_tbl(i).new_category_id ;
      p_inst_hist_rec_tab.old_equipment_gen_object_id(i)  := p_inst_hist_tbl(i).old_equipment_gen_object_id ;
      p_inst_hist_rec_tab.new_equipment_gen_object_id(i)  := p_inst_hist_tbl(i).new_equipment_gen_object_id ;
      p_inst_hist_rec_tab.old_instantiation_flag(i)       := p_inst_hist_tbl(i).old_instantiation_flag;
      p_inst_hist_rec_tab.new_instantiation_flag(i)       := p_inst_hist_tbl(i).new_instantiation_flag;
      p_inst_hist_rec_tab.old_operational_log_flag(i)     := p_inst_hist_tbl(i).old_operational_log_flag ;
      p_inst_hist_rec_tab.new_operational_log_flag(i)     := p_inst_hist_tbl(i).new_operational_log_flag ;
      p_inst_hist_rec_tab.old_supplier_warranty_exp_date(i) := p_inst_hist_tbl(i).old_supplier_warranty_exp_date ;
      p_inst_hist_rec_tab.new_supplier_warranty_exp_date(i) := p_inst_hist_tbl(i).new_supplier_warranty_exp_date ;
      p_inst_hist_rec_tab.old_attribute16(i) := p_inst_hist_tbl(i).old_attribute16           ;
      p_inst_hist_rec_tab.new_attribute16(i) := p_inst_hist_tbl(i).new_attribute16           ;
      p_inst_hist_rec_tab.old_attribute17(i) := p_inst_hist_tbl(i).old_attribute17           ;
      p_inst_hist_rec_tab.new_attribute17(i) := p_inst_hist_tbl(i).new_attribute17           ;
      p_inst_hist_rec_tab.old_attribute18(i) := p_inst_hist_tbl(i).old_attribute18           ;
      p_inst_hist_rec_tab.new_attribute18(i) := p_inst_hist_tbl(i).new_attribute18           ;
      p_inst_hist_rec_tab.old_attribute19(i) := p_inst_hist_tbl(i).old_attribute19           ;
      p_inst_hist_rec_tab.new_attribute19(i) := p_inst_hist_tbl(i).new_attribute19           ;
      p_inst_hist_rec_tab.old_attribute20(i) := p_inst_hist_tbl(i).old_attribute20           ;
      p_inst_hist_rec_tab.new_attribute20(i) := p_inst_hist_tbl(i).new_attribute20           ;
      p_inst_hist_rec_tab.old_attribute21(i) := p_inst_hist_tbl(i).old_attribute21           ;
      p_inst_hist_rec_tab.new_attribute21(i) := p_inst_hist_tbl(i).new_attribute21           ;
      p_inst_hist_rec_tab.old_attribute22(i) := p_inst_hist_tbl(i).old_attribute22           ;
      p_inst_hist_rec_tab.new_attribute22(i) := p_inst_hist_tbl(i).new_attribute22           ;
      p_inst_hist_rec_tab.old_attribute23(i) := p_inst_hist_tbl(i).old_attribute23           ;
      p_inst_hist_rec_tab.new_attribute23(i) := p_inst_hist_tbl(i).new_attribute23           ;
      p_inst_hist_rec_tab.old_attribute24(i) := p_inst_hist_tbl(i).old_attribute24           ;
      p_inst_hist_rec_tab.new_attribute24(i) := p_inst_hist_tbl(i).new_attribute24           ;
      p_inst_hist_rec_tab.old_attribute25(i) := p_inst_hist_tbl(i).old_attribute25           ;
      p_inst_hist_rec_tab.new_attribute25(i) := p_inst_hist_tbl(i).new_attribute25           ;
      p_inst_hist_rec_tab.old_attribute26(i) := p_inst_hist_tbl(i).old_attribute26           ;
      p_inst_hist_rec_tab.new_attribute26(i) := p_inst_hist_tbl(i).new_attribute26           ;
      p_inst_hist_rec_tab.old_attribute27(i) := p_inst_hist_tbl(i).old_attribute27           ;
      p_inst_hist_rec_tab.new_attribute27(i) := p_inst_hist_tbl(i).new_attribute27           ;
      p_inst_hist_rec_tab.old_attribute28(i) := p_inst_hist_tbl(i).old_attribute28           ;
      p_inst_hist_rec_tab.new_attribute28(i) := p_inst_hist_tbl(i).new_attribute28           ;
      p_inst_hist_rec_tab.old_attribute29(i) := p_inst_hist_tbl(i).old_attribute29           ;
      p_inst_hist_rec_tab.new_attribute29(i) := p_inst_hist_tbl(i).new_attribute29           ;
      p_inst_hist_rec_tab.old_attribute30(i) := p_inst_hist_tbl(i).old_attribute30           ;
      p_inst_hist_rec_tab.new_attribute30(i) := p_inst_hist_tbl(i).new_attribute30           ;

      p_inst_hist_rec_tab.old_payables_currency_code(i)   := p_inst_hist_tbl(i).old_payables_currency_code;
      p_inst_hist_rec_tab.new_payables_currency_code(i)   := p_inst_hist_tbl(i).new_payables_currency_code;
      p_inst_hist_rec_tab.old_purchase_unit_price(i)      := p_inst_hist_tbl(i).old_purchase_unit_price;
      p_inst_hist_rec_tab.new_purchase_unit_price(i)      := p_inst_hist_tbl(i).new_purchase_unit_price;
      p_inst_hist_rec_tab.old_purchase_currency_code(i)   := p_inst_hist_tbl(i).old_purchase_currency_code;
      p_inst_hist_rec_tab.new_purchase_currency_code(i)   := p_inst_hist_tbl(i).new_purchase_currency_code;
      p_inst_hist_rec_tab.old_payables_unit_price(i)      := p_inst_hist_tbl(i).old_payables_unit_price;
      p_inst_hist_rec_tab.new_payables_unit_price(i)      := p_inst_hist_tbl(i).new_payables_unit_price;
      p_inst_hist_rec_tab.old_sales_unit_price(i)         := p_inst_hist_tbl(i).old_sales_unit_price;
      p_inst_hist_rec_tab.new_sales_unit_price(i)         := p_inst_hist_tbl(i).new_sales_unit_price;
      p_inst_hist_rec_tab.old_sales_currency_code(i)      := p_inst_hist_tbl(i).old_sales_currency_code;
      p_inst_hist_rec_tab.new_sales_currency_code(i)      := p_inst_hist_tbl(i).new_sales_currency_code;
      p_inst_hist_rec_tab.old_operational_status_code(i)  := p_inst_hist_tbl(i).old_operational_status_code;
      p_inst_hist_rec_tab.new_operational_status_code(i)  := p_inst_hist_tbl(i).new_operational_status_code;

   END LOOP;
END Build_Inst_Hist_Rec_of_Table;
--
PROCEDURE Build_Ver_Label_Rec_of_Table
   (
     p_version_label_tbl     IN     csi_datastructures_pub.version_label_tbl
    ,p_version_label_rec_tab IN OUT NOCOPY  csi_item_instance_grp.version_label_rec_tab
   ) IS
BEGIN
   FOR i in p_version_label_tbl.FIRST .. p_version_label_tbl.LAST LOOP
      p_version_label_rec_tab.version_label_id(i)	:= p_version_label_tbl(i).version_label_id;
      p_version_label_rec_tab.instance_id(i)	:= p_version_label_tbl(i).instance_id;
      p_version_label_rec_tab.version_label(i)	:= p_version_label_tbl(i).version_label;
      p_version_label_rec_tab.description(i)	:= p_version_label_tbl(i).description;
      p_version_label_rec_tab.date_time_stamp(i)	:= p_version_label_tbl(i).date_time_stamp;
      p_version_label_rec_tab.active_start_date(i)	:= p_version_label_tbl(i).active_start_date;
      p_version_label_rec_tab.active_end_date(i)	:= p_version_label_tbl(i).active_end_date;
      p_version_label_rec_tab.context(i)	:= p_version_label_tbl(i).context;
      p_version_label_rec_tab.attribute1(i)	:= p_version_label_tbl(i).attribute1;
      p_version_label_rec_tab.attribute2(i)	:= p_version_label_tbl(i).attribute2;
      p_version_label_rec_tab.attribute3(i)	:= p_version_label_tbl(i).attribute3;
      p_version_label_rec_tab.attribute4(i)	:= p_version_label_tbl(i).attribute4;
      p_version_label_rec_tab.attribute5(i)	:= p_version_label_tbl(i).attribute5;
      p_version_label_rec_tab.attribute6(i)	:= p_version_label_tbl(i).attribute6;
      p_version_label_rec_tab.attribute7(i)	:= p_version_label_tbl(i).attribute7;
      p_version_label_rec_tab.attribute8(i)	:= p_version_label_tbl(i).attribute8;
      p_version_label_rec_tab.attribute9(i)	:= p_version_label_tbl(i).attribute9;
      p_version_label_rec_tab.attribute10(i)	:= p_version_label_tbl(i).attribute10;
      p_version_label_rec_tab.attribute11(i)	:= p_version_label_tbl(i).attribute11;
      p_version_label_rec_tab.attribute12(i)	:= p_version_label_tbl(i).attribute12;
      p_version_label_rec_tab.attribute13(i)	:= p_version_label_tbl(i).attribute13;
      p_version_label_rec_tab.attribute14(i)	:= p_version_label_tbl(i).attribute14;
      p_version_label_rec_tab.attribute15(i)	:= p_version_label_tbl(i).attribute15;
      p_version_label_rec_tab.object_version_number(i)	:= p_version_label_tbl(i).object_version_number;
   END LOOP;
END Build_Ver_Label_Rec_of_Table;
--
PROCEDURE Build_Ver_Lbl_Hist_Rec_Table
   (
     p_ver_label_hist_tbl     IN   csi_datastructures_pub.version_label_history_tbl
    ,p_ver_label_hist_rec_tab IN OUT NOCOPY  csi_item_instance_grp.ver_label_history_rec_tab
   ) IS
BEGIN
   FOR i in p_ver_label_hist_tbl.FIRST .. p_ver_label_hist_tbl.LAST LOOP
      p_ver_label_hist_rec_tab.VERSION_LABEL_HISTORY_ID(i):= p_ver_label_hist_tbl(i).VERSION_LABEL_HISTORY_ID;
      p_ver_label_hist_rec_tab.VERSION_LABEL_ID(i)	:= p_ver_label_hist_tbl(i).VERSION_LABEL_ID;
      p_ver_label_hist_rec_tab.TRANSACTION_ID(i)	:= p_ver_label_hist_tbl(i).TRANSACTION_ID;
      p_ver_label_hist_rec_tab.OLD_VERSION_LABEL(i)	:= p_ver_label_hist_tbl(i).OLD_VERSION_LABEL;
      p_ver_label_hist_rec_tab.NEW_VERSION_LABEL(i)	:= p_ver_label_hist_tbl(i).NEW_VERSION_LABEL;
      p_ver_label_hist_rec_tab.OLD_DESCRIPTION(i)	:= p_ver_label_hist_tbl(i).OLD_DESCRIPTION;
      p_ver_label_hist_rec_tab.NEW_DESCRIPTION(i)	:= p_ver_label_hist_tbl(i).NEW_DESCRIPTION;
      p_ver_label_hist_rec_tab.OLD_DATE_TIME_STAMP(i)	:= p_ver_label_hist_tbl(i).OLD_DATE_TIME_STAMP;
      p_ver_label_hist_rec_tab.NEW_DATE_TIME_STAMP(i)	:= p_ver_label_hist_tbl(i).NEW_DATE_TIME_STAMP;
      p_ver_label_hist_rec_tab.OLD_ACTIVE_START_DATE(i)	:= p_ver_label_hist_tbl(i).OLD_ACTIVE_START_DATE;
      p_ver_label_hist_rec_tab.NEW_ACTIVE_START_DATE(i)	:= p_ver_label_hist_tbl(i).NEW_ACTIVE_START_DATE;
      p_ver_label_hist_rec_tab.OLD_ACTIVE_END_DATE(i)	:= p_ver_label_hist_tbl(i).OLD_ACTIVE_END_DATE;
      p_ver_label_hist_rec_tab.NEW_ACTIVE_END_DATE(i)	:= p_ver_label_hist_tbl(i).NEW_ACTIVE_END_DATE;
      p_ver_label_hist_rec_tab.OLD_CONTEXT(i)	:= p_ver_label_hist_tbl(i).OLD_CONTEXT;
      p_ver_label_hist_rec_tab.NEW_CONTEXT(i)	:= p_ver_label_hist_tbl(i).NEW_CONTEXT;
      p_ver_label_hist_rec_tab.OLD_ATTRIBUTE1(i)	:= p_ver_label_hist_tbl(i).OLD_ATTRIBUTE1;
      p_ver_label_hist_rec_tab.NEW_ATTRIBUTE1(i)	:= p_ver_label_hist_tbl(i).NEW_ATTRIBUTE1;
      p_ver_label_hist_rec_tab.OLD_ATTRIBUTE2(i)	:= p_ver_label_hist_tbl(i).OLD_ATTRIBUTE2;
      p_ver_label_hist_rec_tab.NEW_ATTRIBUTE2(i)	:= p_ver_label_hist_tbl(i).NEW_ATTRIBUTE2;
      p_ver_label_hist_rec_tab.OLD_ATTRIBUTE3(i)	:= p_ver_label_hist_tbl(i).OLD_ATTRIBUTE3;
      p_ver_label_hist_rec_tab.NEW_ATTRIBUTE3(i)	:= p_ver_label_hist_tbl(i).NEW_ATTRIBUTE3;
      p_ver_label_hist_rec_tab.OLD_ATTRIBUTE4(i)	:= p_ver_label_hist_tbl(i).OLD_ATTRIBUTE4;
      p_ver_label_hist_rec_tab.NEW_ATTRIBUTE4(i)	:= p_ver_label_hist_tbl(i).NEW_ATTRIBUTE4;
      p_ver_label_hist_rec_tab.OLD_ATTRIBUTE5(i)	:= p_ver_label_hist_tbl(i).OLD_ATTRIBUTE5;
      p_ver_label_hist_rec_tab.NEW_ATTRIBUTE5(i)	:= p_ver_label_hist_tbl(i).NEW_ATTRIBUTE5;
      p_ver_label_hist_rec_tab.OLD_ATTRIBUTE6(i)	:= p_ver_label_hist_tbl(i).OLD_ATTRIBUTE6;
      p_ver_label_hist_rec_tab.NEW_ATTRIBUTE6(i)	:= p_ver_label_hist_tbl(i).NEW_ATTRIBUTE6;
      p_ver_label_hist_rec_tab.OLD_ATTRIBUTE7(i)	:= p_ver_label_hist_tbl(i).OLD_ATTRIBUTE7;
      p_ver_label_hist_rec_tab.NEW_ATTRIBUTE7(i)	:= p_ver_label_hist_tbl(i).NEW_ATTRIBUTE7;
      p_ver_label_hist_rec_tab.OLD_ATTRIBUTE8(i)	:= p_ver_label_hist_tbl(i).OLD_ATTRIBUTE8;
      p_ver_label_hist_rec_tab.NEW_ATTRIBUTE8(i)	:= p_ver_label_hist_tbl(i).NEW_ATTRIBUTE8;
      p_ver_label_hist_rec_tab.OLD_ATTRIBUTE9(i)	:= p_ver_label_hist_tbl(i).OLD_ATTRIBUTE9;
      p_ver_label_hist_rec_tab.NEW_ATTRIBUTE9(i)	:= p_ver_label_hist_tbl(i).NEW_ATTRIBUTE9;
      p_ver_label_hist_rec_tab.OLD_ATTRIBUTE10(i)	:= p_ver_label_hist_tbl(i).OLD_ATTRIBUTE10;
      p_ver_label_hist_rec_tab.NEW_ATTRIBUTE10(i)	:= p_ver_label_hist_tbl(i).NEW_ATTRIBUTE10;
      p_ver_label_hist_rec_tab.OLD_ATTRIBUTE11(i)	:= p_ver_label_hist_tbl(i).OLD_ATTRIBUTE11;
      p_ver_label_hist_rec_tab.NEW_ATTRIBUTE11(i)	:= p_ver_label_hist_tbl(i).NEW_ATTRIBUTE11;
      p_ver_label_hist_rec_tab.OLD_ATTRIBUTE12(i)	:= p_ver_label_hist_tbl(i).OLD_ATTRIBUTE12;
      p_ver_label_hist_rec_tab.NEW_ATTRIBUTE12(i)	:= p_ver_label_hist_tbl(i).NEW_ATTRIBUTE12;
      p_ver_label_hist_rec_tab.OLD_ATTRIBUTE13(i)	:= p_ver_label_hist_tbl(i).OLD_ATTRIBUTE13;
      p_ver_label_hist_rec_tab.NEW_ATTRIBUTE13(i)	:= p_ver_label_hist_tbl(i).NEW_ATTRIBUTE13;
      p_ver_label_hist_rec_tab.OLD_ATTRIBUTE14(i)	:= p_ver_label_hist_tbl(i).OLD_ATTRIBUTE14;
      p_ver_label_hist_rec_tab.NEW_ATTRIBUTE14(i)	:= p_ver_label_hist_tbl(i).NEW_ATTRIBUTE14;
      p_ver_label_hist_rec_tab.OLD_ATTRIBUTE15(i)	:= p_ver_label_hist_tbl(i).OLD_ATTRIBUTE15;
      p_ver_label_hist_rec_tab.NEW_ATTRIBUTE15(i)	:= p_ver_label_hist_tbl(i).NEW_ATTRIBUTE15;
      p_ver_label_hist_rec_tab.FULL_DUMP_FLAG(i)	:= p_ver_label_hist_tbl(i).FULL_DUMP_FLAG;
      p_ver_label_hist_rec_tab.OBJECT_VERSION_NUMBER(i)	:= p_ver_label_hist_tbl(i).OBJECT_VERSION_NUMBER;
      p_ver_label_hist_rec_tab.INSTANCE_ID(i)	:= p_ver_label_hist_tbl(i).INSTANCE_ID;
   END LOOP;
END Build_Ver_Lbl_Hist_Rec_Table;
--
PROCEDURE Build_Party_Rec_of_Table
   ( p_party_tbl          IN   csi_datastructures_pub.party_tbl
    ,p_party_rec_tab      IN OUT NOCOPY  csi_item_instance_grp.party_rec_tab
   ) IS
BEGIN
   FOR i in p_party_tbl.FIRST .. p_party_tbl.LAST LOOP
      p_party_rec_tab.instance_party_id(i)	  := p_party_tbl(i).instance_party_id;
      p_party_rec_tab.instance_id(i)	  := p_party_tbl(i).instance_id;
      p_party_rec_tab.party_source_table(i)	  := p_party_tbl(i).party_source_table;
      p_party_rec_tab.party_id(i)	  := p_party_tbl(i).party_id;
      p_party_rec_tab.relationship_type_code(i)	  := p_party_tbl(i).relationship_type_code;
      p_party_rec_tab.contact_flag(i)	  := p_party_tbl(i).contact_flag;
      p_party_rec_tab.contact_ip_id(i)	  := p_party_tbl(i).contact_ip_id;
      p_party_rec_tab.active_start_date(i)	  := p_party_tbl(i).active_start_date;
      p_party_rec_tab.active_end_date(i)	  := p_party_tbl(i).active_end_date;
      p_party_rec_tab.context(i)	  := p_party_tbl(i).context;
      p_party_rec_tab.attribute1(i)	  := p_party_tbl(i).attribute1;
      p_party_rec_tab.attribute2(i)	  := p_party_tbl(i).attribute2;
      p_party_rec_tab.attribute3(i)	  := p_party_tbl(i).attribute3;
      p_party_rec_tab.attribute4(i)	  := p_party_tbl(i).attribute4;
      p_party_rec_tab.attribute5(i)	  := p_party_tbl(i).attribute5;
      p_party_rec_tab.attribute6(i)	  := p_party_tbl(i).attribute6;
      p_party_rec_tab.attribute7(i)	  := p_party_tbl(i).attribute7;
      p_party_rec_tab.attribute8(i)	  := p_party_tbl(i).attribute8;
      p_party_rec_tab.attribute9(i)	  := p_party_tbl(i).attribute9;
      p_party_rec_tab.attribute10(i)	  := p_party_tbl(i).attribute10;
      p_party_rec_tab.attribute11(i)	  := p_party_tbl(i).attribute11;
      p_party_rec_tab.attribute12(i)	  := p_party_tbl(i).attribute12;
      p_party_rec_tab.attribute13(i)	  := p_party_tbl(i).attribute13;
      p_party_rec_tab.attribute14(i)	  := p_party_tbl(i).attribute14;
      p_party_rec_tab.attribute15(i)	  := p_party_tbl(i).attribute15;
      p_party_rec_tab.object_version_number(i)	  := p_party_tbl(i).object_version_number;
      p_party_rec_tab.primary_flag(i)	  := p_party_tbl(i).primary_flag;
      p_party_rec_tab.preferred_flag(i)	  := p_party_tbl(i).preferred_flag;
      p_party_rec_tab.parent_tbl_index(i)	  := p_party_tbl(i).parent_tbl_index;
      p_party_rec_tab.call_contracts(i)	  := p_party_tbl(i).call_contracts;
      p_party_rec_tab.contact_parent_tbl_index(i)	  := p_party_tbl(i).contact_parent_tbl_index;
   END LOOP;
END Build_Party_Rec_of_Table;
--
PROCEDURE Build_Party_Hist_Rec_of_Table
   ( p_party_hist_tbl        IN      csi_datastructures_pub.party_history_tbl
    ,p_party_hist_rec_tab    IN OUT NOCOPY   csi_item_instance_grp.party_history_rec_tab
   ) IS
BEGIN
   FOR i in p_party_hist_tbl.FIRST .. p_party_hist_tbl.LAST LOOP
      p_party_hist_rec_tab.INSTANCE_PARTY_HISTORY_ID(i)	   :=  p_party_hist_tbl(i).INSTANCE_PARTY_HISTORY_ID;
      p_party_hist_rec_tab.INSTANCE_PARTY_ID(i)	   :=  p_party_hist_tbl(i).INSTANCE_PARTY_ID;
      p_party_hist_rec_tab.TRANSACTION_ID(i)	   :=  p_party_hist_tbl(i).TRANSACTION_ID;
      p_party_hist_rec_tab.OLD_PARTY_SOURCE_TABLE(i)	   :=  p_party_hist_tbl(i).OLD_PARTY_SOURCE_TABLE;
      p_party_hist_rec_tab.NEW_PARTY_SOURCE_TABLE(i)	   :=  p_party_hist_tbl(i).NEW_PARTY_SOURCE_TABLE;
      p_party_hist_rec_tab.OLD_PARTY_ID(i)	   :=  p_party_hist_tbl(i).OLD_PARTY_ID;
      p_party_hist_rec_tab.NEW_PARTY_ID(i)	   :=  p_party_hist_tbl(i).NEW_PARTY_ID;
      p_party_hist_rec_tab.OLD_RELATIONSHIP_TYPE_CODE(i) :=  p_party_hist_tbl(i).OLD_RELATIONSHIP_TYPE_CODE;
      p_party_hist_rec_tab.NEW_RELATIONSHIP_TYPE_CODE(i) :=  p_party_hist_tbl(i).NEW_RELATIONSHIP_TYPE_CODE;
      p_party_hist_rec_tab.OLD_CONTACT_FLAG(i)	   :=  p_party_hist_tbl(i).OLD_CONTACT_FLAG;
      p_party_hist_rec_tab.NEW_CONTACT_FLAG(i)	   :=  p_party_hist_tbl(i).NEW_CONTACT_FLAG;
      p_party_hist_rec_tab.OLD_CONTACT_IP_ID(i)	   :=  p_party_hist_tbl(i).OLD_CONTACT_IP_ID;
      p_party_hist_rec_tab.NEW_CONTACT_IP_ID(i)	   :=  p_party_hist_tbl(i).NEW_CONTACT_IP_ID;
      p_party_hist_rec_tab.OLD_ACTIVE_START_DATE(i)	   :=  p_party_hist_tbl(i).OLD_ACTIVE_START_DATE;
      p_party_hist_rec_tab.NEW_ACTIVE_START_DATE(i)	   :=  p_party_hist_tbl(i).NEW_ACTIVE_START_DATE;
      p_party_hist_rec_tab.OLD_ACTIVE_END_DATE(i)	   :=  p_party_hist_tbl(i).OLD_ACTIVE_END_DATE;
      p_party_hist_rec_tab.NEW_ACTIVE_END_DATE(i)	   :=  p_party_hist_tbl(i).NEW_ACTIVE_END_DATE;
      p_party_hist_rec_tab.OLD_CONTEXT(i)	   :=  p_party_hist_tbl(i).OLD_CONTEXT;
      p_party_hist_rec_tab.NEW_CONTEXT(i)	   :=  p_party_hist_tbl(i).NEW_CONTEXT;
      p_party_hist_rec_tab.OLD_ATTRIBUTE1(i)	   :=  p_party_hist_tbl(i).OLD_ATTRIBUTE1;
      p_party_hist_rec_tab.NEW_ATTRIBUTE1(i)	   :=  p_party_hist_tbl(i).NEW_ATTRIBUTE1;
      p_party_hist_rec_tab.OLD_ATTRIBUTE2(i)	   :=  p_party_hist_tbl(i).OLD_ATTRIBUTE2;
      p_party_hist_rec_tab.NEW_ATTRIBUTE2(i)	   :=  p_party_hist_tbl(i).NEW_ATTRIBUTE2;
      p_party_hist_rec_tab.OLD_ATTRIBUTE3(i)	   :=  p_party_hist_tbl(i).OLD_ATTRIBUTE3;
      p_party_hist_rec_tab.NEW_ATTRIBUTE3(i)	   :=  p_party_hist_tbl(i).NEW_ATTRIBUTE3;
      p_party_hist_rec_tab.OLD_ATTRIBUTE4(i)	   :=  p_party_hist_tbl(i).OLD_ATTRIBUTE4;
      p_party_hist_rec_tab.NEW_ATTRIBUTE4(i)	   :=  p_party_hist_tbl(i).NEW_ATTRIBUTE4;
      p_party_hist_rec_tab.OLD_ATTRIBUTE5(i)	   :=  p_party_hist_tbl(i).OLD_ATTRIBUTE5;
      p_party_hist_rec_tab.NEW_ATTRIBUTE5(i)	   :=  p_party_hist_tbl(i).NEW_ATTRIBUTE5;
      p_party_hist_rec_tab.OLD_ATTRIBUTE6(i)	   :=  p_party_hist_tbl(i).OLD_ATTRIBUTE6;
      p_party_hist_rec_tab.NEW_ATTRIBUTE6(i)	   :=  p_party_hist_tbl(i).NEW_ATTRIBUTE6;
      p_party_hist_rec_tab.OLD_ATTRIBUTE7(i)	   :=  p_party_hist_tbl(i).OLD_ATTRIBUTE7;
      p_party_hist_rec_tab.NEW_ATTRIBUTE7(i)	   :=  p_party_hist_tbl(i).NEW_ATTRIBUTE7;
      p_party_hist_rec_tab.OLD_ATTRIBUTE8(i)	   :=  p_party_hist_tbl(i).OLD_ATTRIBUTE8;
      p_party_hist_rec_tab.NEW_ATTRIBUTE8(i)	   :=  p_party_hist_tbl(i).NEW_ATTRIBUTE8;
      p_party_hist_rec_tab.OLD_ATTRIBUTE9(i)	   :=  p_party_hist_tbl(i).OLD_ATTRIBUTE9;
      p_party_hist_rec_tab.NEW_ATTRIBUTE9(i)	   :=  p_party_hist_tbl(i).NEW_ATTRIBUTE9;
      p_party_hist_rec_tab.OLD_ATTRIBUTE10(i)	   :=  p_party_hist_tbl(i).OLD_ATTRIBUTE10;
      p_party_hist_rec_tab.NEW_ATTRIBUTE10(i)	   :=  p_party_hist_tbl(i).NEW_ATTRIBUTE10;
      p_party_hist_rec_tab.OLD_ATTRIBUTE11(i)	   :=  p_party_hist_tbl(i).OLD_ATTRIBUTE11;
      p_party_hist_rec_tab.NEW_ATTRIBUTE11(i)	   :=  p_party_hist_tbl(i).NEW_ATTRIBUTE11;
      p_party_hist_rec_tab.OLD_ATTRIBUTE12(i)	   :=  p_party_hist_tbl(i).OLD_ATTRIBUTE12;
      p_party_hist_rec_tab.NEW_ATTRIBUTE12(i)	   :=  p_party_hist_tbl(i).NEW_ATTRIBUTE12;
      p_party_hist_rec_tab.OLD_ATTRIBUTE13(i)	   :=  p_party_hist_tbl(i).OLD_ATTRIBUTE13;
      p_party_hist_rec_tab.NEW_ATTRIBUTE13(i)	   :=  p_party_hist_tbl(i).NEW_ATTRIBUTE13;
      p_party_hist_rec_tab.OLD_ATTRIBUTE14(i)	   :=  p_party_hist_tbl(i).OLD_ATTRIBUTE14;
      p_party_hist_rec_tab.NEW_ATTRIBUTE14(i)	   :=  p_party_hist_tbl(i).NEW_ATTRIBUTE14;
      p_party_hist_rec_tab.OLD_ATTRIBUTE15(i)	   :=  p_party_hist_tbl(i).OLD_ATTRIBUTE15;
      p_party_hist_rec_tab.NEW_ATTRIBUTE15(i)	   :=  p_party_hist_tbl(i).NEW_ATTRIBUTE15;
      p_party_hist_rec_tab.FULL_DUMP_FLAG(i)	   :=  p_party_hist_tbl(i).FULL_DUMP_FLAG;
      p_party_hist_rec_tab.OBJECT_VERSION_NUMBER(i)	   :=  p_party_hist_tbl(i).OBJECT_VERSION_NUMBER;
      p_party_hist_rec_tab.OLD_PREFERRED_FLAG(i)	   :=  p_party_hist_tbl(i).OLD_PREFERRED_FLAG;
      p_party_hist_rec_tab.NEW_PREFERRED_FLAG(i)	   :=  p_party_hist_tbl(i).NEW_PREFERRED_FLAG;
      p_party_hist_rec_tab.OLD_PRIMARY_FLAG(i)	   :=  p_party_hist_tbl(i).OLD_PRIMARY_FLAG;
      p_party_hist_rec_tab.NEW_PRIMARY_FLAG(i)	   :=  p_party_hist_tbl(i).NEW_PRIMARY_FLAG;
      p_party_hist_rec_tab.old_party_number(i)	   :=  p_party_hist_tbl(i).old_party_number;
      p_party_hist_rec_tab.old_party_name(i)	   :=  p_party_hist_tbl(i).old_party_name;
      p_party_hist_rec_tab.old_party_type(i)	   :=  p_party_hist_tbl(i).old_party_type;
      p_party_hist_rec_tab.old_contact_party_number(i)	   :=  p_party_hist_tbl(i).old_contact_party_number;
      p_party_hist_rec_tab.old_contact_party_name(i)	   :=  p_party_hist_tbl(i).old_contact_party_name;
      p_party_hist_rec_tab.old_contact_party_type(i)	   :=  p_party_hist_tbl(i).old_contact_party_type;
      p_party_hist_rec_tab.old_contact_address1(i)	   :=  p_party_hist_tbl(i).old_contact_address1;
      p_party_hist_rec_tab.old_contact_address2(i)	   :=  p_party_hist_tbl(i).old_contact_address2;
      p_party_hist_rec_tab.old_contact_address3(i)	   :=  p_party_hist_tbl(i).old_contact_address3;
      p_party_hist_rec_tab.old_contact_address4(i)	   :=  p_party_hist_tbl(i).old_contact_address4;
      p_party_hist_rec_tab.old_contact_city(i)	   :=  p_party_hist_tbl(i).old_contact_city;
      p_party_hist_rec_tab.old_contact_state(i)	   :=  p_party_hist_tbl(i).old_contact_state;
      p_party_hist_rec_tab.old_contact_postal_code(i)	   :=  p_party_hist_tbl(i).old_contact_postal_code;
      p_party_hist_rec_tab.old_contact_country(i)	   :=  p_party_hist_tbl(i).old_contact_country;
      p_party_hist_rec_tab.old_contact_work_phone_num(i)  :=  p_party_hist_tbl(i).old_contact_work_phone_num;
      p_party_hist_rec_tab.old_contact_email_address(i)	   :=  p_party_hist_tbl(i).old_contact_email_address;
      p_party_hist_rec_tab.new_party_number(i)	   :=  p_party_hist_tbl(i).new_party_number;
      p_party_hist_rec_tab.new_party_name(i)	   :=  p_party_hist_tbl(i).new_party_name;
      p_party_hist_rec_tab.new_party_type(i)	   :=  p_party_hist_tbl(i).new_party_type;
      p_party_hist_rec_tab.new_contact_party_number(i)	   :=  p_party_hist_tbl(i).new_contact_party_number;
      p_party_hist_rec_tab.new_contact_party_name(i)	   :=  p_party_hist_tbl(i).new_contact_party_name;
      p_party_hist_rec_tab.new_contact_party_type(i)	   :=  p_party_hist_tbl(i).new_contact_party_type;
      p_party_hist_rec_tab.new_contact_address1(i)	   :=  p_party_hist_tbl(i).new_contact_address1;
      p_party_hist_rec_tab.new_contact_address2(i)	   :=  p_party_hist_tbl(i).new_contact_address2;
      p_party_hist_rec_tab.new_contact_address3(i)	   :=  p_party_hist_tbl(i).new_contact_address3;
      p_party_hist_rec_tab.new_contact_address4(i)	   :=  p_party_hist_tbl(i).new_contact_address4;
      p_party_hist_rec_tab.new_contact_city(i)	   :=  p_party_hist_tbl(i).new_contact_city;
      p_party_hist_rec_tab.new_contact_state(i)	   :=  p_party_hist_tbl(i).new_contact_state;
      p_party_hist_rec_tab.new_contact_postal_code(i)	   :=  p_party_hist_tbl(i).new_contact_postal_code;
      p_party_hist_rec_tab.new_contact_country(i)	   :=  p_party_hist_tbl(i).new_contact_country;
      p_party_hist_rec_tab.new_contact_work_phone_num(i)  :=  p_party_hist_tbl(i).new_contact_work_phone_num;
      p_party_hist_rec_tab.new_contact_email_address(i)	   :=  p_party_hist_tbl(i).new_contact_email_address;
      p_party_hist_rec_tab.INSTANCE_ID(i)	   :=  p_party_hist_tbl(i).INSTANCE_ID;
   END LOOP;
END Build_Party_Hist_Rec_of_Table;
--
PROCEDURE Build_Acct_Rec_of_Table
   (
     p_account_tbl        IN     csi_datastructures_pub.party_account_tbl
    ,p_account_rec_tab    IN OUT NOCOPY  csi_item_instance_grp.account_rec_tab
   ) IS
BEGIN
   FOR i in p_account_tbl.FIRST .. p_account_tbl.LAST LOOP
      p_account_rec_tab.ip_account_id(i)	 := p_account_tbl(i).ip_account_id;
      p_account_rec_tab.parent_tbl_index(i)	 := p_account_tbl(i).parent_tbl_index;
      p_account_rec_tab.instance_party_id(i)	 := p_account_tbl(i).instance_party_id;
      p_account_rec_tab.party_account_id(i)	 := p_account_tbl(i).party_account_id;
      p_account_rec_tab.relationship_type_code(i)	 := p_account_tbl(i).relationship_type_code;
      p_account_rec_tab.bill_to_address(i)	 := p_account_tbl(i).bill_to_address;
      p_account_rec_tab.ship_to_address(i)	 := p_account_tbl(i).ship_to_address;
      p_account_rec_tab.active_start_date(i)	 := p_account_tbl(i).active_start_date;
      p_account_rec_tab.active_end_date(i)	 := p_account_tbl(i).active_end_date;
      p_account_rec_tab.context(i)	 := p_account_tbl(i).context;
      p_account_rec_tab.attribute1(i)	 := p_account_tbl(i).attribute1;
      p_account_rec_tab.attribute2(i)	 := p_account_tbl(i).attribute2;
      p_account_rec_tab.attribute3(i)	 := p_account_tbl(i).attribute3;
      p_account_rec_tab.attribute4(i)	 := p_account_tbl(i).attribute4;
      p_account_rec_tab.attribute5(i)	 := p_account_tbl(i).attribute5;
      p_account_rec_tab.attribute6(i)	 := p_account_tbl(i).attribute6;
      p_account_rec_tab.attribute7(i)	 := p_account_tbl(i).attribute7;
      p_account_rec_tab.attribute8(i)	 := p_account_tbl(i).attribute8;
      p_account_rec_tab.attribute9(i)	 := p_account_tbl(i).attribute9;
      p_account_rec_tab.attribute10(i)	 := p_account_tbl(i).attribute10;
      p_account_rec_tab.attribute11(i)	 := p_account_tbl(i).attribute11;
      p_account_rec_tab.attribute12(i)	 := p_account_tbl(i).attribute12;
      p_account_rec_tab.attribute13(i)	 := p_account_tbl(i).attribute13;
      p_account_rec_tab.attribute14(i)	 := p_account_tbl(i).attribute14;
      p_account_rec_tab.attribute15(i)	 := p_account_tbl(i).attribute15;
      p_account_rec_tab.object_version_number(i)	 := p_account_tbl(i).object_version_number;
      p_account_rec_tab.call_contracts(i)	 := p_account_tbl(i).call_contracts;
      p_account_rec_tab.vld_organization_id(i)	 := p_account_tbl(i).vld_organization_id;
      p_account_rec_tab.expire_flag(i)	 := p_account_tbl(i).expire_flag;
      p_account_rec_tab.grp_call_contracts(i)	 := p_account_tbl(i).grp_call_contracts;
   END LOOP;
END Build_Acct_Rec_of_Table;
--
PROCEDURE Build_Acct_Hist_Rec_of_Table
   (
     p_acct_hist_tbl      IN     csi_datastructures_pub.account_history_tbl
    ,p_acct_hist_rec_tab  IN OUT NOCOPY  csi_item_instance_grp.account_history_rec_tab
   ) IS
BEGIN
   FOR i in p_acct_hist_tbl.FIRST .. p_acct_hist_tbl.LAST LOOP
      p_acct_hist_rec_tab.IP_ACCOUNT_HISTORY_ID(i)	 := p_acct_hist_tbl(i).IP_ACCOUNT_HISTORY_ID;
      p_acct_hist_rec_tab.IP_ACCOUNT_ID(i)	 := p_acct_hist_tbl(i).IP_ACCOUNT_ID;
      p_acct_hist_rec_tab.TRANSACTION_ID(i)	 := p_acct_hist_tbl(i).TRANSACTION_ID;
      p_acct_hist_rec_tab.OLD_PARTY_ACCOUNT_ID(i)	 := p_acct_hist_tbl(i).OLD_PARTY_ACCOUNT_ID;
      p_acct_hist_rec_tab.NEW_PARTY_ACCOUNT_ID(i)	 := p_acct_hist_tbl(i).NEW_PARTY_ACCOUNT_ID;
      p_acct_hist_rec_tab.OLD_RELATIONSHIP_TYPE_CODE(i)	 := p_acct_hist_tbl(i).OLD_RELATIONSHIP_TYPE_CODE;
      p_acct_hist_rec_tab.NEW_RELATIONSHIP_TYPE_CODE(i)	 := p_acct_hist_tbl(i).NEW_RELATIONSHIP_TYPE_CODE;
      p_acct_hist_rec_tab.OLD_ACTIVE_START_DATE(i)	 := p_acct_hist_tbl(i).OLD_ACTIVE_START_DATE;
      p_acct_hist_rec_tab.NEW_ACTIVE_START_DATE(i)	 := p_acct_hist_tbl(i).NEW_ACTIVE_START_DATE;
      p_acct_hist_rec_tab.OLD_ACTIVE_END_DATE(i)	 := p_acct_hist_tbl(i).OLD_ACTIVE_END_DATE;
      p_acct_hist_rec_tab.NEW_ACTIVE_END_DATE(i)	 := p_acct_hist_tbl(i).NEW_ACTIVE_END_DATE;
      p_acct_hist_rec_tab.OLD_CONTEXT(i)	 := p_acct_hist_tbl(i).OLD_CONTEXT;
      p_acct_hist_rec_tab.NEW_CONTEXT(i)	 := p_acct_hist_tbl(i).NEW_CONTEXT;
      p_acct_hist_rec_tab.OLD_ATTRIBUTE1(i)	 := p_acct_hist_tbl(i).OLD_ATTRIBUTE1;
      p_acct_hist_rec_tab.NEW_ATTRIBUTE1(i)	 := p_acct_hist_tbl(i).NEW_ATTRIBUTE1;
      p_acct_hist_rec_tab.OLD_ATTRIBUTE2(i)	 := p_acct_hist_tbl(i).OLD_ATTRIBUTE2;
      p_acct_hist_rec_tab.NEW_ATTRIBUTE2(i)	 := p_acct_hist_tbl(i).NEW_ATTRIBUTE2;
      p_acct_hist_rec_tab.OLD_ATTRIBUTE3(i)	 := p_acct_hist_tbl(i).OLD_ATTRIBUTE3;
      p_acct_hist_rec_tab.NEW_ATTRIBUTE3(i)	 := p_acct_hist_tbl(i).NEW_ATTRIBUTE3;
      p_acct_hist_rec_tab.OLD_ATTRIBUTE4(i)	 := p_acct_hist_tbl(i).OLD_ATTRIBUTE4;
      p_acct_hist_rec_tab.NEW_ATTRIBUTE4(i)	 := p_acct_hist_tbl(i).NEW_ATTRIBUTE4;
      p_acct_hist_rec_tab.OLD_ATTRIBUTE5(i)	 := p_acct_hist_tbl(i).OLD_ATTRIBUTE5;
      p_acct_hist_rec_tab.NEW_ATTRIBUTE5(i)	 := p_acct_hist_tbl(i).NEW_ATTRIBUTE5;
      p_acct_hist_rec_tab.OLD_ATTRIBUTE6(i)	 := p_acct_hist_tbl(i).OLD_ATTRIBUTE6;
      p_acct_hist_rec_tab.NEW_ATTRIBUTE6(i)	 := p_acct_hist_tbl(i).NEW_ATTRIBUTE6;
      p_acct_hist_rec_tab.OLD_ATTRIBUTE7(i)	 := p_acct_hist_tbl(i).OLD_ATTRIBUTE7;
      p_acct_hist_rec_tab.NEW_ATTRIBUTE7(i)	 := p_acct_hist_tbl(i).NEW_ATTRIBUTE7;
      p_acct_hist_rec_tab.OLD_ATTRIBUTE8(i)	 := p_acct_hist_tbl(i).OLD_ATTRIBUTE8;
      p_acct_hist_rec_tab.NEW_ATTRIBUTE8(i)	 := p_acct_hist_tbl(i).NEW_ATTRIBUTE8;
      p_acct_hist_rec_tab.OLD_ATTRIBUTE9(i)	 := p_acct_hist_tbl(i).OLD_ATTRIBUTE9;
      p_acct_hist_rec_tab.NEW_ATTRIBUTE9(i)	 := p_acct_hist_tbl(i).NEW_ATTRIBUTE9;
      p_acct_hist_rec_tab.OLD_ATTRIBUTE10(i)	 := p_acct_hist_tbl(i).OLD_ATTRIBUTE10;
      p_acct_hist_rec_tab.NEW_ATTRIBUTE10(i)	 := p_acct_hist_tbl(i).NEW_ATTRIBUTE10;
      p_acct_hist_rec_tab.OLD_ATTRIBUTE11(i)	 := p_acct_hist_tbl(i).OLD_ATTRIBUTE11;
      p_acct_hist_rec_tab.NEW_ATTRIBUTE11(i)	 := p_acct_hist_tbl(i).NEW_ATTRIBUTE11;
      p_acct_hist_rec_tab.OLD_ATTRIBUTE12(i)	 := p_acct_hist_tbl(i).OLD_ATTRIBUTE12;
      p_acct_hist_rec_tab.NEW_ATTRIBUTE12(i)	 := p_acct_hist_tbl(i).NEW_ATTRIBUTE12;
      p_acct_hist_rec_tab.OLD_ATTRIBUTE13(i)	 := p_acct_hist_tbl(i).OLD_ATTRIBUTE13;
      p_acct_hist_rec_tab.NEW_ATTRIBUTE13(i)	 := p_acct_hist_tbl(i).NEW_ATTRIBUTE13;
      p_acct_hist_rec_tab.OLD_ATTRIBUTE14(i)	 := p_acct_hist_tbl(i).OLD_ATTRIBUTE14;
      p_acct_hist_rec_tab.NEW_ATTRIBUTE14(i)	 := p_acct_hist_tbl(i).NEW_ATTRIBUTE14;
      p_acct_hist_rec_tab.OLD_ATTRIBUTE15(i)	 := p_acct_hist_tbl(i).OLD_ATTRIBUTE15;
      p_acct_hist_rec_tab.NEW_ATTRIBUTE15(i)	 := p_acct_hist_tbl(i).NEW_ATTRIBUTE15;
      p_acct_hist_rec_tab.FULL_DUMP_FLAG(i)	 := p_acct_hist_tbl(i).FULL_DUMP_FLAG;
      p_acct_hist_rec_tab.OBJECT_VERSION_NUMBER(i)	 := p_acct_hist_tbl(i).OBJECT_VERSION_NUMBER;
      p_acct_hist_rec_tab.OLD_BILL_TO_ADDRESS(i)	 := p_acct_hist_tbl(i).OLD_BILL_TO_ADDRESS;
      p_acct_hist_rec_tab.NEW_BILL_TO_ADDRESS(i)	 := p_acct_hist_tbl(i).NEW_BILL_TO_ADDRESS;
      p_acct_hist_rec_tab.OLD_SHIP_TO_ADDRESS(i)	 := p_acct_hist_tbl(i).OLD_SHIP_TO_ADDRESS;
      p_acct_hist_rec_tab.NEW_SHIP_TO_ADDRESS(i)	 := p_acct_hist_tbl(i).NEW_SHIP_TO_ADDRESS;
      p_acct_hist_rec_tab.old_party_account_number(i)	 := p_acct_hist_tbl(i).old_party_account_number;
      p_acct_hist_rec_tab.old_party_account_name(i)	 := p_acct_hist_tbl(i).old_party_account_name;
      p_acct_hist_rec_tab.old_bill_to_location(i)	 := p_acct_hist_tbl(i).old_bill_to_location;
      p_acct_hist_rec_tab.old_ship_to_location(i)	 := p_acct_hist_tbl(i).old_ship_to_location;
      p_acct_hist_rec_tab.new_party_account_number(i)	 := p_acct_hist_tbl(i).new_party_account_number;
      p_acct_hist_rec_tab.new_party_account_name(i)	 := p_acct_hist_tbl(i).new_party_account_name;
      p_acct_hist_rec_tab.new_bill_to_location(i)	 := p_acct_hist_tbl(i).new_bill_to_location;
      p_acct_hist_rec_tab.new_ship_to_location(i)	 := p_acct_hist_tbl(i).new_ship_to_location;
      p_acct_hist_rec_tab.INSTANCE_ID(i)	 := p_acct_hist_tbl(i).INSTANCE_ID;
   END LOOP;
END Build_Acct_Hist_Rec_of_Table;
--
PROCEDURE Build_Owner_Pty_Acct_Rec_Table
   (
     p_owner_pty_acct_tbl     IN     csi_item_instance_pvt.owner_pty_acct_tbl
    ,p_owner_pty_acct_rec_tab IN OUT NOCOPY  csi_item_instance_pvt.owner_pty_acct_rec_tab
   ) IS
BEGIN
   FOR i in p_owner_pty_acct_tbl.FIRST .. p_owner_pty_acct_tbl.LAST LOOP
      p_owner_pty_acct_rec_tab.instance_id(i) := p_owner_pty_acct_tbl(i).instance_id;
      p_owner_pty_acct_rec_tab.party_source_table(i) := p_owner_pty_acct_tbl(i).party_source_table;
      p_owner_pty_acct_rec_tab.party_id(i) := p_owner_pty_acct_tbl(i).party_id;
      p_owner_pty_acct_rec_tab.account_id(i) := p_owner_pty_acct_tbl(i).account_id;
   END LOOP;
END Build_Owner_Pty_Acct_Rec_Table;
--
PROCEDURE Build_Txn_Rec_of_Table
   (
     p_txn_tbl        IN     csi_datastructures_pub.transaction_tbl
    ,p_txn_rec_tab    IN OUT NOCOPY  csi_item_instance_grp.transaction_rec_tab
   ) IS
BEGIN
   FOR i in p_txn_tbl.FIRST .. p_txn_tbl.LAST LOOP
      p_txn_rec_tab.TRANSACTION_ID(i)	 := p_txn_tbl(i).TRANSACTION_ID;
      p_txn_rec_tab.TRANSACTION_DATE(i)	 := p_txn_tbl(i).TRANSACTION_DATE;
      p_txn_rec_tab.SOURCE_TRANSACTION_DATE(i)	 := p_txn_tbl(i).SOURCE_TRANSACTION_DATE;
      p_txn_rec_tab.TRANSACTION_TYPE_ID(i)	 := p_txn_tbl(i).TRANSACTION_TYPE_ID;
      p_txn_rec_tab.TXN_SUB_TYPE_ID(i)	 := p_txn_tbl(i).TXN_SUB_TYPE_ID;
      p_txn_rec_tab.SOURCE_GROUP_REF_ID(i)	 := p_txn_tbl(i).SOURCE_GROUP_REF_ID;
      p_txn_rec_tab.SOURCE_GROUP_REF(i)	 := p_txn_tbl(i).SOURCE_GROUP_REF;
      p_txn_rec_tab.SOURCE_HEADER_REF_ID(i)	 := p_txn_tbl(i).SOURCE_HEADER_REF_ID;
      p_txn_rec_tab.SOURCE_HEADER_REF(i)	 := p_txn_tbl(i).SOURCE_HEADER_REF;
      p_txn_rec_tab.SOURCE_LINE_REF_ID(i)	 := p_txn_tbl(i).SOURCE_LINE_REF_ID;
      p_txn_rec_tab.SOURCE_LINE_REF(i)	 := p_txn_tbl(i).SOURCE_LINE_REF;
      p_txn_rec_tab.SOURCE_DIST_REF_ID1(i)	 := p_txn_tbl(i).SOURCE_DIST_REF_ID1;
      p_txn_rec_tab.SOURCE_DIST_REF_ID2(i)	 := p_txn_tbl(i).SOURCE_DIST_REF_ID2;
      p_txn_rec_tab.INV_MATERIAL_TRANSACTION_ID(i)	 := p_txn_tbl(i).INV_MATERIAL_TRANSACTION_ID;
      p_txn_rec_tab.TRANSACTION_QUANTITY(i)	 := p_txn_tbl(i).TRANSACTION_QUANTITY;
      p_txn_rec_tab.TRANSACTION_UOM_CODE(i)	 := p_txn_tbl(i).TRANSACTION_UOM_CODE;
      p_txn_rec_tab.TRANSACTED_BY(i)	 := p_txn_tbl(i).TRANSACTED_BY;
      p_txn_rec_tab.TRANSACTION_STATUS_CODE(i)	 := p_txn_tbl(i).TRANSACTION_STATUS_CODE;
      p_txn_rec_tab.TRANSACTION_ACTION_CODE(i)	 := p_txn_tbl(i).TRANSACTION_ACTION_CODE;
      p_txn_rec_tab.MESSAGE_ID(i)	 := p_txn_tbl(i).MESSAGE_ID;
      p_txn_rec_tab.CONTEXT(i)	 := p_txn_tbl(i).CONTEXT;
      p_txn_rec_tab.ATTRIBUTE1(i)	 := p_txn_tbl(i).ATTRIBUTE1;
      p_txn_rec_tab.ATTRIBUTE2(i)	 := p_txn_tbl(i).ATTRIBUTE2;
      p_txn_rec_tab.ATTRIBUTE3(i)	 := p_txn_tbl(i).ATTRIBUTE3;
      p_txn_rec_tab.ATTRIBUTE4(i)	 := p_txn_tbl(i).ATTRIBUTE4;
      p_txn_rec_tab.ATTRIBUTE5(i)	 := p_txn_tbl(i).ATTRIBUTE5;
      p_txn_rec_tab.ATTRIBUTE6(i)	 := p_txn_tbl(i).ATTRIBUTE6;
      p_txn_rec_tab.ATTRIBUTE7(i)	 := p_txn_tbl(i).ATTRIBUTE7;
      p_txn_rec_tab.ATTRIBUTE8(i)	 := p_txn_tbl(i).ATTRIBUTE8;
      p_txn_rec_tab.ATTRIBUTE9(i)	 := p_txn_tbl(i).ATTRIBUTE9;
      p_txn_rec_tab.ATTRIBUTE10(i)	 := p_txn_tbl(i).ATTRIBUTE10;
      p_txn_rec_tab.ATTRIBUTE11(i)	 := p_txn_tbl(i).ATTRIBUTE11;
      p_txn_rec_tab.ATTRIBUTE12(i)	 := p_txn_tbl(i).ATTRIBUTE12;
      p_txn_rec_tab.ATTRIBUTE13(i)	 := p_txn_tbl(i).ATTRIBUTE13;
      p_txn_rec_tab.ATTRIBUTE14(i)	 := p_txn_tbl(i).ATTRIBUTE14;
      p_txn_rec_tab.ATTRIBUTE15(i)	 := p_txn_tbl(i).ATTRIBUTE15;
      p_txn_rec_tab.OBJECT_VERSION_NUMBER(i)	 := p_txn_tbl(i).OBJECT_VERSION_NUMBER;
      p_txn_rec_tab.SPLIT_REASON_CODE(i)	 := p_txn_tbl(i).SPLIT_REASON_CODE;
      p_txn_rec_tab.GL_INTERFACE_STATUS_CODE(i)	 := p_txn_tbl(i).GL_INTERFACE_STATUS_CODE;
   END LOOP;
END Build_Txn_Rec_of_Table;
--
PROCEDURE Build_Org_Rec_of_Table
   (
     p_org_tbl                 IN      csi_datastructures_pub.organization_units_tbl
    ,p_org_units_rec_tab       IN OUT NOCOPY   csi_item_instance_grp.org_units_rec_tab
   ) IS
BEGIN
   FOR i in p_org_tbl.FIRST .. p_org_tbl.LAST LOOP
     p_org_units_rec_tab.instance_ou_id(i)          := p_org_tbl(i).instance_ou_id;
     p_org_units_rec_tab.instance_id(i)	            := p_org_tbl(i).instance_id;
     p_org_units_rec_tab.operating_unit_id(i)       := p_org_tbl(i).operating_unit_id;
     p_org_units_rec_tab.relationship_type_code(i)  := p_org_tbl(i).relationship_type_code;
     p_org_units_rec_tab.active_start_date(i)       := p_org_tbl(i).active_start_date;
     p_org_units_rec_tab.active_end_date(i)         := p_org_tbl(i).active_end_date;
     p_org_units_rec_tab.context(i)	            := p_org_tbl(i).context;
     p_org_units_rec_tab.attribute1(i)	            := p_org_tbl(i).attribute1;
     p_org_units_rec_tab.attribute2(i)	            := p_org_tbl(i).attribute2;
     p_org_units_rec_tab.attribute3(i)	            := p_org_tbl(i).attribute3;
     p_org_units_rec_tab.attribute4(i)	            := p_org_tbl(i).attribute4;
     p_org_units_rec_tab.attribute5(i)	            := p_org_tbl(i).attribute5;
     p_org_units_rec_tab.attribute6(i)	            := p_org_tbl(i).attribute6;
     p_org_units_rec_tab.attribute7(i)	            := p_org_tbl(i).attribute7;
     p_org_units_rec_tab.attribute8(i)	            := p_org_tbl(i).attribute8;
     p_org_units_rec_tab.attribute9(i)	            := p_org_tbl(i).attribute9;
     p_org_units_rec_tab.attribute10(i)	            := p_org_tbl(i).attribute10;
     p_org_units_rec_tab.attribute11(i)	            := p_org_tbl(i).attribute11;
     p_org_units_rec_tab.attribute12(i)	            := p_org_tbl(i).attribute12;
     p_org_units_rec_tab.attribute13(i)	            := p_org_tbl(i).attribute13;
     p_org_units_rec_tab.attribute14(i)	            := p_org_tbl(i).attribute14;
     p_org_units_rec_tab.attribute15(i)	            := p_org_tbl(i).attribute15;
     p_org_units_rec_tab.object_version_number(i)   := p_org_tbl(i).object_version_number;
     p_org_units_rec_tab.parent_tbl_index(i)	    := p_org_tbl(i).parent_tbl_index;
   END LOOP;
END Build_Org_Rec_of_Table;
--
PROCEDURE Build_Org_Hist_Rec_of_Table
  ( p_org_hist_tbl       IN     csi_datastructures_pub.org_units_history_tbl
   ,p_org_hist_rec_tab   IN OUT NOCOPY  csi_item_instance_grp.org_units_history_rec_tab
  ) IS
BEGIN
   FOR i in p_org_hist_tbl.FIRST .. p_org_hist_tbl.LAST LOOP
       p_org_hist_rec_tab.INSTANCE_OU_HISTORY_ID(i)	:= p_org_hist_tbl(i).INSTANCE_OU_HISTORY_ID;
       p_org_hist_rec_tab.INSTANCE_OU_ID(i)	        := p_org_hist_tbl(i).INSTANCE_OU_ID;
       p_org_hist_rec_tab.TRANSACTION_ID(i)	        := p_org_hist_tbl(i).TRANSACTION_ID;
       p_org_hist_rec_tab.OLD_OPERATING_UNIT_ID(i)	:= p_org_hist_tbl(i).OLD_OPERATING_UNIT_ID;
       p_org_hist_rec_tab.NEW_OPERATING_UNIT_ID(i)	:= p_org_hist_tbl(i).NEW_OPERATING_UNIT_ID;
       p_org_hist_rec_tab.OLD_RELATIONSHIP_TYPE_CODE(i)	:= p_org_hist_tbl(i).OLD_RELATIONSHIP_TYPE_CODE;
       p_org_hist_rec_tab.NEW_RELATIONSHIP_TYPE_CODE(i)	:= p_org_hist_tbl(i).NEW_RELATIONSHIP_TYPE_CODE;
       p_org_hist_rec_tab.OLD_ACTIVE_START_DATE(i)	:= p_org_hist_tbl(i).OLD_ACTIVE_START_DATE;
       p_org_hist_rec_tab.NEW_ACTIVE_START_DATE(i)	:= p_org_hist_tbl(i).NEW_ACTIVE_START_DATE;
       p_org_hist_rec_tab.OLD_ACTIVE_END_DATE(i)	:= p_org_hist_tbl(i).OLD_ACTIVE_END_DATE;
       p_org_hist_rec_tab.NEW_ACTIVE_END_DATE(i)	:= p_org_hist_tbl(i).NEW_ACTIVE_END_DATE;
       p_org_hist_rec_tab.OLD_CONTEXT(i)	        := p_org_hist_tbl(i).OLD_CONTEXT;
       p_org_hist_rec_tab.NEW_CONTEXT(i)	        := p_org_hist_tbl(i).NEW_CONTEXT;
       p_org_hist_rec_tab.OLD_ATTRIBUTE1(i)	        := p_org_hist_tbl(i).OLD_ATTRIBUTE1;
       p_org_hist_rec_tab.NEW_ATTRIBUTE1(i)	        := p_org_hist_tbl(i).NEW_ATTRIBUTE1;
       p_org_hist_rec_tab.OLD_ATTRIBUTE2(i)	        := p_org_hist_tbl(i).OLD_ATTRIBUTE2;
       p_org_hist_rec_tab.NEW_ATTRIBUTE2(i)	        := p_org_hist_tbl(i).NEW_ATTRIBUTE2;
       p_org_hist_rec_tab.OLD_ATTRIBUTE3(i)	        := p_org_hist_tbl(i).OLD_ATTRIBUTE3;
       p_org_hist_rec_tab.NEW_ATTRIBUTE3(i)	        := p_org_hist_tbl(i).NEW_ATTRIBUTE3;
       p_org_hist_rec_tab.OLD_ATTRIBUTE4(i)	        := p_org_hist_tbl(i).OLD_ATTRIBUTE4;
       p_org_hist_rec_tab.NEW_ATTRIBUTE4(i)	        := p_org_hist_tbl(i).NEW_ATTRIBUTE4;
       p_org_hist_rec_tab.OLD_ATTRIBUTE5(i)	        := p_org_hist_tbl(i).OLD_ATTRIBUTE5;
       p_org_hist_rec_tab.NEW_ATTRIBUTE5(i)	        := p_org_hist_tbl(i).NEW_ATTRIBUTE5;
       p_org_hist_rec_tab.OLD_ATTRIBUTE6(i)	        := p_org_hist_tbl(i).OLD_ATTRIBUTE6;
       p_org_hist_rec_tab.NEW_ATTRIBUTE6(i)	        := p_org_hist_tbl(i).NEW_ATTRIBUTE6;
       p_org_hist_rec_tab.OLD_ATTRIBUTE7(i)	        := p_org_hist_tbl(i).OLD_ATTRIBUTE7;
       p_org_hist_rec_tab.NEW_ATTRIBUTE7(i)	        := p_org_hist_tbl(i).NEW_ATTRIBUTE7;
       p_org_hist_rec_tab.OLD_ATTRIBUTE8(i)	        := p_org_hist_tbl(i).OLD_ATTRIBUTE8;
       p_org_hist_rec_tab.NEW_ATTRIBUTE8(i)	        := p_org_hist_tbl(i).NEW_ATTRIBUTE8;
       p_org_hist_rec_tab.OLD_ATTRIBUTE9(i)	        := p_org_hist_tbl(i).OLD_ATTRIBUTE9;
       p_org_hist_rec_tab.NEW_ATTRIBUTE9(i)	        := p_org_hist_tbl(i).NEW_ATTRIBUTE9;
       p_org_hist_rec_tab.OLD_ATTRIBUTE10(i)	        := p_org_hist_tbl(i).OLD_ATTRIBUTE10;
       p_org_hist_rec_tab.NEW_ATTRIBUTE10(i)	        := p_org_hist_tbl(i).NEW_ATTRIBUTE10;
       p_org_hist_rec_tab.OLD_ATTRIBUTE11(i)	        := p_org_hist_tbl(i).OLD_ATTRIBUTE11;
       p_org_hist_rec_tab.NEW_ATTRIBUTE11(i)	        := p_org_hist_tbl(i).NEW_ATTRIBUTE11;
       p_org_hist_rec_tab.OLD_ATTRIBUTE12(i)	        := p_org_hist_tbl(i).OLD_ATTRIBUTE12;
       p_org_hist_rec_tab.NEW_ATTRIBUTE12(i)	        := p_org_hist_tbl(i).NEW_ATTRIBUTE12;
       p_org_hist_rec_tab.OLD_ATTRIBUTE13(i)	        := p_org_hist_tbl(i).OLD_ATTRIBUTE13;
       p_org_hist_rec_tab.NEW_ATTRIBUTE13(i)	        := p_org_hist_tbl(i).NEW_ATTRIBUTE13;
       p_org_hist_rec_tab.OLD_ATTRIBUTE14(i)	        := p_org_hist_tbl(i).OLD_ATTRIBUTE14;
       p_org_hist_rec_tab.NEW_ATTRIBUTE14(i)	        := p_org_hist_tbl(i).NEW_ATTRIBUTE14;
       p_org_hist_rec_tab.OLD_ATTRIBUTE15(i)	        := p_org_hist_tbl(i).OLD_ATTRIBUTE15;
       p_org_hist_rec_tab.NEW_ATTRIBUTE15(i)	        := p_org_hist_tbl(i).NEW_ATTRIBUTE15;
       p_org_hist_rec_tab.FULL_DUMP_FLAG(i)	        := p_org_hist_tbl(i).FULL_DUMP_FLAG;
       p_org_hist_rec_tab.OBJECT_VERSION_NUMBER(i)	:= p_org_hist_tbl(i).OBJECT_VERSION_NUMBER;
       p_org_hist_rec_tab.new_operating_unit_name(i)	:= p_org_hist_tbl(i).new_operating_unit_name;
       p_org_hist_rec_tab.old_operating_unit_name(i)	:= p_org_hist_tbl(i).old_operating_unit_name;
       p_org_hist_rec_tab.INSTANCE_ID(i)	        := p_org_hist_tbl(i).INSTANCE_ID;

   END LOOP;
END Build_Org_Hist_Rec_of_Table;
--
PROCEDURE Build_pricing_Rec_of_Table
   (
     p_pricing_tbl           IN      csi_datastructures_pub.pricing_attribs_tbl
    ,p_pricing_rec_tab       IN OUT NOCOPY   csi_item_instance_grp.pricing_attribs_rec_tab
   ) IS
BEGIN
   FOR i in p_pricing_tbl.FIRST .. p_pricing_tbl.LAST LOOP
       p_pricing_rec_tab.pricing_attribute_id(i)    := p_pricing_tbl(i).pricing_attribute_id;
       p_pricing_rec_tab.instance_id(i)	            := p_pricing_tbl(i).instance_id;
       p_pricing_rec_tab.active_start_date(i)	    := p_pricing_tbl(i).active_start_date;
       p_pricing_rec_tab.active_end_date(i)	        := p_pricing_tbl(i).active_end_date;
       p_pricing_rec_tab.pricing_context(i)	        := p_pricing_tbl(i).pricing_context;
       p_pricing_rec_tab.pricing_attribute1(i)	    := p_pricing_tbl(i).pricing_attribute1;
       p_pricing_rec_tab.pricing_attribute2(i)	    := p_pricing_tbl(i).pricing_attribute2;
       p_pricing_rec_tab.pricing_attribute3(i)	    := p_pricing_tbl(i).pricing_attribute3;
       p_pricing_rec_tab.pricing_attribute4(i)	    := p_pricing_tbl(i).pricing_attribute4;
       p_pricing_rec_tab.pricing_attribute5(i)	    := p_pricing_tbl(i).pricing_attribute5;
       p_pricing_rec_tab.pricing_attribute6(i)	    := p_pricing_tbl(i).pricing_attribute6;
       p_pricing_rec_tab.pricing_attribute7(i)	    := p_pricing_tbl(i).pricing_attribute7;
       p_pricing_rec_tab.pricing_attribute8(i) 	    := p_pricing_tbl(i).pricing_attribute8;
       p_pricing_rec_tab.pricing_attribute9(i)	    := p_pricing_tbl(i).pricing_attribute9;
       p_pricing_rec_tab.pricing_attribute10(i)	    := p_pricing_tbl(i).pricing_attribute10;
       p_pricing_rec_tab.pricing_attribute11(i)	    := p_pricing_tbl(i).pricing_attribute11;
       p_pricing_rec_tab.pricing_attribute12(i)	    := p_pricing_tbl(i).pricing_attribute12;
       p_pricing_rec_tab.pricing_attribute13(i)	    := p_pricing_tbl(i).pricing_attribute13;
       p_pricing_rec_tab.pricing_attribute14(i)	    := p_pricing_tbl(i).pricing_attribute14;
       p_pricing_rec_tab.pricing_attribute15(i)	    := p_pricing_tbl(i).pricing_attribute15;
       p_pricing_rec_tab.pricing_attribute16(i)	    := p_pricing_tbl(i).pricing_attribute16;
       p_pricing_rec_tab.pricing_attribute17(i)	    := p_pricing_tbl(i).pricing_attribute17;
       p_pricing_rec_tab.pricing_attribute18(i)	    := p_pricing_tbl(i).pricing_attribute18;
       p_pricing_rec_tab.pricing_attribute19(i)	    := p_pricing_tbl(i).pricing_attribute19;
       p_pricing_rec_tab.pricing_attribute20(i)	    := p_pricing_tbl(i).pricing_attribute20;
       p_pricing_rec_tab.pricing_attribute21(i)	    := p_pricing_tbl(i).pricing_attribute21;
       p_pricing_rec_tab.pricing_attribute22(i)	    := p_pricing_tbl(i).pricing_attribute22;
       p_pricing_rec_tab.pricing_attribute23(i)	    := p_pricing_tbl(i).pricing_attribute23;
       p_pricing_rec_tab.pricing_attribute24(i)	    := p_pricing_tbl(i).pricing_attribute24;
       p_pricing_rec_tab.pricing_attribute25(i)	    := p_pricing_tbl(i).pricing_attribute25;
       p_pricing_rec_tab.pricing_attribute26(i)	    := p_pricing_tbl(i).pricing_attribute26;
       p_pricing_rec_tab.pricing_attribute27(i)	    := p_pricing_tbl(i).pricing_attribute27;
       p_pricing_rec_tab.pricing_attribute28(i)	    := p_pricing_tbl(i).pricing_attribute28;
       p_pricing_rec_tab.pricing_attribute29(i)	    := p_pricing_tbl(i).pricing_attribute29;
       p_pricing_rec_tab.pricing_attribute30(i)	    := p_pricing_tbl(i).pricing_attribute30;
       p_pricing_rec_tab.pricing_attribute31(i)	    := p_pricing_tbl(i).pricing_attribute31;
       p_pricing_rec_tab.pricing_attribute32(i)	    := p_pricing_tbl(i).pricing_attribute32;
       p_pricing_rec_tab.pricing_attribute33(i)     := p_pricing_tbl(i).pricing_attribute33;
       p_pricing_rec_tab.pricing_attribute34(i)	    := p_pricing_tbl(i).pricing_attribute34;
       p_pricing_rec_tab.pricing_attribute35(i)	    := p_pricing_tbl(i).pricing_attribute35;
       p_pricing_rec_tab.pricing_attribute36(i)	    := p_pricing_tbl(i).pricing_attribute36;
       p_pricing_rec_tab.pricing_attribute37(i)	    := p_pricing_tbl(i).pricing_attribute37;
       p_pricing_rec_tab.pricing_attribute38(i)	    := p_pricing_tbl(i).pricing_attribute38;
       p_pricing_rec_tab.pricing_attribute39(i)	    := p_pricing_tbl(i).pricing_attribute39;
       p_pricing_rec_tab.pricing_attribute40(i)	    := p_pricing_tbl(i).pricing_attribute40;
       p_pricing_rec_tab.pricing_attribute41(i)	    := p_pricing_tbl(i).pricing_attribute41;
       p_pricing_rec_tab.pricing_attribute42(i)	    := p_pricing_tbl(i).pricing_attribute42;
       p_pricing_rec_tab.pricing_attribute43(i)     := p_pricing_tbl(i).pricing_attribute43;
       p_pricing_rec_tab.pricing_attribute44(i)	    := p_pricing_tbl(i).pricing_attribute44;
       p_pricing_rec_tab.pricing_attribute45(i)	    := p_pricing_tbl(i).pricing_attribute45;
       p_pricing_rec_tab.pricing_attribute46(i)	    := p_pricing_tbl(i).pricing_attribute46;
       p_pricing_rec_tab.pricing_attribute47(i)	    := p_pricing_tbl(i).pricing_attribute47;
       p_pricing_rec_tab.pricing_attribute48(i)	    := p_pricing_tbl(i).pricing_attribute48;
       p_pricing_rec_tab.pricing_attribute49(i)	    := p_pricing_tbl(i).pricing_attribute49;
       p_pricing_rec_tab.pricing_attribute50(i)	    := p_pricing_tbl(i).pricing_attribute50;
       p_pricing_rec_tab.pricing_attribute51(i)	    := p_pricing_tbl(i).pricing_attribute51;
       p_pricing_rec_tab.pricing_attribute52(i)	    := p_pricing_tbl(i).pricing_attribute52;
       p_pricing_rec_tab.pricing_attribute53(i)	    := p_pricing_tbl(i).pricing_attribute53;
       p_pricing_rec_tab.pricing_attribute54(i)	    := p_pricing_tbl(i).pricing_attribute54;
       p_pricing_rec_tab.pricing_attribute55(i)	    := p_pricing_tbl(i).pricing_attribute55;
       p_pricing_rec_tab.pricing_attribute56(i)	    := p_pricing_tbl(i).pricing_attribute56;
       p_pricing_rec_tab.pricing_attribute57(i)	    := p_pricing_tbl(i).pricing_attribute57;
       p_pricing_rec_tab.pricing_attribute58(i)	    := p_pricing_tbl(i).pricing_attribute58;
       p_pricing_rec_tab.pricing_attribute59(i)	    := p_pricing_tbl(i).pricing_attribute59;
       p_pricing_rec_tab.pricing_attribute60(i)	    := p_pricing_tbl(i).pricing_attribute60;
       p_pricing_rec_tab.pricing_attribute61(i)	    := p_pricing_tbl(i).pricing_attribute61;
       p_pricing_rec_tab.pricing_attribute62(i)	    := p_pricing_tbl(i).pricing_attribute62;
       p_pricing_rec_tab.pricing_attribute63(i)	    := p_pricing_tbl(i).pricing_attribute63;
       p_pricing_rec_tab.pricing_attribute64(i)	    := p_pricing_tbl(i).pricing_attribute64;
       p_pricing_rec_tab.pricing_attribute65(i)	    := p_pricing_tbl(i).pricing_attribute65;
       p_pricing_rec_tab.pricing_attribute66(i)	    := p_pricing_tbl(i).pricing_attribute66;
       p_pricing_rec_tab.pricing_attribute67(i)	    := p_pricing_tbl(i).pricing_attribute67;
       p_pricing_rec_tab.pricing_attribute68(i)	    := p_pricing_tbl(i).pricing_attribute68;
       p_pricing_rec_tab.pricing_attribute69(i)	    := p_pricing_tbl(i).pricing_attribute69;
       p_pricing_rec_tab.pricing_attribute70(i)	    := p_pricing_tbl(i).pricing_attribute70;
       p_pricing_rec_tab.pricing_attribute71(i)	    := p_pricing_tbl(i).pricing_attribute71;
       p_pricing_rec_tab.pricing_attribute72(i)	    := p_pricing_tbl(i).pricing_attribute72;
       p_pricing_rec_tab.pricing_attribute73(i)	    := p_pricing_tbl(i).pricing_attribute73;
       p_pricing_rec_tab.pricing_attribute74(i)	    := p_pricing_tbl(i).pricing_attribute74;
       p_pricing_rec_tab.pricing_attribute75(i)	    := p_pricing_tbl(i).pricing_attribute75;
       p_pricing_rec_tab.pricing_attribute76(i)	    := p_pricing_tbl(i).pricing_attribute76;
       p_pricing_rec_tab.pricing_attribute77(i)	    := p_pricing_tbl(i).pricing_attribute77;
       p_pricing_rec_tab.pricing_attribute78(i)	    := p_pricing_tbl(i).pricing_attribute78;
       p_pricing_rec_tab.pricing_attribute79(i)	    := p_pricing_tbl(i).pricing_attribute79;
       p_pricing_rec_tab.pricing_attribute80(i)	    := p_pricing_tbl(i).pricing_attribute80;
       p_pricing_rec_tab.pricing_attribute81(i)	    := p_pricing_tbl(i).pricing_attribute81;
       p_pricing_rec_tab.pricing_attribute82(i)	    := p_pricing_tbl(i).pricing_attribute82;
       p_pricing_rec_tab.pricing_attribute83(i)	    := p_pricing_tbl(i).pricing_attribute83;
       p_pricing_rec_tab.pricing_attribute84(i)	    := p_pricing_tbl(i).pricing_attribute84;
       p_pricing_rec_tab.pricing_attribute85(i)	    := p_pricing_tbl(i).pricing_attribute85;
       p_pricing_rec_tab.pricing_attribute86(i)	    := p_pricing_tbl(i).pricing_attribute86;
       p_pricing_rec_tab.pricing_attribute87(i)	    := p_pricing_tbl(i).pricing_attribute87;
       p_pricing_rec_tab.pricing_attribute88(i)	    := p_pricing_tbl(i).pricing_attribute88;
       p_pricing_rec_tab.pricing_attribute89(i)	    := p_pricing_tbl(i).pricing_attribute89;
       p_pricing_rec_tab.pricing_attribute90(i)	    := p_pricing_tbl(i).pricing_attribute90;
       p_pricing_rec_tab.pricing_attribute91(i)	    := p_pricing_tbl(i).pricing_attribute91;
       p_pricing_rec_tab.pricing_attribute92(i)	    := p_pricing_tbl(i).pricing_attribute92;
       p_pricing_rec_tab.pricing_attribute93(i)	    := p_pricing_tbl(i).pricing_attribute93;
       p_pricing_rec_tab.pricing_attribute94(i)	    := p_pricing_tbl(i).pricing_attribute94;
       p_pricing_rec_tab.pricing_attribute95(i)	    := p_pricing_tbl(i).pricing_attribute95;
       p_pricing_rec_tab.pricing_attribute96(i)	    := p_pricing_tbl(i).pricing_attribute96;
       p_pricing_rec_tab.pricing_attribute97(i)	    := p_pricing_tbl(i).pricing_attribute97;
       p_pricing_rec_tab.pricing_attribute98(i)	    := p_pricing_tbl(i).pricing_attribute98;
       p_pricing_rec_tab.pricing_attribute99(i)	    := p_pricing_tbl(i).pricing_attribute99;
       p_pricing_rec_tab.pricing_attribute100(i)    := p_pricing_tbl(i).pricing_attribute100;
       p_pricing_rec_tab.context(i)	                := p_pricing_tbl(i).context;
       p_pricing_rec_tab.attribute1(i)	            := p_pricing_tbl(i).attribute1;
       p_pricing_rec_tab.attribute2(i)	            := p_pricing_tbl(i).attribute2;
       p_pricing_rec_tab.attribute3(i)	            := p_pricing_tbl(i).attribute3;
       p_pricing_rec_tab.attribute4(i)	            := p_pricing_tbl(i).attribute4;
       p_pricing_rec_tab.attribute5(i)	            := p_pricing_tbl(i).attribute5;
       p_pricing_rec_tab.attribute6(i)	            := p_pricing_tbl(i).attribute6;
       p_pricing_rec_tab.attribute7(i)	            := p_pricing_tbl(i).attribute7;
       p_pricing_rec_tab.attribute8(i)	            := p_pricing_tbl(i).attribute8;
       p_pricing_rec_tab.attribute9(i)	            := p_pricing_tbl(i).attribute9;
       p_pricing_rec_tab.attribute10(i)	            := p_pricing_tbl(i).attribute10;
       p_pricing_rec_tab.attribute11(i)	            := p_pricing_tbl(i).attribute11;
       p_pricing_rec_tab.attribute12(i)	            := p_pricing_tbl(i).attribute12;
       p_pricing_rec_tab.attribute13(i)	            := p_pricing_tbl(i).attribute13;
       p_pricing_rec_tab.attribute14(i)	            := p_pricing_tbl(i).attribute14;
       p_pricing_rec_tab.attribute15(i)	            := p_pricing_tbl(i).attribute15;
       p_pricing_rec_tab.object_version_number(i)   := p_pricing_tbl(i).object_version_number;
       p_pricing_rec_tab.parent_tbl_index(i)	    := p_pricing_tbl(i).parent_tbl_index;
   END LOOP;
END Build_pricing_Rec_of_Table;
--
PROCEDURE Build_pricing_Hist_Rec_Table
  ( p_pricing_hist_tbl       IN     csi_datastructures_pub.pricing_history_tbl
   ,p_pricing_hist_rec_tab   IN OUT NOCOPY  csi_item_instance_grp.pricing_attribs_hist_rec_tab
  ) IS
BEGIN
   FOR i in p_pricing_hist_tbl.FIRST .. p_pricing_hist_tbl.LAST LOOP
      p_pricing_hist_rec_tab.PRICE_ATTRIB_HISTORY_ID(i):= p_pricing_hist_tbl(i).PRICE_ATTRIB_HISTORY_ID;
      p_pricing_hist_rec_tab.PRICING_ATTRIBUTE_ID(i):= p_pricing_hist_tbl(i).PRICING_ATTRIBUTE_ID;
      p_pricing_hist_rec_tab.TRANSACTION_ID(i)         := p_pricing_hist_tbl(i).TRANSACTION_ID;
      p_pricing_hist_rec_tab.OLD_PRICING_CONTEXT(i):= p_pricing_hist_tbl(i).OLD_PRICING_CONTEXT;
      p_pricing_hist_rec_tab.NEW_PRICING_CONTEXT(i):= p_pricing_hist_tbl(i).NEW_PRICING_CONTEXT;
      p_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE1(i):= p_pricing_hist_tbl(i).OLD_PRICING_ATTRIBUTE1;
      p_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE1(i):= p_pricing_hist_tbl(i).NEW_PRICING_ATTRIBUTE1;
      p_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE2(i):= p_pricing_hist_tbl(i).OLD_PRICING_ATTRIBUTE2;
      p_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE2(i):= p_pricing_hist_tbl(i).NEW_PRICING_ATTRIBUTE2;
      p_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE3(i):= p_pricing_hist_tbl(i).OLD_PRICING_ATTRIBUTE3;
      p_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE3(i):= p_pricing_hist_tbl(i).NEW_PRICING_ATTRIBUTE3;
      p_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE4(i):= p_pricing_hist_tbl(i).OLD_PRICING_ATTRIBUTE4;
      p_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE4(i):= p_pricing_hist_tbl(i).NEW_PRICING_ATTRIBUTE4;
      p_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE5(i):= p_pricing_hist_tbl(i).OLD_PRICING_ATTRIBUTE5;
      p_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE5(i):= p_pricing_hist_tbl(i).NEW_PRICING_ATTRIBUTE5;
      p_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE6(i):= p_pricing_hist_tbl(i).OLD_PRICING_ATTRIBUTE6;
      p_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE6(i):= p_pricing_hist_tbl(i).NEW_PRICING_ATTRIBUTE6;
      p_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE7(i):= p_pricing_hist_tbl(i).OLD_PRICING_ATTRIBUTE7;
      p_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE7(i):= p_pricing_hist_tbl(i).NEW_PRICING_ATTRIBUTE7;
      p_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE8(i):= p_pricing_hist_tbl(i).OLD_PRICING_ATTRIBUTE8;
      p_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE8(i):= p_pricing_hist_tbl(i).NEW_PRICING_ATTRIBUTE8;
      p_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE9(i):= p_pricing_hist_tbl(i).OLD_PRICING_ATTRIBUTE9;
      p_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE9(i):= p_pricing_hist_tbl(i).NEW_PRICING_ATTRIBUTE9;
      p_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE10(i):= p_pricing_hist_tbl(i).OLD_PRICING_ATTRIBUTE10;
      p_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE10(i):= p_pricing_hist_tbl(i).NEW_PRICING_ATTRIBUTE10;
      p_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE11(i):= p_pricing_hist_tbl(i).OLD_PRICING_ATTRIBUTE11;
      p_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE11(i):= p_pricing_hist_tbl(i).NEW_PRICING_ATTRIBUTE11;
      p_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE12(i):= p_pricing_hist_tbl(i).OLD_PRICING_ATTRIBUTE12;
      p_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE12(i):= p_pricing_hist_tbl(i).NEW_PRICING_ATTRIBUTE12;
      p_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE13(i):= p_pricing_hist_tbl(i).OLD_PRICING_ATTRIBUTE13;
      p_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE13(i):= p_pricing_hist_tbl(i).NEW_PRICING_ATTRIBUTE13;
      p_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE14(i):= p_pricing_hist_tbl(i).OLD_PRICING_ATTRIBUTE14;
      p_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE14(i):= p_pricing_hist_tbl(i).NEW_PRICING_ATTRIBUTE14;
      p_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE15(i):= p_pricing_hist_tbl(i).OLD_PRICING_ATTRIBUTE15;
      p_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE15(i):= p_pricing_hist_tbl(i).NEW_PRICING_ATTRIBUTE15;
      p_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE16(i):= p_pricing_hist_tbl(i).OLD_PRICING_ATTRIBUTE16;
      p_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE16(i):= p_pricing_hist_tbl(i).NEW_PRICING_ATTRIBUTE16;
      p_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE17(i):= p_pricing_hist_tbl(i).OLD_PRICING_ATTRIBUTE17;
      p_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE17(i):= p_pricing_hist_tbl(i).NEW_PRICING_ATTRIBUTE17;
      p_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE18(i):= p_pricing_hist_tbl(i).OLD_PRICING_ATTRIBUTE18;
      p_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE18(i):= p_pricing_hist_tbl(i).NEW_PRICING_ATTRIBUTE18;
      p_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE19(i):= p_pricing_hist_tbl(i).OLD_PRICING_ATTRIBUTE19;
      p_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE19(i):= p_pricing_hist_tbl(i).NEW_PRICING_ATTRIBUTE19;
      p_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE20(i):= p_pricing_hist_tbl(i).OLD_PRICING_ATTRIBUTE20;
      p_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE20(i):= p_pricing_hist_tbl(i).NEW_PRICING_ATTRIBUTE20;
      p_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE21(i):= p_pricing_hist_tbl(i).OLD_PRICING_ATTRIBUTE21;
      p_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE21(i):= p_pricing_hist_tbl(i).NEW_PRICING_ATTRIBUTE21;
      p_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE22(i):= p_pricing_hist_tbl(i).OLD_PRICING_ATTRIBUTE22;
      p_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE22(i):= p_pricing_hist_tbl(i).NEW_PRICING_ATTRIBUTE22;
      p_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE23(i):= p_pricing_hist_tbl(i).OLD_PRICING_ATTRIBUTE23;
      p_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE23(i):= p_pricing_hist_tbl(i).NEW_PRICING_ATTRIBUTE23;
      p_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE24(i):= p_pricing_hist_tbl(i).OLD_PRICING_ATTRIBUTE24;
      p_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE24(i):= p_pricing_hist_tbl(i).NEW_PRICING_ATTRIBUTE24;
      p_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE25(i):= p_pricing_hist_tbl(i).NEW_PRICING_ATTRIBUTE25;
      p_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE25(i):= p_pricing_hist_tbl(i).OLD_PRICING_ATTRIBUTE25;
      p_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE26(i):= p_pricing_hist_tbl(i).OLD_PRICING_ATTRIBUTE26;
      p_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE26(i):= p_pricing_hist_tbl(i).NEW_PRICING_ATTRIBUTE26;
      p_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE27(i):= p_pricing_hist_tbl(i).OLD_PRICING_ATTRIBUTE27;
      p_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE27(i):= p_pricing_hist_tbl(i).NEW_PRICING_ATTRIBUTE27;
      p_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE28(i):= p_pricing_hist_tbl(i).OLD_PRICING_ATTRIBUTE28;
      p_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE28(i):= p_pricing_hist_tbl(i).NEW_PRICING_ATTRIBUTE28;
      p_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE29(i):= p_pricing_hist_tbl(i).OLD_PRICING_ATTRIBUTE29;
      p_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE29(i):= p_pricing_hist_tbl(i).NEW_PRICING_ATTRIBUTE29;
      p_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE30(i):= p_pricing_hist_tbl(i).OLD_PRICING_ATTRIBUTE30;
      p_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE30(i):= p_pricing_hist_tbl(i).NEW_PRICING_ATTRIBUTE30;
      p_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE31(i):= p_pricing_hist_tbl(i).OLD_PRICING_ATTRIBUTE31;
      p_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE31(i):= p_pricing_hist_tbl(i).NEW_PRICING_ATTRIBUTE31;
      p_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE32(i):= p_pricing_hist_tbl(i).OLD_PRICING_ATTRIBUTE32;
      p_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE32(i):= p_pricing_hist_tbl(i).NEW_PRICING_ATTRIBUTE32;
      p_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE33(i):= p_pricing_hist_tbl(i).OLD_PRICING_ATTRIBUTE33;
      p_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE33(i):= p_pricing_hist_tbl(i).NEW_PRICING_ATTRIBUTE33;
      p_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE34(i):= p_pricing_hist_tbl(i).OLD_PRICING_ATTRIBUTE34;
      p_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE34(i):= p_pricing_hist_tbl(i).NEW_PRICING_ATTRIBUTE34;
      p_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE35(i):= p_pricing_hist_tbl(i).OLD_PRICING_ATTRIBUTE35;
      p_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE35(i):= p_pricing_hist_tbl(i).NEW_PRICING_ATTRIBUTE35;
      p_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE36(i):= p_pricing_hist_tbl(i).OLD_PRICING_ATTRIBUTE36;
      p_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE36(i):= p_pricing_hist_tbl(i).NEW_PRICING_ATTRIBUTE36;
      p_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE37(i):= p_pricing_hist_tbl(i).OLD_PRICING_ATTRIBUTE37;
      p_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE37(i):= p_pricing_hist_tbl(i).NEW_PRICING_ATTRIBUTE37;
      p_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE38(i):= p_pricing_hist_tbl(i).OLD_PRICING_ATTRIBUTE38;
      p_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE38(i):= p_pricing_hist_tbl(i).NEW_PRICING_ATTRIBUTE38;
      p_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE39(i):= p_pricing_hist_tbl(i).OLD_PRICING_ATTRIBUTE39;
      p_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE39(i):= p_pricing_hist_tbl(i).NEW_PRICING_ATTRIBUTE39;
      p_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE40(i):= p_pricing_hist_tbl(i).OLD_PRICING_ATTRIBUTE40;
      p_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE40(i):= p_pricing_hist_tbl(i).NEW_PRICING_ATTRIBUTE40;
      p_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE41(i):= p_pricing_hist_tbl(i).OLD_PRICING_ATTRIBUTE41;
      p_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE41(i):= p_pricing_hist_tbl(i).NEW_PRICING_ATTRIBUTE41;
      p_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE42(i):= p_pricing_hist_tbl(i).OLD_PRICING_ATTRIBUTE42;
      p_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE42(i):= p_pricing_hist_tbl(i).NEW_PRICING_ATTRIBUTE42;
      p_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE43(i):= p_pricing_hist_tbl(i).OLD_PRICING_ATTRIBUTE43;
      p_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE43(i):= p_pricing_hist_tbl(i).NEW_PRICING_ATTRIBUTE43;
      p_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE44(i):= p_pricing_hist_tbl(i).OLD_PRICING_ATTRIBUTE44;
      p_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE44(i):= p_pricing_hist_tbl(i).NEW_PRICING_ATTRIBUTE44;
      p_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE45(i):= p_pricing_hist_tbl(i).OLD_PRICING_ATTRIBUTE45;
      p_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE45(i):= p_pricing_hist_tbl(i).NEW_PRICING_ATTRIBUTE45;
      p_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE46(i):= p_pricing_hist_tbl(i).OLD_PRICING_ATTRIBUTE46;
      p_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE46(i):= p_pricing_hist_tbl(i).NEW_PRICING_ATTRIBUTE46;
      p_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE47(i):= p_pricing_hist_tbl(i).OLD_PRICING_ATTRIBUTE47;
      p_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE47(i):= p_pricing_hist_tbl(i).NEW_PRICING_ATTRIBUTE47;
      p_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE48(i):= p_pricing_hist_tbl(i).OLD_PRICING_ATTRIBUTE48;
      p_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE48(i):= p_pricing_hist_tbl(i).NEW_PRICING_ATTRIBUTE48;
      p_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE49(i):= p_pricing_hist_tbl(i).OLD_PRICING_ATTRIBUTE49;
      p_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE49(i):= p_pricing_hist_tbl(i).NEW_PRICING_ATTRIBUTE49;
      p_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE50(i):= p_pricing_hist_tbl(i).OLD_PRICING_ATTRIBUTE50;
      p_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE50(i):= p_pricing_hist_tbl(i).NEW_PRICING_ATTRIBUTE50;
      p_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE51(i):= p_pricing_hist_tbl(i).OLD_PRICING_ATTRIBUTE51;
      p_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE51(i):= p_pricing_hist_tbl(i).NEW_PRICING_ATTRIBUTE51;
      p_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE52(i):= p_pricing_hist_tbl(i).OLD_PRICING_ATTRIBUTE52;
      p_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE52(i):= p_pricing_hist_tbl(i).NEW_PRICING_ATTRIBUTE52;
      p_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE53(i):= p_pricing_hist_tbl(i).OLD_PRICING_ATTRIBUTE53;
      p_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE53(i):= p_pricing_hist_tbl(i).NEW_PRICING_ATTRIBUTE53;
      p_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE54(i):= p_pricing_hist_tbl(i).OLD_PRICING_ATTRIBUTE54;
      p_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE54(i):= p_pricing_hist_tbl(i).NEW_PRICING_ATTRIBUTE54;
      p_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE55(i):= p_pricing_hist_tbl(i).OLD_PRICING_ATTRIBUTE55;
      p_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE55(i):= p_pricing_hist_tbl(i).NEW_PRICING_ATTRIBUTE55;
      p_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE56(i):= p_pricing_hist_tbl(i).OLD_PRICING_ATTRIBUTE56;
      p_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE56(i):= p_pricing_hist_tbl(i).NEW_PRICING_ATTRIBUTE56;
      p_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE57(i):= p_pricing_hist_tbl(i).OLD_PRICING_ATTRIBUTE57;
      p_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE57(i):= p_pricing_hist_tbl(i).NEW_PRICING_ATTRIBUTE57;
      p_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE58(i):= p_pricing_hist_tbl(i).OLD_PRICING_ATTRIBUTE58;
      p_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE58(i):= p_pricing_hist_tbl(i).NEW_PRICING_ATTRIBUTE58;
      p_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE59(i):= p_pricing_hist_tbl(i).OLD_PRICING_ATTRIBUTE59;
      p_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE59(i):= p_pricing_hist_tbl(i).NEW_PRICING_ATTRIBUTE59;
      p_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE60(i):= p_pricing_hist_tbl(i).OLD_PRICING_ATTRIBUTE60;
      p_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE60(i):= p_pricing_hist_tbl(i).NEW_PRICING_ATTRIBUTE60;
      p_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE61(i):= p_pricing_hist_tbl(i).OLD_PRICING_ATTRIBUTE61;
      p_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE61(i):= p_pricing_hist_tbl(i).NEW_PRICING_ATTRIBUTE61;
      p_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE62(i):= p_pricing_hist_tbl(i).OLD_PRICING_ATTRIBUTE62;
      p_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE62(i):= p_pricing_hist_tbl(i).NEW_PRICING_ATTRIBUTE62;
      p_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE63(i):= p_pricing_hist_tbl(i).OLD_PRICING_ATTRIBUTE63;
      p_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE63(i):= p_pricing_hist_tbl(i).NEW_PRICING_ATTRIBUTE63;
      p_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE64(i):= p_pricing_hist_tbl(i).OLD_PRICING_ATTRIBUTE64;
      p_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE64(i):= p_pricing_hist_tbl(i).NEW_PRICING_ATTRIBUTE64;
      p_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE65(i):= p_pricing_hist_tbl(i).OLD_PRICING_ATTRIBUTE65;
      p_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE65(i):= p_pricing_hist_tbl(i).NEW_PRICING_ATTRIBUTE65;
      p_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE66(i):= p_pricing_hist_tbl(i).OLD_PRICING_ATTRIBUTE66;
      p_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE66(i):= p_pricing_hist_tbl(i).NEW_PRICING_ATTRIBUTE66;
      p_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE67(i):= p_pricing_hist_tbl(i).OLD_PRICING_ATTRIBUTE67;
      p_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE67(i):= p_pricing_hist_tbl(i).NEW_PRICING_ATTRIBUTE67;
      p_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE68(i):= p_pricing_hist_tbl(i).OLD_PRICING_ATTRIBUTE68;
      p_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE68(i):= p_pricing_hist_tbl(i).NEW_PRICING_ATTRIBUTE68;
      p_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE69(i):= p_pricing_hist_tbl(i).OLD_PRICING_ATTRIBUTE69;
      p_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE69(i):= p_pricing_hist_tbl(i).NEW_PRICING_ATTRIBUTE69;
      p_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE70(i):= p_pricing_hist_tbl(i).OLD_PRICING_ATTRIBUTE70;
      p_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE70(i):= p_pricing_hist_tbl(i).NEW_PRICING_ATTRIBUTE70;
      p_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE71(i):= p_pricing_hist_tbl(i).OLD_PRICING_ATTRIBUTE71;
      p_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE71(i):= p_pricing_hist_tbl(i).NEW_PRICING_ATTRIBUTE71;
      p_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE72(i):= p_pricing_hist_tbl(i).OLD_PRICING_ATTRIBUTE72;
      p_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE72(i):= p_pricing_hist_tbl(i).NEW_PRICING_ATTRIBUTE72;
      p_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE73(i):= p_pricing_hist_tbl(i).OLD_PRICING_ATTRIBUTE73;
      p_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE73(i):= p_pricing_hist_tbl(i).NEW_PRICING_ATTRIBUTE73;
      p_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE74(i):= p_pricing_hist_tbl(i).OLD_PRICING_ATTRIBUTE74;
      p_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE74(i):= p_pricing_hist_tbl(i).NEW_PRICING_ATTRIBUTE74;
      p_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE75(i):= p_pricing_hist_tbl(i).OLD_PRICING_ATTRIBUTE75;
      p_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE75(i):= p_pricing_hist_tbl(i).NEW_PRICING_ATTRIBUTE75;
      p_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE76(i):= p_pricing_hist_tbl(i).OLD_PRICING_ATTRIBUTE76;
      p_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE76(i):= p_pricing_hist_tbl(i).NEW_PRICING_ATTRIBUTE76;
      p_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE77(i):= p_pricing_hist_tbl(i).OLD_PRICING_ATTRIBUTE77;
      p_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE77(i):= p_pricing_hist_tbl(i).NEW_PRICING_ATTRIBUTE77;
      p_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE78(i):= p_pricing_hist_tbl(i).OLD_PRICING_ATTRIBUTE78;
      p_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE78(i):= p_pricing_hist_tbl(i).NEW_PRICING_ATTRIBUTE78;
      p_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE79(i):= p_pricing_hist_tbl(i).OLD_PRICING_ATTRIBUTE79;
      p_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE79(i):= p_pricing_hist_tbl(i).NEW_PRICING_ATTRIBUTE79;
      p_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE80(i):= p_pricing_hist_tbl(i).OLD_PRICING_ATTRIBUTE80;
      p_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE80(i):= p_pricing_hist_tbl(i).NEW_PRICING_ATTRIBUTE80;
      p_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE81(i):= p_pricing_hist_tbl(i).OLD_PRICING_ATTRIBUTE81;
      p_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE81(i):= p_pricing_hist_tbl(i).NEW_PRICING_ATTRIBUTE81;
      p_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE82(i):= p_pricing_hist_tbl(i).OLD_PRICING_ATTRIBUTE82;
      p_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE82(i):= p_pricing_hist_tbl(i).NEW_PRICING_ATTRIBUTE82;
      p_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE83(i):= p_pricing_hist_tbl(i).OLD_PRICING_ATTRIBUTE83;
      p_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE83(i):= p_pricing_hist_tbl(i).NEW_PRICING_ATTRIBUTE83;
      p_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE84(i):= p_pricing_hist_tbl(i).OLD_PRICING_ATTRIBUTE84;
      p_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE84(i):= p_pricing_hist_tbl(i).NEW_PRICING_ATTRIBUTE84;
      p_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE85(i):= p_pricing_hist_tbl(i).OLD_PRICING_ATTRIBUTE85;
      p_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE85(i):= p_pricing_hist_tbl(i).NEW_PRICING_ATTRIBUTE85;
      p_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE86(i):= p_pricing_hist_tbl(i).OLD_PRICING_ATTRIBUTE86;
      p_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE86(i):= p_pricing_hist_tbl(i).NEW_PRICING_ATTRIBUTE86;
      p_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE87(i):= p_pricing_hist_tbl(i).OLD_PRICING_ATTRIBUTE87;
      p_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE87(i):= p_pricing_hist_tbl(i).NEW_PRICING_ATTRIBUTE87;
      p_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE88(i):= p_pricing_hist_tbl(i).OLD_PRICING_ATTRIBUTE88;
      p_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE88(i):= p_pricing_hist_tbl(i).NEW_PRICING_ATTRIBUTE88;
      p_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE89(i):= p_pricing_hist_tbl(i).OLD_PRICING_ATTRIBUTE89;
      p_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE89(i):= p_pricing_hist_tbl(i).NEW_PRICING_ATTRIBUTE89;
      p_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE90(i):= p_pricing_hist_tbl(i).OLD_PRICING_ATTRIBUTE90;
      p_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE90(i):= p_pricing_hist_tbl(i).NEW_PRICING_ATTRIBUTE90;
      p_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE91(i):= p_pricing_hist_tbl(i).OLD_PRICING_ATTRIBUTE91;
      p_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE91(i):= p_pricing_hist_tbl(i).NEW_PRICING_ATTRIBUTE91;
      p_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE92(i):= p_pricing_hist_tbl(i).OLD_PRICING_ATTRIBUTE92;
      p_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE92(i):= p_pricing_hist_tbl(i).NEW_PRICING_ATTRIBUTE92;
      p_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE93(i):= p_pricing_hist_tbl(i).OLD_PRICING_ATTRIBUTE93;
      p_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE93(i):= p_pricing_hist_tbl(i).NEW_PRICING_ATTRIBUTE93;
      p_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE94(i):= p_pricing_hist_tbl(i).OLD_PRICING_ATTRIBUTE94;
      p_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE94(i):= p_pricing_hist_tbl(i).NEW_PRICING_ATTRIBUTE94;
      p_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE95(i):= p_pricing_hist_tbl(i).OLD_PRICING_ATTRIBUTE95;
      p_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE95(i):= p_pricing_hist_tbl(i).NEW_PRICING_ATTRIBUTE95;
      p_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE96(i):= p_pricing_hist_tbl(i).OLD_PRICING_ATTRIBUTE96;
      p_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE96(i):= p_pricing_hist_tbl(i).NEW_PRICING_ATTRIBUTE96;
      p_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE97(i):= p_pricing_hist_tbl(i).OLD_PRICING_ATTRIBUTE97;
      p_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE97(i):= p_pricing_hist_tbl(i).NEW_PRICING_ATTRIBUTE97;
      p_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE98(i):= p_pricing_hist_tbl(i).OLD_PRICING_ATTRIBUTE98;
      p_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE98(i):= p_pricing_hist_tbl(i).NEW_PRICING_ATTRIBUTE98;
      p_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE99(i):= p_pricing_hist_tbl(i).OLD_PRICING_ATTRIBUTE99;
      p_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE99(i):= p_pricing_hist_tbl(i).NEW_PRICING_ATTRIBUTE99;
      p_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE100(i)  := p_pricing_hist_tbl(i).OLD_PRICING_ATTRIBUTE100;
      p_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE100(i)  := p_pricing_hist_tbl(i).NEW_PRICING_ATTRIBUTE100;
      p_pricing_hist_rec_tab.OLD_ACTIVE_START_DATE(i):= p_pricing_hist_tbl(i).OLD_ACTIVE_START_DATE;
      p_pricing_hist_rec_tab.NEW_ACTIVE_START_DATE(i):= p_pricing_hist_tbl(i).NEW_ACTIVE_START_DATE;
      p_pricing_hist_rec_tab.OLD_ACTIVE_END_DATE(i):= p_pricing_hist_tbl(i).OLD_ACTIVE_END_DATE;
      p_pricing_hist_rec_tab.NEW_ACTIVE_END_DATE(i):= p_pricing_hist_tbl(i).NEW_ACTIVE_END_DATE;
      p_pricing_hist_rec_tab.OLD_CONTEXT(i)	        := p_pricing_hist_tbl(i).OLD_CONTEXT;
      p_pricing_hist_rec_tab.NEW_CONTEXT(i)	        := p_pricing_hist_tbl(i).NEW_CONTEXT;
      p_pricing_hist_rec_tab.OLD_ATTRIBUTE1(i)	        := p_pricing_hist_tbl(i).OLD_ATTRIBUTE1;
      p_pricing_hist_rec_tab.NEW_ATTRIBUTE1(i)        := p_pricing_hist_tbl(i).NEW_ATTRIBUTE1;
      p_pricing_hist_rec_tab.OLD_ATTRIBUTE2(i)        := p_pricing_hist_tbl(i).OLD_ATTRIBUTE2;
      p_pricing_hist_rec_tab.NEW_ATTRIBUTE2(i)        := p_pricing_hist_tbl(i).NEW_ATTRIBUTE2;
      p_pricing_hist_rec_tab.OLD_ATTRIBUTE3(i)        := p_pricing_hist_tbl(i).OLD_ATTRIBUTE3;
      p_pricing_hist_rec_tab.NEW_ATTRIBUTE3(i)	        := p_pricing_hist_tbl(i).NEW_ATTRIBUTE3;
      p_pricing_hist_rec_tab.OLD_ATTRIBUTE4(i)	        := p_pricing_hist_tbl(i).OLD_ATTRIBUTE4;
      p_pricing_hist_rec_tab.NEW_ATTRIBUTE4(i)        := p_pricing_hist_tbl(i).NEW_ATTRIBUTE4;
      p_pricing_hist_rec_tab.OLD_ATTRIBUTE5(i)        := p_pricing_hist_tbl(i).OLD_ATTRIBUTE5;
      p_pricing_hist_rec_tab.NEW_ATTRIBUTE5(i)        := p_pricing_hist_tbl(i).NEW_ATTRIBUTE5;
      p_pricing_hist_rec_tab.OLD_ATTRIBUTE6(i)	        := p_pricing_hist_tbl(i).OLD_ATTRIBUTE6;
      p_pricing_hist_rec_tab.NEW_ATTRIBUTE6(i)        := p_pricing_hist_tbl(i).NEW_ATTRIBUTE6;
      p_pricing_hist_rec_tab.OLD_ATTRIBUTE7(i)        := p_pricing_hist_tbl(i).OLD_ATTRIBUTE7;
      p_pricing_hist_rec_tab.NEW_ATTRIBUTE7(i)	        := p_pricing_hist_tbl(i).NEW_ATTRIBUTE7;
      p_pricing_hist_rec_tab.OLD_ATTRIBUTE8(i)	        := p_pricing_hist_tbl(i).OLD_ATTRIBUTE8;
      p_pricing_hist_rec_tab.NEW_ATTRIBUTE8(i)        := p_pricing_hist_tbl(i).NEW_ATTRIBUTE8;
      p_pricing_hist_rec_tab.OLD_ATTRIBUTE9(i)        := p_pricing_hist_tbl(i).OLD_ATTRIBUTE9;
      p_pricing_hist_rec_tab.NEW_ATTRIBUTE9(i)        := p_pricing_hist_tbl(i).NEW_ATTRIBUTE9;
      p_pricing_hist_rec_tab.OLD_ATTRIBUTE10(i)        := p_pricing_hist_tbl(i).OLD_ATTRIBUTE10;
      p_pricing_hist_rec_tab.NEW_ATTRIBUTE10(i)	    := p_pricing_hist_tbl(i).NEW_ATTRIBUTE10;
      p_pricing_hist_rec_tab.OLD_ATTRIBUTE11(i)        := p_pricing_hist_tbl(i).OLD_ATTRIBUTE11;
      p_pricing_hist_rec_tab.NEW_ATTRIBUTE11(i)	    := p_pricing_hist_tbl(i).NEW_ATTRIBUTE11;
      p_pricing_hist_rec_tab.OLD_ATTRIBUTE12(i)        := p_pricing_hist_tbl(i).OLD_ATTRIBUTE12;
      p_pricing_hist_rec_tab.NEW_ATTRIBUTE12(i)        := p_pricing_hist_tbl(i).NEW_ATTRIBUTE12;
      p_pricing_hist_rec_tab.OLD_ATTRIBUTE13(i)        := p_pricing_hist_tbl(i).OLD_ATTRIBUTE13;
      p_pricing_hist_rec_tab.NEW_ATTRIBUTE13(i)        := p_pricing_hist_tbl(i).NEW_ATTRIBUTE13;
      p_pricing_hist_rec_tab.OLD_ATTRIBUTE14(i)	    := p_pricing_hist_tbl(i).OLD_ATTRIBUTE14;
      p_pricing_hist_rec_tab.NEW_ATTRIBUTE14(i)	    := p_pricing_hist_tbl(i).NEW_ATTRIBUTE14;
      p_pricing_hist_rec_tab.OLD_ATTRIBUTE15(i)	    := p_pricing_hist_tbl(i).OLD_ATTRIBUTE15;
      p_pricing_hist_rec_tab.NEW_ATTRIBUTE15(i)	    := p_pricing_hist_tbl(i).NEW_ATTRIBUTE15;
      p_pricing_hist_rec_tab.FULL_DUMP_FLAG(i)        := p_pricing_hist_tbl(i).FULL_DUMP_FLAG;
   END LOOP;
END Build_pricing_Hist_Rec_Table;
--
PROCEDURE Build_Ext_Attr_Rec_Table
   (
     p_ext_attr_tbl     IN     csi_datastructures_pub.extend_attrib_values_tbl
    ,p_ext_attr_rec_tab IN OUT NOCOPY  csi_item_instance_grp.extend_attrib_values_rec_tab
   ) IS

BEGIN
   FOR i in p_ext_attr_tbl.FIRST .. p_ext_attr_tbl.LAST LOOP

     p_ext_attr_rec_tab.attribute_value_id(i)      :=  p_ext_attr_tbl(i).attribute_value_id;
     p_ext_attr_rec_tab.instance_id(i)             :=  p_ext_attr_tbl(i).instance_id;
     p_ext_attr_rec_tab.attribute_id(i)            :=  p_ext_attr_tbl(i).attribute_id;
     p_ext_attr_rec_tab.attribute_code(i)          :=  p_ext_attr_tbl(i).attribute_code;
     p_ext_attr_rec_tab.attribute_value(i)         :=  p_ext_attr_tbl(i).attribute_value;
     p_ext_attr_rec_tab.active_start_date(i)       :=  p_ext_attr_tbl(i).active_start_date;
     p_ext_attr_rec_tab.active_end_date(i)         :=  p_ext_attr_tbl(i).active_end_date;
     p_ext_attr_rec_tab.context(i)                 :=  p_ext_attr_tbl(i).context;
     p_ext_attr_rec_tab.attribute1(i)              :=  p_ext_attr_tbl(i).attribute1;
     p_ext_attr_rec_tab.attribute2 (i)             :=  p_ext_attr_tbl(i).attribute2;
     p_ext_attr_rec_tab.attribute3(i)              :=  p_ext_attr_tbl(i).attribute3;
     p_ext_attr_rec_tab.attribute4(i)              :=  p_ext_attr_tbl(i).attribute4;
     p_ext_attr_rec_tab.attribute5(i)              :=  p_ext_attr_tbl(i).attribute5;
     p_ext_attr_rec_tab.attribute6(i)              :=  p_ext_attr_tbl(i).attribute6;
     p_ext_attr_rec_tab.attribute7(i)              :=  p_ext_attr_tbl(i).attribute7;
     p_ext_attr_rec_tab.attribute8(i)              :=  p_ext_attr_tbl(i).attribute8;
     p_ext_attr_rec_tab.attribute9(i)              :=  p_ext_attr_tbl(i).attribute9;
     p_ext_attr_rec_tab.attribute10(i)             :=  p_ext_attr_tbl(i).attribute10;
     p_ext_attr_rec_tab.attribute11(i)             :=  p_ext_attr_tbl(i).attribute11;
     p_ext_attr_rec_tab.attribute12(i)             :=  p_ext_attr_tbl(i).attribute12;
     p_ext_attr_rec_tab.attribute13(i)             :=  p_ext_attr_tbl(i).attribute13;
     p_ext_attr_rec_tab.attribute14(i)             :=  p_ext_attr_tbl(i).attribute14;
     p_ext_attr_rec_tab.attribute15(i)             :=  p_ext_attr_tbl(i).attribute15;
     p_ext_attr_rec_tab.object_version_number(i)   :=  p_ext_attr_tbl(i).object_version_number;
     p_ext_attr_rec_tab.parent_tbl_index(i)        :=  p_ext_attr_tbl(i).parent_tbl_index;

   END LOOP;
END Build_Ext_Attr_Rec_Table;
--
PROCEDURE Build_Ext_Attr_Hist_Rec_Table
   (
     p_ext_attr_hist_tbl  IN  csi_datastructures_pub.ext_attrib_val_history_tbl
    ,p_ext_attr_hist_rec_tab IN OUT NOCOPY  csi_item_instance_grp.ext_attrib_val_hist_rec_tab
   ) IS
BEGIN
   FOR i in p_ext_attr_hist_tbl.FIRST .. p_ext_attr_hist_tbl.LAST LOOP

      p_ext_attr_hist_rec_tab.attribute_value_history_id(i) := p_ext_attr_hist_tbl(i).attribute_value_history_id;
      p_ext_attr_hist_rec_tab.attribute_value_id(i)       := p_ext_attr_hist_tbl(i).attribute_value_id;
      p_ext_attr_hist_rec_tab.transaction_id(i)           := p_ext_attr_hist_tbl(i).transaction_id;
      p_ext_attr_hist_rec_tab.old_attribute_value(i)      := p_ext_attr_hist_tbl(i).old_attribute_value;
      p_ext_attr_hist_rec_tab.new_attribute_value(i)      := p_ext_attr_hist_tbl(i).new_attribute_value;
      p_ext_attr_hist_rec_tab.old_active_start_date(i)    := p_ext_attr_hist_tbl(i).old_active_start_date;
      p_ext_attr_hist_rec_tab.new_active_start_date(i)    := p_ext_attr_hist_tbl(i).new_active_start_date;
      p_ext_attr_hist_rec_tab.old_active_end_date(i)      := p_ext_attr_hist_tbl(i).old_active_end_date;
      p_ext_attr_hist_rec_tab.new_active_end_date(i)      := p_ext_attr_hist_tbl(i).new_active_end_date;
      p_ext_attr_hist_rec_tab.old_context(i)              := p_ext_attr_hist_tbl(i).old_context;
      p_ext_attr_hist_rec_tab.new_context(i)              := p_ext_attr_hist_tbl(i).new_context;
      p_ext_attr_hist_rec_tab.old_attribute1(i)           := p_ext_attr_hist_tbl(i).old_attribute1;
      p_ext_attr_hist_rec_tab.new_attribute1(i)           := p_ext_attr_hist_tbl(i).new_attribute1;
      p_ext_attr_hist_rec_tab.old_attribute2(i)           := p_ext_attr_hist_tbl(i).old_attribute2;
      p_ext_attr_hist_rec_tab.new_attribute2(i)           := p_ext_attr_hist_tbl(i).new_attribute2;
      p_ext_attr_hist_rec_tab.old_attribute3(i)           := p_ext_attr_hist_tbl(i).old_attribute3;
      p_ext_attr_hist_rec_tab.new_attribute3(i)           := p_ext_attr_hist_tbl(i).new_attribute3;
      p_ext_attr_hist_rec_tab.old_attribute4(i)           := p_ext_attr_hist_tbl(i).old_attribute4;
      p_ext_attr_hist_rec_tab.new_attribute4(i)           := p_ext_attr_hist_tbl(i).new_attribute4;
      p_ext_attr_hist_rec_tab.old_attribute5(i)           := p_ext_attr_hist_tbl(i).old_attribute5;
      p_ext_attr_hist_rec_tab.new_attribute5(i)           := p_ext_attr_hist_tbl(i).new_attribute5;
      p_ext_attr_hist_rec_tab.old_attribute6(i)           := p_ext_attr_hist_tbl(i).old_attribute6;
      p_ext_attr_hist_rec_tab.new_attribute6(i)           := p_ext_attr_hist_tbl(i).new_attribute6;
      p_ext_attr_hist_rec_tab.old_attribute7(i)           := p_ext_attr_hist_tbl(i).old_attribute7;
      p_ext_attr_hist_rec_tab.new_attribute7(i)           := p_ext_attr_hist_tbl(i).new_attribute7;
      p_ext_attr_hist_rec_tab.old_attribute8(i)           := p_ext_attr_hist_tbl(i).old_attribute8;
      p_ext_attr_hist_rec_tab.new_attribute8(i)           := p_ext_attr_hist_tbl(i).new_attribute8;
      p_ext_attr_hist_rec_tab.old_attribute9(i)           := p_ext_attr_hist_tbl(i).old_attribute9;
      p_ext_attr_hist_rec_tab.new_attribute9(i)           := p_ext_attr_hist_tbl(i).new_attribute9;
      p_ext_attr_hist_rec_tab.old_attribute10(i)          := p_ext_attr_hist_tbl(i).old_attribute10;
      p_ext_attr_hist_rec_tab.new_attribute10(i)          := p_ext_attr_hist_tbl(i).new_attribute10;
      p_ext_attr_hist_rec_tab.old_attribute11(i)          := p_ext_attr_hist_tbl(i).old_attribute11;
      p_ext_attr_hist_rec_tab.new_attribute11(i)          := p_ext_attr_hist_tbl(i).new_attribute11;
      p_ext_attr_hist_rec_tab.old_attribute12(i)          := p_ext_attr_hist_tbl(i).old_attribute12;
      p_ext_attr_hist_rec_tab.new_attribute12(i)          := p_ext_attr_hist_tbl(i).new_attribute12;
      p_ext_attr_hist_rec_tab.old_attribute13(i)          := p_ext_attr_hist_tbl(i).old_attribute13;
      p_ext_attr_hist_rec_tab.new_attribute13(i)          := p_ext_attr_hist_tbl(i).new_attribute13;
      p_ext_attr_hist_rec_tab.old_attribute14(i)          := p_ext_attr_hist_tbl(i).old_attribute14;
      p_ext_attr_hist_rec_tab.new_attribute14(i)          := p_ext_attr_hist_tbl(i).new_attribute14;
      p_ext_attr_hist_rec_tab.old_attribute15(i)          := p_ext_attr_hist_tbl(i).old_attribute15;
      p_ext_attr_hist_rec_tab.new_attribute15(i)          := p_ext_attr_hist_tbl(i).new_attribute15;
      p_ext_attr_hist_rec_tab.instance_id(i)              := p_ext_attr_hist_tbl(i).instance_id;
      p_ext_attr_hist_rec_tab.attribute_code(i)           := p_ext_attr_hist_tbl(i).attribute_code;

   END LOOP;
END Build_Ext_Attr_Hist_Rec_Table;
--
PROCEDURE Build_Asset_Rec_Table
   (
     p_asset_tbl     IN     csi_datastructures_pub.instance_asset_tbl
    ,p_asset_rec_tab IN OUT NOCOPY  csi_item_instance_grp.instance_asset_rec_tab
   ) IS

BEGIN
   FOR i in p_asset_tbl.FIRST .. p_asset_tbl.LAST LOOP

     p_asset_rec_tab.instance_asset_id(i)          := p_asset_tbl(i).instance_asset_id;
     p_asset_rec_tab.instance_id(i)                := p_asset_tbl(i).instance_id;
     p_asset_rec_tab.fa_asset_id(i)                := p_asset_tbl(i).fa_asset_id;
     p_asset_rec_tab.fa_book_type_code(i)          := p_asset_tbl(i).fa_book_type_code;
     p_asset_rec_tab.fa_location_id(i)             := p_asset_tbl(i).fa_location_id;
     p_asset_rec_tab.asset_quantity(i)             := p_asset_tbl(i).asset_quantity;
     p_asset_rec_tab.update_status(i)              := p_asset_tbl(i).update_status;
     p_asset_rec_tab.active_start_date(i)          := p_asset_tbl(i).active_start_date;
     p_asset_rec_tab.active_end_date(i)            := p_asset_tbl(i).active_end_date;
     p_asset_rec_tab.object_version_number(i)      := p_asset_tbl(i).object_version_number;
     p_asset_rec_tab.check_for_instance_expiry(i)  := p_asset_tbl(i).check_for_instance_expiry;
     p_asset_rec_tab.parent_tbl_index(i)           := p_asset_tbl(i).parent_tbl_index;
     p_asset_rec_tab.fa_sync_flag(i)               := p_asset_tbl(i).fa_sync_flag;

   END LOOP;
END Build_Asset_Rec_Table;
--
PROCEDURE Build_Asset_Hist_Rec_Table
   (
     p_asset_hist_tbl  IN  csi_datastructures_pub.ins_asset_history_tbl
    ,p_asset_hist_rec_tab IN OUT NOCOPY  csi_item_instance_grp.ins_asset_history_rec_tab
   ) IS
BEGIN
   FOR i in p_asset_hist_tbl.FIRST .. p_asset_hist_tbl.LAST LOOP

     p_asset_hist_rec_tab.instance_asset_history_id(i)    := p_asset_hist_tbl(i).instance_asset_history_id;
     p_asset_hist_rec_tab.transaction_id(i)               := p_asset_hist_tbl(i).transaction_id;
     p_asset_hist_rec_tab.instance_asset_id(i)            := p_asset_hist_tbl(i).instance_asset_id;
     p_asset_hist_rec_tab.old_instance_id(i)              := p_asset_hist_tbl(i).old_instance_id;
     p_asset_hist_rec_tab.new_instance_id(i)              := p_asset_hist_tbl(i).new_instance_id;
     p_asset_hist_rec_tab.old_fa_asset_id(i)              := p_asset_hist_tbl(i).old_fa_asset_id;
     p_asset_hist_rec_tab.new_fa_asset_id(i)              := p_asset_hist_tbl(i).new_fa_asset_id;
     p_asset_hist_rec_tab.old_fa_book_type_code(i)        := p_asset_hist_tbl(i).old_fa_book_type_code;
     p_asset_hist_rec_tab.new_fa_book_type_code(i)        := p_asset_hist_tbl(i).new_fa_book_type_code;
     p_asset_hist_rec_tab.old_fa_location_id(i)           := p_asset_hist_tbl(i).old_fa_location_id;
     p_asset_hist_rec_tab.new_fa_location_id(i)           := p_asset_hist_tbl(i).new_fa_location_id;
     p_asset_hist_rec_tab.old_asset_quantity(i)           := p_asset_hist_tbl(i).old_asset_quantity;
     p_asset_hist_rec_tab.new_asset_quantity(i)           := p_asset_hist_tbl(i).new_asset_quantity;
     p_asset_hist_rec_tab.old_update_status(i)            := p_asset_hist_tbl(i).old_update_status;
     p_asset_hist_rec_tab.new_update_status(i)            := p_asset_hist_tbl(i).new_update_status;
     p_asset_hist_rec_tab.old_active_start_date(i)        := p_asset_hist_tbl(i).old_active_start_date;
     p_asset_hist_rec_tab.new_active_start_date(i)        := p_asset_hist_tbl(i).new_active_start_date;
     p_asset_hist_rec_tab.old_active_end_date(i)          := p_asset_hist_tbl(i).old_active_end_date;
     p_asset_hist_rec_tab.new_active_end_date(i)          := p_asset_hist_tbl(i).new_active_end_date;
     p_asset_hist_rec_tab.old_asset_number(i)             := p_asset_hist_tbl(i).old_asset_number;
     p_asset_hist_rec_tab.new_asset_number(i)             := p_asset_hist_tbl(i).new_asset_number;
     p_asset_hist_rec_tab.old_serial_number(i)            := p_asset_hist_tbl(i).old_serial_number;
     p_asset_hist_rec_tab.new_serial_number(i)            := p_asset_hist_tbl(i).new_serial_number;
     p_asset_hist_rec_tab.old_tag_number(i)               := p_asset_hist_tbl(i).old_tag_number;
     p_asset_hist_rec_tab.new_tag_number(i)               := p_asset_hist_tbl(i).new_tag_number;
     p_asset_hist_rec_tab.old_category(i)                 := p_asset_hist_tbl(i).old_category;
     p_asset_hist_rec_tab.new_category(i)                 := p_asset_hist_tbl(i).new_category;
     p_asset_hist_rec_tab.old_fa_location_segment1(i)     := p_asset_hist_tbl(i).old_fa_location_segment1;
     p_asset_hist_rec_tab.new_fa_location_segment1(i)     := p_asset_hist_tbl(i).new_fa_location_segment1;
     p_asset_hist_rec_tab.old_fa_location_segment2(i)     := p_asset_hist_tbl(i).old_fa_location_segment2;
     p_asset_hist_rec_tab.new_fa_location_segment2(i)     := p_asset_hist_tbl(i).new_fa_location_segment2;
     p_asset_hist_rec_tab.old_fa_location_segment3(i)     := p_asset_hist_tbl(i).old_fa_location_segment3;
     p_asset_hist_rec_tab.new_fa_location_segment3(i)     := p_asset_hist_tbl(i).new_fa_location_segment3;
     p_asset_hist_rec_tab.old_fa_location_segment4(i)     := p_asset_hist_tbl(i).old_fa_location_segment4;
     p_asset_hist_rec_tab.new_fa_location_segment4(i)     := p_asset_hist_tbl(i).new_fa_location_segment4;
     p_asset_hist_rec_tab.old_fa_location_segment5(i)     := p_asset_hist_tbl(i).old_fa_location_segment5;
     p_asset_hist_rec_tab.new_fa_location_segment5(i)     := p_asset_hist_tbl(i).new_fa_location_segment5;
     p_asset_hist_rec_tab.old_fa_location_segment6(i)     := p_asset_hist_tbl(i).old_fa_location_segment6;
     p_asset_hist_rec_tab.new_fa_location_segment6(i)     := p_asset_hist_tbl(i).new_fa_location_segment6;
     p_asset_hist_rec_tab.old_fa_location_segment7(i)     := p_asset_hist_tbl(i).old_fa_location_segment7;
     p_asset_hist_rec_tab.new_fa_location_segment7(i)     := p_asset_hist_tbl(i).new_fa_location_segment7;
     p_asset_hist_rec_tab.old_date_placed_in_service(i)   := p_asset_hist_tbl(i).old_date_placed_in_service;
     p_asset_hist_rec_tab.new_date_placed_in_service(i)   := p_asset_hist_tbl(i).new_date_placed_in_service;
     p_asset_hist_rec_tab.old_description(i)              := p_asset_hist_tbl(i).old_description;
     p_asset_hist_rec_tab.new_description(i)              := p_asset_hist_tbl(i).new_description;
     p_asset_hist_rec_tab.old_employee_name(i)            := p_asset_hist_tbl(i).old_employee_name;
     p_asset_hist_rec_tab.new_employee_name(i)            := p_asset_hist_tbl(i).new_employee_name;
     p_asset_hist_rec_tab.old_expense_account_number(i)   := p_asset_hist_tbl(i).old_expense_account_number;
     p_asset_hist_rec_tab.new_expense_account_number(i)   := p_asset_hist_tbl(i).new_expense_account_number;
     p_asset_hist_rec_tab.instance_id(i)                  := p_asset_hist_tbl(i).instance_id;
     p_asset_hist_rec_tab.old_fa_sync_flag(i)             := p_asset_hist_tbl(i).old_fa_sync_flag;
     p_asset_hist_rec_tab.new_fa_sync_flag(i)             := p_asset_hist_tbl(i).new_fa_sync_flag;

   END LOOP;
END Build_Asset_Hist_Rec_Table;
--
PROCEDURE Bulk_Insert
   (
     p_inst_tbl           IN  csi_datastructures_pub.instance_tbl
    ,p_txn_tbl            IN  csi_datastructures_pub.transaction_tbl
    ,p_inst_hist_tbl      IN  csi_datastructures_pub.instance_history_tbl
    ,p_version_label_tbl  IN  csi_datastructures_pub.version_label_tbl
    ,p_ver_label_hist_tbl IN  csi_datastructures_pub.version_label_history_tbl
    ,p_party_tbl          IN  csi_datastructures_pub.party_tbl
    ,p_party_hist_tbl     IN  csi_datastructures_pub.party_history_tbl
    ,p_account_tbl        IN  csi_datastructures_pub.party_account_tbl
    ,p_acct_hist_tbl      IN  csi_datastructures_pub.account_history_tbl
    ,p_owner_pty_acct_tbl IN  csi_item_instance_pvt.owner_pty_acct_tbl
    ,p_org_units_tbl      IN  csi_datastructures_pub.organization_units_tbl
    ,p_org_units_hist_tbl IN  csi_datastructures_pub.org_units_history_tbl
    ,p_pricing_tbl        IN  csi_datastructures_pub.pricing_attribs_tbl
    ,p_pricing_hist_tbl   IN  csi_datastructures_pub.pricing_history_tbl
    ,p_ext_attr_values_tbl IN csi_datastructures_pub.extend_attrib_values_tbl
    ,p_ext_attr_val_hist_tbl IN csi_datastructures_pub.ext_attrib_val_history_tbl
    ,p_asset_tbl          IN  csi_datastructures_pub.instance_asset_tbl
    ,p_asset_hist_tbl     IN  csi_datastructures_pub.ins_asset_history_tbl
    ,x_return_status      OUT NOCOPY VARCHAR2
   ) IS
   --
   l_inst_rec_tab                csi_item_instance_grp.instance_rec_tab;
   l_inst_hist_rec_tab           csi_item_instance_grp.instance_history_rec_tab;
   l_version_label_rec_tab       csi_item_instance_grp.version_label_rec_tab;
   l_ver_label_hist_rec_tab      csi_item_instance_grp.ver_label_history_rec_tab;
   l_party_rec_tab               csi_item_instance_grp.party_rec_tab;
   l_party_hist_rec_tab          csi_item_instance_grp.party_history_rec_tab;
   l_account_rec_tab             csi_item_instance_grp.account_rec_tab;
   l_acct_hist_rec_tab           csi_item_instance_grp.account_history_rec_tab;
   l_txn_rec_tab                 csi_item_instance_grp.transaction_rec_tab;
   l_owner_pty_acct_rec_tab      csi_item_instance_pvt.owner_pty_acct_rec_tab;
   l_ext_attr_rec_tab            csi_item_instance_grp.extend_attrib_values_rec_tab;
   l_ext_attr_hist_rec_tab       csi_item_instance_grp.ext_attrib_val_hist_rec_tab;
   l_asset_rec_tab               csi_item_instance_grp.instance_asset_rec_tab;
   l_asset_hist_rec_tab          csi_item_instance_grp.ins_asset_history_rec_tab;
   l_org_units_rec_tab           csi_item_instance_grp.org_units_rec_tab;
   l_org_hist_rec_tab            csi_item_instance_grp.org_units_history_rec_tab;
   l_pricing_rec_tab             csi_item_instance_grp.pricing_attribs_rec_tab;
   l_pricing_hist_rec_tab        csi_item_instance_grp.pricing_attribs_hist_rec_tab;
   --
   l_user_id      NUMBER := FND_GLOBAL.USER_ID;
   l_login_id     NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
   l_ctr          NUMBER;
BEGIN
   SAVEPOINT Bulk_Insert;
   --
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   --
   IF p_inst_tbl.count > 0 THEN
      Build_Inst_Rec_of_Table
         ( p_inst_tbl  => p_inst_tbl
          ,p_inst_rec_tab => l_inst_rec_tab
         );
      --
      l_ctr := l_inst_rec_tab.instance_id.count;
      FORALL i in 1 .. l_ctr
         INSERT INTO CSI_ITEM_INSTANCES(
         INSTANCE_ID,
         INSTANCE_NUMBER,
         EXTERNAL_REFERENCE,
         INVENTORY_ITEM_ID,
         INVENTORY_REVISION,
         INV_MASTER_ORGANIZATION_ID,
         SERIAL_NUMBER,
         MFG_SERIAL_NUMBER_FLAG,
         LOT_NUMBER,
         QUANTITY,
         UNIT_OF_MEASURE,
         ACCOUNTING_CLASS_CODE,
         INSTANCE_CONDITION_ID,
         INSTANCE_STATUS_ID,
         CUSTOMER_VIEW_FLAG,
         MERCHANT_VIEW_FLAG,
         SELLABLE_FLAG,
         SYSTEM_ID,
         INSTANCE_TYPE_CODE,
         ACTIVE_START_DATE,
         ACTIVE_END_DATE,
         LOCATION_TYPE_CODE,
         LOCATION_ID,
         INV_ORGANIZATION_ID,
         INV_SUBINVENTORY_NAME,
         INV_LOCATOR_ID,
         PA_PROJECT_ID,
         PA_PROJECT_TASK_ID,
         IN_TRANSIT_ORDER_LINE_ID,
         WIP_JOB_ID,
         PO_ORDER_LINE_ID,
         LAST_OE_ORDER_LINE_ID,
         LAST_OE_RMA_LINE_ID,
         LAST_PO_PO_LINE_ID,
         LAST_OE_PO_NUMBER,
         LAST_WIP_JOB_ID,
         LAST_PA_PROJECT_ID,
         LAST_PA_TASK_ID,
         LAST_OE_AGREEMENT_ID,
         INSTALL_DATE,
         MANUALLY_CREATED_FLAG,
         RETURN_BY_DATE,
         ACTUAL_RETURN_DATE,
         CREATION_COMPLETE_FLAG,
         COMPLETENESS_FLAG,
         CONTEXT,
	 ATTRIBUTE1,
	 ATTRIBUTE2,
	 ATTRIBUTE3,
	 ATTRIBUTE4,
	 ATTRIBUTE5,
	 ATTRIBUTE6,
	 ATTRIBUTE7,
	 ATTRIBUTE8,
	 ATTRIBUTE9,
	 ATTRIBUTE10,
	 ATTRIBUTE11,
	 ATTRIBUTE12,
	 ATTRIBUTE13,
	 ATTRIBUTE14,
	 ATTRIBUTE15,
	 CREATED_BY,
	 CREATION_DATE,
	 LAST_UPDATED_BY,
	 LAST_UPDATE_DATE,
	 LAST_UPDATE_LOGIN,
	 OBJECT_VERSION_NUMBER,
	 LAST_TXN_LINE_DETAIL_ID,
	 INSTALL_LOCATION_TYPE_CODE,
	 INSTALL_LOCATION_ID,
	 INSTANCE_USAGE_CODE,
         LAST_VLD_ORGANIZATION_ID,
         CONFIG_INST_HDR_ID,
         CONFIG_INST_REV_NUM,
         CONFIG_INST_ITEM_ID,
         CONFIG_VALID_STATUS,
         INSTANCE_DESCRIPTION,
         NETWORK_ASSET_FLAG,
         MAINTAINABLE_FLAG ,
         ASSET_CRITICALITY_CODE,
         CATEGORY_ID           ,
         EQUIPMENT_GEN_OBJECT_ID,
         INSTANTIATION_FLAG     ,
         OPERATIONAL_LOG_FLAG   ,
         SUPPLIER_WARRANTY_EXP_DATE,
         ATTRIBUTE16 ,
         ATTRIBUTE17 ,
         ATTRIBUTE18 ,
         ATTRIBUTE19 ,
         ATTRIBUTE20 ,
         ATTRIBUTE21 ,
         ATTRIBUTE22 ,
         ATTRIBUTE23 ,
         ATTRIBUTE24 ,
         ATTRIBUTE25 ,
         ATTRIBUTE26 ,
         ATTRIBUTE27 ,
         ATTRIBUTE28 ,
         ATTRIBUTE29 ,
         ATTRIBUTE30 ,
	 PURCHASE_UNIT_PRICE ,
	 PURCHASE_CURRENCY_CODE ,
	 PAYABLES_UNIT_PRICE ,
	 PAYABLES_CURRENCY_CODE ,
	 SALES_UNIT_PRICE ,
	 SALES_CURRENCY_CODE ,
	 OPERATIONAL_STATUS_CODE
         ) VALUES(
          l_inst_rec_tab.INSTANCE_ID(i),
	  decode( l_inst_rec_tab.INSTANCE_NUMBER(i), FND_API.G_MISS_CHAR, NULL, l_inst_rec_tab.INSTANCE_NUMBER(i)),
	  decode( l_inst_rec_tab.EXTERNAL_REFERENCE(i), FND_API.G_MISS_CHAR, NULL, l_inst_rec_tab.EXTERNAL_REFERENCE(i)),
	  decode( l_inst_rec_tab.INVENTORY_ITEM_ID(i), FND_API.G_MISS_NUM, NULL, l_inst_rec_tab.INVENTORY_ITEM_ID(i)),
	  decode( l_inst_rec_tab.INVENTORY_REVISION(i), FND_API.G_MISS_CHAR, NULL, l_inst_rec_tab.INVENTORY_REVISION(i)),
	  decode( l_inst_rec_tab.INV_MASTER_ORGANIZATION_ID(i), FND_API.G_MISS_NUM, NULL, l_inst_rec_tab.INV_MASTER_ORGANIZATION_ID(i)),
	  decode( l_inst_rec_tab.SERIAL_NUMBER(i), FND_API.G_MISS_CHAR, NULL, l_inst_rec_tab.SERIAL_NUMBER(i)),
	  decode( l_inst_rec_tab.MFG_SERIAL_NUMBER_FLAG(i), FND_API.G_MISS_CHAR, NULL, l_inst_rec_tab.MFG_SERIAL_NUMBER_FLAG(i)),
	  decode( l_inst_rec_tab.LOT_NUMBER(i), FND_API.G_MISS_CHAR, NULL, l_inst_rec_tab.LOT_NUMBER(i)),
	  decode( l_inst_rec_tab.QUANTITY(i), FND_API.G_MISS_NUM, NULL, l_inst_rec_tab.QUANTITY(i)),
	  decode( l_inst_rec_tab.UNIT_OF_MEASURE(i), FND_API.G_MISS_CHAR, NULL, l_inst_rec_tab.UNIT_OF_MEASURE(i)),
	  decode( l_inst_rec_tab.ACCOUNTING_CLASS_CODE(i), FND_API.G_MISS_CHAR, NULL, l_inst_rec_tab.ACCOUNTING_CLASS_CODE(i)),
	  decode( l_inst_rec_tab.INSTANCE_CONDITION_ID(i), FND_API.G_MISS_NUM, NULL, l_inst_rec_tab.INSTANCE_CONDITION_ID(i)),
	  decode( l_inst_rec_tab.INSTANCE_STATUS_ID(i), FND_API.G_MISS_NUM, NULL, l_inst_rec_tab.INSTANCE_STATUS_ID(i)),
	  decode( l_inst_rec_tab.CUSTOMER_VIEW_FLAG(i), FND_API.G_MISS_CHAR, NULL, l_inst_rec_tab.CUSTOMER_VIEW_FLAG(i)),
	  decode( l_inst_rec_tab.MERCHANT_VIEW_FLAG(i), FND_API.G_MISS_CHAR, NULL, l_inst_rec_tab.MERCHANT_VIEW_FLAG(i)),
	  decode( l_inst_rec_tab.SELLABLE_FLAG(i), FND_API.G_MISS_CHAR, NULL, l_inst_rec_tab.SELLABLE_FLAG(i)),
	  decode( l_inst_rec_tab.SYSTEM_ID(i), FND_API.G_MISS_NUM, NULL, l_inst_rec_tab.SYSTEM_ID(i)),
	  decode( l_inst_rec_tab.INSTANCE_TYPE_CODE(i), FND_API.G_MISS_CHAR, NULL, l_inst_rec_tab.INSTANCE_TYPE_CODE(i)),
	  decode( l_inst_rec_tab.ACTIVE_START_DATE(i), FND_API.G_MISS_DATE, TO_DATE(NULL), l_inst_rec_tab.ACTIVE_START_DATE(i)),
	  decode( l_inst_rec_tab.ACTIVE_END_DATE(i), FND_API.G_MISS_DATE, TO_DATE(NULL), l_inst_rec_tab.ACTIVE_END_DATE(i)),
	  decode( l_inst_rec_tab.LOCATION_TYPE_CODE(i), FND_API.G_MISS_CHAR, NULL, l_inst_rec_tab.LOCATION_TYPE_CODE(i)),
	  decode( l_inst_rec_tab.LOCATION_ID(i), FND_API.G_MISS_NUM, NULL, l_inst_rec_tab.LOCATION_ID(i)),
	  decode( l_inst_rec_tab.INV_ORGANIZATION_ID(i), FND_API.G_MISS_NUM, NULL, l_inst_rec_tab.INV_ORGANIZATION_ID(i)),
	  decode( l_inst_rec_tab.INV_SUBINVENTORY_NAME(i), FND_API.G_MISS_CHAR, NULL, l_inst_rec_tab.INV_SUBINVENTORY_NAME(i)),
	  decode( l_inst_rec_tab.INV_LOCATOR_ID(i), FND_API.G_MISS_NUM, NULL, l_inst_rec_tab.INV_LOCATOR_ID(i)),
	  decode( l_inst_rec_tab.PA_PROJECT_ID(i), FND_API.G_MISS_NUM, NULL, l_inst_rec_tab.PA_PROJECT_ID(i)),
	  decode( l_inst_rec_tab.PA_PROJECT_TASK_ID(i), FND_API.G_MISS_NUM, NULL, l_inst_rec_tab.PA_PROJECT_TASK_ID(i)),
	  decode( l_inst_rec_tab.IN_TRANSIT_ORDER_LINE_ID(i), FND_API.G_MISS_NUM, NULL, l_inst_rec_tab.IN_TRANSIT_ORDER_LINE_ID(i)),
	  decode( l_inst_rec_tab.WIP_JOB_ID(i), FND_API.G_MISS_NUM, NULL, l_inst_rec_tab.WIP_JOB_ID(i)),
	  decode( l_inst_rec_tab.PO_ORDER_LINE_ID(i), FND_API.G_MISS_NUM, NULL, l_inst_rec_tab.PO_ORDER_LINE_ID(i)),
	  decode( l_inst_rec_tab.LAST_OE_ORDER_LINE_ID(i), FND_API.G_MISS_NUM, NULL, l_inst_rec_tab.LAST_OE_ORDER_LINE_ID(i)),
	  decode( l_inst_rec_tab.LAST_OE_RMA_LINE_ID(i), FND_API.G_MISS_NUM, NULL, l_inst_rec_tab.LAST_OE_RMA_LINE_ID(i)),
	  decode( l_inst_rec_tab.LAST_PO_PO_LINE_ID(i), FND_API.G_MISS_NUM, NULL, l_inst_rec_tab.LAST_PO_PO_LINE_ID(i)),
	  decode( l_inst_rec_tab.LAST_OE_PO_NUMBER(i), FND_API.G_MISS_CHAR, NULL, l_inst_rec_tab.LAST_OE_PO_NUMBER(i)),
	  decode( l_inst_rec_tab.LAST_WIP_JOB_ID(i), FND_API.G_MISS_NUM, NULL, l_inst_rec_tab.LAST_WIP_JOB_ID(i)),
	  decode( l_inst_rec_tab.LAST_PA_PROJECT_ID(i), FND_API.G_MISS_NUM, NULL, l_inst_rec_tab.LAST_PA_PROJECT_ID(i)),
	  decode( l_inst_rec_tab.LAST_PA_TASK_ID(i), FND_API.G_MISS_NUM, NULL, l_inst_rec_tab.LAST_PA_TASK_ID(i)),
	  decode( l_inst_rec_tab.LAST_OE_AGREEMENT_ID(i), FND_API.G_MISS_NUM, NULL, l_inst_rec_tab.LAST_OE_AGREEMENT_ID(i)),
	  decode( l_inst_rec_tab.INSTALL_DATE(i), FND_API.G_MISS_DATE, TO_DATE(NULL), l_inst_rec_tab.INSTALL_DATE(i)),
	  decode( l_inst_rec_tab.MANUALLY_CREATED_FLAG(i), FND_API.G_MISS_CHAR, NULL, l_inst_rec_tab.MANUALLY_CREATED_FLAG(i)),
	  decode( l_inst_rec_tab.RETURN_BY_DATE(i), FND_API.G_MISS_DATE, TO_DATE(NULL), l_inst_rec_tab.RETURN_BY_DATE(i)),
	  decode( l_inst_rec_tab.ACTUAL_RETURN_DATE(i), FND_API.G_MISS_DATE, TO_DATE(NULL), l_inst_rec_tab.ACTUAL_RETURN_DATE(i)),
	  decode( l_inst_rec_tab.CREATION_COMPLETE_FLAG(i), FND_API.G_MISS_CHAR, NULL, l_inst_rec_tab.CREATION_COMPLETE_FLAG(i)),
	  decode( l_inst_rec_tab.COMPLETENESS_FLAG(i), FND_API.G_MISS_CHAR, NULL, l_inst_rec_tab.COMPLETENESS_FLAG(i)),
	  decode( l_inst_rec_tab.CONTEXT(i), FND_API.G_MISS_CHAR, NULL, l_inst_rec_tab.CONTEXT(i)),
	  decode( l_inst_rec_tab.ATTRIBUTE1(i), FND_API.G_MISS_CHAR, NULL, l_inst_rec_tab.ATTRIBUTE1(i)),
	  decode( l_inst_rec_tab.ATTRIBUTE2(i), FND_API.G_MISS_CHAR, NULL, l_inst_rec_tab.ATTRIBUTE2(i)),
	  decode( l_inst_rec_tab.ATTRIBUTE3(i), FND_API.G_MISS_CHAR, NULL, l_inst_rec_tab.ATTRIBUTE3(i)),
	  decode( l_inst_rec_tab.ATTRIBUTE4(i), FND_API.G_MISS_CHAR, NULL, l_inst_rec_tab.ATTRIBUTE4(i)),
	  decode( l_inst_rec_tab.ATTRIBUTE5(i), FND_API.G_MISS_CHAR, NULL, l_inst_rec_tab.ATTRIBUTE5(i)),
	  decode( l_inst_rec_tab.ATTRIBUTE6(i), FND_API.G_MISS_CHAR, NULL, l_inst_rec_tab.ATTRIBUTE6(i)),
	  decode( l_inst_rec_tab.ATTRIBUTE7(i), FND_API.G_MISS_CHAR, NULL, l_inst_rec_tab.ATTRIBUTE7(i)),
	  decode( l_inst_rec_tab.ATTRIBUTE8(i), FND_API.G_MISS_CHAR, NULL, l_inst_rec_tab.ATTRIBUTE8(i)),
	  decode( l_inst_rec_tab.ATTRIBUTE9(i), FND_API.G_MISS_CHAR, NULL, l_inst_rec_tab.ATTRIBUTE9(i)),
	  decode( l_inst_rec_tab.ATTRIBUTE10(i), FND_API.G_MISS_CHAR, NULL, l_inst_rec_tab.ATTRIBUTE10(i)),
	  decode( l_inst_rec_tab.ATTRIBUTE11(i), FND_API.G_MISS_CHAR, NULL, l_inst_rec_tab.ATTRIBUTE11(i)),
	  decode( l_inst_rec_tab.ATTRIBUTE12(i), FND_API.G_MISS_CHAR, NULL, l_inst_rec_tab.ATTRIBUTE12(i)),
	  decode( l_inst_rec_tab.ATTRIBUTE13(i), FND_API.G_MISS_CHAR, NULL, l_inst_rec_tab.ATTRIBUTE13(i)),
	  decode( l_inst_rec_tab.ATTRIBUTE14(i), FND_API.G_MISS_CHAR, NULL, l_inst_rec_tab.ATTRIBUTE14(i)),
	  decode( l_inst_rec_tab.ATTRIBUTE15(i), FND_API.G_MISS_CHAR, NULL, l_inst_rec_tab.ATTRIBUTE15(i)),
	  l_user_id,
	  SYSDATE,
	  l_user_id,
	  SYSDATE,
	  l_login_id,
	  1,
	  decode( l_inst_rec_tab.LAST_TXN_LINE_DETAIL_ID(i), FND_API.G_MISS_NUM, NULL, l_inst_rec_tab.LAST_TXN_LINE_DETAIL_ID(i)),
	  decode( l_inst_rec_tab.INSTALL_LOCATION_TYPE_CODE(i), FND_API.G_MISS_CHAR, NULL, l_inst_rec_tab.INSTALL_LOCATION_TYPE_CODE(i)),
	  decode( l_inst_rec_tab.INSTALL_LOCATION_ID(i), FND_API.G_MISS_NUM, NULL, l_inst_rec_tab.INSTALL_LOCATION_ID(i)),
	  decode( l_inst_rec_tab.INSTANCE_USAGE_CODE(i), FND_API.G_MISS_CHAR, NULL, l_inst_rec_tab.INSTANCE_USAGE_CODE(i)),
	  decode( l_inst_rec_tab.vld_organization_id(i), FND_API.G_MISS_NUM, NULL, l_inst_rec_tab.vld_organization_id(i)),
          decode( l_inst_rec_tab.CONFIG_INST_HDR_ID(i), FND_API.G_MISS_NUM, NULL,l_inst_rec_tab.CONFIG_INST_HDR_ID(i)),
          decode( l_inst_rec_tab.CONFIG_INST_REV_NUM(i), FND_API.G_MISS_NUM, NULL,l_inst_rec_tab.CONFIG_INST_REV_NUM(i)),
          decode( l_inst_rec_tab.CONFIG_INST_ITEM_ID(i), FND_API.G_MISS_NUM, NULL,l_inst_rec_tab.CONFIG_INST_ITEM_ID(i)),
          decode( l_inst_rec_tab.CONFIG_VALID_STATUS(i), FND_API.G_MISS_CHAR, NULL,l_inst_rec_tab.CONFIG_VALID_STATUS(i)),
          decode( l_inst_rec_tab.INSTANCE_DESCRIPTION(i), FND_API.G_MISS_CHAR, NULL,l_inst_rec_tab.INSTANCE_DESCRIPTION(i)),
          decode( l_inst_rec_tab.NETWORK_ASSET_FLAG(i), FND_API.G_MISS_CHAR, NULL,l_inst_rec_tab.NETWORK_ASSET_FLAG(i)),
          decode( l_inst_rec_tab.MAINTAINABLE_FLAG(i), FND_API.G_MISS_CHAR, NULL,l_inst_rec_tab.MAINTAINABLE_FLAG(i)),
          decode( l_inst_rec_tab.ASSET_CRITICALITY_CODE(i), FND_API.G_MISS_CHAR, NULL,l_inst_rec_tab.ASSET_CRITICALITY_CODE(i)),
          decode( l_inst_rec_tab.CATEGORY_ID(i), FND_API.G_MISS_NUM, NULL,l_inst_rec_tab.CATEGORY_ID(i)),
          decode( l_inst_rec_tab.EQUIPMENT_GEN_OBJECT_ID(i), FND_API.G_MISS_NUM, NULL,l_inst_rec_tab.EQUIPMENT_GEN_OBJECT_ID(i)),
          decode( l_inst_rec_tab.INSTANTIATION_FLAG(i), FND_API.G_MISS_CHAR, NULL,l_inst_rec_tab.INSTANTIATION_FLAG(i)),
          decode( l_inst_rec_tab.OPERATIONAL_LOG_FLAG(i), FND_API.G_MISS_CHAR, NULL,l_inst_rec_tab.OPERATIONAL_LOG_FLAG(i)),
          decode( l_inst_rec_tab.SUPPLIER_WARRANTY_EXP_DATE(i), FND_API.G_MISS_DATE, NULL,l_inst_rec_tab.SUPPLIER_WARRANTY_EXP_DATE(i)),
	  decode( l_inst_rec_tab.ATTRIBUTE16(i), FND_API.G_MISS_CHAR, NULL, l_inst_rec_tab.ATTRIBUTE16(i)),
	  decode( l_inst_rec_tab.ATTRIBUTE17(i), FND_API.G_MISS_CHAR, NULL, l_inst_rec_tab.ATTRIBUTE17(i)),
	  decode( l_inst_rec_tab.ATTRIBUTE18(i), FND_API.G_MISS_CHAR, NULL, l_inst_rec_tab.ATTRIBUTE18(i)),
	  decode( l_inst_rec_tab.ATTRIBUTE19(i), FND_API.G_MISS_CHAR, NULL, l_inst_rec_tab.ATTRIBUTE19(i)),
	  decode( l_inst_rec_tab.ATTRIBUTE20(i), FND_API.G_MISS_CHAR, NULL, l_inst_rec_tab.ATTRIBUTE20(i)),
	  decode( l_inst_rec_tab.ATTRIBUTE21(i), FND_API.G_MISS_CHAR, NULL, l_inst_rec_tab.ATTRIBUTE21(i)),
	  decode( l_inst_rec_tab.ATTRIBUTE22(i), FND_API.G_MISS_CHAR, NULL, l_inst_rec_tab.ATTRIBUTE22(i)),
	  decode( l_inst_rec_tab.ATTRIBUTE23(i), FND_API.G_MISS_CHAR, NULL, l_inst_rec_tab.ATTRIBUTE23(i)),
	  decode( l_inst_rec_tab.ATTRIBUTE24(i), FND_API.G_MISS_CHAR, NULL, l_inst_rec_tab.ATTRIBUTE24(i)),
	  decode( l_inst_rec_tab.ATTRIBUTE25(i), FND_API.G_MISS_CHAR, NULL, l_inst_rec_tab.ATTRIBUTE25(i)),
	  decode( l_inst_rec_tab.ATTRIBUTE26(i), FND_API.G_MISS_CHAR, NULL, l_inst_rec_tab.ATTRIBUTE26(i)),
	  decode( l_inst_rec_tab.ATTRIBUTE27(i), FND_API.G_MISS_CHAR, NULL, l_inst_rec_tab.ATTRIBUTE27(i)),
	  decode( l_inst_rec_tab.ATTRIBUTE28(i), FND_API.G_MISS_CHAR, NULL, l_inst_rec_tab.ATTRIBUTE28(i)),
	  decode( l_inst_rec_tab.ATTRIBUTE29(i), FND_API.G_MISS_CHAR, NULL, l_inst_rec_tab.ATTRIBUTE29(i)),
	  decode( l_inst_rec_tab.ATTRIBUTE30(i), FND_API.G_MISS_CHAR, NULL, l_inst_rec_tab.ATTRIBUTE30(i)),
	  decode( l_inst_rec_tab.PURCHASE_UNIT_PRICE(i),FND_API.G_MISS_NUM, NULL,l_inst_rec_tab.PURCHASE_UNIT_PRICE(i)),
	  decode( l_inst_rec_tab.PURCHASE_CURRENCY_CODE(i),FND_API.G_MISS_CHAR, NULL,l_inst_rec_tab.PURCHASE_CURRENCY_CODE(i)),
	 decode( l_inst_rec_tab.PAYABLES_UNIT_PRICE(i),FND_API.G_MISS_NUM, NULL,l_inst_rec_tab.PAYABLES_UNIT_PRICE(i)),
	 decode( l_inst_rec_tab.PAYABLES_CURRENCY_CODE(i),FND_API.G_MISS_CHAR, NULL,l_inst_rec_tab.PAYABLES_CURRENCY_CODE(i)),
	 decode(l_inst_rec_tab.SALES_UNIT_PRICE(i),FND_API.G_MISS_NUM, NULL,l_inst_rec_tab.SALES_UNIT_PRICE(i)),
	 decode( l_inst_rec_tab.SALES_CURRENCY_CODE(i),FND_API.G_MISS_CHAR, NULL,l_inst_rec_tab.SALES_CURRENCY_CODE(i)),
	 decode( l_inst_rec_tab.OPERATIONAL_STATUS_CODE(i),FND_API.G_MISS_CHAR, NULL,l_inst_rec_tab.OPERATIONAL_STATUS_CODE(i))
         );
   END IF;
   --
   IF p_txn_tbl.count > 0 THEN
      Build_Txn_Rec_of_Table
        (
          p_txn_tbl     => p_txn_tbl
         ,p_txn_rec_tab => l_txn_rec_tab
        );
      --
      l_ctr := l_txn_rec_tab.transaction_id.count;
      --
      FORALL i in 1 .. l_ctr
         INSERT INTO CSI_TRANSACTIONS(
	    transaction_id,
	    transaction_date,
	    source_transaction_date,
	    transaction_type_id,
	    txn_sub_type_id,
	    source_group_ref_id,
	    source_group_ref,
	    source_header_ref_id,
	    source_header_ref,
	    source_line_ref_id,
	    source_line_ref,
	    source_dist_ref_id1,
	    source_dist_ref_id2,
	    inv_material_transaction_id,
	    transaction_quantity,
	    transaction_uom_code,
	    transacted_by,
	    transaction_status_code,
	    transaction_action_code,
	    message_id,
	    context,
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
	    last_update_login,
	    object_version_number,
	    split_reason_code,
            gl_interface_status_code
	   ) VALUES (
	    l_txn_rec_tab.transaction_id(i),
	    decode( l_txn_rec_tab.transaction_date(i), fnd_api.g_miss_date, to_date(null), l_txn_rec_tab.transaction_date(i)),
	    decode( l_txn_rec_tab.source_transaction_date(i), fnd_api.g_miss_date, to_date(null), l_txn_rec_tab.source_transaction_date(i)),
	    decode( l_txn_rec_tab.transaction_type_id(i), fnd_api.g_miss_num, null, l_txn_rec_tab.transaction_type_id(i)),
	    decode( l_txn_rec_tab.txn_sub_type_id(i), fnd_api.g_miss_num, null, l_txn_rec_tab.txn_sub_type_id(i)),
	    decode( l_txn_rec_tab.source_group_ref_id(i), fnd_api.g_miss_num, null, l_txn_rec_tab.source_group_ref_id(i)),
	    decode( l_txn_rec_tab.source_group_ref(i), fnd_api.g_miss_char, null, l_txn_rec_tab.source_group_ref(i)),
	    decode( l_txn_rec_tab.source_header_ref_id(i), fnd_api.g_miss_num, null, l_txn_rec_tab.source_header_ref_id(i)),
	    decode( l_txn_rec_tab.source_header_ref(i), fnd_api.g_miss_char, null, l_txn_rec_tab.source_header_ref(i)),
	    decode( l_txn_rec_tab.source_line_ref_id(i), fnd_api.g_miss_num, null, l_txn_rec_tab.source_line_ref_id(i)),
	    decode( l_txn_rec_tab.source_line_ref(i), fnd_api.g_miss_char, null, l_txn_rec_tab.source_line_ref(i)),
	    decode( l_txn_rec_tab.source_dist_ref_id1(i), fnd_api.g_miss_num, null, l_txn_rec_tab.source_dist_ref_id1(i)),
	    decode( l_txn_rec_tab.source_dist_ref_id2(i), fnd_api.g_miss_num, null, l_txn_rec_tab.source_dist_ref_id2(i)),
	    decode( l_txn_rec_tab.inv_material_transaction_id(i), fnd_api.g_miss_num, null, l_txn_rec_tab.inv_material_transaction_id(i)),
	    decode( l_txn_rec_tab.transaction_quantity(i), fnd_api.g_miss_num, null, l_txn_rec_tab.transaction_quantity(i)),
	    decode( l_txn_rec_tab.transaction_uom_code(i), fnd_api.g_miss_char, null, l_txn_rec_tab.transaction_uom_code(i)),
	    decode( l_txn_rec_tab.transacted_by(i), fnd_api.g_miss_num, null, l_txn_rec_tab.transacted_by(i)),
	    decode( l_txn_rec_tab.transaction_status_code(i), fnd_api.g_miss_char, null, l_txn_rec_tab.transaction_status_code(i)),
	    decode( l_txn_rec_tab.transaction_action_code(i), fnd_api.g_miss_char, null, l_txn_rec_tab.transaction_action_code(i)),
	    decode( l_txn_rec_tab.message_id(i), fnd_api.g_miss_num, null, l_txn_rec_tab.message_id(i)),
	    decode( l_txn_rec_tab.context(i), fnd_api.g_miss_char, null, l_txn_rec_tab.context(i)),
	    decode( l_txn_rec_tab.attribute1(i), fnd_api.g_miss_char, null, l_txn_rec_tab.attribute1(i)),
	    decode( l_txn_rec_tab.attribute2(i), fnd_api.g_miss_char, null, l_txn_rec_tab.attribute2(i)),
	    decode( l_txn_rec_tab.attribute3(i), fnd_api.g_miss_char, null, l_txn_rec_tab.attribute3(i)),
	    decode( l_txn_rec_tab.attribute4(i), fnd_api.g_miss_char, null, l_txn_rec_tab.attribute4(i)),
	    decode( l_txn_rec_tab.attribute5(i), fnd_api.g_miss_char, null, l_txn_rec_tab.attribute5(i)),
	    decode( l_txn_rec_tab.attribute6(i), fnd_api.g_miss_char, null, l_txn_rec_tab.attribute6(i)),
	    decode( l_txn_rec_tab.attribute7(i), fnd_api.g_miss_char, null, l_txn_rec_tab.attribute7(i)),
	    decode( l_txn_rec_tab.attribute8(i), fnd_api.g_miss_char, null, l_txn_rec_tab.attribute8(i)),
	    decode( l_txn_rec_tab.attribute9(i), fnd_api.g_miss_char, null, l_txn_rec_tab.attribute9(i)),
	    decode( l_txn_rec_tab.attribute10(i), fnd_api.g_miss_char, null, l_txn_rec_tab.attribute10(i)),
	    decode( l_txn_rec_tab.attribute11(i), fnd_api.g_miss_char, null, l_txn_rec_tab.attribute11(i)),
	    decode( l_txn_rec_tab.attribute12(i), fnd_api.g_miss_char, null, l_txn_rec_tab.attribute12(i)),
	    decode( l_txn_rec_tab.attribute13(i), fnd_api.g_miss_char, null, l_txn_rec_tab.attribute13(i)),
	    decode( l_txn_rec_tab.attribute14(i), fnd_api.g_miss_char, null, l_txn_rec_tab.attribute14(i)),
	    decode( l_txn_rec_tab.attribute15(i), fnd_api.g_miss_char, null, l_txn_rec_tab.attribute15(i)),
	    l_user_id,
	    SYSDATE,
	    l_user_id,
	    SYSDATE,
	    l_login_id,
	    1,
	    decode( l_txn_rec_tab.split_reason_code(i), fnd_api.g_miss_char, null, l_txn_rec_tab.split_reason_code(i)),
	    decode( l_txn_rec_tab.gl_interface_status_code(i), fnd_api.g_miss_num, null, l_txn_rec_tab.gl_interface_status_code(i))
	    );
   END IF;
   --
   IF p_inst_hist_tbl.count > 0 THEN
      Build_Inst_Hist_Rec_of_Table
       ( p_inst_hist_tbl     => p_inst_hist_tbl
        ,p_inst_hist_rec_tab => l_inst_hist_rec_tab
       );
      --
      l_ctr := l_inst_hist_rec_tab.instance_history_id.count;
      --
      FORALL i in 1 .. l_ctr
         INSERT INTO CSI_ITEM_INSTANCES_H(
		 INSTANCE_HISTORY_ID,
		 INSTANCE_ID,
		 TRANSACTION_ID,
		 OLD_INSTANCE_NUMBER,
		 NEW_INSTANCE_NUMBER,
		 OLD_EXTERNAL_REFERENCE,
		 NEW_EXTERNAL_REFERENCE,
		 OLD_INVENTORY_ITEM_ID,
		 NEW_INVENTORY_ITEM_ID,
		 OLD_INVENTORY_REVISION,
		 NEW_INVENTORY_REVISION,
		 OLD_INV_MASTER_ORGANIZATION_ID,
		 NEW_INV_MASTER_ORGANIZATION_ID,
		 OLD_SERIAL_NUMBER,
		 NEW_SERIAL_NUMBER ,
		 OLD_MFG_SERIAL_NUMBER_FLAG,
		 NEW_MFG_SERIAL_NUMBER_FLAG,
		 OLD_LOT_NUMBER,
		 NEW_LOT_NUMBER,
		 OLD_QUANTITY,
		 NEW_QUANTITY,
		 OLD_UNIT_OF_MEASURE,
		 NEW_UNIT_OF_MEASURE,
		 OLD_ACCOUNTING_CLASS_CODE,
		 NEW_ACCOUNTING_CLASS_CODE,
		 OLD_INSTANCE_CONDITION_ID,
		 NEW_INSTANCE_CONDITION_ID,
		 OLD_INSTANCE_STATUS_ID,
		 NEW_INSTANCE_STATUS_ID,
		 OLD_CUSTOMER_VIEW_FLAG,
		 NEW_CUSTOMER_VIEW_FLAG,
		 OLD_MERCHANT_VIEW_FLAG,
		 NEW_MERCHANT_VIEW_FLAG,
		 OLD_SELLABLE_FLAG,
		 NEW_SELLABLE_FLAG,
		 OLD_SYSTEM_ID,
		 NEW_SYSTEM_ID,
		 OLD_INSTANCE_TYPE_CODE,
		 NEW_INSTANCE_TYPE_CODE,
		 OLD_ACTIVE_START_DATE,
		 NEW_ACTIVE_START_DATE,
		 OLD_ACTIVE_END_DATE,
		 NEW_ACTIVE_END_DATE,
		 OLD_LOCATION_TYPE_CODE,
		 NEW_LOCATION_TYPE_CODE,
		 OLD_LOCATION_ID,
		 NEW_LOCATION_ID,
		 OLD_INV_ORGANIZATION_ID,
		 NEW_INV_ORGANIZATION_ID,
		 OLD_INV_SUBINVENTORY_NAME,
		 NEW_INV_SUBINVENTORY_NAME,
		 OLD_INV_LOCATOR_ID,
		 NEW_INV_LOCATOR_ID,
		 OLD_PA_PROJECT_ID,
		 NEW_PA_PROJECT_ID,
		 OLD_PA_PROJECT_TASK_ID,
		 NEW_PA_PROJECT_TASK_ID,
		 OLD_IN_TRANSIT_ORDER_LINE_ID,
		 NEW_IN_TRANSIT_ORDER_LINE_ID,
		 OLD_WIP_JOB_ID,
		 NEW_WIP_JOB_ID,
		 OLD_PO_ORDER_LINE_ID,
		 NEW_PO_ORDER_LINE_ID,
		 OLD_COMPLETENESS_FLAG,
		 NEW_COMPLETENESS_FLAG,
		 FULL_DUMP_FLAG,
		 OLD_CONTEXT,
		 NEW_CONTEXT,
		 OLD_ATTRIBUTE1,
		 NEW_ATTRIBUTE1,
		 OLD_ATTRIBUTE2,
		 NEW_ATTRIBUTE2,
		 OLD_ATTRIBUTE3,
		 NEW_ATTRIBUTE3,
		 OLD_ATTRIBUTE4,
		 NEW_ATTRIBUTE4,
		 OLD_ATTRIBUTE5,
		 NEW_ATTRIBUTE5,
		 OLD_ATTRIBUTE6,
		 NEW_ATTRIBUTE6,
		 OLD_ATTRIBUTE7,
		 NEW_ATTRIBUTE7,
		 OLD_ATTRIBUTE8,
		 NEW_ATTRIBUTE8,
		 OLD_ATTRIBUTE9,
		 NEW_ATTRIBUTE9,
		 OLD_ATTRIBUTE10,
		 NEW_ATTRIBUTE10,
		 OLD_ATTRIBUTE11,
		 NEW_ATTRIBUTE11,
		 OLD_ATTRIBUTE12,
		 NEW_ATTRIBUTE12,
		 OLD_ATTRIBUTE13,
		 NEW_ATTRIBUTE13,
		 OLD_ATTRIBUTE14,
		 NEW_ATTRIBUTE14,
		 OLD_ATTRIBUTE15,
		 NEW_ATTRIBUTE15,
		 CREATED_BY,
		 CREATION_DATE,
		 LAST_UPDATED_BY,
		 LAST_UPDATE_DATE,
		 LAST_UPDATE_LOGIN,
		 OBJECT_VERSION_NUMBER,
		 OLD_INST_LOC_TYPE_CODE,
		 NEW_INST_LOC_TYPE_CODE,
		 OLD_INST_LOC_ID,
		 NEW_INST_LOC_ID,
		 OLD_INST_USAGE_CODE,
		 NEW_INST_USAGE_CODE,
		 OLD_last_vld_organization_id,
		 NEW_last_vld_organization_id,
		 OLD_CONFIG_INST_REV_NUM   ,
		 NEW_CONFIG_INST_REV_NUM   ,
		 OLD_CONFIG_VALID_STATUS   ,
		 NEW_CONFIG_VALID_STATUS   ,
		 OLD_INSTANCE_DESCRIPTION  ,
		 NEW_INSTANCE_DESCRIPTION  ,
                 OLD_OE_AGREEMENT_ID ,
                 NEW_OE_AGREEMENT_ID ,
                 OLD_INSTALL_DATE ,
		 NEW_INSTALL_DATE ,
		 OLD_RETURN_BY_DATE ,
		 NEW_RETURN_BY_DATE ,
		 OLD_ACTUAL_RETURN_DATE ,
		 NEW_ACTUAL_RETURN_DATE ,
		 OLD_LAST_OE_ORDER_LINE_ID ,
		 NEW_LAST_OE_ORDER_LINE_ID ,
		 OLD_LAST_OE_RMA_LINE_ID ,
		 NEW_LAST_OE_RMA_LINE_ID ,
		 OLD_LAST_WIP_JOB_ID ,
		 NEW_LAST_WIP_JOB_ID ,
		 OLD_LAST_PO_PO_LINE_ID ,
		 NEW_LAST_PO_PO_LINE_ID ,
		 OLD_LAST_PA_PROJECT_ID ,
		 NEW_LAST_PA_PROJECT_ID ,
		 OLD_LAST_PA_TASK_ID ,
		 NEW_LAST_PA_TASK_ID ,
		 OLD_LAST_TXN_LINE_DETAIL_ID ,
		 NEW_LAST_TXN_LINE_DETAIL_ID ,
		 OLD_LAST_OE_PO_NUMBER ,
		 NEW_LAST_OE_PO_NUMBER,

		 OLD_NETWORK_ASSET_FLAG,
		 NEW_NETWORK_ASSET_FLAG,
		 OLD_MAINTAINABLE_FLAG,
		 NEW_MAINTAINABLE_FLAG,
		 OLD_ASSET_CRITICALITY_CODE,
		 NEW_ASSET_CRITICALITY_CODE,
		 OLD_CATEGORY_ID          ,
		 NEW_CATEGORY_ID          ,
		 OLD_EQUIPMENT_GEN_OBJECT_ID,
		 NEW_EQUIPMENT_GEN_OBJECT_ID,
		 OLD_INSTANTIATION_FLAG     ,
		 NEW_INSTANTIATION_FLAG     ,
		 OLD_OPERATIONAL_LOG_FLAG   ,
		 NEW_OPERATIONAL_LOG_FLAG   ,
		 OLD_SUPPLIER_WARRANTY_EXP_DATE,
		 NEW_SUPPLIER_WARRANTY_EXP_DATE,
		 OLD_ATTRIBUTE16,
		 NEW_ATTRIBUTE16,
		 OLD_ATTRIBUTE17,
		 NEW_ATTRIBUTE17,
		 OLD_ATTRIBUTE18,
		 NEW_ATTRIBUTE18,
		 OLD_ATTRIBUTE19,
		 NEW_ATTRIBUTE19,
		 OLD_ATTRIBUTE20,
		 NEW_ATTRIBUTE20,
		 OLD_ATTRIBUTE21,
		 NEW_ATTRIBUTE21,
		 OLD_ATTRIBUTE22,
		 NEW_ATTRIBUTE22,
		 OLD_ATTRIBUTE23,
		 NEW_ATTRIBUTE23,
		 OLD_ATTRIBUTE24,
		 NEW_ATTRIBUTE24,
		 OLD_ATTRIBUTE25,
		 NEW_ATTRIBUTE25,
		 OLD_ATTRIBUTE26,
		 NEW_ATTRIBUTE26,
		 OLD_ATTRIBUTE27,
		 NEW_ATTRIBUTE27,
		 OLD_ATTRIBUTE28,
		 NEW_ATTRIBUTE28,
		 OLD_ATTRIBUTE29,
		 NEW_ATTRIBUTE29,
		 OLD_ATTRIBUTE30,
		 NEW_ATTRIBUTE30,
                 OLD_PAYABLES_CURRENCY_CODE,
                 NEW_PAYABLES_CURRENCY_CODE,
                 OLD_PURCHASE_UNIT_PRICE,
                 NEW_PURCHASE_UNIT_PRICE,
                 OLD_PURCHASE_CURRENCY_CODE,
                 NEW_PURCHASE_CURRENCY_CODE,
                 OLD_PAYABLES_UNIT_PRICE,
                 NEW_PAYABLES_UNIT_PRICE,
                 OLD_SALES_UNIT_PRICE,
                 NEW_SALES_UNIT_PRICE,
                 OLD_SALES_CURRENCY_CODE,
                 NEW_SALES_CURRENCY_CODE,
                 OLD_OPERATIONAL_STATUS_CODE,
                 NEW_OPERATIONAL_STATUS_CODE
                )
		 VALUES (
		 l_inst_hist_rec_tab.INSTANCE_HISTORY_ID(i),
		 decode( l_inst_hist_rec_tab.INSTANCE_ID(i), FND_API.G_MISS_NUM, NULL, l_inst_hist_rec_tab.INSTANCE_ID(i)),
		 decode( l_inst_hist_rec_tab.TRANSACTION_ID(i), FND_API.G_MISS_NUM, NULL, l_inst_hist_rec_tab.TRANSACTION_ID(i)),
		 decode( l_inst_hist_rec_tab.OLD_INSTANCE_NUMBER(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.OLD_INSTANCE_NUMBER(i)),
		 decode( l_inst_hist_rec_tab.NEW_INSTANCE_NUMBER(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.NEW_INSTANCE_NUMBER(i)),
		 decode( l_inst_hist_rec_tab.OLD_EXTERNAL_REFERENCE(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.OLD_EXTERNAL_REFERENCE(i)),
		 decode( l_inst_hist_rec_tab.NEW_EXTERNAL_REFERENCE(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.NEW_EXTERNAL_REFERENCE(i)),
		 decode( l_inst_hist_rec_tab.OLD_INVENTORY_ITEM_ID(i), FND_API.G_MISS_NUM, NULL, l_inst_hist_rec_tab.OLD_INVENTORY_ITEM_ID(i)),
		 decode( l_inst_hist_rec_tab.NEW_INVENTORY_ITEM_ID(i), FND_API.G_MISS_NUM, NULL, l_inst_hist_rec_tab.NEW_INVENTORY_ITEM_ID(i)),
		 decode( l_inst_hist_rec_tab.OLD_INVENTORY_REVISION(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.OLD_INVENTORY_REVISION(i)),
		 decode( l_inst_hist_rec_tab.NEW_INVENTORY_REVISION(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.NEW_INVENTORY_REVISION(i)),
		 decode( l_inst_hist_rec_tab.OLD_INV_MASTER_ORG_ID(i), FND_API.G_MISS_NUM, NULL, l_inst_hist_rec_tab.OLD_INV_MASTER_ORG_ID(i)),
		 decode( l_inst_hist_rec_tab.NEW_INV_MASTER_ORG_ID(i), FND_API.G_MISS_NUM, NULL, l_inst_hist_rec_tab.NEW_INV_MASTER_ORG_ID(i)),
		 decode( l_inst_hist_rec_tab.OLD_SERIAL_NUMBER(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.OLD_SERIAL_NUMBER(i)),
		 decode( l_inst_hist_rec_tab.NEW_SERIAL_NUMBER(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.NEW_SERIAL_NUMBER(i)),
		 decode( l_inst_hist_rec_tab.OLD_MFG_SERIAL_NUMBER_FLAG(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.OLD_MFG_SERIAL_NUMBER_FLAG(i)),
		 decode( l_inst_hist_rec_tab.NEW_MFG_SERIAL_NUMBER_FLAG(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.NEW_MFG_SERIAL_NUMBER_FLAG(i)),
		 decode( l_inst_hist_rec_tab.OLD_LOT_NUMBER(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.OLD_LOT_NUMBER(i)),
		 decode( l_inst_hist_rec_tab.NEW_LOT_NUMBER(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.NEW_LOT_NUMBER(i)),
		 decode( l_inst_hist_rec_tab.OLD_QUANTITY(i), FND_API.G_MISS_NUM, NULL, l_inst_hist_rec_tab.OLD_QUANTITY(i)),
		 decode( l_inst_hist_rec_tab.NEW_QUANTITY(i), FND_API.G_MISS_NUM, NULL, l_inst_hist_rec_tab.NEW_QUANTITY(i)),
		 decode( l_inst_hist_rec_tab.OLD_UNIT_OF_MEASURE(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.OLD_UNIT_OF_MEASURE(i)),
		 decode( l_inst_hist_rec_tab.NEW_UNIT_OF_MEASURE(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.NEW_UNIT_OF_MEASURE(i)),
		 decode( l_inst_hist_rec_tab.OLD_ACCOUNTING_CLASS_CODE(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.OLD_ACCOUNTING_CLASS_CODE(i)),
		 decode( l_inst_hist_rec_tab.NEW_ACCOUNTING_CLASS_CODE(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.NEW_ACCOUNTING_CLASS_CODE(i)),
		 decode( l_inst_hist_rec_tab.OLD_INSTANCE_CONDITION_ID(i), FND_API.G_MISS_NUM, NULL, l_inst_hist_rec_tab.OLD_INSTANCE_CONDITION_ID(i)),
		 decode( l_inst_hist_rec_tab.NEW_INSTANCE_CONDITION_ID(i), FND_API.G_MISS_NUM, NULL, l_inst_hist_rec_tab.NEW_INSTANCE_CONDITION_ID(i)),
		 decode( l_inst_hist_rec_tab.OLD_INSTANCE_STATUS_ID(i), FND_API.G_MISS_NUM, NULL, l_inst_hist_rec_tab.OLD_INSTANCE_STATUS_ID(i)),
		 decode( l_inst_hist_rec_tab.NEW_INSTANCE_STATUS_ID(i), FND_API.G_MISS_NUM, NULL, l_inst_hist_rec_tab.NEW_INSTANCE_STATUS_ID(i)),
		 decode( l_inst_hist_rec_tab.OLD_CUSTOMER_VIEW_FLAG(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.OLD_CUSTOMER_VIEW_FLAG(i)),
		 decode( l_inst_hist_rec_tab.NEW_CUSTOMER_VIEW_FLAG(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.NEW_CUSTOMER_VIEW_FLAG(i)),
		 decode( l_inst_hist_rec_tab.OLD_MERCHANT_VIEW_FLAG(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.OLD_MERCHANT_VIEW_FLAG(i)),
		 decode( l_inst_hist_rec_tab.NEW_MERCHANT_VIEW_FLAG(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.NEW_MERCHANT_VIEW_FLAG(i)),
		 decode( l_inst_hist_rec_tab.OLD_SELLABLE_FLAG(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.OLD_SELLABLE_FLAG(i)),
		 decode( l_inst_hist_rec_tab.NEW_SELLABLE_FLAG(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.NEW_SELLABLE_FLAG(i)),
		 decode( l_inst_hist_rec_tab.OLD_SYSTEM_ID(i), FND_API.G_MISS_NUM, NULL, l_inst_hist_rec_tab.OLD_SYSTEM_ID(i)),
		 decode( l_inst_hist_rec_tab.NEW_SYSTEM_ID(i), FND_API.G_MISS_NUM, NULL, l_inst_hist_rec_tab.NEW_SYSTEM_ID(i)),
		 decode( l_inst_hist_rec_tab.OLD_INSTANCE_TYPE_CODE(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.OLD_INSTANCE_TYPE_CODE(i)),
		 decode( l_inst_hist_rec_tab.NEW_INSTANCE_TYPE_CODE(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.NEW_INSTANCE_TYPE_CODE(i)),
		 decode( l_inst_hist_rec_tab.OLD_ACTIVE_START_DATE(i), FND_API.G_MISS_DATE, TO_DATE(NULL), l_inst_hist_rec_tab.OLD_ACTIVE_START_DATE(i)),
		 decode( l_inst_hist_rec_tab.NEW_ACTIVE_START_DATE(i), FND_API.G_MISS_DATE, TO_DATE(NULL), l_inst_hist_rec_tab.NEW_ACTIVE_START_DATE(i)),
		 decode( l_inst_hist_rec_tab.OLD_ACTIVE_END_DATE(i), FND_API.G_MISS_DATE, TO_DATE(NULL), l_inst_hist_rec_tab.OLD_ACTIVE_END_DATE(i)),
		 decode( l_inst_hist_rec_tab.NEW_ACTIVE_END_DATE(i), FND_API.G_MISS_DATE, TO_DATE(NULL), l_inst_hist_rec_tab.NEW_ACTIVE_END_DATE(i)),
		 decode( l_inst_hist_rec_tab.OLD_LOCATION_TYPE_CODE(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.OLD_LOCATION_TYPE_CODE(i)),
		 decode( l_inst_hist_rec_tab.NEW_LOCATION_TYPE_CODE(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.NEW_LOCATION_TYPE_CODE(i)),
		 decode( l_inst_hist_rec_tab.OLD_LOCATION_ID(i), FND_API.G_MISS_NUM, NULL, l_inst_hist_rec_tab.OLD_LOCATION_ID(i)),
		 decode( l_inst_hist_rec_tab.NEW_LOCATION_ID(i), FND_API.G_MISS_NUM, NULL, l_inst_hist_rec_tab.NEW_LOCATION_ID(i)),
		 decode( l_inst_hist_rec_tab.OLD_INV_ORGANIZATION_ID(i), FND_API.G_MISS_NUM, NULL, l_inst_hist_rec_tab.OLD_INV_ORGANIZATION_ID(i)),
		 decode( l_inst_hist_rec_tab.NEW_INV_ORGANIZATION_ID(i), FND_API.G_MISS_NUM, NULL, l_inst_hist_rec_tab.NEW_INV_ORGANIZATION_ID(i)),
		 decode( l_inst_hist_rec_tab.OLD_INV_SUBINVENTORY_NAME(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.OLD_INV_SUBINVENTORY_NAME(i)),
		 decode( l_inst_hist_rec_tab.NEW_INV_SUBINVENTORY_NAME(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.NEW_INV_SUBINVENTORY_NAME(i)),
		 decode( l_inst_hist_rec_tab.OLD_INV_LOCATOR_ID(i), FND_API.G_MISS_NUM, NULL, l_inst_hist_rec_tab.OLD_INV_LOCATOR_ID(i)),
		 decode( l_inst_hist_rec_tab.NEW_INV_LOCATOR_ID(i), FND_API.G_MISS_NUM, NULL, l_inst_hist_rec_tab.NEW_INV_LOCATOR_ID(i)),
		 decode( l_inst_hist_rec_tab.OLD_PA_PROJECT_ID(i), FND_API.G_MISS_NUM, NULL, l_inst_hist_rec_tab.OLD_PA_PROJECT_ID(i)),
		 decode( l_inst_hist_rec_tab.NEW_PA_PROJECT_ID(i), FND_API.G_MISS_NUM, NULL, l_inst_hist_rec_tab.NEW_PA_PROJECT_ID(i)),
		 decode( l_inst_hist_rec_tab.OLD_PA_PROJECT_TASK_ID(i), FND_API.G_MISS_NUM, NULL, l_inst_hist_rec_tab.OLD_PA_PROJECT_TASK_ID(i)),
		 decode( l_inst_hist_rec_tab.NEW_PA_PROJECT_TASK_ID(i), FND_API.G_MISS_NUM, NULL, l_inst_hist_rec_tab.NEW_PA_PROJECT_TASK_ID(i)),
		 decode( l_inst_hist_rec_tab.OLD_IN_TRANSIT_ORDER_LINE_ID(i), FND_API.G_MISS_NUM, NULL, l_inst_hist_rec_tab.OLD_IN_TRANSIT_ORDER_LINE_ID(i)),
		 decode( l_inst_hist_rec_tab.NEW_IN_TRANSIT_ORDER_LINE_ID(i), FND_API.G_MISS_NUM, NULL, l_inst_hist_rec_tab.NEW_IN_TRANSIT_ORDER_LINE_ID(i)),
		 decode( l_inst_hist_rec_tab.OLD_WIP_JOB_ID(i), FND_API.G_MISS_NUM, NULL, l_inst_hist_rec_tab.OLD_WIP_JOB_ID(i)),
		 decode( l_inst_hist_rec_tab.NEW_WIP_JOB_ID(i), FND_API.G_MISS_NUM, NULL, l_inst_hist_rec_tab.NEW_WIP_JOB_ID(i)),
		 decode( l_inst_hist_rec_tab.OLD_PO_ORDER_LINE_ID(i), FND_API.G_MISS_NUM, NULL, l_inst_hist_rec_tab.OLD_PO_ORDER_LINE_ID(i)),
		 decode( l_inst_hist_rec_tab.NEW_PO_ORDER_LINE_ID(i), FND_API.G_MISS_NUM, NULL, l_inst_hist_rec_tab.NEW_PO_ORDER_LINE_ID(i)),
		 decode( l_inst_hist_rec_tab.OLD_COMPLETENESS_FLAG(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.OLD_COMPLETENESS_FLAG(i)),
		 decode( l_inst_hist_rec_tab.NEW_COMPLETENESS_FLAG(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.NEW_COMPLETENESS_FLAG(i)),
		 'N',
		 decode( l_inst_hist_rec_tab.OLD_CONTEXT(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.OLD_CONTEXT(i)),
		 decode( l_inst_hist_rec_tab.NEW_CONTEXT(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.NEW_CONTEXT(i)),
		 decode( l_inst_hist_rec_tab.OLD_ATTRIBUTE1(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.OLD_ATTRIBUTE1(i)),
		 decode( l_inst_hist_rec_tab.NEW_ATTRIBUTE1(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.NEW_ATTRIBUTE1(i)),
		 decode( l_inst_hist_rec_tab.OLD_ATTRIBUTE2(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.OLD_ATTRIBUTE2(i)),
		 decode( l_inst_hist_rec_tab.NEW_ATTRIBUTE2(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.NEW_ATTRIBUTE2(i)),
		 decode( l_inst_hist_rec_tab.OLD_ATTRIBUTE3(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.OLD_ATTRIBUTE3(i)),
		 decode( l_inst_hist_rec_tab.NEW_ATTRIBUTE3(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.NEW_ATTRIBUTE3(i)),
		 decode( l_inst_hist_rec_tab.OLD_ATTRIBUTE4(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.OLD_ATTRIBUTE4(i)),
		 decode( l_inst_hist_rec_tab.NEW_ATTRIBUTE4(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.NEW_ATTRIBUTE4(i)),
		 decode( l_inst_hist_rec_tab.OLD_ATTRIBUTE5(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.OLD_ATTRIBUTE5(i)),
		 decode( l_inst_hist_rec_tab.NEW_ATTRIBUTE5(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.NEW_ATTRIBUTE5(i)),
		 decode( l_inst_hist_rec_tab.OLD_ATTRIBUTE6(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.OLD_ATTRIBUTE6(i)),
		 decode( l_inst_hist_rec_tab.NEW_ATTRIBUTE6(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.NEW_ATTRIBUTE6(i)),
		 decode( l_inst_hist_rec_tab.OLD_ATTRIBUTE7(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.OLD_ATTRIBUTE7(i)),
		 decode( l_inst_hist_rec_tab.NEW_ATTRIBUTE7(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.NEW_ATTRIBUTE7(i)),
		 decode( l_inst_hist_rec_tab.OLD_ATTRIBUTE8(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.OLD_ATTRIBUTE8(i)),
		 decode( l_inst_hist_rec_tab.NEW_ATTRIBUTE8(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.NEW_ATTRIBUTE8(i)),
		 decode( l_inst_hist_rec_tab.OLD_ATTRIBUTE9(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.OLD_ATTRIBUTE9(i)),
		 decode( l_inst_hist_rec_tab.NEW_ATTRIBUTE9(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.NEW_ATTRIBUTE9(i)),
		 decode( l_inst_hist_rec_tab.OLD_ATTRIBUTE10(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.OLD_ATTRIBUTE10(i)),
		 decode( l_inst_hist_rec_tab.NEW_ATTRIBUTE10(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.NEW_ATTRIBUTE10(i)),
		 decode( l_inst_hist_rec_tab.OLD_ATTRIBUTE11(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.OLD_ATTRIBUTE11(i)),
		 decode( l_inst_hist_rec_tab.NEW_ATTRIBUTE11(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.NEW_ATTRIBUTE11(i)),
		 decode( l_inst_hist_rec_tab.OLD_ATTRIBUTE12(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.OLD_ATTRIBUTE12(i)),
		 decode( l_inst_hist_rec_tab.NEW_ATTRIBUTE12(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.NEW_ATTRIBUTE12(i)),
		 decode( l_inst_hist_rec_tab.OLD_ATTRIBUTE13(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.OLD_ATTRIBUTE13(i)),
		 decode( l_inst_hist_rec_tab.NEW_ATTRIBUTE13(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.NEW_ATTRIBUTE13(i)),
		 decode( l_inst_hist_rec_tab.OLD_ATTRIBUTE14(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.OLD_ATTRIBUTE14(i)),
		 decode( l_inst_hist_rec_tab.NEW_ATTRIBUTE14(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.NEW_ATTRIBUTE14(i)),
		 decode( l_inst_hist_rec_tab.OLD_ATTRIBUTE15(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.OLD_ATTRIBUTE15(i)),
		 decode( l_inst_hist_rec_tab.NEW_ATTRIBUTE15(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.NEW_ATTRIBUTE15(i)),
		 l_user_id,
		 SYSDATE,
		 l_user_id,
		 SYSDATE,
		 l_login_id,
		 1,
		 decode( l_inst_hist_rec_tab.OLD_INSTALL_LOCATION_TYPE_CODE(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.OLD_INSTALL_LOCATION_TYPE_CODE(i)),
		 decode( l_inst_hist_rec_tab.NEW_INSTALL_LOCATION_TYPE_CODE(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.NEW_INSTALL_LOCATION_TYPE_CODE(i)),
		 decode( l_inst_hist_rec_tab.OLD_INSTALL_LOCATION_ID(i), FND_API.G_MISS_NUM, NULL, l_inst_hist_rec_tab.OLD_INSTALL_LOCATION_ID(i)),
		 decode( l_inst_hist_rec_tab.NEW_INSTALL_LOCATION_ID(i), FND_API.G_MISS_NUM, NULL, l_inst_hist_rec_tab.NEW_INSTALL_LOCATION_ID(i)),
		 decode( l_inst_hist_rec_tab.OLD_INSTANCE_USAGE_CODE(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.OLD_INSTANCE_USAGE_CODE(i)),
		 decode( l_inst_hist_rec_tab.NEW_INSTANCE_USAGE_CODE(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.NEW_INSTANCE_USAGE_CODE(i)),
		 decode( l_inst_hist_rec_tab.OLD_last_vld_organization_id(i), FND_API.G_MISS_NUM, NULL, l_inst_hist_rec_tab.OLD_last_vld_organization_id(i)),
		 decode( l_inst_hist_rec_tab.NEW_last_vld_organization_id(i), FND_API.G_MISS_NUM, NULL, l_inst_hist_rec_tab.new_last_vld_organization_id(i)),
		 decode( l_inst_hist_rec_tab.OLD_CONFIG_INST_REV_NUM(i), FND_API.G_MISS_NUM, NULL, l_inst_hist_rec_tab.OLD_CONFIG_INST_REV_NUM(i)),
		 decode( l_inst_hist_rec_tab.NEW_CONFIG_INST_REV_NUM(i), FND_API.G_MISS_NUM, NULL, l_inst_hist_rec_tab.NEW_CONFIG_INST_REV_NUM(i)),
		 decode( l_inst_hist_rec_tab.OLD_CONFIG_VALID_STATUS(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.OLD_CONFIG_VALID_STATUS(i)),
		 decode( l_inst_hist_rec_tab.NEW_CONFIG_VALID_STATUS(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.NEW_CONFIG_VALID_STATUS(i)),
		 decode( l_inst_hist_rec_tab.OLD_INSTANCE_DESCRIPTION(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.OLD_INSTANCE_DESCRIPTION(i)),
		 decode( l_inst_hist_rec_tab.NEW_INSTANCE_DESCRIPTION(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.NEW_INSTANCE_DESCRIPTION(i)),
                 decode( l_inst_hist_rec_tab.OLD_LAST_OE_AGREEMENT_ID(i),FND_API.G_MISS_NUM, NULL,l_inst_hist_rec_tab.OLD_LAST_OE_AGREEMENT_ID(i)),
                 decode( l_inst_hist_rec_tab.NEW_LAST_OE_AGREEMENT_ID(i),FND_API.G_MISS_NUM, NULL,l_inst_hist_rec_tab.NEW_LAST_OE_AGREEMENT_ID(i)),
                 decode( l_inst_hist_rec_tab.OLD_INSTALL_DATE(i),FND_API.G_MISS_DATE, NULL, l_inst_hist_rec_tab.OLD_INSTALL_DATE(i)) ,
		 decode(l_inst_hist_rec_tab.NEW_INSTALL_DATE(i),FND_API.G_MISS_DATE, NULL, l_inst_hist_rec_tab.NEW_INSTALL_DATE(i)) ,
		 decode(l_inst_hist_rec_tab.OLD_RETURN_BY_DATE(i) ,FND_API.G_MISS_DATE,NULL, l_inst_hist_rec_tab.OLD_RETURN_BY_DATE(i)),
		 decode(l_inst_hist_rec_tab.NEW_RETURN_BY_DATE(i) ,FND_API.G_MISS_DATE,NULL,l_inst_hist_rec_tab.NEW_RETURN_BY_DATE(i)),
		 decode(l_inst_hist_rec_tab.OLD_ACTUAL_RETURN_DATE(i) ,FND_API.G_MISS_DATE,NULL,l_inst_hist_rec_tab.OLD_ACTUAL_RETURN_DATE(i)),
		 decode(l_inst_hist_rec_tab.NEW_ACTUAL_RETURN_DATE(i) ,FND_API.G_MISS_DATE,NULL,l_inst_hist_rec_tab.NEW_ACTUAL_RETURN_DATE(i)),
		 decode(l_inst_hist_rec_tab.OLD_LAST_OE_ORDER_LINE_ID(i) ,FND_API.G_MISS_NUM,NULL,l_inst_hist_rec_tab.OLD_LAST_OE_ORDER_LINE_ID(i)),
		 decode(l_inst_hist_rec_tab.NEW_LAST_OE_ORDER_LINE_ID(i) ,FND_API.G_MISS_NUM,NULL,l_inst_hist_rec_tab.NEW_LAST_OE_ORDER_LINE_ID(i)),
		 decode(l_inst_hist_rec_tab.OLD_LAST_OE_RMA_LINE_ID(i) ,FND_API.G_MISS_NUM,NULL,l_inst_hist_rec_tab.OLD_LAST_OE_RMA_LINE_ID(i)),
		 decode(l_inst_hist_rec_tab.NEW_LAST_OE_RMA_LINE_ID(i) ,FND_API.G_MISS_NUM,NULL,l_inst_hist_rec_tab.NEW_LAST_OE_RMA_LINE_ID(i)),
		 decode(l_inst_hist_rec_tab.OLD_LAST_WIP_JOB_ID(i) ,FND_API.G_MISS_NUM,NULL,l_inst_hist_rec_tab.OLD_LAST_WIP_JOB_ID(i)),
		 decode(l_inst_hist_rec_tab.NEW_LAST_WIP_JOB_ID(i) ,FND_API.G_MISS_NUM,NULL,l_inst_hist_rec_tab.NEW_LAST_WIP_JOB_ID(i)),
		 decode(l_inst_hist_rec_tab.OLD_LAST_PO_PO_LINE_ID(i) ,FND_API.G_MISS_NUM,NULL,l_inst_hist_rec_tab.OLD_LAST_PO_PO_LINE_ID(i)),
		 decode(l_inst_hist_rec_tab.NEW_LAST_PO_PO_LINE_ID(i) ,FND_API.G_MISS_NUM,NULL,l_inst_hist_rec_tab.NEW_LAST_PO_PO_LINE_ID(i)),
		 decode(l_inst_hist_rec_tab.OLD_LAST_PA_PROJECT_ID(i) ,FND_API.G_MISS_NUM,NULL,l_inst_hist_rec_tab.OLD_LAST_PA_PROJECT_ID(i)),
		 decode(l_inst_hist_rec_tab.NEW_LAST_PA_PROJECT_ID(i) ,FND_API.G_MISS_NUM,NULL,l_inst_hist_rec_tab.NEW_LAST_PA_PROJECT_ID(i)),
		 decode(l_inst_hist_rec_tab.OLD_LAST_PA_TASK_ID(i) ,FND_API.G_MISS_NUM,NULL,l_inst_hist_rec_tab.OLD_LAST_PA_TASK_ID(i)),
		 decode(l_inst_hist_rec_tab.NEW_LAST_PA_TASK_ID(i) ,FND_API.G_MISS_NUM,NULL,l_inst_hist_rec_tab.NEW_LAST_PA_TASK_ID(i)),
		 decode(l_inst_hist_rec_tab.OLD_LAST_TXN_LINE_DETAIL_ID(i) ,FND_API.G_MISS_NUM,NULL,l_inst_hist_rec_tab.OLD_LAST_TXN_LINE_DETAIL_ID(i)),
		 decode(l_inst_hist_rec_tab.NEW_LAST_TXN_LINE_DETAIL_ID(i) ,FND_API.G_MISS_NUM,NULL,l_inst_hist_rec_tab.NEW_LAST_TXN_LINE_DETAIL_ID(i)),
		 decode(l_inst_hist_rec_tab.OLD_LAST_OE_PO_NUMBER(i) ,FND_API.G_MISS_CHAR,NULL,l_inst_hist_rec_tab.OLD_LAST_OE_PO_NUMBER(i)),
		 decode(l_inst_hist_rec_tab.NEW_LAST_OE_PO_NUMBER(i) ,FND_API.G_MISS_CHAR,NULL,l_inst_hist_rec_tab.NEW_LAST_OE_PO_NUMBER(i)),
		 decode(l_inst_hist_rec_tab.OLD_NETWORK_ASSET_FLAG(i) ,FND_API.G_MISS_CHAR,NULL,l_inst_hist_rec_tab.OLD_NETWORK_ASSET_FLAG(i)),
		 decode(l_inst_hist_rec_tab.NEW_NETWORK_ASSET_FLAG(i) ,FND_API.G_MISS_CHAR,NULL,l_inst_hist_rec_tab.NEW_NETWORK_ASSET_FLAG(i)),
		 decode(l_inst_hist_rec_tab.OLD_MAINTAINABLE_FLAG(i) ,FND_API.G_MISS_CHAR,NULL,l_inst_hist_rec_tab.OLD_MAINTAINABLE_FLAG(i)),
		 decode(l_inst_hist_rec_tab.NEW_MAINTAINABLE_FLAG(i) ,FND_API.G_MISS_CHAR,NULL,l_inst_hist_rec_tab.NEW_MAINTAINABLE_FLAG(i)),
		 decode(l_inst_hist_rec_tab.OLD_ASSET_CRITICALITY_CODE(i) ,FND_API.G_MISS_CHAR,NULL,l_inst_hist_rec_tab.OLD_ASSET_CRITICALITY_CODE(i)),
		 decode(l_inst_hist_rec_tab.NEW_ASSET_CRITICALITY_CODE(i) ,FND_API.G_MISS_CHAR,NULL,l_inst_hist_rec_tab.NEW_ASSET_CRITICALITY_CODE(i)),
		 decode(l_inst_hist_rec_tab.OLD_CATEGORY_ID(i) ,FND_API.G_MISS_NUM,NULL,l_inst_hist_rec_tab.OLD_CATEGORY_ID(i)),
		 decode(l_inst_hist_rec_tab.NEW_CATEGORY_ID(i) ,FND_API.G_MISS_NUM,NULL,l_inst_hist_rec_tab.NEW_CATEGORY_ID(i)),
		 decode(l_inst_hist_rec_tab.OLD_EQUIPMENT_GEN_OBJECT_ID(i) ,FND_API.G_MISS_NUM,NULL,l_inst_hist_rec_tab.OLD_EQUIPMENT_GEN_OBJECT_ID(i)),
		 decode(l_inst_hist_rec_tab.NEW_EQUIPMENT_GEN_OBJECT_ID(i) ,FND_API.G_MISS_NUM,NULL,l_inst_hist_rec_tab.NEW_EQUIPMENT_GEN_OBJECT_ID(i)),
		 decode(l_inst_hist_rec_tab.OLD_INSTANTIATION_FLAG(i) ,FND_API.G_MISS_CHAR,NULL,l_inst_hist_rec_tab.OLD_INSTANTIATION_FLAG(i)),
		 decode(l_inst_hist_rec_tab.NEW_INSTANTIATION_FLAG(i) ,FND_API.G_MISS_CHAR,NULL,l_inst_hist_rec_tab.NEW_INSTANTIATION_FLAG(i)),
		 decode(l_inst_hist_rec_tab.OLD_OPERATIONAL_LOG_FLAG(i) ,FND_API.G_MISS_CHAR,NULL,l_inst_hist_rec_tab.OLD_OPERATIONAL_LOG_FLAG(i)),
		 decode(l_inst_hist_rec_tab.NEW_OPERATIONAL_LOG_FLAG(i) ,FND_API.G_MISS_CHAR,NULL,l_inst_hist_rec_tab.NEW_OPERATIONAL_LOG_FLAG(i)),
		 decode(l_inst_hist_rec_tab.OLD_SUPPLIER_WARRANTY_EXP_DATE(i) ,FND_API.G_MISS_DATE,NULL,l_inst_hist_rec_tab.OLD_SUPPLIER_WARRANTY_EXP_DATE(i)),
		 decode(l_inst_hist_rec_tab.NEW_SUPPLIER_WARRANTY_EXP_DATE(i) ,FND_API.G_MISS_DATE,NULL,l_inst_hist_rec_tab.NEW_SUPPLIER_WARRANTY_EXP_DATE(i)),
		 decode( l_inst_hist_rec_tab.OLD_ATTRIBUTE16(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.OLD_ATTRIBUTE16(i)),
		 decode( l_inst_hist_rec_tab.NEW_ATTRIBUTE16(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.NEW_ATTRIBUTE16(i)),
		 decode( l_inst_hist_rec_tab.OLD_ATTRIBUTE17(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.OLD_ATTRIBUTE17(i)),
		 decode( l_inst_hist_rec_tab.NEW_ATTRIBUTE17(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.NEW_ATTRIBUTE17(i)),
		 decode( l_inst_hist_rec_tab.OLD_ATTRIBUTE18(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.OLD_ATTRIBUTE18(i)),
		 decode( l_inst_hist_rec_tab.NEW_ATTRIBUTE18(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.NEW_ATTRIBUTE18(i)),
		 decode( l_inst_hist_rec_tab.OLD_ATTRIBUTE19(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.OLD_ATTRIBUTE19(i)),
		 decode( l_inst_hist_rec_tab.NEW_ATTRIBUTE19(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.NEW_ATTRIBUTE19(i)),
		 decode( l_inst_hist_rec_tab.OLD_ATTRIBUTE20(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.OLD_ATTRIBUTE20(i)),
		 decode( l_inst_hist_rec_tab.NEW_ATTRIBUTE20(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.NEW_ATTRIBUTE20(i)),
		 decode( l_inst_hist_rec_tab.OLD_ATTRIBUTE21(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.OLD_ATTRIBUTE21(i)),
		 decode( l_inst_hist_rec_tab.NEW_ATTRIBUTE21(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.NEW_ATTRIBUTE21(i)),
		 decode( l_inst_hist_rec_tab.OLD_ATTRIBUTE22(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.OLD_ATTRIBUTE22(i)),
		 decode( l_inst_hist_rec_tab.NEW_ATTRIBUTE22(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.NEW_ATTRIBUTE22(i)),
		 decode( l_inst_hist_rec_tab.OLD_ATTRIBUTE23(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.OLD_ATTRIBUTE23(i)),
		 decode( l_inst_hist_rec_tab.NEW_ATTRIBUTE23(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.NEW_ATTRIBUTE23(i)),
		 decode( l_inst_hist_rec_tab.OLD_ATTRIBUTE24(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.OLD_ATTRIBUTE24(i)),
		 decode( l_inst_hist_rec_tab.NEW_ATTRIBUTE24(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.NEW_ATTRIBUTE24(i)),
		 decode( l_inst_hist_rec_tab.OLD_ATTRIBUTE25(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.OLD_ATTRIBUTE25(i)),
		 decode( l_inst_hist_rec_tab.NEW_ATTRIBUTE25(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.NEW_ATTRIBUTE25(i)),
		 decode( l_inst_hist_rec_tab.OLD_ATTRIBUTE26(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.OLD_ATTRIBUTE26(i)),
		 decode( l_inst_hist_rec_tab.NEW_ATTRIBUTE26(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.NEW_ATTRIBUTE26(i)),
		 decode( l_inst_hist_rec_tab.OLD_ATTRIBUTE27(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.OLD_ATTRIBUTE27(i)),
		 decode( l_inst_hist_rec_tab.NEW_ATTRIBUTE27(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.NEW_ATTRIBUTE27(i)),
		 decode( l_inst_hist_rec_tab.OLD_ATTRIBUTE28(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.OLD_ATTRIBUTE28(i)),
		 decode( l_inst_hist_rec_tab.NEW_ATTRIBUTE28(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.NEW_ATTRIBUTE28(i)),
		 decode( l_inst_hist_rec_tab.OLD_ATTRIBUTE29(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.OLD_ATTRIBUTE29(i)),
		 decode( l_inst_hist_rec_tab.NEW_ATTRIBUTE29(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.NEW_ATTRIBUTE29(i)),
		 decode( l_inst_hist_rec_tab.OLD_ATTRIBUTE30(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.OLD_ATTRIBUTE30(i)),
		 decode( l_inst_hist_rec_tab.NEW_ATTRIBUTE30(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.NEW_ATTRIBUTE30(i)),
                 decode( l_inst_hist_rec_tab.OLD_PAYABLES_CURRENCY_CODE(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.OLD_PAYABLES_CURRENCY_CODE(i)),
                 decode( l_inst_hist_rec_tab.NEW_PAYABLES_CURRENCY_CODE(i), FND_API.G_MISS_CHAR, NULL,l_inst_hist_rec_tab.NEW_PAYABLES_CURRENCY_CODE(i)),
                 decode( l_inst_hist_rec_tab.OLD_PURCHASE_UNIT_PRICE(i), FND_API.G_MISS_NUM, NULL, l_inst_hist_rec_tab.OLD_PURCHASE_UNIT_PRICE(i)),
                 decode( l_inst_hist_rec_tab.NEW_PURCHASE_UNIT_PRICE(i), FND_API.G_MISS_NUM, NULL, l_inst_hist_rec_tab.NEW_PURCHASE_UNIT_PRICE(i)),
                 decode( l_inst_hist_rec_tab.OLD_PURCHASE_CURRENCY_CODE(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.OLD_PURCHASE_CURRENCY_CODE(i)),
                 decode( l_inst_hist_rec_tab.NEW_PURCHASE_CURRENCY_CODE(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.NEW_PURCHASE_CURRENCY_CODE(i)),
                 decode( l_inst_hist_rec_tab.OLD_PAYABLES_UNIT_PRICE(i), FND_API.G_MISS_NUM, NULL, l_inst_hist_rec_tab.OLD_PAYABLES_UNIT_PRICE(i)),
                 decode( l_inst_hist_rec_tab.NEW_PAYABLES_UNIT_PRICE(i), FND_API.G_MISS_NUM, NULL, l_inst_hist_rec_tab.NEW_PAYABLES_UNIT_PRICE(i)),
                 decode( l_inst_hist_rec_tab.OLD_SALES_UNIT_PRICE(i), FND_API.G_MISS_NUM, NULL, l_inst_hist_rec_tab.OLD_SALES_UNIT_PRICE(i)),
                 decode( l_inst_hist_rec_tab.NEW_SALES_UNIT_PRICE(i), FND_API.G_MISS_NUM, NULL, l_inst_hist_rec_tab.NEW_SALES_UNIT_PRICE(i)),
                 decode( l_inst_hist_rec_tab.OLD_SALES_CURRENCY_CODE(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.OLD_SALES_CURRENCY_CODE(i)),
                 decode( l_inst_hist_rec_tab.NEW_SALES_CURRENCY_CODE(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.NEW_SALES_CURRENCY_CODE(i)),
                 decode( l_inst_hist_rec_tab.OLD_OPERATIONAL_STATUS_CODE(i), FND_API.G_MISS_CHAR, NULL, l_inst_hist_rec_tab.OLD_OPERATIONAL_STATUS_CODE(i)),
                 decode( l_inst_hist_rec_tab.NEW_OPERATIONAL_STATUS_CODE(i),FND_API.G_MISS_CHAR, NULL,l_inst_hist_rec_tab.NEW_OPERATIONAL_STATUS_CODE(i))
		 );
   END IF;
   --
   IF p_version_label_tbl.count > 0 THEN
      Build_Ver_Label_Rec_of_Table
         (
           p_version_label_tbl     => p_version_label_tbl
          ,p_version_label_rec_tab => l_version_label_rec_tab
         );
      --
      l_ctr := l_version_label_rec_tab.version_label_id.count;
      --
         FORALL i in 1 .. l_ctr
	    INSERT INTO CSI_I_VERSION_LABELS(
		    VERSION_LABEL_ID,
		    INSTANCE_ID,
		    VERSION_LABEL,
		    DATE_TIME_STAMP,
		    DESCRIPTION,
		    ACTIVE_START_DATE,
		    ACTIVE_END_DATE,
		    CONTEXT,
		    ATTRIBUTE1,
		    ATTRIBUTE2,
		    ATTRIBUTE3,
		    ATTRIBUTE4,
		    ATTRIBUTE5,
		    ATTRIBUTE6,
		    ATTRIBUTE7,
		    ATTRIBUTE8,
		    ATTRIBUTE9,
		    ATTRIBUTE10,
		    ATTRIBUTE11,
		    ATTRIBUTE12,
		    ATTRIBUTE13,
		    ATTRIBUTE14,
		    ATTRIBUTE15,
		    CREATED_BY,
		    CREATION_DATE,
		    LAST_UPDATED_BY,
		    LAST_UPDATE_DATE,
		    LAST_UPDATE_LOGIN,
		    OBJECT_VERSION_NUMBER
		   ) VALUES (
		    l_version_label_rec_tab.VERSION_LABEL_ID(i),
		    decode( l_version_label_rec_tab.INSTANCE_ID(i), FND_API.G_MISS_NUM, NULL, l_version_label_rec_tab.INSTANCE_ID(i)),
		    decode( l_version_label_rec_tab.VERSION_LABEL(i), FND_API.G_MISS_CHAR, NULL, l_version_label_rec_tab.VERSION_LABEL(i)),
		    decode( l_version_label_rec_tab.DATE_TIME_STAMP(i), FND_API.G_MISS_DATE, TO_DATE(NULL), l_version_label_rec_tab.DATE_TIME_STAMP(i)),
		    decode( l_version_label_rec_tab.DESCRIPTION(i), FND_API.G_MISS_CHAR, NULL, l_version_label_rec_tab.DESCRIPTION(i)),
		    decode( l_version_label_rec_tab.ACTIVE_START_DATE(i), FND_API.G_MISS_DATE, TO_DATE(NULL), l_version_label_rec_tab.ACTIVE_START_DATE(i)),
		    decode( l_version_label_rec_tab.ACTIVE_END_DATE(i), FND_API.G_MISS_DATE, TO_DATE(NULL), l_version_label_rec_tab.ACTIVE_END_DATE(i)),
		    decode( l_version_label_rec_tab.CONTEXT(i), FND_API.G_MISS_CHAR, NULL, l_version_label_rec_tab.CONTEXT(i)),
		    decode( l_version_label_rec_tab.ATTRIBUTE1(i), FND_API.G_MISS_CHAR, NULL, l_version_label_rec_tab.ATTRIBUTE1(i)),
		    decode( l_version_label_rec_tab.ATTRIBUTE2(i), FND_API.G_MISS_CHAR, NULL, l_version_label_rec_tab.ATTRIBUTE2(i)),
		    decode( l_version_label_rec_tab.ATTRIBUTE3(i), FND_API.G_MISS_CHAR, NULL, l_version_label_rec_tab.ATTRIBUTE3(i)),
		    decode( l_version_label_rec_tab.ATTRIBUTE4(i), FND_API.G_MISS_CHAR, NULL, l_version_label_rec_tab.ATTRIBUTE4(i)),
		    decode( l_version_label_rec_tab.ATTRIBUTE5(i), FND_API.G_MISS_CHAR, NULL, l_version_label_rec_tab.ATTRIBUTE5(i)),
		    decode( l_version_label_rec_tab.ATTRIBUTE6(i), FND_API.G_MISS_CHAR, NULL, l_version_label_rec_tab.ATTRIBUTE6(i)),
		    decode( l_version_label_rec_tab.ATTRIBUTE7(i), FND_API.G_MISS_CHAR, NULL, l_version_label_rec_tab.ATTRIBUTE7(i)),
		    decode( l_version_label_rec_tab.ATTRIBUTE8(i), FND_API.G_MISS_CHAR, NULL, l_version_label_rec_tab.ATTRIBUTE8(i)),
		    decode( l_version_label_rec_tab.ATTRIBUTE9(i), FND_API.G_MISS_CHAR, NULL, l_version_label_rec_tab.ATTRIBUTE9(i)),
		    decode( l_version_label_rec_tab.ATTRIBUTE10(i), FND_API.G_MISS_CHAR, NULL, l_version_label_rec_tab.ATTRIBUTE10(i)),
		    decode( l_version_label_rec_tab.ATTRIBUTE11(i), FND_API.G_MISS_CHAR, NULL, l_version_label_rec_tab.ATTRIBUTE11(i)),
		    decode( l_version_label_rec_tab.ATTRIBUTE12(i), FND_API.G_MISS_CHAR, NULL, l_version_label_rec_tab.ATTRIBUTE12(i)),
		    decode( l_version_label_rec_tab.ATTRIBUTE13(i), FND_API.G_MISS_CHAR, NULL, l_version_label_rec_tab.ATTRIBUTE13(i)),
		    decode( l_version_label_rec_tab.ATTRIBUTE14(i), FND_API.G_MISS_CHAR, NULL, l_version_label_rec_tab.ATTRIBUTE14(i)),
		    decode( l_version_label_rec_tab.ATTRIBUTE15(i), FND_API.G_MISS_CHAR, NULL, l_version_label_rec_tab.ATTRIBUTE15(i)),
		    l_user_id,
		    SYSDATE,
		    l_user_id,
		    SYSDATE,
		    l_login_id,
		    1
                 );
   END IF;
   --
   IF p_ver_label_hist_tbl.count > 0 THEN
      Build_Ver_Lbl_Hist_Rec_Table
         (
           p_ver_label_hist_tbl     => p_ver_label_hist_tbl
          ,p_ver_label_hist_rec_tab => l_ver_label_hist_rec_tab
         );
      --
      l_ctr := l_ver_label_hist_rec_tab.version_label_history_id.count;
      --
         FORALL i in 1 .. l_ctr
	    INSERT INTO CSI_I_VERSION_LABELS_H(
		    VERSION_LABEL_HISTORY_ID,
		    VERSION_LABEL_ID,
		    TRANSACTION_ID,
		    OLD_VERSION_LABEL,
		    NEW_VERSION_LABEL,
		    OLD_DESCRIPTION,
		    NEW_DESCRIPTION,
		    OLD_DATE_TIME_STAMP,
		    NEW_DATE_TIME_STAMP,
		    OLD_ACTIVE_START_DATE,
		    NEW_ACTIVE_START_DATE,
		    OLD_ACTIVE_END_DATE,
		    NEW_ACTIVE_END_DATE,
		    OLD_CONTEXT,
		    NEW_CONTEXT,
		    OLD_ATTRIBUTE1,
		    NEW_ATTRIBUTE1,
		    OLD_ATTRIBUTE2,
		    NEW_ATTRIBUTE2,
		    OLD_ATTRIBUTE3,
		    NEW_ATTRIBUTE3,
		    OLD_ATTRIBUTE4,
		    NEW_ATTRIBUTE4,
		    OLD_ATTRIBUTE5,
		    NEW_ATTRIBUTE5,
		    OLD_ATTRIBUTE6,
		    NEW_ATTRIBUTE6,
		    OLD_ATTRIBUTE7,
		    NEW_ATTRIBUTE7,
		    OLD_ATTRIBUTE8,
		    NEW_ATTRIBUTE8,
		    OLD_ATTRIBUTE9,
		    NEW_ATTRIBUTE9,
		    OLD_ATTRIBUTE10,
		    NEW_ATTRIBUTE10,
		    OLD_ATTRIBUTE11,
		    NEW_ATTRIBUTE11,
		    OLD_ATTRIBUTE12,
		    NEW_ATTRIBUTE12,
		    OLD_ATTRIBUTE13,
		    NEW_ATTRIBUTE13,
		    OLD_ATTRIBUTE14,
		    NEW_ATTRIBUTE14,
		    OLD_ATTRIBUTE15,
		    NEW_ATTRIBUTE15,
		    FULL_DUMP_FLAG,
		    CREATED_BY,
		    CREATION_DATE,
		    LAST_UPDATED_BY,
		    LAST_UPDATE_DATE,
		    LAST_UPDATE_LOGIN,
		    OBJECT_VERSION_NUMBER
		   ) VALUES (
		    l_ver_label_hist_rec_tab.VERSION_LABEL_HISTORY_ID(i),
		    decode( l_ver_label_hist_rec_tab.VERSION_LABEL_ID(i), FND_API.G_MISS_NUM, NULL, l_ver_label_hist_rec_tab.VERSION_LABEL_ID(i)),
		    decode( l_ver_label_hist_rec_tab.TRANSACTION_ID(i), FND_API.G_MISS_NUM, NULL, l_ver_label_hist_rec_tab.TRANSACTION_ID(i)),
		    decode( l_ver_label_hist_rec_tab.OLD_VERSION_LABEL(i), FND_API.G_MISS_CHAR, NULL, l_ver_label_hist_rec_tab.OLD_VERSION_LABEL(i)),
		    decode( l_ver_label_hist_rec_tab.NEW_VERSION_LABEL(i), FND_API.G_MISS_CHAR, NULL, l_ver_label_hist_rec_tab.NEW_VERSION_LABEL(i)),
		    decode( l_ver_label_hist_rec_tab.OLD_DESCRIPTION(i), FND_API.G_MISS_CHAR, NULL, l_ver_label_hist_rec_tab.OLD_DESCRIPTION(i)),
		    decode( l_ver_label_hist_rec_tab.NEW_DESCRIPTION(i), FND_API.G_MISS_CHAR, NULL, l_ver_label_hist_rec_tab.NEW_DESCRIPTION(i)),
		    decode( l_ver_label_hist_rec_tab.OLD_DATE_TIME_STAMP(i), FND_API.G_MISS_DATE, TO_DATE(NULL), l_ver_label_hist_rec_tab.OLD_DATE_TIME_STAMP(i)),
		    decode( l_ver_label_hist_rec_tab.NEW_DATE_TIME_STAMP(i), FND_API.G_MISS_DATE, TO_DATE(NULL), l_ver_label_hist_rec_tab.NEW_DATE_TIME_STAMP(i)),
		    decode( l_ver_label_hist_rec_tab.OLD_ACTIVE_START_DATE(i), FND_API.G_MISS_DATE, TO_DATE(NULL), l_ver_label_hist_rec_tab.OLD_ACTIVE_START_DATE(i)),
		    decode( l_ver_label_hist_rec_tab.NEW_ACTIVE_START_DATE(i), FND_API.G_MISS_DATE, TO_DATE(NULL), l_ver_label_hist_rec_tab.NEW_ACTIVE_START_DATE(i)),
		    decode( l_ver_label_hist_rec_tab.OLD_ACTIVE_END_DATE(i), FND_API.G_MISS_DATE, TO_DATE(NULL), l_ver_label_hist_rec_tab.OLD_ACTIVE_END_DATE(i)),
		    decode( l_ver_label_hist_rec_tab.NEW_ACTIVE_END_DATE(i), FND_API.G_MISS_DATE, TO_DATE(NULL), l_ver_label_hist_rec_tab.NEW_ACTIVE_END_DATE(i)),
		    decode( l_ver_label_hist_rec_tab.OLD_CONTEXT(i), FND_API.G_MISS_CHAR, NULL, l_ver_label_hist_rec_tab.OLD_CONTEXT(i)),
		    decode( l_ver_label_hist_rec_tab.NEW_CONTEXT(i), FND_API.G_MISS_CHAR, NULL, l_ver_label_hist_rec_tab.NEW_CONTEXT(i)),
		    decode( l_ver_label_hist_rec_tab.OLD_ATTRIBUTE1(i), FND_API.G_MISS_CHAR, NULL, l_ver_label_hist_rec_tab.OLD_ATTRIBUTE1(i)),
		    decode( l_ver_label_hist_rec_tab.NEW_ATTRIBUTE1(i), FND_API.G_MISS_CHAR, NULL, l_ver_label_hist_rec_tab.NEW_ATTRIBUTE1(i)),
		    decode( l_ver_label_hist_rec_tab.OLD_ATTRIBUTE2(i), FND_API.G_MISS_CHAR, NULL, l_ver_label_hist_rec_tab.OLD_ATTRIBUTE2(i)),
		    decode( l_ver_label_hist_rec_tab.NEW_ATTRIBUTE2(i), FND_API.G_MISS_CHAR, NULL, l_ver_label_hist_rec_tab.NEW_ATTRIBUTE2(i)),
		    decode( l_ver_label_hist_rec_tab.OLD_ATTRIBUTE3(i), FND_API.G_MISS_CHAR, NULL, l_ver_label_hist_rec_tab.OLD_ATTRIBUTE3(i)),
		    decode( l_ver_label_hist_rec_tab.NEW_ATTRIBUTE3(i), FND_API.G_MISS_CHAR, NULL, l_ver_label_hist_rec_tab.NEW_ATTRIBUTE3(i)),
		    decode( l_ver_label_hist_rec_tab.OLD_ATTRIBUTE4(i), FND_API.G_MISS_CHAR, NULL, l_ver_label_hist_rec_tab.OLD_ATTRIBUTE4(i)),
		    decode( l_ver_label_hist_rec_tab.NEW_ATTRIBUTE4(i), FND_API.G_MISS_CHAR, NULL, l_ver_label_hist_rec_tab.NEW_ATTRIBUTE4(i)),
		    decode( l_ver_label_hist_rec_tab.OLD_ATTRIBUTE5(i), FND_API.G_MISS_CHAR, NULL, l_ver_label_hist_rec_tab.OLD_ATTRIBUTE5(i)),
		    decode( l_ver_label_hist_rec_tab.NEW_ATTRIBUTE5(i), FND_API.G_MISS_CHAR, NULL, l_ver_label_hist_rec_tab.NEW_ATTRIBUTE5(i)),
		    decode( l_ver_label_hist_rec_tab.OLD_ATTRIBUTE6(i), FND_API.G_MISS_CHAR, NULL, l_ver_label_hist_rec_tab.OLD_ATTRIBUTE6(i)),
		    decode( l_ver_label_hist_rec_tab.NEW_ATTRIBUTE6(i), FND_API.G_MISS_CHAR, NULL, l_ver_label_hist_rec_tab.NEW_ATTRIBUTE6(i)),
		    decode( l_ver_label_hist_rec_tab.OLD_ATTRIBUTE7(i), FND_API.G_MISS_CHAR, NULL, l_ver_label_hist_rec_tab.OLD_ATTRIBUTE7(i)),
		    decode( l_ver_label_hist_rec_tab.NEW_ATTRIBUTE7(i), FND_API.G_MISS_CHAR, NULL, l_ver_label_hist_rec_tab.NEW_ATTRIBUTE7(i)),
		    decode( l_ver_label_hist_rec_tab.OLD_ATTRIBUTE8(i), FND_API.G_MISS_CHAR, NULL, l_ver_label_hist_rec_tab.OLD_ATTRIBUTE8(i)),
		    decode( l_ver_label_hist_rec_tab.NEW_ATTRIBUTE8(i), FND_API.G_MISS_CHAR, NULL, l_ver_label_hist_rec_tab.NEW_ATTRIBUTE8(i)),
		    decode( l_ver_label_hist_rec_tab.OLD_ATTRIBUTE9(i), FND_API.G_MISS_CHAR, NULL, l_ver_label_hist_rec_tab.OLD_ATTRIBUTE9(i)),
		    decode( l_ver_label_hist_rec_tab.NEW_ATTRIBUTE9(i), FND_API.G_MISS_CHAR, NULL, l_ver_label_hist_rec_tab.NEW_ATTRIBUTE9(i)),
		    decode( l_ver_label_hist_rec_tab.OLD_ATTRIBUTE10(i), FND_API.G_MISS_CHAR, NULL, l_ver_label_hist_rec_tab.OLD_ATTRIBUTE10(i)),
		    decode( l_ver_label_hist_rec_tab.NEW_ATTRIBUTE10(i), FND_API.G_MISS_CHAR, NULL, l_ver_label_hist_rec_tab.NEW_ATTRIBUTE10(i)),
		    decode( l_ver_label_hist_rec_tab.OLD_ATTRIBUTE11(i), FND_API.G_MISS_CHAR, NULL, l_ver_label_hist_rec_tab.OLD_ATTRIBUTE11(i)),
		    decode( l_ver_label_hist_rec_tab.NEW_ATTRIBUTE11(i), FND_API.G_MISS_CHAR, NULL, l_ver_label_hist_rec_tab.NEW_ATTRIBUTE11(i)),
		    decode( l_ver_label_hist_rec_tab.OLD_ATTRIBUTE12(i), FND_API.G_MISS_CHAR, NULL, l_ver_label_hist_rec_tab.OLD_ATTRIBUTE12(i)),
		    decode( l_ver_label_hist_rec_tab.NEW_ATTRIBUTE12(i), FND_API.G_MISS_CHAR, NULL, l_ver_label_hist_rec_tab.NEW_ATTRIBUTE12(i)),
		    decode( l_ver_label_hist_rec_tab.OLD_ATTRIBUTE13(i), FND_API.G_MISS_CHAR, NULL, l_ver_label_hist_rec_tab.OLD_ATTRIBUTE13(i)),
		    decode( l_ver_label_hist_rec_tab.NEW_ATTRIBUTE13(i), FND_API.G_MISS_CHAR, NULL, l_ver_label_hist_rec_tab.NEW_ATTRIBUTE13(i)),
		    decode( l_ver_label_hist_rec_tab.OLD_ATTRIBUTE14(i), FND_API.G_MISS_CHAR, NULL, l_ver_label_hist_rec_tab.OLD_ATTRIBUTE14(i)),
		    decode( l_ver_label_hist_rec_tab.NEW_ATTRIBUTE14(i), FND_API.G_MISS_CHAR, NULL, l_ver_label_hist_rec_tab.NEW_ATTRIBUTE14(i)),
		    decode( l_ver_label_hist_rec_tab.OLD_ATTRIBUTE15(i), FND_API.G_MISS_CHAR, NULL, l_ver_label_hist_rec_tab.OLD_ATTRIBUTE15(i)),
		    decode( l_ver_label_hist_rec_tab.NEW_ATTRIBUTE15(i), FND_API.G_MISS_CHAR, NULL, l_ver_label_hist_rec_tab.NEW_ATTRIBUTE15(i)),
		    'N',
		    l_user_id,
		    SYSDATE,
		    l_user_id,
		    SYSDATE,
		    l_login_id,
		    1
                  );
   END IF;
   --
   IF p_party_tbl.count > 0 THEN
      Build_Party_Rec_of_Table
        ( p_party_tbl    => p_party_tbl
         ,p_party_rec_tab => l_party_rec_tab
        );
      --
      l_ctr := l_party_rec_tab.instance_party_id.count;
      --
        FORALL i in 1 .. l_ctr
         INSERT INTO CSI_I_PARTIES(
	 INSTANCE_PARTY_ID,
	 INSTANCE_ID,
	 PARTY_SOURCE_TABLE,
	 PARTY_ID,
	 RELATIONSHIP_TYPE_CODE,
	 CONTACT_FLAG,
	 CONTACT_IP_ID,
	 ACTIVE_START_DATE,
	 ACTIVE_END_DATE,
	 CONTEXT,
	 ATTRIBUTE1,
	 ATTRIBUTE2,
	 ATTRIBUTE3,
	 ATTRIBUTE4,
	 ATTRIBUTE5,
	 ATTRIBUTE6,
	 ATTRIBUTE7,
	 ATTRIBUTE8,
	 ATTRIBUTE9,
	 ATTRIBUTE10,
	 ATTRIBUTE11,
	 ATTRIBUTE12,
	 ATTRIBUTE13,
	 ATTRIBUTE14,
	 ATTRIBUTE15,
	 CREATED_BY,
	 CREATION_DATE,
	 LAST_UPDATED_BY,
	 LAST_UPDATE_DATE,
	 LAST_UPDATE_LOGIN,
	 OBJECT_VERSION_NUMBER,
	 PRIMARY_FLAG,
	 PREFERRED_FLAG
	 ) VALUES (
	 l_party_rec_tab.INSTANCE_PARTY_ID(i),
	 decode( l_party_rec_tab.INSTANCE_ID(i), FND_API.G_MISS_NUM, NULL, l_party_rec_tab.INSTANCE_ID(i)),
	 decode( l_party_rec_tab.PARTY_SOURCE_TABLE(i), FND_API.G_MISS_CHAR, NULL, l_party_rec_tab.PARTY_SOURCE_TABLE(i)),
	 decode( l_party_rec_tab.PARTY_ID(i), FND_API.G_MISS_NUM, NULL, l_party_rec_tab.PARTY_ID(i)),
	 decode( l_party_rec_tab.RELATIONSHIP_TYPE_CODE(i), FND_API.G_MISS_CHAR, NULL, l_party_rec_tab.RELATIONSHIP_TYPE_CODE(i)),
	 decode( l_party_rec_tab.CONTACT_FLAG(i), FND_API.G_MISS_CHAR, NULL, l_party_rec_tab.CONTACT_FLAG(i)),
	 decode( l_party_rec_tab.CONTACT_IP_ID(i), FND_API.G_MISS_NUM, NULL, l_party_rec_tab.CONTACT_IP_ID(i)),
	 decode( l_party_rec_tab.ACTIVE_START_DATE(i), FND_API.G_MISS_DATE, TO_DATE(NULL), l_party_rec_tab.ACTIVE_START_DATE(i)),
	 decode( l_party_rec_tab.ACTIVE_END_DATE(i), FND_API.G_MISS_DATE, TO_DATE(NULL), l_party_rec_tab.ACTIVE_END_DATE(i)),
	 decode( l_party_rec_tab.CONTEXT(i), FND_API.G_MISS_CHAR, NULL, l_party_rec_tab.CONTEXT(i)),
	 decode( l_party_rec_tab.ATTRIBUTE1(i), FND_API.G_MISS_CHAR, NULL, l_party_rec_tab.ATTRIBUTE1(i)),
	 decode( l_party_rec_tab.ATTRIBUTE2(i), FND_API.G_MISS_CHAR, NULL, l_party_rec_tab.ATTRIBUTE2(i)),
	 decode( l_party_rec_tab.ATTRIBUTE3(i), FND_API.G_MISS_CHAR, NULL, l_party_rec_tab.ATTRIBUTE3(i)),
	 decode( l_party_rec_tab.ATTRIBUTE4(i), FND_API.G_MISS_CHAR, NULL, l_party_rec_tab.ATTRIBUTE4(i)),
	 decode( l_party_rec_tab.ATTRIBUTE5(i), FND_API.G_MISS_CHAR, NULL, l_party_rec_tab.ATTRIBUTE5(i)),
	 decode( l_party_rec_tab.ATTRIBUTE6(i), FND_API.G_MISS_CHAR, NULL, l_party_rec_tab.ATTRIBUTE6(i)),
	 decode( l_party_rec_tab.ATTRIBUTE7(i), FND_API.G_MISS_CHAR, NULL, l_party_rec_tab.ATTRIBUTE7(i)),
	 decode( l_party_rec_tab.ATTRIBUTE8(i), FND_API.G_MISS_CHAR, NULL, l_party_rec_tab.ATTRIBUTE8(i)),
	 decode( l_party_rec_tab.ATTRIBUTE9(i), FND_API.G_MISS_CHAR, NULL, l_party_rec_tab.ATTRIBUTE9(i)),
	 decode( l_party_rec_tab.ATTRIBUTE10(i), FND_API.G_MISS_CHAR, NULL, l_party_rec_tab.ATTRIBUTE10(i)),
	 decode( l_party_rec_tab.ATTRIBUTE11(i), FND_API.G_MISS_CHAR, NULL, l_party_rec_tab.ATTRIBUTE11(i)),
	 decode( l_party_rec_tab.ATTRIBUTE12(i), FND_API.G_MISS_CHAR, NULL, l_party_rec_tab.ATTRIBUTE12(i)),
	 decode( l_party_rec_tab.ATTRIBUTE13(i), FND_API.G_MISS_CHAR, NULL, l_party_rec_tab.ATTRIBUTE13(i)),
	 decode( l_party_rec_tab.ATTRIBUTE14(i), FND_API.G_MISS_CHAR, NULL, l_party_rec_tab.ATTRIBUTE14(i)),
	 decode( l_party_rec_tab.ATTRIBUTE15(i), FND_API.G_MISS_CHAR, NULL, l_party_rec_tab.ATTRIBUTE15(i)),
	 l_user_id,
	 SYSDATE,
	 l_user_id,
	 SYSDATE,
	 l_login_id,
	 1,
	 decode(l_party_rec_tab.PRIMARY_FLAG(i), FND_API.G_MISS_CHAR, NULL, l_party_rec_tab.PRIMARY_FLAG(i)),
	 decode( l_party_rec_tab.PREFERRED_FLAG(i), FND_API.G_MISS_CHAR, NULL, l_party_rec_tab.PREFERRED_FLAG(i)));
         --
   END IF;
   --
   IF p_party_hist_tbl.count > 0 THEN
         Build_Party_Hist_Rec_of_Table
            ( p_party_hist_tbl     => p_party_hist_tbl
             ,p_party_hist_rec_tab => l_party_hist_rec_tab
            );
         --
         l_ctr := l_party_hist_rec_tab.instance_party_history_id.count;
         --
         FORALL i in 1 .. l_ctr
	   INSERT INTO CSI_I_PARTIES_H(
		 INSTANCE_PARTY_HISTORY_ID,
		 INSTANCE_PARTY_ID,
		 TRANSACTION_ID,
		 OLD_PARTY_SOURCE_TABLE,
		 NEW_PARTY_SOURCE_TABLE,
		 OLD_PARTY_ID,
		 NEW_PARTY_ID,
		 OLD_RELATIONSHIP_TYPE_CODE,
		 NEW_RELATIONSHIP_TYPE_CODE,
		 OLD_CONTACT_FLAG,
		 NEW_CONTACT_FLAG,
		 OLD_CONTACT_IP_ID,
		 NEW_CONTACT_IP_ID,
		 OLD_ACTIVE_START_DATE,
		 NEW_ACTIVE_START_DATE,
		 OLD_ACTIVE_END_DATE,
		 NEW_ACTIVE_END_DATE,
		 OLD_CONTEXT,
		 NEW_CONTEXT,
		 OLD_ATTRIBUTE1,
		 NEW_ATTRIBUTE1,
		 OLD_ATTRIBUTE2,
		 NEW_ATTRIBUTE2,
		 OLD_ATTRIBUTE3,
		 NEW_ATTRIBUTE3,
		 OLD_ATTRIBUTE4,
		 NEW_ATTRIBUTE4,
		 OLD_ATTRIBUTE5,
		 NEW_ATTRIBUTE5,
		 OLD_ATTRIBUTE6,
		 NEW_ATTRIBUTE6,
		 OLD_ATTRIBUTE7,
		 NEW_ATTRIBUTE7,
		 OLD_ATTRIBUTE8,
		 NEW_ATTRIBUTE8,
		 OLD_ATTRIBUTE9,
		 NEW_ATTRIBUTE9,
		 OLD_ATTRIBUTE10,
		 NEW_ATTRIBUTE10,
		 OLD_ATTRIBUTE11,
		 NEW_ATTRIBUTE11,
		 OLD_ATTRIBUTE12,
		 NEW_ATTRIBUTE12,
		 OLD_ATTRIBUTE13,
		 NEW_ATTRIBUTE13,
		 OLD_ATTRIBUTE14,
		 NEW_ATTRIBUTE14,
		 OLD_ATTRIBUTE15,
		 NEW_ATTRIBUTE15,
		 FULL_DUMP_FLAG,
		 CREATED_BY,
		 CREATION_DATE,
		 LAST_UPDATED_BY,
		 LAST_UPDATE_DATE,
		 LAST_UPDATE_LOGIN,
		 OBJECT_VERSION_NUMBER,
		 OLD_PRIMARY_FLAG,
		 NEW_PRIMARY_FLAG,
		 OLD_PREFERRED_FLAG,
		 NEW_PREFERRED_FLAG
		) VALUES (
		 l_party_hist_rec_tab.INSTANCE_PARTY_HISTORY_ID(i),
		 decode( l_party_hist_rec_tab.INSTANCE_PARTY_ID(i), FND_API.G_MISS_NUM, NULL, l_party_hist_rec_tab.INSTANCE_PARTY_ID(i)),
		 decode( l_party_hist_rec_tab.TRANSACTION_ID(i), FND_API.G_MISS_NUM, NULL, l_party_hist_rec_tab.TRANSACTION_ID(i)),
		 decode( l_party_hist_rec_tab.OLD_PARTY_SOURCE_TABLE(i), FND_API.G_MISS_CHAR, NULL, l_party_hist_rec_tab.OLD_PARTY_SOURCE_TABLE(i)),
		 decode( l_party_hist_rec_tab.NEW_PARTY_SOURCE_TABLE(i), FND_API.G_MISS_CHAR, NULL, l_party_hist_rec_tab.NEW_PARTY_SOURCE_TABLE(i)),
		 decode( l_party_hist_rec_tab.OLD_PARTY_ID(i), FND_API.G_MISS_NUM, NULL, l_party_hist_rec_tab.OLD_PARTY_ID(i)),
		 decode( l_party_hist_rec_tab.NEW_PARTY_ID(i), FND_API.G_MISS_NUM, NULL, l_party_hist_rec_tab.NEW_PARTY_ID(i)),
		 decode( l_party_hist_rec_tab.OLD_RELATIONSHIP_TYPE_CODE(i), FND_API.G_MISS_CHAR, NULL, l_party_hist_rec_tab.OLD_RELATIONSHIP_TYPE_CODE(i)),
		 decode( l_party_hist_rec_tab.NEW_RELATIONSHIP_TYPE_CODE(i), FND_API.G_MISS_CHAR, NULL, l_party_hist_rec_tab.NEW_RELATIONSHIP_TYPE_CODE(i)),
		 decode( l_party_hist_rec_tab.OLD_CONTACT_FLAG(i), FND_API.G_MISS_CHAR, NULL, l_party_hist_rec_tab.OLD_CONTACT_FLAG(i)),
		 decode( l_party_hist_rec_tab.NEW_CONTACT_FLAG(i), FND_API.G_MISS_CHAR, NULL, l_party_hist_rec_tab.NEW_CONTACT_FLAG(i)),
		 decode( l_party_hist_rec_tab.OLD_CONTACT_IP_ID(i), FND_API.G_MISS_NUM, NULL, l_party_hist_rec_tab.OLD_CONTACT_IP_ID(i)),
		 decode( l_party_hist_rec_tab.NEW_CONTACT_IP_ID(i), FND_API.G_MISS_NUM, NULL, l_party_hist_rec_tab.NEW_CONTACT_IP_ID(i)),
		 decode( l_party_hist_rec_tab.OLD_ACTIVE_START_DATE(i), FND_API.G_MISS_DATE, TO_DATE(NULL), l_party_hist_rec_tab.OLD_ACTIVE_START_DATE(i)),
		 decode( l_party_hist_rec_tab.NEW_ACTIVE_START_DATE(i), FND_API.G_MISS_DATE, TO_DATE(NULL), l_party_hist_rec_tab.NEW_ACTIVE_START_DATE(i)),
		 decode( l_party_hist_rec_tab.OLD_ACTIVE_END_DATE(i), FND_API.G_MISS_DATE, TO_DATE(NULL), l_party_hist_rec_tab.OLD_ACTIVE_END_DATE(i)),
		 decode( l_party_hist_rec_tab.NEW_ACTIVE_END_DATE(i), FND_API.G_MISS_DATE, TO_DATE(NULL), l_party_hist_rec_tab.NEW_ACTIVE_END_DATE(i)),
		 decode( l_party_hist_rec_tab.OLD_CONTEXT(i), FND_API.G_MISS_CHAR, NULL, l_party_hist_rec_tab.OLD_CONTEXT(i)),
		 decode( l_party_hist_rec_tab.NEW_CONTEXT(i), FND_API.G_MISS_CHAR, NULL, l_party_hist_rec_tab.NEW_CONTEXT(i)),
		 decode( l_party_hist_rec_tab.OLD_ATTRIBUTE1(i), FND_API.G_MISS_CHAR, NULL, l_party_hist_rec_tab.OLD_ATTRIBUTE1(i)),
		 decode( l_party_hist_rec_tab.NEW_ATTRIBUTE1(i), FND_API.G_MISS_CHAR, NULL, l_party_hist_rec_tab.NEW_ATTRIBUTE1(i)),
		 decode( l_party_hist_rec_tab.OLD_ATTRIBUTE2(i), FND_API.G_MISS_CHAR, NULL, l_party_hist_rec_tab.OLD_ATTRIBUTE2(i)),
		 decode( l_party_hist_rec_tab.NEW_ATTRIBUTE2(i), FND_API.G_MISS_CHAR, NULL, l_party_hist_rec_tab.NEW_ATTRIBUTE2(i)),
		 decode( l_party_hist_rec_tab.OLD_ATTRIBUTE3(i), FND_API.G_MISS_CHAR, NULL, l_party_hist_rec_tab.OLD_ATTRIBUTE3(i)),
		 decode( l_party_hist_rec_tab.NEW_ATTRIBUTE3(i), FND_API.G_MISS_CHAR, NULL, l_party_hist_rec_tab.NEW_ATTRIBUTE3(i)),
		 decode( l_party_hist_rec_tab.OLD_ATTRIBUTE4(i), FND_API.G_MISS_CHAR, NULL, l_party_hist_rec_tab.OLD_ATTRIBUTE4(i)),
		 decode( l_party_hist_rec_tab.NEW_ATTRIBUTE4(i), FND_API.G_MISS_CHAR, NULL, l_party_hist_rec_tab.NEW_ATTRIBUTE4(i)),
		 decode( l_party_hist_rec_tab.OLD_ATTRIBUTE5(i), FND_API.G_MISS_CHAR, NULL, l_party_hist_rec_tab.OLD_ATTRIBUTE5(i)),
		 decode( l_party_hist_rec_tab.NEW_ATTRIBUTE5(i), FND_API.G_MISS_CHAR, NULL, l_party_hist_rec_tab.NEW_ATTRIBUTE5(i)),
		 decode( l_party_hist_rec_tab.OLD_ATTRIBUTE6(i), FND_API.G_MISS_CHAR, NULL, l_party_hist_rec_tab.OLD_ATTRIBUTE6(i)),
		 decode( l_party_hist_rec_tab.NEW_ATTRIBUTE6(i), FND_API.G_MISS_CHAR, NULL, l_party_hist_rec_tab.NEW_ATTRIBUTE6(i)),
		 decode( l_party_hist_rec_tab.OLD_ATTRIBUTE7(i), FND_API.G_MISS_CHAR, NULL, l_party_hist_rec_tab.OLD_ATTRIBUTE7(i)),
		 decode( l_party_hist_rec_tab.NEW_ATTRIBUTE7(i), FND_API.G_MISS_CHAR, NULL, l_party_hist_rec_tab.NEW_ATTRIBUTE7(i)),
		 decode( l_party_hist_rec_tab.OLD_ATTRIBUTE8(i), FND_API.G_MISS_CHAR, NULL, l_party_hist_rec_tab.OLD_ATTRIBUTE8(i)),
		 decode( l_party_hist_rec_tab.NEW_ATTRIBUTE8(i), FND_API.G_MISS_CHAR, NULL, l_party_hist_rec_tab.NEW_ATTRIBUTE8(i)),
		 decode( l_party_hist_rec_tab.OLD_ATTRIBUTE9(i), FND_API.G_MISS_CHAR, NULL, l_party_hist_rec_tab.OLD_ATTRIBUTE9(i)),
		 decode( l_party_hist_rec_tab.NEW_ATTRIBUTE9(i), FND_API.G_MISS_CHAR, NULL, l_party_hist_rec_tab.NEW_ATTRIBUTE9(i)),
		 decode( l_party_hist_rec_tab.OLD_ATTRIBUTE10(i), FND_API.G_MISS_CHAR, NULL, l_party_hist_rec_tab.OLD_ATTRIBUTE10(i)),
		 decode( l_party_hist_rec_tab.NEW_ATTRIBUTE10(i), FND_API.G_MISS_CHAR, NULL, l_party_hist_rec_tab.NEW_ATTRIBUTE10(i)),
		 decode( l_party_hist_rec_tab.OLD_ATTRIBUTE11(i), FND_API.G_MISS_CHAR, NULL, l_party_hist_rec_tab.OLD_ATTRIBUTE11(i)),
		 decode( l_party_hist_rec_tab.NEW_ATTRIBUTE11(i), FND_API.G_MISS_CHAR, NULL, l_party_hist_rec_tab.NEW_ATTRIBUTE11(i)),
		 decode( l_party_hist_rec_tab.OLD_ATTRIBUTE12(i), FND_API.G_MISS_CHAR, NULL, l_party_hist_rec_tab.OLD_ATTRIBUTE12(i)),
		 decode( l_party_hist_rec_tab.NEW_ATTRIBUTE12(i), FND_API.G_MISS_CHAR, NULL, l_party_hist_rec_tab.NEW_ATTRIBUTE12(i)),
		 decode( l_party_hist_rec_tab.OLD_ATTRIBUTE13(i), FND_API.G_MISS_CHAR, NULL, l_party_hist_rec_tab.OLD_ATTRIBUTE13(i)),
		 decode( l_party_hist_rec_tab.NEW_ATTRIBUTE13(i), FND_API.G_MISS_CHAR, NULL, l_party_hist_rec_tab.NEW_ATTRIBUTE13(i)),
		 decode( l_party_hist_rec_tab.OLD_ATTRIBUTE14(i), FND_API.G_MISS_CHAR, NULL, l_party_hist_rec_tab.OLD_ATTRIBUTE14(i)),
		 decode( l_party_hist_rec_tab.NEW_ATTRIBUTE14(i), FND_API.G_MISS_CHAR, NULL, l_party_hist_rec_tab.NEW_ATTRIBUTE14(i)),
		 decode( l_party_hist_rec_tab.OLD_ATTRIBUTE15(i), FND_API.G_MISS_CHAR, NULL, l_party_hist_rec_tab.OLD_ATTRIBUTE15(i)),
		 decode( l_party_hist_rec_tab.NEW_ATTRIBUTE15(i), FND_API.G_MISS_CHAR, NULL, l_party_hist_rec_tab.NEW_ATTRIBUTE15(i)),
		 'N',
		 l_user_id,
		 SYSDATE,
		 l_user_id,
		 SYSDATE,
		 l_login_id,
		 1,
		 decode( l_party_hist_rec_tab.OLD_PRIMARY_FLAG(i), FND_API.G_MISS_CHAR, NULL, l_party_hist_rec_tab.OLD_PRIMARY_FLAG(i)),
		 decode( l_party_hist_rec_tab.NEW_PRIMARY_FLAG(i), FND_API.G_MISS_CHAR, NULL, l_party_hist_rec_tab.NEW_PRIMARY_FLAG(i)),
		 decode( l_party_hist_rec_tab.OLD_PREFERRED_FLAG(i), FND_API.G_MISS_CHAR, NULL, l_party_hist_rec_tab.OLD_PREFERRED_FLAG(i)),
		 decode( l_party_hist_rec_tab.NEW_PREFERRED_FLAG(i), FND_API.G_MISS_CHAR, NULL, l_party_hist_rec_tab.NEW_PREFERRED_FLAG(i))
            );
   END IF;
   --
   IF p_account_tbl.count > 0 THEN
         Build_Acct_Rec_of_Table
            ( p_account_tbl       => p_account_tbl
             ,p_account_rec_tab   => l_account_rec_tab
            );
         --
         l_ctr := l_account_rec_tab.ip_account_id.count;
         --
         FORALL i in 1 .. l_ctr
	    INSERT INTO CSI_IP_ACCOUNTS(
		 IP_ACCOUNT_ID,
		 INSTANCE_PARTY_ID,
		 PARTY_ACCOUNT_ID,
		 RELATIONSHIP_TYPE_CODE,
		 ACTIVE_START_DATE,
		 ACTIVE_END_DATE,
		 CONTEXT,
		 ATTRIBUTE1,
		 ATTRIBUTE2,
		 ATTRIBUTE3,
		 ATTRIBUTE4,
		 ATTRIBUTE5,
		 ATTRIBUTE6,
		 ATTRIBUTE7,
		 ATTRIBUTE8,
		 ATTRIBUTE9,
		 ATTRIBUTE10,
		 ATTRIBUTE11,
		 ATTRIBUTE12,
		 ATTRIBUTE13,
		 ATTRIBUTE14,
		 ATTRIBUTE15,
		 CREATED_BY,
		 CREATION_DATE,
		 LAST_UPDATED_BY,
		 LAST_UPDATE_DATE,
		 LAST_UPDATE_LOGIN,
		 OBJECT_VERSION_NUMBER,
		 BILL_TO_ADDRESS,
		 SHIP_TO_ADDRESS
		) VALUES (
		 l_account_rec_tab.IP_ACCOUNT_ID(i),
		 decode( l_account_rec_tab.INSTANCE_PARTY_ID(i), FND_API.G_MISS_NUM, NULL, l_account_rec_tab.INSTANCE_PARTY_ID(i)),
		 decode( l_account_rec_tab.PARTY_ACCOUNT_ID(i), FND_API.G_MISS_NUM, NULL, l_account_rec_tab.PARTY_ACCOUNT_ID(i)),
		 decode( l_account_rec_tab.RELATIONSHIP_TYPE_CODE(i), FND_API.G_MISS_CHAR, NULL, l_account_rec_tab.RELATIONSHIP_TYPE_CODE(i)),
		 decode( l_account_rec_tab.ACTIVE_START_DATE(i), FND_API.G_MISS_DATE, TO_DATE(NULL), l_account_rec_tab.ACTIVE_START_DATE(i)),
		 decode( l_account_rec_tab.ACTIVE_END_DATE(i), FND_API.G_MISS_DATE, TO_DATE(NULL), l_account_rec_tab.ACTIVE_END_DATE(i)),
		 decode( l_account_rec_tab.CONTEXT(i), FND_API.G_MISS_CHAR, NULL, l_account_rec_tab.CONTEXT(i)),
		 decode( l_account_rec_tab.ATTRIBUTE1(i), FND_API.G_MISS_CHAR, NULL, l_account_rec_tab.ATTRIBUTE1(i)),
		 decode( l_account_rec_tab.ATTRIBUTE2(i), FND_API.G_MISS_CHAR, NULL, l_account_rec_tab.ATTRIBUTE2(i)),
		 decode( l_account_rec_tab.ATTRIBUTE3(i), FND_API.G_MISS_CHAR, NULL, l_account_rec_tab.ATTRIBUTE3(i)),
		 decode( l_account_rec_tab.ATTRIBUTE4(i), FND_API.G_MISS_CHAR, NULL, l_account_rec_tab.ATTRIBUTE4(i)),
		 decode( l_account_rec_tab.ATTRIBUTE5(i), FND_API.G_MISS_CHAR, NULL, l_account_rec_tab.ATTRIBUTE5(i)),
		 decode( l_account_rec_tab.ATTRIBUTE6(i), FND_API.G_MISS_CHAR, NULL, l_account_rec_tab.ATTRIBUTE6(i)),
		 decode( l_account_rec_tab.ATTRIBUTE7(i), FND_API.G_MISS_CHAR, NULL, l_account_rec_tab.ATTRIBUTE7(i)),
		 decode( l_account_rec_tab.ATTRIBUTE8(i), FND_API.G_MISS_CHAR, NULL, l_account_rec_tab.ATTRIBUTE8(i)),
		 decode( l_account_rec_tab.ATTRIBUTE9(i), FND_API.G_MISS_CHAR, NULL, l_account_rec_tab.ATTRIBUTE9(i)),
		 decode( l_account_rec_tab.ATTRIBUTE10(i), FND_API.G_MISS_CHAR, NULL, l_account_rec_tab.ATTRIBUTE10(i)),
		 decode( l_account_rec_tab.ATTRIBUTE11(i), FND_API.G_MISS_CHAR, NULL, l_account_rec_tab.ATTRIBUTE11(i)),
		 decode( l_account_rec_tab.ATTRIBUTE12(i), FND_API.G_MISS_CHAR, NULL, l_account_rec_tab.ATTRIBUTE12(i)),
		 decode( l_account_rec_tab.ATTRIBUTE13(i), FND_API.G_MISS_CHAR, NULL, l_account_rec_tab.ATTRIBUTE13(i)),
		 decode( l_account_rec_tab.ATTRIBUTE14(i), FND_API.G_MISS_CHAR, NULL, l_account_rec_tab.ATTRIBUTE14(i)),
		 decode( l_account_rec_tab.ATTRIBUTE15(i), FND_API.G_MISS_CHAR, NULL, l_account_rec_tab.ATTRIBUTE15(i)),
		 l_user_id,
		 SYSDATE,
		  l_user_id,
		 SYSDATE,
		 l_login_id,
		 1,
		 decode( l_account_rec_tab.BILL_TO_ADDRESS(i), FND_API.G_MISS_NUM, NULL, l_account_rec_tab.BILL_TO_ADDRESS(i)),
		 decode( l_account_rec_tab.SHIP_TO_ADDRESS(i), FND_API.G_MISS_NUM, NULL, l_account_rec_tab.SHIP_TO_ADDRESS(i))
              );
   END IF;
   --
   IF p_owner_pty_acct_tbl.count > 0 THEN
         Build_Owner_Pty_Acct_Rec_Table
            (
              p_owner_pty_acct_tbl     => p_owner_pty_acct_tbl
             ,p_owner_pty_acct_rec_tab => l_owner_pty_acct_rec_tab
            );
         --
         l_ctr := l_owner_pty_acct_rec_tab.instance_id.count;
         --
         FORALL i in 1 .. l_ctr
         UPDATE CSI_ITEM_INSTANCES
         SET owner_party_id = l_owner_pty_acct_rec_tab.party_id(i)
            ,owner_party_source_table = l_owner_pty_acct_rec_tab.party_source_table(i)
            ,owner_party_account_id = l_owner_pty_acct_rec_tab.account_id(i)
         WHERE instance_id = l_owner_pty_acct_rec_tab.instance_id(i);
   END IF;
   --
   IF p_acct_hist_tbl.count > 0 THEN
         Build_Acct_Hist_Rec_of_Table
           ( p_acct_hist_tbl      => p_acct_hist_tbl
            ,p_acct_hist_rec_tab  => l_acct_hist_rec_tab
           );
         --
         l_ctr := l_acct_hist_rec_tab.ip_account_history_id.count;
         --
         FORALL i in 1 .. l_ctr
	    INSERT INTO CSI_IP_ACCOUNTS_H(
		 IP_ACCOUNT_HISTORY_ID,
		 IP_ACCOUNT_ID,
		 TRANSACTION_ID,
		 OLD_PARTY_ACCOUNT_ID,
		 NEW_PARTY_ACCOUNT_ID,
		 OLD_RELATIONSHIP_TYPE_CODE,
		 NEW_RELATIONSHIP_TYPE_CODE,
		 OLD_ACTIVE_START_DATE,
		 NEW_ACTIVE_START_DATE,
		 OLD_ACTIVE_END_DATE,
		 NEW_ACTIVE_END_DATE,
		 OLD_CONTEXT,
		 NEW_CONTEXT,
		 OLD_ATTRIBUTE1,
		 NEW_ATTRIBUTE1,
		 OLD_ATTRIBUTE2,
		 NEW_ATTRIBUTE2,
		 OLD_ATTRIBUTE3,
		 NEW_ATTRIBUTE3,
		 OLD_ATTRIBUTE4,
		 NEW_ATTRIBUTE4,
		 OLD_ATTRIBUTE5,
		 NEW_ATTRIBUTE5,
		 OLD_ATTRIBUTE6,
		 NEW_ATTRIBUTE6,
		 OLD_ATTRIBUTE7,
		 NEW_ATTRIBUTE7,
		 OLD_ATTRIBUTE8,
		 NEW_ATTRIBUTE8,
		 OLD_ATTRIBUTE9,
		 NEW_ATTRIBUTE9,
		 OLD_ATTRIBUTE10,
		 NEW_ATTRIBUTE10,
		 OLD_ATTRIBUTE11,
		 NEW_ATTRIBUTE11,
		 OLD_ATTRIBUTE12,
		 NEW_ATTRIBUTE12,
		 OLD_ATTRIBUTE13,
		 NEW_ATTRIBUTE13,
		 OLD_ATTRIBUTE14,
		 NEW_ATTRIBUTE14,
		 OLD_ATTRIBUTE15,
		 NEW_ATTRIBUTE15,
		 FULL_DUMP_FLAG,
		 CREATED_BY,
		 CREATION_DATE,
		 LAST_UPDATED_BY,
		 LAST_UPDATE_DATE,
		 LAST_UPDATE_LOGIN,
		 OBJECT_VERSION_NUMBER,
		 OLD_BILL_TO_ADDRESS,
		 NEW_BILL_TO_ADDRESS,
		 OLD_SHIP_TO_ADDRESS,
		 NEW_SHIP_TO_ADDRESS
		) VALUES (
		 l_acct_hist_rec_tab.IP_ACCOUNT_HISTORY_ID(i),
		 decode( l_acct_hist_rec_tab.IP_ACCOUNT_ID(i), FND_API.G_MISS_NUM, NULL, l_acct_hist_rec_tab.IP_ACCOUNT_ID(i)),
		 decode( l_acct_hist_rec_tab.TRANSACTION_ID(i), FND_API.G_MISS_NUM, NULL, l_acct_hist_rec_tab.TRANSACTION_ID(i)),
		 decode( l_acct_hist_rec_tab.OLD_PARTY_ACCOUNT_ID(i), FND_API.G_MISS_NUM, NULL, l_acct_hist_rec_tab.OLD_PARTY_ACCOUNT_ID(i)),
		 decode( l_acct_hist_rec_tab.NEW_PARTY_ACCOUNT_ID(i), FND_API.G_MISS_NUM, NULL, l_acct_hist_rec_tab.NEW_PARTY_ACCOUNT_ID(i)),
		 decode( l_acct_hist_rec_tab.OLD_RELATIONSHIP_TYPE_CODE(i), FND_API.G_MISS_CHAR, NULL, l_acct_hist_rec_tab.OLD_RELATIONSHIP_TYPE_CODE(i)),
		 decode( l_acct_hist_rec_tab.NEW_RELATIONSHIP_TYPE_CODE(i), FND_API.G_MISS_CHAR, NULL, l_acct_hist_rec_tab.NEW_RELATIONSHIP_TYPE_CODE(i)),
		 decode( l_acct_hist_rec_tab.OLD_ACTIVE_START_DATE(i), FND_API.G_MISS_DATE, TO_DATE(NULL), l_acct_hist_rec_tab.OLD_ACTIVE_START_DATE(i)),
		 decode( l_acct_hist_rec_tab.NEW_ACTIVE_START_DATE(i), FND_API.G_MISS_DATE, TO_DATE(NULL), l_acct_hist_rec_tab.NEW_ACTIVE_START_DATE(i)),
		 decode( l_acct_hist_rec_tab.OLD_ACTIVE_END_DATE(i), FND_API.G_MISS_DATE, TO_DATE(NULL), l_acct_hist_rec_tab.OLD_ACTIVE_END_DATE(i)),
		 decode( l_acct_hist_rec_tab.NEW_ACTIVE_END_DATE(i), FND_API.G_MISS_DATE, TO_DATE(NULL), l_acct_hist_rec_tab.NEW_ACTIVE_END_DATE(i)),
		 decode( l_acct_hist_rec_tab.OLD_CONTEXT(i), FND_API.G_MISS_CHAR, NULL, l_acct_hist_rec_tab.OLD_CONTEXT(i)),
		 decode( l_acct_hist_rec_tab.NEW_CONTEXT(i), FND_API.G_MISS_CHAR, NULL, l_acct_hist_rec_tab.NEW_CONTEXT(i)),
		 decode( l_acct_hist_rec_tab.OLD_ATTRIBUTE1(i), FND_API.G_MISS_CHAR, NULL, l_acct_hist_rec_tab.OLD_ATTRIBUTE1(i)),
		 decode( l_acct_hist_rec_tab.NEW_ATTRIBUTE1(i), FND_API.G_MISS_CHAR, NULL, l_acct_hist_rec_tab.NEW_ATTRIBUTE1(i)),
		 decode( l_acct_hist_rec_tab.OLD_ATTRIBUTE2(i), FND_API.G_MISS_CHAR, NULL, l_acct_hist_rec_tab.OLD_ATTRIBUTE2(i)),
		 decode( l_acct_hist_rec_tab.NEW_ATTRIBUTE2(i), FND_API.G_MISS_CHAR, NULL, l_acct_hist_rec_tab.NEW_ATTRIBUTE2(i)),
		 decode( l_acct_hist_rec_tab.OLD_ATTRIBUTE3(i), FND_API.G_MISS_CHAR, NULL, l_acct_hist_rec_tab.OLD_ATTRIBUTE3(i)),
		 decode( l_acct_hist_rec_tab.NEW_ATTRIBUTE3(i), FND_API.G_MISS_CHAR, NULL, l_acct_hist_rec_tab.NEW_ATTRIBUTE3(i)),
		 decode( l_acct_hist_rec_tab.OLD_ATTRIBUTE4(i), FND_API.G_MISS_CHAR, NULL, l_acct_hist_rec_tab.OLD_ATTRIBUTE4(i)),
		 decode( l_acct_hist_rec_tab.NEW_ATTRIBUTE4(i), FND_API.G_MISS_CHAR, NULL, l_acct_hist_rec_tab.NEW_ATTRIBUTE4(i)),
		 decode( l_acct_hist_rec_tab.OLD_ATTRIBUTE5(i), FND_API.G_MISS_CHAR, NULL, l_acct_hist_rec_tab.OLD_ATTRIBUTE5(i)),
		 decode( l_acct_hist_rec_tab.NEW_ATTRIBUTE5(i), FND_API.G_MISS_CHAR, NULL, l_acct_hist_rec_tab.NEW_ATTRIBUTE5(i)),
		 decode( l_acct_hist_rec_tab.OLD_ATTRIBUTE6(i), FND_API.G_MISS_CHAR, NULL, l_acct_hist_rec_tab.OLD_ATTRIBUTE6(i)),
		 decode( l_acct_hist_rec_tab.NEW_ATTRIBUTE6(i), FND_API.G_MISS_CHAR, NULL, l_acct_hist_rec_tab.NEW_ATTRIBUTE6(i)),
		 decode( l_acct_hist_rec_tab.OLD_ATTRIBUTE7(i), FND_API.G_MISS_CHAR, NULL, l_acct_hist_rec_tab.OLD_ATTRIBUTE7(i)),
		 decode( l_acct_hist_rec_tab.NEW_ATTRIBUTE7(i), FND_API.G_MISS_CHAR, NULL, l_acct_hist_rec_tab.NEW_ATTRIBUTE7(i)),
		 decode( l_acct_hist_rec_tab.OLD_ATTRIBUTE8(i), FND_API.G_MISS_CHAR, NULL, l_acct_hist_rec_tab.OLD_ATTRIBUTE8(i)),
		 decode( l_acct_hist_rec_tab.NEW_ATTRIBUTE8(i), FND_API.G_MISS_CHAR, NULL, l_acct_hist_rec_tab.NEW_ATTRIBUTE8(i)),
		 decode( l_acct_hist_rec_tab.OLD_ATTRIBUTE9(i), FND_API.G_MISS_CHAR, NULL, l_acct_hist_rec_tab.OLD_ATTRIBUTE9(i)),
		 decode( l_acct_hist_rec_tab.NEW_ATTRIBUTE9(i), FND_API.G_MISS_CHAR, NULL, l_acct_hist_rec_tab.NEW_ATTRIBUTE9(i)),
		 decode( l_acct_hist_rec_tab.OLD_ATTRIBUTE10(i), FND_API.G_MISS_CHAR, NULL, l_acct_hist_rec_tab.OLD_ATTRIBUTE10(i)),
		 decode( l_acct_hist_rec_tab.NEW_ATTRIBUTE10(i), FND_API.G_MISS_CHAR, NULL, l_acct_hist_rec_tab.NEW_ATTRIBUTE10(i)),
		 decode( l_acct_hist_rec_tab.OLD_ATTRIBUTE11(i), FND_API.G_MISS_CHAR, NULL, l_acct_hist_rec_tab.OLD_ATTRIBUTE11(i)),
		 decode( l_acct_hist_rec_tab.NEW_ATTRIBUTE11(i), FND_API.G_MISS_CHAR, NULL, l_acct_hist_rec_tab.NEW_ATTRIBUTE11(i)),
		 decode( l_acct_hist_rec_tab.OLD_ATTRIBUTE12(i), FND_API.G_MISS_CHAR, NULL, l_acct_hist_rec_tab.OLD_ATTRIBUTE12(i)),
		 decode( l_acct_hist_rec_tab.NEW_ATTRIBUTE12(i), FND_API.G_MISS_CHAR, NULL, l_acct_hist_rec_tab.NEW_ATTRIBUTE12(i)),
		 decode( l_acct_hist_rec_tab.OLD_ATTRIBUTE13(i), FND_API.G_MISS_CHAR, NULL, l_acct_hist_rec_tab.OLD_ATTRIBUTE13(i)),
		 decode( l_acct_hist_rec_tab.NEW_ATTRIBUTE13(i), FND_API.G_MISS_CHAR, NULL, l_acct_hist_rec_tab.NEW_ATTRIBUTE13(i)),
		 decode( l_acct_hist_rec_tab.OLD_ATTRIBUTE14(i), FND_API.G_MISS_CHAR, NULL, l_acct_hist_rec_tab.OLD_ATTRIBUTE14(i)),
		 decode( l_acct_hist_rec_tab.NEW_ATTRIBUTE14(i), FND_API.G_MISS_CHAR, NULL, l_acct_hist_rec_tab.NEW_ATTRIBUTE14(i)),
		 decode( l_acct_hist_rec_tab.OLD_ATTRIBUTE15(i), FND_API.G_MISS_CHAR, NULL, l_acct_hist_rec_tab.OLD_ATTRIBUTE15(i)),
		 decode( l_acct_hist_rec_tab.NEW_ATTRIBUTE15(i), FND_API.G_MISS_CHAR, NULL, l_acct_hist_rec_tab.NEW_ATTRIBUTE15(i)),
		 'N',
		 l_user_id,
		 SYSDATE,
		 l_user_id,
		 SYSDATE,
		 l_login_id,
		 1,
		 decode( l_acct_hist_rec_tab.OLD_BILL_TO_ADDRESS(i), FND_API.G_MISS_NUM, NULL, l_acct_hist_rec_tab.OLD_BILL_TO_ADDRESS(i)),
		 decode( l_acct_hist_rec_tab.NEW_BILL_TO_ADDRESS(i), FND_API.G_MISS_NUM, NULL, l_acct_hist_rec_tab.NEW_BILL_TO_ADDRESS(i)),
		 decode( l_acct_hist_rec_tab.OLD_SHIP_TO_ADDRESS(i), FND_API.G_MISS_NUM, NULL, l_acct_hist_rec_tab.OLD_SHIP_TO_ADDRESS(i)),
		 decode( l_acct_hist_rec_tab.NEW_SHIP_TO_ADDRESS(i), FND_API.G_MISS_NUM, NULL, l_acct_hist_rec_tab.NEW_SHIP_TO_ADDRESS(i))
             );
   END IF;
   --
   IF p_org_units_tbl.count > 0 THEN
         Build_Org_Rec_of_Table
            (
              p_org_tbl           => p_org_units_tbl
             ,p_org_units_rec_tab => l_org_units_rec_tab
            );
         --
         l_ctr := l_org_units_rec_tab.instance_ou_id.count;
         --
	 FORALL i in 1 .. l_ctr
	  INSERT INTO CSI_I_ORG_ASSIGNMENTS(
	     INSTANCE_OU_ID,
	     INSTANCE_ID,
	     OPERATING_UNIT_ID,
	     RELATIONSHIP_TYPE_CODE,
	     ACTIVE_START_DATE,
	     ACTIVE_END_DATE,
	     CONTEXT,
	     ATTRIBUTE1,
	     ATTRIBUTE2,
	     ATTRIBUTE3,
	     ATTRIBUTE4,
	     ATTRIBUTE5,
	     ATTRIBUTE6,
	     ATTRIBUTE7,
	     ATTRIBUTE8,
	     ATTRIBUTE9,
	     ATTRIBUTE10,
	     ATTRIBUTE11,
	     ATTRIBUTE12,
	     ATTRIBUTE13,
	     ATTRIBUTE14,
	     ATTRIBUTE15,
	     CREATED_BY,
	     CREATION_DATE,
	     LAST_UPDATED_BY,
	     LAST_UPDATE_DATE,
	     LAST_UPDATE_LOGIN,
	     OBJECT_VERSION_NUMBER
	    ) VALUES (
	     l_org_units_rec_tab.INSTANCE_OU_ID(i),
	     decode( l_org_units_rec_tab.INSTANCE_ID(i), FND_API.G_MISS_NUM, NULL, l_org_units_rec_tab.INSTANCE_ID(i)),
	     decode( l_org_units_rec_tab.OPERATING_UNIT_ID(i), FND_API.G_MISS_NUM, NULL, l_org_units_rec_tab.OPERATING_UNIT_ID(i)),
	     decode( l_org_units_rec_tab.RELATIONSHIP_TYPE_CODE(i), FND_API.G_MISS_CHAR, NULL, l_org_units_rec_tab.RELATIONSHIP_TYPE_CODE(i)),
	     decode( l_org_units_rec_tab.ACTIVE_START_DATE(i), FND_API.G_MISS_DATE, TO_DATE(NULL), l_org_units_rec_tab.ACTIVE_START_DATE(i)),
	     decode( l_org_units_rec_tab.ACTIVE_END_DATE(i), FND_API.G_MISS_DATE, TO_DATE(NULL), l_org_units_rec_tab.ACTIVE_END_DATE(i)),
	     decode( l_org_units_rec_tab.CONTEXT(i), FND_API.G_MISS_CHAR, NULL, l_org_units_rec_tab.CONTEXT(i)),
	     decode( l_org_units_rec_tab.ATTRIBUTE1(i), FND_API.G_MISS_CHAR, NULL, l_org_units_rec_tab.ATTRIBUTE1(i)),
	     decode( l_org_units_rec_tab.ATTRIBUTE2(i), FND_API.G_MISS_CHAR, NULL, l_org_units_rec_tab.ATTRIBUTE2(i)),
	     decode( l_org_units_rec_tab.ATTRIBUTE3(i), FND_API.G_MISS_CHAR, NULL, l_org_units_rec_tab.ATTRIBUTE3(i)),
	     decode( l_org_units_rec_tab.ATTRIBUTE4(i), FND_API.G_MISS_CHAR, NULL, l_org_units_rec_tab.ATTRIBUTE4(i)),
	     decode( l_org_units_rec_tab.ATTRIBUTE5(i), FND_API.G_MISS_CHAR, NULL, l_org_units_rec_tab.ATTRIBUTE5(i)),
	     decode( l_org_units_rec_tab.ATTRIBUTE6(i), FND_API.G_MISS_CHAR, NULL, l_org_units_rec_tab.ATTRIBUTE6(i)),
	     decode( l_org_units_rec_tab.ATTRIBUTE7(i), FND_API.G_MISS_CHAR, NULL, l_org_units_rec_tab.ATTRIBUTE7(i)),
	     decode( l_org_units_rec_tab.ATTRIBUTE8(i), FND_API.G_MISS_CHAR, NULL, l_org_units_rec_tab.ATTRIBUTE8(i)),
	     decode( l_org_units_rec_tab.ATTRIBUTE9(i), FND_API.G_MISS_CHAR, NULL, l_org_units_rec_tab.ATTRIBUTE9(i)),
	     decode( l_org_units_rec_tab.ATTRIBUTE10(i), FND_API.G_MISS_CHAR, NULL, l_org_units_rec_tab.ATTRIBUTE10(i)),
	     decode( l_org_units_rec_tab.ATTRIBUTE11(i), FND_API.G_MISS_CHAR, NULL, l_org_units_rec_tab.ATTRIBUTE11(i)),
	     decode( l_org_units_rec_tab.ATTRIBUTE12(i), FND_API.G_MISS_CHAR, NULL, l_org_units_rec_tab.ATTRIBUTE12(i)),
	     decode( l_org_units_rec_tab.ATTRIBUTE13(i), FND_API.G_MISS_CHAR, NULL, l_org_units_rec_tab.ATTRIBUTE13(i)),
	     decode( l_org_units_rec_tab.ATTRIBUTE14(i), FND_API.G_MISS_CHAR, NULL, l_org_units_rec_tab.ATTRIBUTE14(i)),
	     decode( l_org_units_rec_tab.ATTRIBUTE15(i), FND_API.G_MISS_CHAR, NULL, l_org_units_rec_tab.ATTRIBUTE15(i)),
	     l_user_id,
	     SYSDATE,
	     l_user_id,
	     SYSDATE,
	     l_login_id,
	     1);
   END IF;
   --
   IF p_org_units_hist_tbl.count > 0 THEN
         Build_Org_Hist_Rec_of_Table
            (
              p_org_hist_tbl         => p_org_units_hist_tbl
             ,p_org_hist_rec_tab     => l_org_hist_rec_tab
            );
         --
         l_ctr := l_org_hist_rec_tab.instance_ou_history_id.count;
         --
	 FORALL i in 1 .. l_ctr
	 INSERT INTO CSI_I_ORG_ASSIGNMENTS_H(
	    INSTANCE_OU_HISTORY_ID,
	    INSTANCE_OU_ID,
	    TRANSACTION_ID,
	    OLD_OPERATING_UNIT_ID,
	    NEW_OPERATING_UNIT_ID,
	    OLD_RELATIONSHIP_TYPE_CODE,
	    NEW_RELATIONSHIP_TYPE_CODE,
	    OLD_ACTIVE_START_DATE,
	    NEW_ACTIVE_START_DATE,
	    OLD_ACTIVE_END_DATE,
	    NEW_ACTIVE_END_DATE,
	    OLD_CONTEXT,
	    NEW_CONTEXT,
	    OLD_ATTRIBUTE1,
	    NEW_ATTRIBUTE1,
	    OLD_ATTRIBUTE2,
	    NEW_ATTRIBUTE2,
	    OLD_ATTRIBUTE3,
	    NEW_ATTRIBUTE3,
	    OLD_ATTRIBUTE4,
	    NEW_ATTRIBUTE4,
	    OLD_ATTRIBUTE5,
	    NEW_ATTRIBUTE5,
	    OLD_ATTRIBUTE6,
	    NEW_ATTRIBUTE6,
	    OLD_ATTRIBUTE7,
	    NEW_ATTRIBUTE7,
	    OLD_ATTRIBUTE8,
	    NEW_ATTRIBUTE8,
	    OLD_ATTRIBUTE9,
	    NEW_ATTRIBUTE9,
	    OLD_ATTRIBUTE10,
	    NEW_ATTRIBUTE10,
	    OLD_ATTRIBUTE11,
	    NEW_ATTRIBUTE11,
	    OLD_ATTRIBUTE12,
	    NEW_ATTRIBUTE12,
	    OLD_ATTRIBUTE13,
	    NEW_ATTRIBUTE13,
	    OLD_ATTRIBUTE14,
	    NEW_ATTRIBUTE14,
	    OLD_ATTRIBUTE15,
	    NEW_ATTRIBUTE15,
	    FULL_DUMP_FLAG,
	    CREATED_BY,
	    CREATION_DATE,
	    LAST_UPDATED_BY,
	    LAST_UPDATE_DATE,
	    LAST_UPDATE_LOGIN,
	    OBJECT_VERSION_NUMBER
	    ) VALUES (
	    l_org_hist_rec_tab.INSTANCE_OU_HISTORY_ID(i),
	    decode( l_org_hist_rec_tab.INSTANCE_OU_ID(i), FND_API.G_MISS_NUM, NULL, l_org_hist_rec_tab.INSTANCE_OU_ID(i)),
	    decode( l_org_hist_rec_tab.TRANSACTION_ID(i), FND_API.G_MISS_NUM, NULL, l_org_hist_rec_tab.TRANSACTION_ID(i)),
	    decode( l_org_hist_rec_tab.OLD_OPERATING_UNIT_ID(i), FND_API.G_MISS_NUM, NULL, l_org_hist_rec_tab.OLD_OPERATING_UNIT_ID(i)),
	    decode( l_org_hist_rec_tab.NEW_OPERATING_UNIT_ID(i), FND_API.G_MISS_NUM, NULL, l_org_hist_rec_tab.NEW_OPERATING_UNIT_ID(i)),
	    decode( l_org_hist_rec_tab.OLD_RELATIONSHIP_TYPE_CODE(i), FND_API.G_MISS_CHAR, NULL, l_org_hist_rec_tab.OLD_RELATIONSHIP_TYPE_CODE(i)),
	    decode( l_org_hist_rec_tab.NEW_RELATIONSHIP_TYPE_CODE(i), FND_API.G_MISS_CHAR, NULL, l_org_hist_rec_tab.NEW_RELATIONSHIP_TYPE_CODE(i)),
	    decode( l_org_hist_rec_tab.OLD_ACTIVE_START_DATE(i), FND_API.G_MISS_DATE, TO_DATE(NULL), l_org_hist_rec_tab.OLD_ACTIVE_START_DATE(i)),
	    decode( l_org_hist_rec_tab.NEW_ACTIVE_START_DATE(i), FND_API.G_MISS_DATE, TO_DATE(NULL), l_org_hist_rec_tab.NEW_ACTIVE_START_DATE(i)),
	    decode( l_org_hist_rec_tab.OLD_ACTIVE_END_DATE(i), FND_API.G_MISS_DATE, TO_DATE(NULL), l_org_hist_rec_tab.OLD_ACTIVE_END_DATE(i)),
	    decode( l_org_hist_rec_tab.NEW_ACTIVE_END_DATE(i), FND_API.G_MISS_DATE, TO_DATE(NULL), l_org_hist_rec_tab.NEW_ACTIVE_END_DATE(i)),
	    decode( l_org_hist_rec_tab.OLD_CONTEXT(i), FND_API.G_MISS_CHAR, NULL, l_org_hist_rec_tab.OLD_CONTEXT(i)),
	    decode( l_org_hist_rec_tab.NEW_CONTEXT(i), FND_API.G_MISS_CHAR, NULL, l_org_hist_rec_tab.NEW_CONTEXT(i)),
	    decode( l_org_hist_rec_tab.OLD_ATTRIBUTE1(i), FND_API.G_MISS_CHAR, NULL, l_org_hist_rec_tab.OLD_ATTRIBUTE1(i)),
	    decode( l_org_hist_rec_tab.NEW_ATTRIBUTE1(i), FND_API.G_MISS_CHAR, NULL, l_org_hist_rec_tab.NEW_ATTRIBUTE1(i)),
	    decode( l_org_hist_rec_tab.OLD_ATTRIBUTE2(i), FND_API.G_MISS_CHAR, NULL, l_org_hist_rec_tab.OLD_ATTRIBUTE2(i)),
	    decode( l_org_hist_rec_tab.NEW_ATTRIBUTE2(i), FND_API.G_MISS_CHAR, NULL, l_org_hist_rec_tab.NEW_ATTRIBUTE2(i)),
	    decode( l_org_hist_rec_tab.OLD_ATTRIBUTE3(i), FND_API.G_MISS_CHAR, NULL, l_org_hist_rec_tab.OLD_ATTRIBUTE3(i)),
	    decode( l_org_hist_rec_tab.NEW_ATTRIBUTE3(i), FND_API.G_MISS_CHAR, NULL, l_org_hist_rec_tab.NEW_ATTRIBUTE3(i)),
	    decode( l_org_hist_rec_tab.OLD_ATTRIBUTE4(i), FND_API.G_MISS_CHAR, NULL, l_org_hist_rec_tab.OLD_ATTRIBUTE4(i)),
	    decode( l_org_hist_rec_tab.NEW_ATTRIBUTE4(i), FND_API.G_MISS_CHAR, NULL, l_org_hist_rec_tab.NEW_ATTRIBUTE4(i)),
	    decode( l_org_hist_rec_tab.OLD_ATTRIBUTE5(i), FND_API.G_MISS_CHAR, NULL, l_org_hist_rec_tab.OLD_ATTRIBUTE5(i)),
	    decode( l_org_hist_rec_tab.NEW_ATTRIBUTE5(i), FND_API.G_MISS_CHAR, NULL, l_org_hist_rec_tab.NEW_ATTRIBUTE5(i)),
	    decode( l_org_hist_rec_tab.OLD_ATTRIBUTE6(i), FND_API.G_MISS_CHAR, NULL, l_org_hist_rec_tab.OLD_ATTRIBUTE6(i)),
	    decode( l_org_hist_rec_tab.NEW_ATTRIBUTE6(i), FND_API.G_MISS_CHAR, NULL, l_org_hist_rec_tab.NEW_ATTRIBUTE6(i)),
	    decode( l_org_hist_rec_tab.OLD_ATTRIBUTE7(i), FND_API.G_MISS_CHAR, NULL, l_org_hist_rec_tab.OLD_ATTRIBUTE7(i)),
	    decode( l_org_hist_rec_tab.NEW_ATTRIBUTE7(i), FND_API.G_MISS_CHAR, NULL, l_org_hist_rec_tab.NEW_ATTRIBUTE7(i)),
	    decode( l_org_hist_rec_tab.OLD_ATTRIBUTE8(i), FND_API.G_MISS_CHAR, NULL, l_org_hist_rec_tab.OLD_ATTRIBUTE8(i)),
	    decode( l_org_hist_rec_tab.NEW_ATTRIBUTE8(i), FND_API.G_MISS_CHAR, NULL, l_org_hist_rec_tab.NEW_ATTRIBUTE8(i)),
	    decode( l_org_hist_rec_tab.OLD_ATTRIBUTE9(i), FND_API.G_MISS_CHAR, NULL, l_org_hist_rec_tab.OLD_ATTRIBUTE9(i)),
	    decode( l_org_hist_rec_tab.NEW_ATTRIBUTE9(i), FND_API.G_MISS_CHAR, NULL, l_org_hist_rec_tab.NEW_ATTRIBUTE9(i)),
	    decode( l_org_hist_rec_tab.OLD_ATTRIBUTE10(i), FND_API.G_MISS_CHAR, NULL, l_org_hist_rec_tab.OLD_ATTRIBUTE10(i)),
	    decode( l_org_hist_rec_tab.NEW_ATTRIBUTE10(i), FND_API.G_MISS_CHAR, NULL, l_org_hist_rec_tab.NEW_ATTRIBUTE10(i)),
	    decode( l_org_hist_rec_tab.OLD_ATTRIBUTE11(i), FND_API.G_MISS_CHAR, NULL, l_org_hist_rec_tab.OLD_ATTRIBUTE11(i)),
	    decode( l_org_hist_rec_tab.NEW_ATTRIBUTE11(i), FND_API.G_MISS_CHAR, NULL, l_org_hist_rec_tab.NEW_ATTRIBUTE11(i)),
	    decode( l_org_hist_rec_tab.OLD_ATTRIBUTE12(i), FND_API.G_MISS_CHAR, NULL, l_org_hist_rec_tab.OLD_ATTRIBUTE12(i)),
	    decode( l_org_hist_rec_tab.NEW_ATTRIBUTE12(i), FND_API.G_MISS_CHAR, NULL, l_org_hist_rec_tab.NEW_ATTRIBUTE12(i)),
	    decode( l_org_hist_rec_tab.OLD_ATTRIBUTE13(i), FND_API.G_MISS_CHAR, NULL, l_org_hist_rec_tab.OLD_ATTRIBUTE13(i)),
	    decode( l_org_hist_rec_tab.NEW_ATTRIBUTE13(i), FND_API.G_MISS_CHAR, NULL, l_org_hist_rec_tab.NEW_ATTRIBUTE13(i)),
	    decode( l_org_hist_rec_tab.OLD_ATTRIBUTE14(i), FND_API.G_MISS_CHAR, NULL, l_org_hist_rec_tab.OLD_ATTRIBUTE14(i)),
	    decode( l_org_hist_rec_tab.NEW_ATTRIBUTE14(i), FND_API.G_MISS_CHAR, NULL, l_org_hist_rec_tab.NEW_ATTRIBUTE14(i)),
	    decode( l_org_hist_rec_tab.OLD_ATTRIBUTE15(i), FND_API.G_MISS_CHAR, NULL, l_org_hist_rec_tab.OLD_ATTRIBUTE15(i)),
	    decode( l_org_hist_rec_tab.NEW_ATTRIBUTE15(i), FND_API.G_MISS_CHAR, NULL, l_org_hist_rec_tab.NEW_ATTRIBUTE15(i)),
	    'N',
	    l_user_id,
	    SYSDATE,
	    l_user_id,
	    SYSDATE,
	    l_login_id,
	    1);
   END IF;
   --
   IF p_pricing_tbl.count > 0 THEN
      Build_pricing_Rec_of_Table
        (
          p_pricing_tbl       => p_pricing_tbl
         ,p_pricing_rec_tab   => l_pricing_rec_tab
        );
      --
      l_ctr := l_pricing_rec_tab.pricing_attribute_id.count;
      --
      FORALL i in 1 .. l_ctr
       INSERT INTO CSI_I_PRICING_ATTRIBS(
	  PRICING_ATTRIBUTE_ID,
	  INSTANCE_ID,
	  ACTIVE_START_DATE,
	  ACTIVE_END_DATE,
	  CONTEXT,
	  ATTRIBUTE1,
	  ATTRIBUTE2,
	  ATTRIBUTE3,
	  ATTRIBUTE4,
	  ATTRIBUTE5,
	  ATTRIBUTE6,
	  ATTRIBUTE7,
	  ATTRIBUTE8,
	  ATTRIBUTE9,
	  ATTRIBUTE10,
	  ATTRIBUTE11,
	  ATTRIBUTE12,
	  ATTRIBUTE13,
	  ATTRIBUTE14,
	  ATTRIBUTE15,
	  CREATED_BY,
	  CREATION_DATE,
	  LAST_UPDATED_BY,
	  LAST_UPDATE_DATE,
	  LAST_UPDATE_LOGIN,
	  OBJECT_VERSION_NUMBER,
	  PRICING_CONTEXT,
	  PRICING_ATTRIBUTE1,
	  PRICING_ATTRIBUTE2,
	  PRICING_ATTRIBUTE3,
	  PRICING_ATTRIBUTE4,
	  PRICING_ATTRIBUTE5,
	  PRICING_ATTRIBUTE6,
	  PRICING_ATTRIBUTE7,
	  PRICING_ATTRIBUTE8,
	  PRICING_ATTRIBUTE9,
	  PRICING_ATTRIBUTE10,
	  PRICING_ATTRIBUTE11,
	  PRICING_ATTRIBUTE12,
	  PRICING_ATTRIBUTE13,
	  PRICING_ATTRIBUTE14,
	  PRICING_ATTRIBUTE15,
	  PRICING_ATTRIBUTE16,
	  PRICING_ATTRIBUTE17,
	  PRICING_ATTRIBUTE18,
	  PRICING_ATTRIBUTE19,
	  PRICING_ATTRIBUTE20,
	  PRICING_ATTRIBUTE21,
	  PRICING_ATTRIBUTE22,
	  PRICING_ATTRIBUTE23,
	  PRICING_ATTRIBUTE24,
	  PRICING_ATTRIBUTE25,
	  PRICING_ATTRIBUTE26,
	  PRICING_ATTRIBUTE27,
	  PRICING_ATTRIBUTE28,
	  PRICING_ATTRIBUTE29,
	  PRICING_ATTRIBUTE30,
	  PRICING_ATTRIBUTE31,
	  PRICING_ATTRIBUTE32,
	  PRICING_ATTRIBUTE33,
	  PRICING_ATTRIBUTE34,
	  PRICING_ATTRIBUTE35,
	  PRICING_ATTRIBUTE36,
	  PRICING_ATTRIBUTE37,
	  PRICING_ATTRIBUTE38,
	  PRICING_ATTRIBUTE39,
	  PRICING_ATTRIBUTE40,
	  PRICING_ATTRIBUTE41,
	  PRICING_ATTRIBUTE42,
	  PRICING_ATTRIBUTE43,
	  PRICING_ATTRIBUTE44,
	  PRICING_ATTRIBUTE45,
	  PRICING_ATTRIBUTE46,
	  PRICING_ATTRIBUTE47,
	  PRICING_ATTRIBUTE48,
	  PRICING_ATTRIBUTE49,
	  PRICING_ATTRIBUTE50,
	  PRICING_ATTRIBUTE51,
	  PRICING_ATTRIBUTE52,
	  PRICING_ATTRIBUTE53,
	  PRICING_ATTRIBUTE54,
	  PRICING_ATTRIBUTE55,
	  PRICING_ATTRIBUTE56,
	  PRICING_ATTRIBUTE57,
	  PRICING_ATTRIBUTE58,
	  PRICING_ATTRIBUTE59,
	  PRICING_ATTRIBUTE60,
	  PRICING_ATTRIBUTE61,
	  PRICING_ATTRIBUTE62,
	  PRICING_ATTRIBUTE63,
	  PRICING_ATTRIBUTE64,
	  PRICING_ATTRIBUTE65,
	  PRICING_ATTRIBUTE66,
	  PRICING_ATTRIBUTE67,
	  PRICING_ATTRIBUTE68,
	  PRICING_ATTRIBUTE69,
	  PRICING_ATTRIBUTE70,
	  PRICING_ATTRIBUTE71,
	  PRICING_ATTRIBUTE72,
	  PRICING_ATTRIBUTE73,
	  PRICING_ATTRIBUTE74,
	  PRICING_ATTRIBUTE75,
	  PRICING_ATTRIBUTE76,
	  PRICING_ATTRIBUTE77,
	  PRICING_ATTRIBUTE78,
	  PRICING_ATTRIBUTE79,
	  PRICING_ATTRIBUTE80,
	  PRICING_ATTRIBUTE81,
	  PRICING_ATTRIBUTE82,
	  PRICING_ATTRIBUTE83,
	  PRICING_ATTRIBUTE84,
	  PRICING_ATTRIBUTE85,
	  PRICING_ATTRIBUTE86,
	  PRICING_ATTRIBUTE87,
	  PRICING_ATTRIBUTE88,
	  PRICING_ATTRIBUTE89,
	  PRICING_ATTRIBUTE90,
	  PRICING_ATTRIBUTE91,
	  PRICING_ATTRIBUTE92,
	  PRICING_ATTRIBUTE93,
	  PRICING_ATTRIBUTE94,
	  PRICING_ATTRIBUTE95,
	  PRICING_ATTRIBUTE96,
	  PRICING_ATTRIBUTE97,
	  PRICING_ATTRIBUTE98,
	  PRICING_ATTRIBUTE99,
	  PRICING_ATTRIBUTE100
	 ) VALUES (
	  l_pricing_rec_tab.PRICING_ATTRIBUTE_ID(i),
	  decode( l_pricing_rec_tab.INSTANCE_ID(i), FND_API.G_MISS_NUM, NULL, l_pricing_rec_tab.INSTANCE_ID(i)),
	  decode( l_pricing_rec_tab.ACTIVE_START_DATE(i), FND_API.G_MISS_DATE, TO_DATE(NULL), l_pricing_rec_tab.ACTIVE_START_DATE(i)),
	  decode( l_pricing_rec_tab.ACTIVE_END_DATE(i), FND_API.G_MISS_DATE, TO_DATE(NULL), l_pricing_rec_tab.ACTIVE_END_DATE(i)),
	  decode( l_pricing_rec_tab.CONTEXT(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.CONTEXT(i)),
	  decode( l_pricing_rec_tab.ATTRIBUTE1(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.ATTRIBUTE1(i)),
	  decode( l_pricing_rec_tab.ATTRIBUTE2(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.ATTRIBUTE2(i)),
	  decode( l_pricing_rec_tab.ATTRIBUTE3(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.ATTRIBUTE3(i)),
	  decode( l_pricing_rec_tab.ATTRIBUTE4(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.ATTRIBUTE4(i)),
	  decode( l_pricing_rec_tab.ATTRIBUTE5(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.ATTRIBUTE5(i)),
	  decode( l_pricing_rec_tab.ATTRIBUTE6(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.ATTRIBUTE6(i)),
	  decode( l_pricing_rec_tab.ATTRIBUTE7(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.ATTRIBUTE7(i)),
	  decode( l_pricing_rec_tab.ATTRIBUTE8(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.ATTRIBUTE8(i)),
	  decode( l_pricing_rec_tab.ATTRIBUTE9(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.ATTRIBUTE9(i)),
	  decode( l_pricing_rec_tab.ATTRIBUTE10(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.ATTRIBUTE10(i)),
	  decode( l_pricing_rec_tab.ATTRIBUTE11(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.ATTRIBUTE11(i)),
	  decode( l_pricing_rec_tab.ATTRIBUTE12(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.ATTRIBUTE12(i)),
	  decode( l_pricing_rec_tab.ATTRIBUTE13(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.ATTRIBUTE13(i)),
	  decode( l_pricing_rec_tab.ATTRIBUTE14(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.ATTRIBUTE14(i)),
	  decode( l_pricing_rec_tab.ATTRIBUTE15(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.ATTRIBUTE15(i)),
	  l_user_id,
	  SYSDATE,
	  l_user_id,
	  SYSDATE,
	  l_login_id,
	  1,
	  decode( l_pricing_rec_tab.PRICING_CONTEXT(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.PRICING_CONTEXT(i)),
	  decode( l_pricing_rec_tab.PRICING_ATTRIBUTE1(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.PRICING_ATTRIBUTE1(i)),
	  decode( l_pricing_rec_tab.PRICING_ATTRIBUTE2(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.PRICING_ATTRIBUTE2(i)),
	  decode( l_pricing_rec_tab.PRICING_ATTRIBUTE3(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.PRICING_ATTRIBUTE3(i)),
	  decode( l_pricing_rec_tab.PRICING_ATTRIBUTE4(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.PRICING_ATTRIBUTE4(i)),
	  decode( l_pricing_rec_tab.PRICING_ATTRIBUTE5(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.PRICING_ATTRIBUTE5(i)),
	  decode( l_pricing_rec_tab.PRICING_ATTRIBUTE6(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.PRICING_ATTRIBUTE6(i)),
	  decode( l_pricing_rec_tab.PRICING_ATTRIBUTE7(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.PRICING_ATTRIBUTE7(i)),
	  decode( l_pricing_rec_tab.PRICING_ATTRIBUTE8(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.PRICING_ATTRIBUTE8(i)),
	  decode( l_pricing_rec_tab.PRICING_ATTRIBUTE9(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.PRICING_ATTRIBUTE9(i)),
	  decode( l_pricing_rec_tab.PRICING_ATTRIBUTE10(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.PRICING_ATTRIBUTE10(i)),
	  decode( l_pricing_rec_tab.PRICING_ATTRIBUTE11(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.PRICING_ATTRIBUTE11(i)),
	  decode( l_pricing_rec_tab.PRICING_ATTRIBUTE12(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.PRICING_ATTRIBUTE12(i)),
	  decode( l_pricing_rec_tab.PRICING_ATTRIBUTE13(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.PRICING_ATTRIBUTE13(i)),
	  decode( l_pricing_rec_tab.PRICING_ATTRIBUTE14(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.PRICING_ATTRIBUTE14(i)),
	  decode( l_pricing_rec_tab.PRICING_ATTRIBUTE15(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.PRICING_ATTRIBUTE15(i)),
	  decode( l_pricing_rec_tab.PRICING_ATTRIBUTE16(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.PRICING_ATTRIBUTE16(i)),
	  decode( l_pricing_rec_tab.PRICING_ATTRIBUTE17(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.PRICING_ATTRIBUTE17(i)),
	  decode( l_pricing_rec_tab.PRICING_ATTRIBUTE18(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.PRICING_ATTRIBUTE18(i)),
	  decode( l_pricing_rec_tab.PRICING_ATTRIBUTE19(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.PRICING_ATTRIBUTE19(i)),
	  decode( l_pricing_rec_tab.PRICING_ATTRIBUTE20(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.PRICING_ATTRIBUTE20(i)),
	  decode( l_pricing_rec_tab.PRICING_ATTRIBUTE21(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.PRICING_ATTRIBUTE21(i)),
	  decode( l_pricing_rec_tab.PRICING_ATTRIBUTE22(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.PRICING_ATTRIBUTE22(i)),
	  decode( l_pricing_rec_tab.PRICING_ATTRIBUTE23(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.PRICING_ATTRIBUTE23(i)),
	  decode( l_pricing_rec_tab.PRICING_ATTRIBUTE24(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.PRICING_ATTRIBUTE24(i)),
	  decode( l_pricing_rec_tab.PRICING_ATTRIBUTE25(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.PRICING_ATTRIBUTE25(i)),
	  decode( l_pricing_rec_tab.PRICING_ATTRIBUTE26(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.PRICING_ATTRIBUTE26(i)),
	  decode( l_pricing_rec_tab.PRICING_ATTRIBUTE27(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.PRICING_ATTRIBUTE27(i)),
	  decode( l_pricing_rec_tab.PRICING_ATTRIBUTE28(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.PRICING_ATTRIBUTE28(i)),
	  decode( l_pricing_rec_tab.PRICING_ATTRIBUTE29(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.PRICING_ATTRIBUTE29(i)),
	  decode( l_pricing_rec_tab.PRICING_ATTRIBUTE30(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.PRICING_ATTRIBUTE30(i)),
	  decode( l_pricing_rec_tab.PRICING_ATTRIBUTE31(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.PRICING_ATTRIBUTE31(i)),
	  decode( l_pricing_rec_tab.PRICING_ATTRIBUTE32(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.PRICING_ATTRIBUTE32(i)),
	  decode( l_pricing_rec_tab.PRICING_ATTRIBUTE33(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.PRICING_ATTRIBUTE33(i)),
	  decode( l_pricing_rec_tab.PRICING_ATTRIBUTE34(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.PRICING_ATTRIBUTE34(i)),
	  decode( l_pricing_rec_tab.PRICING_ATTRIBUTE35(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.PRICING_ATTRIBUTE35(i)),
	  decode( l_pricing_rec_tab.PRICING_ATTRIBUTE36(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.PRICING_ATTRIBUTE36(i)),
	  decode( l_pricing_rec_tab.PRICING_ATTRIBUTE37(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.PRICING_ATTRIBUTE37(i)),
	  decode( l_pricing_rec_tab.PRICING_ATTRIBUTE38(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.PRICING_ATTRIBUTE38(i)),
	  decode( l_pricing_rec_tab.PRICING_ATTRIBUTE39(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.PRICING_ATTRIBUTE39(i)),
	  decode( l_pricing_rec_tab.PRICING_ATTRIBUTE40(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.PRICING_ATTRIBUTE40(i)),
	  decode( l_pricing_rec_tab.PRICING_ATTRIBUTE41(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.PRICING_ATTRIBUTE41(i)),
	  decode( l_pricing_rec_tab.PRICING_ATTRIBUTE42(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.PRICING_ATTRIBUTE42(i)),
	  decode( l_pricing_rec_tab.PRICING_ATTRIBUTE43(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.PRICING_ATTRIBUTE43(i)),
	  decode( l_pricing_rec_tab.PRICING_ATTRIBUTE44(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.PRICING_ATTRIBUTE44(i)),
	  decode( l_pricing_rec_tab.PRICING_ATTRIBUTE45(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.PRICING_ATTRIBUTE45(i)),
	  decode( l_pricing_rec_tab.PRICING_ATTRIBUTE46(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.PRICING_ATTRIBUTE46(i)),
	  decode( l_pricing_rec_tab.PRICING_ATTRIBUTE47(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.PRICING_ATTRIBUTE47(i)),
	  decode( l_pricing_rec_tab.PRICING_ATTRIBUTE48(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.PRICING_ATTRIBUTE48(i)),
	  decode( l_pricing_rec_tab.PRICING_ATTRIBUTE49(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.PRICING_ATTRIBUTE49(i)),
	  decode( l_pricing_rec_tab.PRICING_ATTRIBUTE50(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.PRICING_ATTRIBUTE50(i)),
	  decode( l_pricing_rec_tab.PRICING_ATTRIBUTE51(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.PRICING_ATTRIBUTE51(i)),
	  decode( l_pricing_rec_tab.PRICING_ATTRIBUTE52(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.PRICING_ATTRIBUTE52(i)),
	  decode( l_pricing_rec_tab.PRICING_ATTRIBUTE53(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.PRICING_ATTRIBUTE53(i)),
	  decode( l_pricing_rec_tab.PRICING_ATTRIBUTE54(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.PRICING_ATTRIBUTE54(i)),
	  decode( l_pricing_rec_tab.PRICING_ATTRIBUTE55(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.PRICING_ATTRIBUTE55(i)),
	  decode( l_pricing_rec_tab.PRICING_ATTRIBUTE56(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.PRICING_ATTRIBUTE56(i)),
	  decode( l_pricing_rec_tab.PRICING_ATTRIBUTE57(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.PRICING_ATTRIBUTE57(i)),
	  decode( l_pricing_rec_tab.PRICING_ATTRIBUTE58(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.PRICING_ATTRIBUTE58(i)),
	  decode( l_pricing_rec_tab.PRICING_ATTRIBUTE59(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.PRICING_ATTRIBUTE59(i)),
	  decode( l_pricing_rec_tab.PRICING_ATTRIBUTE60(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.PRICING_ATTRIBUTE60(i)),
	  decode( l_pricing_rec_tab.PRICING_ATTRIBUTE61(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.PRICING_ATTRIBUTE61(i)),
	  decode( l_pricing_rec_tab.PRICING_ATTRIBUTE62(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.PRICING_ATTRIBUTE62(i)),
	  decode( l_pricing_rec_tab.PRICING_ATTRIBUTE63(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.PRICING_ATTRIBUTE63(i)),
	  decode( l_pricing_rec_tab.PRICING_ATTRIBUTE64(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.PRICING_ATTRIBUTE64(i)),
	  decode( l_pricing_rec_tab.PRICING_ATTRIBUTE65(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.PRICING_ATTRIBUTE65(i)),
	  decode( l_pricing_rec_tab.PRICING_ATTRIBUTE66(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.PRICING_ATTRIBUTE66(i)),
	  decode( l_pricing_rec_tab.PRICING_ATTRIBUTE67(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.PRICING_ATTRIBUTE67(i)),
	  decode( l_pricing_rec_tab.PRICING_ATTRIBUTE68(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.PRICING_ATTRIBUTE68(i)),
	  decode( l_pricing_rec_tab.PRICING_ATTRIBUTE69(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.PRICING_ATTRIBUTE69(i)),
	  decode( l_pricing_rec_tab.PRICING_ATTRIBUTE70(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.PRICING_ATTRIBUTE70(i)),
	  decode( l_pricing_rec_tab.PRICING_ATTRIBUTE71(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.PRICING_ATTRIBUTE71(i)),
	  decode( l_pricing_rec_tab.PRICING_ATTRIBUTE72(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.PRICING_ATTRIBUTE72(i)),
	  decode( l_pricing_rec_tab.PRICING_ATTRIBUTE73(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.PRICING_ATTRIBUTE73(i)),
	  decode( l_pricing_rec_tab.PRICING_ATTRIBUTE74(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.PRICING_ATTRIBUTE74(i)),
	  decode( l_pricing_rec_tab.PRICING_ATTRIBUTE75(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.PRICING_ATTRIBUTE75(i)),
	  decode( l_pricing_rec_tab.PRICING_ATTRIBUTE76(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.PRICING_ATTRIBUTE76(i)),
	  decode( l_pricing_rec_tab.PRICING_ATTRIBUTE77(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.PRICING_ATTRIBUTE77(i)),
	  decode( l_pricing_rec_tab.PRICING_ATTRIBUTE78(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.PRICING_ATTRIBUTE78(i)),
	  decode( l_pricing_rec_tab.PRICING_ATTRIBUTE79(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.PRICING_ATTRIBUTE79(i)),
	  decode( l_pricing_rec_tab.PRICING_ATTRIBUTE80(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.PRICING_ATTRIBUTE80(i)),
	  decode( l_pricing_rec_tab.PRICING_ATTRIBUTE81(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.PRICING_ATTRIBUTE81(i)),
	  decode( l_pricing_rec_tab.PRICING_ATTRIBUTE82(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.PRICING_ATTRIBUTE82(i)),
	  decode( l_pricing_rec_tab.PRICING_ATTRIBUTE83(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.PRICING_ATTRIBUTE83(i)),
	  decode( l_pricing_rec_tab.PRICING_ATTRIBUTE84(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.PRICING_ATTRIBUTE84(i)),
	  decode( l_pricing_rec_tab.PRICING_ATTRIBUTE85(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.PRICING_ATTRIBUTE85(i)),
	  decode( l_pricing_rec_tab.PRICING_ATTRIBUTE86(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.PRICING_ATTRIBUTE86(i)),
	  decode( l_pricing_rec_tab.PRICING_ATTRIBUTE87(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.PRICING_ATTRIBUTE87(i)),
	  decode( l_pricing_rec_tab.PRICING_ATTRIBUTE88(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.PRICING_ATTRIBUTE88(i)),
	  decode( l_pricing_rec_tab.PRICING_ATTRIBUTE89(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.PRICING_ATTRIBUTE89(i)),
	  decode( l_pricing_rec_tab.PRICING_ATTRIBUTE90(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.PRICING_ATTRIBUTE90(i)),
	  decode( l_pricing_rec_tab.PRICING_ATTRIBUTE91(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.PRICING_ATTRIBUTE91(i)),
	  decode( l_pricing_rec_tab.PRICING_ATTRIBUTE92(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.PRICING_ATTRIBUTE92(i)),
	  decode( l_pricing_rec_tab.PRICING_ATTRIBUTE93(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.PRICING_ATTRIBUTE93(i)),
	  decode( l_pricing_rec_tab.PRICING_ATTRIBUTE94(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.PRICING_ATTRIBUTE94(i)),
	  decode( l_pricing_rec_tab.PRICING_ATTRIBUTE95(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.PRICING_ATTRIBUTE95(i)),
	  decode( l_pricing_rec_tab.PRICING_ATTRIBUTE96(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.PRICING_ATTRIBUTE96(i)),
	  decode( l_pricing_rec_tab.PRICING_ATTRIBUTE97(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.PRICING_ATTRIBUTE97(i)),
	  decode( l_pricing_rec_tab.PRICING_ATTRIBUTE98(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.PRICING_ATTRIBUTE98(i)),
	  decode( l_pricing_rec_tab.PRICING_ATTRIBUTE99(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.PRICING_ATTRIBUTE99(i)),
	  decode( l_pricing_rec_tab.PRICING_ATTRIBUTE100(i), FND_API.G_MISS_CHAR, NULL, l_pricing_rec_tab.PRICING_ATTRIBUTE100(i))
	  );
   END IF;
   --
   IF p_pricing_hist_tbl.count > 0 THEN
         Build_pricing_Hist_Rec_Table
            (
              p_pricing_hist_tbl       => p_pricing_hist_tbl
             ,p_pricing_hist_rec_tab   => l_pricing_hist_rec_tab
            );
         --
         l_ctr := l_pricing_hist_rec_tab.price_attrib_history_id.count;
         --
	 FORALL i in 1 .. l_ctr
	  INSERT INTO CSI_I_PRICING_ATTRIBS_H(
	    PRICE_ATTRIB_HISTORY_ID,
	    PRICING_ATTRIBUTE_ID,
	    TRANSACTION_ID,
	    OLD_PRICING_CONTEXT,
	    NEW_PRICING_CONTEXT,
	    OLD_PRICING_ATTRIBUTE1,
	    NEW_PRICING_ATTRIBUTE1,
	    OLD_PRICING_ATTRIBUTE2,
	    NEW_PRICING_ATTRIBUTE2,
	    OLD_PRICING_ATTRIBUTE3,
	    NEW_PRICING_ATTRIBUTE3,
	    OLD_PRICING_ATTRIBUTE4,
	    NEW_PRICING_ATTRIBUTE4,
	    OLD_PRICING_ATTRIBUTE5,
	    NEW_PRICING_ATTRIBUTE5,
	    OLD_PRICING_ATTRIBUTE6,
	    NEW_PRICING_ATTRIBUTE6,
	    OLD_PRICING_ATTRIBUTE7,
	    NEW_PRICING_ATTRIBUTE7,
	    OLD_PRICING_ATTRIBUTE8,
	    NEW_PRICING_ATTRIBUTE8,
	    OLD_PRICING_ATTRIBUTE9,
	    NEW_PRICING_ATTRIBUTE9,
	    OLD_PRICING_ATTRIBUTE10,
	    NEW_PRICING_ATTRIBUTE10,
	    OLD_PRICING_ATTRIBUTE11,
	    NEW_PRICING_ATTRIBUTE11,
	    OLD_PRICING_ATTRIBUTE12,
	    NEW_PRICING_ATTRIBUTE12,
	    OLD_PRICING_ATTRIBUTE13,
	    NEW_PRICING_ATTRIBUTE13,
	    OLD_PRICING_ATTRIBUTE14,
	    NEW_PRICING_ATTRIBUTE14,
	    OLD_PRICING_ATTRIBUTE15,
	    NEW_PRICING_ATTRIBUTE15,
	    OLD_PRICING_ATTRIBUTE16,
	    NEW_PRICING_ATTRIBUTE16,
	    OLD_PRICING_ATTRIBUTE17,
	    NEW_PRICING_ATTRIBUTE17,
	    OLD_PRICING_ATTRIBUTE18,
	    NEW_PRICING_ATTRIBUTE18,
	    OLD_PRICING_ATTRIBUTE19,
	    NEW_PRICING_ATTRIBUTE19,
	    OLD_PRICING_ATTRIBUTE20,
	    NEW_PRICING_ATTRIBUTE20,
	    OLD_PRICING_ATTRIBUTE21,
	    NEW_PRICING_ATTRIBUTE21,
	    OLD_PRICING_ATTRIBUTE22,
	    NEW_PRICING_ATTRIBUTE22,
	    OLD_PRICING_ATTRIBUTE23,
	    NEW_PRICING_ATTRIBUTE23,
	    OLD_PRICING_ATTRIBUTE24,
	    NEW_PRICING_ATTRIBUTE24,
	    NEW_PRICING_ATTRIBUTE25,
	    OLD_PRICING_ATTRIBUTE25,
	    OLD_PRICING_ATTRIBUTE26,
	    NEW_PRICING_ATTRIBUTE26,
	    OLD_PRICING_ATTRIBUTE27,
	    NEW_PRICING_ATTRIBUTE27,
	    OLD_PRICING_ATTRIBUTE28,
	    NEW_PRICING_ATTRIBUTE28,
	    OLD_PRICING_ATTRIBUTE29,
	    NEW_PRICING_ATTRIBUTE29,
	    OLD_PRICING_ATTRIBUTE30,
	    NEW_PRICING_ATTRIBUTE30,
	    OLD_PRICING_ATTRIBUTE31,
	    NEW_PRICING_ATTRIBUTE31,
	    OLD_PRICING_ATTRIBUTE32,
	    NEW_PRICING_ATTRIBUTE32,
	    OLD_PRICING_ATTRIBUTE33,
	    NEW_PRICING_ATTRIBUTE33,
	    OLD_PRICING_ATTRIBUTE34,
	    NEW_PRICING_ATTRIBUTE34,
	    OLD_PRICING_ATTRIBUTE35,
	    NEW_PRICING_ATTRIBUTE35,
	    OLD_PRICING_ATTRIBUTE36,
	    NEW_PRICING_ATTRIBUTE36,
	    OLD_PRICING_ATTRIBUTE37,
	    NEW_PRICING_ATTRIBUTE37,
	    OLD_PRICING_ATTRIBUTE38,
	    NEW_PRICING_ATTRIBUTE38,
	    OLD_PRICING_ATTRIBUTE39,
	    NEW_PRICING_ATTRIBUTE39,
	    OLD_PRICING_ATTRIBUTE40,
	    NEW_PRICING_ATTRIBUTE40,
	    OLD_PRICING_ATTRIBUTE41,
	    NEW_PRICING_ATTRIBUTE41,
	    OLD_PRICING_ATTRIBUTE42,
	    NEW_PRICING_ATTRIBUTE42,
	    OLD_PRICING_ATTRIBUTE43,
	    NEW_PRICING_ATTRIBUTE43,
	    OLD_PRICING_ATTRIBUTE44,
	    NEW_PRICING_ATTRIBUTE44,
	    OLD_PRICING_ATTRIBUTE45,
	    NEW_PRICING_ATTRIBUTE45,
	    OLD_PRICING_ATTRIBUTE46,
	    NEW_PRICING_ATTRIBUTE46,
	    OLD_PRICING_ATTRIBUTE47,
	    NEW_PRICING_ATTRIBUTE47,
	    OLD_PRICING_ATTRIBUTE48,
	    NEW_PRICING_ATTRIBUTE48,
	    OLD_PRICING_ATTRIBUTE49,
	    NEW_PRICING_ATTRIBUTE49,
	    OLD_PRICING_ATTRIBUTE50,
	    NEW_PRICING_ATTRIBUTE50,
	    OLD_PRICING_ATTRIBUTE51,
	    NEW_PRICING_ATTRIBUTE51,
	    OLD_PRICING_ATTRIBUTE52,
	    NEW_PRICING_ATTRIBUTE52,
	    OLD_PRICING_ATTRIBUTE53,
	    NEW_PRICING_ATTRIBUTE53,
	    OLD_PRICING_ATTRIBUTE54,
	    NEW_PRICING_ATTRIBUTE54,
	    OLD_PRICING_ATTRIBUTE55,
	    NEW_PRICING_ATTRIBUTE55,
	    OLD_PRICING_ATTRIBUTE56,
	    NEW_PRICING_ATTRIBUTE56,
	    OLD_PRICING_ATTRIBUTE57,
	    NEW_PRICING_ATTRIBUTE57,
	    OLD_PRICING_ATTRIBUTE58,
	    NEW_PRICING_ATTRIBUTE58,
	    OLD_PRICING_ATTRIBUTE59,
	    NEW_PRICING_ATTRIBUTE59,
	    OLD_PRICING_ATTRIBUTE60,
	    NEW_PRICING_ATTRIBUTE60,
	    OLD_PRICING_ATTRIBUTE61,
	    NEW_PRICING_ATTRIBUTE61,
	    OLD_PRICING_ATTRIBUTE62,
	    NEW_PRICING_ATTRIBUTE62,
	    OLD_PRICING_ATTRIBUTE63,
	    NEW_PRICING_ATTRIBUTE63,
	    OLD_PRICING_ATTRIBUTE64,
	    NEW_PRICING_ATTRIBUTE64,
	    OLD_PRICING_ATTRIBUTE65,
	    NEW_PRICING_ATTRIBUTE65,
	    OLD_PRICING_ATTRIBUTE66,
	    NEW_PRICING_ATTRIBUTE66,
	    OLD_PRICING_ATTRIBUTE67,
	    NEW_PRICING_ATTRIBUTE67,
	    OLD_PRICING_ATTRIBUTE68,
	    NEW_PRICING_ATTRIBUTE68,
	    OLD_PRICING_ATTRIBUTE69,
	    NEW_PRICING_ATTRIBUTE69,
	    OLD_PRICING_ATTRIBUTE70,
	    NEW_PRICING_ATTRIBUTE70,
	    OLD_PRICING_ATTRIBUTE71,
	    NEW_PRICING_ATTRIBUTE71,
	    OLD_PRICING_ATTRIBUTE72,
	    NEW_PRICING_ATTRIBUTE72,
	    OLD_PRICING_ATTRIBUTE73,
	    NEW_PRICING_ATTRIBUTE73,
	    OLD_PRICING_ATTRIBUTE74,
	    NEW_PRICING_ATTRIBUTE74,
	    OLD_PRICING_ATTRIBUTE75,
	    NEW_PRICING_ATTRIBUTE75,
	    OLD_PRICING_ATTRIBUTE76,
	    NEW_PRICING_ATTRIBUTE76,
	    OLD_PRICING_ATTRIBUTE77,
	    NEW_PRICING_ATTRIBUTE77,
	    OLD_PRICING_ATTRIBUTE78,
	    NEW_PRICING_ATTRIBUTE78,
	    OLD_PRICING_ATTRIBUTE79,
	    NEW_PRICING_ATTRIBUTE79,
	    OLD_PRICING_ATTRIBUTE80,
	    NEW_PRICING_ATTRIBUTE80,
	    OLD_PRICING_ATTRIBUTE81,
	    NEW_PRICING_ATTRIBUTE81,
	    OLD_PRICING_ATTRIBUTE82,
	    NEW_PRICING_ATTRIBUTE82,
	    OLD_PRICING_ATTRIBUTE83,
	    NEW_PRICING_ATTRIBUTE83,
	    OLD_PRICING_ATTRIBUTE84,
	    NEW_PRICING_ATTRIBUTE84,
	    OLD_PRICING_ATTRIBUTE85,
	    NEW_PRICING_ATTRIBUTE85,
	    OLD_PRICING_ATTRIBUTE86,
	    NEW_PRICING_ATTRIBUTE86,
	    OLD_PRICING_ATTRIBUTE87,
	    NEW_PRICING_ATTRIBUTE87,
	    OLD_PRICING_ATTRIBUTE88,
	    NEW_PRICING_ATTRIBUTE88,
	    OLD_PRICING_ATTRIBUTE89,
	    NEW_PRICING_ATTRIBUTE89,
	    OLD_PRICING_ATTRIBUTE90,
	    NEW_PRICING_ATTRIBUTE90,
	    OLD_PRICING_ATTRIBUTE91,
	    NEW_PRICING_ATTRIBUTE91,
	    OLD_PRICING_ATTRIBUTE92,
	    NEW_PRICING_ATTRIBUTE92,
	    OLD_PRICING_ATTRIBUTE93,
	    NEW_PRICING_ATTRIBUTE93,
	    OLD_PRICING_ATTRIBUTE94,
	    NEW_PRICING_ATTRIBUTE94,
	    OLD_PRICING_ATTRIBUTE95,
	    NEW_PRICING_ATTRIBUTE95,
	    OLD_PRICING_ATTRIBUTE96,
	    NEW_PRICING_ATTRIBUTE96,
	    OLD_PRICING_ATTRIBUTE97,
	    NEW_PRICING_ATTRIBUTE97,
	    OLD_PRICING_ATTRIBUTE98,
	    NEW_PRICING_ATTRIBUTE98,
	    OLD_PRICING_ATTRIBUTE99,
	    NEW_PRICING_ATTRIBUTE99,
	    OLD_PRICING_ATTRIBUTE100,
	    NEW_PRICING_ATTRIBUTE100,
	    OLD_ACTIVE_START_DATE,
	    NEW_ACTIVE_START_DATE,
	    OLD_ACTIVE_END_DATE,
	    NEW_ACTIVE_END_DATE,
	    OLD_CONTEXT,
	    NEW_CONTEXT,
	    OLD_ATTRIBUTE1,
	    NEW_ATTRIBUTE1,
	    OLD_ATTRIBUTE2,
	    NEW_ATTRIBUTE2,
	    OLD_ATTRIBUTE3,
	    NEW_ATTRIBUTE3,
	    OLD_ATTRIBUTE4,
	    NEW_ATTRIBUTE4,
	    OLD_ATTRIBUTE5,
	    NEW_ATTRIBUTE5,
	    OLD_ATTRIBUTE6,
	    NEW_ATTRIBUTE6,
	    OLD_ATTRIBUTE7,
	    NEW_ATTRIBUTE7,
	    OLD_ATTRIBUTE8,
	    NEW_ATTRIBUTE8,
	    OLD_ATTRIBUTE9,
	    NEW_ATTRIBUTE9,
	    OLD_ATTRIBUTE10,
	    NEW_ATTRIBUTE10,
	    OLD_ATTRIBUTE11,
	    NEW_ATTRIBUTE11,
	    OLD_ATTRIBUTE12,
	    NEW_ATTRIBUTE12,
	    OLD_ATTRIBUTE13,
	    NEW_ATTRIBUTE13,
	    OLD_ATTRIBUTE14,
	    NEW_ATTRIBUTE14,
	    OLD_ATTRIBUTE15,
	    NEW_ATTRIBUTE15,
	    FULL_DUMP_FLAG,
	    CREATED_BY,
	    CREATION_DATE,
	    LAST_UPDATED_BY,
	    LAST_UPDATE_DATE,
	    LAST_UPDATE_LOGIN,
	    OBJECT_VERSION_NUMBER
	   ) VALUES (
	    l_pricing_hist_rec_tab.PRICE_ATTRIB_HISTORY_ID(i),
	    decode( l_pricing_hist_rec_tab.PRICING_ATTRIBUTE_ID(i), FND_API.G_MISS_NUM, NULL, l_pricing_hist_rec_tab.PRICING_ATTRIBUTE_ID(i)),
	    decode( l_pricing_hist_rec_tab.TRANSACTION_ID(i), FND_API.G_MISS_NUM, NULL, l_pricing_hist_rec_tab.TRANSACTION_ID(i)),
	    decode( l_pricing_hist_rec_tab.OLD_PRICING_CONTEXT(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_PRICING_CONTEXT(i)),
	    decode( l_pricing_hist_rec_tab.NEW_PRICING_CONTEXT(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_PRICING_CONTEXT(i)),
	    decode( l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE1(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE1(i)),
	    decode( l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE1(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE1(i)),
	    decode( l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE2(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE2(i)),
	    decode( l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE2(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE2(i)),
	    decode( l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE3(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE3(i)),
	    decode( l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE3(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE3(i)),
	    decode( l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE4(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE4(i)),
	    decode( l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE4(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE4(i)),
	    decode( l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE5(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE5(i)),
	    decode( l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE5(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE5(i)),
	    decode( l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE6(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE6(i)),
	    decode( l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE6(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE6(i)),
	    decode( l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE7(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE7(i)),
	    decode( l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE7(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE7(i)),
	    decode( l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE8(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE8(i)),
	    decode( l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE8(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE8(i)),
	    decode( l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE9(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE9(i)),
	    decode( l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE9(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE9(i)),
	    decode( l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE10(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE10(i)),
	    decode( l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE10(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE10(i)),
	    decode( l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE11(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE11(i)),
	    decode( l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE11(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE11(i)),
	    decode( l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE12(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE12(i)),
	    decode( l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE12(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE12(i)),
	    decode( l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE13(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE13(i)),
	    decode( l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE13(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE13(i)),
	    decode( l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE14(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE14(i)),
	    decode( l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE14(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE14(i)),
	    decode( l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE15(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE15(i)),
	    decode( l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE15(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE15(i)),
	    decode( l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE16(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE16(i)),
	    decode( l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE16(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE16(i)),
	    decode( l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE17(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE17(i)),
	    decode( l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE17(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE17(i)),
	    decode( l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE18(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE18(i)),
	    decode( l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE18(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE18(i)),
	    decode( l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE19(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE19(i)),
	    decode( l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE19(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE19(i)),
	    decode( l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE20(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE20(i)),
	    decode( l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE20(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE20(i)),
	    decode( l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE21(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE21(i)),
	    decode( l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE21(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE21(i)),
	    decode( l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE22(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE22(i)),
	    decode( l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE22(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE22(i)),
	    decode( l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE23(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE23(i)),
	    decode( l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE23(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE23(i)),
	    decode( l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE24(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE24(i)),
	    decode( l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE24(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE24(i)),
	    decode( l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE25(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE25(i)),
	    decode( l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE25(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE25(i)),
	    decode( l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE26(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE26(i)),
	    decode( l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE26(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE26(i)),
	    decode( l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE27(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE27(i)),
	    decode( l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE27(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE27(i)),
	    decode( l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE28(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE28(i)),
	    decode( l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE28(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE28(i)),
	    decode( l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE29(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE29(i)),
	    decode( l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE29(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE29(i)),
	    decode( l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE30(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE30(i)),
	    decode( l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE30(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE30(i)),
	    decode( l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE31(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE31(i)),
	    decode( l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE31(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE31(i)),
	    decode( l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE32(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE32(i)),
	    decode( l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE32(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE32(i)),
	    decode( l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE33(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE33(i)),
	    decode( l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE33(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE33(i)),
	    decode( l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE34(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE34(i)),
	    decode( l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE34(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE34(i)),
	    decode( l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE35(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE35(i)),
	    decode( l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE35(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE35(i)),
	    decode( l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE36(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE36(i)),
	    decode( l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE36(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE36(i)),
	    decode( l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE37(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE37(i)),
	    decode( l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE37(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE37(i)),
	    decode( l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE38(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE38(i)),
	    decode( l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE38(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE38(i)),
	    decode( l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE39(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE39(i)),
	    decode( l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE39(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE39(i)),
	    decode( l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE40(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE40(i)),
	    decode( l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE40(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE40(i)),
	    decode( l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE41(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE41(i)),
	    decode( l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE41(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE41(i)),
	    decode( l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE42(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE42(i)),
	    decode( l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE42(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE42(i)),
	    decode( l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE43(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE43(i)),
	    decode( l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE43(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE43(i)),
	    decode( l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE44(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE44(i)),
	    decode( l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE44(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE44(i)),
	    decode( l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE45(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE45(i)),
	    decode( l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE45(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE45(i)),
	    decode( l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE46(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE46(i)),
	    decode( l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE46(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE46(i)),
	    decode( l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE47(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE47(i)),
	    decode( l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE47(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE47(i)),
	    decode( l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE48(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE48(i)),
	    decode( l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE48(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE48(i)),
	    decode( l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE49(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE49(i)),
	    decode( l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE49(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE49(i)),
	    decode( l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE50(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE50(i)),
	    decode( l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE50(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE50(i)),
	    decode( l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE51(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE51(i)),
	    decode( l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE51(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE51(i)),
	    decode( l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE52(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE52(i)),
	    decode( l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE52(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE52(i)),
	    decode( l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE53(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE53(i)),
	    decode( l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE53(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE53(i)),
	    decode( l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE54(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE54(i)),
	    decode( l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE54(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE54(i)),
	    decode( l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE55(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE55(i)),
	    decode( l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE55(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE55(i)),
	    decode( l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE56(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE56(i)),
	    decode( l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE56(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE56(i)),
	    decode( l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE57(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE57(i)),
	    decode( l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE57(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE57(i)),
	    decode( l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE58(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE58(i)),
	    decode( l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE58(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE58(i)),
	    decode( l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE59(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE59(i)),
	    decode( l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE59(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE59(i)),
	    decode( l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE60(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE60(i)),
	    decode( l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE60(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE60(i)),
	    decode( l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE61(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE61(i)),
	    decode( l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE61(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE61(i)),
	    decode( l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE62(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE62(i)),
	    decode( l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE62(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE62(i)),
	    decode( l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE63(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE63(i)),
	    decode( l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE63(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE63(i)),
	    decode( l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE64(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE64(i)),
	    decode( l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE64(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE64(i)),
	    decode( l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE65(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE65(i)),
	    decode( l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE65(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE65(i)),
	    decode( l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE66(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE66(i)),
	    decode( l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE66(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE66(i)),
	    decode( l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE67(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE67(i)),
	    decode( l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE67(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE67(i)),
	    decode( l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE68(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE68(i)),
	    decode( l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE68(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE68(i)),
	    decode( l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE69(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE69(i)),
	    decode( l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE69(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE69(i)),
	    decode( l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE70(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE70(i)),
	    decode( l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE70(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE70(i)),
	    decode( l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE71(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE71(i)),
	    decode( l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE71(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE71(i)),
	    decode( l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE72(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE72(i)),
	    decode( l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE72(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE72(i)),
	    decode( l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE73(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE73(i)),
	    decode( l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE73(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE73(i)),
	    decode( l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE74(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE74(i)),
	    decode( l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE74(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE74(i)),
	    decode( l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE75(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE75(i)),
	    decode( l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE75(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE75(i)),
	    decode( l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE76(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE76(i)),
	    decode( l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE76(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE76(i)),
	    decode( l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE77(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE77(i)),
	    decode( l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE77(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE77(i)),
	    decode( l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE78(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE78(i)),
	    decode( l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE78(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE78(i)),
	    decode( l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE79(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE79(i)),
	    decode( l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE79(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE79(i)),
	    decode( l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE80(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE80(i)),
	    decode( l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE80(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE80(i)),
	    decode( l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE81(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE81(i)),
	    decode( l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE81(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE81(i)),
	    decode( l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE82(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE82(i)),
	    decode( l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE82(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE82(i)),
	    decode( l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE83(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE83(i)),
	    decode( l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE83(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE83(i)),
	    decode( l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE84(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE84(i)),
	    decode( l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE84(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE84(i)),
	    decode( l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE85(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE85(i)),
	    decode( l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE85(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE85(i)),
	    decode( l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE86(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE86(i)),
	    decode( l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE86(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE86(i)),
	    decode( l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE87(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE87(i)),
	    decode( l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE87(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE87(i)),
	    decode( l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE88(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE88(i)),
	    decode( l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE88(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE88(i)),
	    decode( l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE89(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE89(i)),
	    decode( l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE89(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE89(i)),
	    decode( l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE90(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE90(i)),
	    decode( l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE90(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE90(i)),
	    decode( l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE91(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE91(i)),
	    decode( l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE91(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE91(i)),
	    decode( l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE92(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE92(i)),
	    decode( l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE92(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE92(i)),
	    decode( l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE93(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE93(i)),
	    decode( l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE93(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE93(i)),
	    decode( l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE94(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE94(i)),
	    decode( l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE94(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE94(i)),
	    decode( l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE95(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE95(i)),
	    decode( l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE95(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE95(i)),
	    decode( l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE96(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE96(i)),
	    decode( l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE96(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE96(i)),
	    decode( l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE97(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE97(i)),
	    decode( l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE97(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE97(i)),
	    decode( l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE98(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE98(i)),
	    decode( l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE98(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE98(i)),
	    decode( l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE99(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE99(i)),
	    decode( l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE99(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE99(i)),
	    decode( l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE100(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_PRICING_ATTRIBUTE100(i)),
	    decode( l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE100(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_PRICING_ATTRIBUTE100(i)),
	    decode( l_pricing_hist_rec_tab.OLD_ACTIVE_START_DATE(i), FND_API.G_MISS_DATE, TO_DATE(NULL), l_pricing_hist_rec_tab.OLD_ACTIVE_START_DATE(i)),
	    decode( l_pricing_hist_rec_tab.NEW_ACTIVE_START_DATE(i), FND_API.G_MISS_DATE, TO_DATE(NULL), l_pricing_hist_rec_tab.NEW_ACTIVE_START_DATE(i)),
	    decode( l_pricing_hist_rec_tab.OLD_ACTIVE_END_DATE(i), FND_API.G_MISS_DATE, TO_DATE(NULL), l_pricing_hist_rec_tab.OLD_ACTIVE_END_DATE(i)),
	    decode( l_pricing_hist_rec_tab.NEW_ACTIVE_END_DATE(i), FND_API.G_MISS_DATE, TO_DATE(NULL), l_pricing_hist_rec_tab.NEW_ACTIVE_END_DATE(i)),
	    decode( l_pricing_hist_rec_tab.OLD_CONTEXT(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_CONTEXT(i)),
	    decode( l_pricing_hist_rec_tab.NEW_CONTEXT(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_CONTEXT(i)),
	    decode( l_pricing_hist_rec_tab.OLD_ATTRIBUTE1(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_ATTRIBUTE1(i)),
	    decode( l_pricing_hist_rec_tab.NEW_ATTRIBUTE1(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_ATTRIBUTE1(i)),
	    decode( l_pricing_hist_rec_tab.OLD_ATTRIBUTE2(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_ATTRIBUTE2(i)),
	    decode( l_pricing_hist_rec_tab.NEW_ATTRIBUTE2(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_ATTRIBUTE2(i)),
	    decode( l_pricing_hist_rec_tab.OLD_ATTRIBUTE3(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_ATTRIBUTE3(i)),
	    decode( l_pricing_hist_rec_tab.NEW_ATTRIBUTE3(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_ATTRIBUTE3(i)),
	    decode( l_pricing_hist_rec_tab.OLD_ATTRIBUTE4(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_ATTRIBUTE4(i)),
	    decode( l_pricing_hist_rec_tab.NEW_ATTRIBUTE4(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_ATTRIBUTE4(i)),
	    decode( l_pricing_hist_rec_tab.OLD_ATTRIBUTE5(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_ATTRIBUTE5(i)),
	    decode( l_pricing_hist_rec_tab.NEW_ATTRIBUTE5(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_ATTRIBUTE5(i)),
	    decode( l_pricing_hist_rec_tab.OLD_ATTRIBUTE6(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_ATTRIBUTE6(i)),
	    decode( l_pricing_hist_rec_tab.NEW_ATTRIBUTE6(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_ATTRIBUTE6(i)),
	    decode( l_pricing_hist_rec_tab.OLD_ATTRIBUTE7(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_ATTRIBUTE7(i)),
	    decode( l_pricing_hist_rec_tab.NEW_ATTRIBUTE7(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_ATTRIBUTE7(i)),
	    decode( l_pricing_hist_rec_tab.OLD_ATTRIBUTE8(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_ATTRIBUTE8(i)),
	    decode( l_pricing_hist_rec_tab.NEW_ATTRIBUTE8(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_ATTRIBUTE8(i)),
	    decode( l_pricing_hist_rec_tab.OLD_ATTRIBUTE9(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_ATTRIBUTE9(i)),
	    decode( l_pricing_hist_rec_tab.NEW_ATTRIBUTE9(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_ATTRIBUTE9(i)),
	    decode( l_pricing_hist_rec_tab.OLD_ATTRIBUTE10(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_ATTRIBUTE10(i)),
	    decode( l_pricing_hist_rec_tab.NEW_ATTRIBUTE10(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_ATTRIBUTE10(i)),
	    decode( l_pricing_hist_rec_tab.OLD_ATTRIBUTE11(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_ATTRIBUTE11(i)),
	    decode( l_pricing_hist_rec_tab.NEW_ATTRIBUTE11(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_ATTRIBUTE11(i)),
	    decode( l_pricing_hist_rec_tab.OLD_ATTRIBUTE12(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_ATTRIBUTE12(i)),
	    decode( l_pricing_hist_rec_tab.NEW_ATTRIBUTE12(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_ATTRIBUTE12(i)),
	    decode( l_pricing_hist_rec_tab.OLD_ATTRIBUTE13(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_ATTRIBUTE13(i)),
	    decode( l_pricing_hist_rec_tab.NEW_ATTRIBUTE13(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_ATTRIBUTE13(i)),
	    decode( l_pricing_hist_rec_tab.OLD_ATTRIBUTE14(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_ATTRIBUTE14(i)),
	    decode( l_pricing_hist_rec_tab.NEW_ATTRIBUTE14(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_ATTRIBUTE14(i)),
	    decode( l_pricing_hist_rec_tab.OLD_ATTRIBUTE15(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.OLD_ATTRIBUTE15(i)),
	    decode( l_pricing_hist_rec_tab.NEW_ATTRIBUTE15(i), FND_API.G_MISS_CHAR, NULL, l_pricing_hist_rec_tab.NEW_ATTRIBUTE15(i)),
	    'N',
	    l_user_id,
	    SYSDATE,
	    l_user_id,
	    SYSDATE,
	    l_login_id,
	    1
	   );
   END IF;
   IF p_ext_attr_values_tbl.count > 0 THEN
         Build_Ext_Attr_Rec_Table
            (
              p_ext_attr_tbl     => p_ext_attr_values_tbl
             ,p_ext_attr_rec_tab => l_ext_attr_rec_tab
            );
         --
         l_ctr := l_ext_attr_rec_tab.attribute_value_id.count;
         --
         FORALL i in 1 .. l_ctr
            INSERT INTO CSI_IEA_VALUES(
              ATTRIBUTE_VALUE_ID,
              ATTRIBUTE_ID,
              INSTANCE_ID,
              ATTRIBUTE_VALUE,
              ACTIVE_START_DATE,
              ACTIVE_END_DATE,
              CONTEXT,
              ATTRIBUTE1,
              ATTRIBUTE2,
              ATTRIBUTE3,
              ATTRIBUTE4,
              ATTRIBUTE5,
              ATTRIBUTE6,
              ATTRIBUTE7,
              ATTRIBUTE8,
              ATTRIBUTE9,
              ATTRIBUTE10,
              ATTRIBUTE11,
              ATTRIBUTE12,
              ATTRIBUTE13,
              ATTRIBUTE14,
              ATTRIBUTE15,
              CREATED_BY,
              CREATION_DATE,
              LAST_UPDATED_BY,
              LAST_UPDATE_DATE,
              LAST_UPDATE_LOGIN,
              OBJECT_VERSION_NUMBER
              ) VALUES (
              l_ext_attr_rec_tab.ATTRIBUTE_VALUE_ID(i),
              decode( l_ext_attr_rec_tab.ATTRIBUTE_ID(i), FND_API.G_MISS_NUM, NULL, l_ext_attr_rec_tab.ATTRIBUTE_ID(i)),
              decode( l_ext_attr_rec_tab.INSTANCE_ID(i), FND_API.G_MISS_NUM, NULL, l_ext_attr_rec_tab.INSTANCE_ID(i)),
              decode( l_ext_attr_rec_tab.ATTRIBUTE_VALUE(i), FND_API.G_MISS_CHAR, NULL, l_ext_attr_rec_tab.ATTRIBUTE_VALUE(i)),
              decode( l_ext_attr_rec_tab.ACTIVE_START_DATE(i), FND_API.G_MISS_DATE, NULL, l_ext_attr_rec_tab.ACTIVE_START_DATE(i)),
              decode( l_ext_attr_rec_tab.ACTIVE_END_DATE(i), FND_API.G_MISS_DATE, NULL, l_ext_attr_rec_tab.ACTIVE_END_DATE(i)),
              decode( l_ext_attr_rec_tab.CONTEXT(i), FND_API.G_MISS_CHAR, NULL, l_ext_attr_rec_tab.CONTEXT(i)),
              decode( l_ext_attr_rec_tab.ATTRIBUTE1(i), FND_API.G_MISS_CHAR, NULL, l_ext_attr_rec_tab.ATTRIBUTE1(i)),
              decode( l_ext_attr_rec_tab.ATTRIBUTE2(i), FND_API.G_MISS_CHAR, NULL, l_ext_attr_rec_tab.ATTRIBUTE2(i)),
              decode( l_ext_attr_rec_tab.ATTRIBUTE3(i), FND_API.G_MISS_CHAR, NULL, l_ext_attr_rec_tab.ATTRIBUTE3(i)),
              decode( l_ext_attr_rec_tab.ATTRIBUTE4(i), FND_API.G_MISS_CHAR, NULL, l_ext_attr_rec_tab.ATTRIBUTE4(i)),
              decode( l_ext_attr_rec_tab.ATTRIBUTE5(i), FND_API.G_MISS_CHAR, NULL, l_ext_attr_rec_tab.ATTRIBUTE5(i)),
              decode( l_ext_attr_rec_tab.ATTRIBUTE6(i), FND_API.G_MISS_CHAR, NULL, l_ext_attr_rec_tab.ATTRIBUTE6(i)),
              decode( l_ext_attr_rec_tab.ATTRIBUTE7(i), FND_API.G_MISS_CHAR, NULL, l_ext_attr_rec_tab.ATTRIBUTE7(i)),
              decode( l_ext_attr_rec_tab.ATTRIBUTE8(i), FND_API.G_MISS_CHAR, NULL, l_ext_attr_rec_tab.ATTRIBUTE8(i)),
              decode( l_ext_attr_rec_tab.ATTRIBUTE9(i), FND_API.G_MISS_CHAR, NULL, l_ext_attr_rec_tab.ATTRIBUTE9(i)),
              decode( l_ext_attr_rec_tab.ATTRIBUTE10(i), FND_API.G_MISS_CHAR, NULL, l_ext_attr_rec_tab.ATTRIBUTE10(i)),
              decode( l_ext_attr_rec_tab.ATTRIBUTE11(i), FND_API.G_MISS_CHAR, NULL, l_ext_attr_rec_tab.ATTRIBUTE11(i)),
              decode( l_ext_attr_rec_tab.ATTRIBUTE12(i), FND_API.G_MISS_CHAR, NULL, l_ext_attr_rec_tab.ATTRIBUTE12(i)),
              decode( l_ext_attr_rec_tab.ATTRIBUTE13(i), FND_API.G_MISS_CHAR, NULL, l_ext_attr_rec_tab.ATTRIBUTE13(i)),
              decode( l_ext_attr_rec_tab.ATTRIBUTE14(i), FND_API.G_MISS_CHAR, NULL, l_ext_attr_rec_tab.ATTRIBUTE14(i)),
              decode( l_ext_attr_rec_tab.ATTRIBUTE15(i), FND_API.G_MISS_CHAR, NULL, l_ext_attr_rec_tab.ATTRIBUTE15(i)),
              l_user_id,
              SYSDATE,
              l_user_id,
              SYSDATE,
              l_login_id,
              1
              );
   END IF;
   --
   IF p_ext_attr_val_hist_tbl.count > 0 THEN
         Build_Ext_Attr_Hist_Rec_Table
            (
              p_ext_attr_hist_tbl      =>  p_ext_attr_val_hist_tbl
             ,p_ext_attr_hist_rec_tab  =>  l_ext_attr_hist_rec_tab
            );
         --
         l_ctr := l_ext_attr_hist_rec_tab.attribute_value_history_id.count;
         --
         FORALL i in 1 .. l_ctr
            INSERT INTO CSI_IEA_VALUES_H(
              ATTRIBUTE_VALUE_HISTORY_ID,
              ATTRIBUTE_VALUE_ID,
              TRANSACTION_ID,
              OLD_ATTRIBUTE_VALUE,
              NEW_ATTRIBUTE_VALUE,
              OLD_ACTIVE_START_DATE,
              NEW_ACTIVE_START_DATE,
              OLD_ACTIVE_END_DATE,
              NEW_ACTIVE_END_DATE,
              OLD_CONTEXT,
              NEW_CONTEXT,
              OLD_ATTRIBUTE1,
              NEW_ATTRIBUTE1,
              OLD_ATTRIBUTE2,
              NEW_ATTRIBUTE2,
              OLD_ATTRIBUTE3,
              NEW_ATTRIBUTE3,
              OLD_ATTRIBUTE4,
              NEW_ATTRIBUTE4,
              OLD_ATTRIBUTE5,
              NEW_ATTRIBUTE5,
              OLD_ATTRIBUTE6,
              NEW_ATTRIBUTE6,
              OLD_ATTRIBUTE7,
              NEW_ATTRIBUTE7,
              OLD_ATTRIBUTE8,
              NEW_ATTRIBUTE8,
              OLD_ATTRIBUTE9,
              NEW_ATTRIBUTE9,
              OLD_ATTRIBUTE10,
              NEW_ATTRIBUTE10,
              OLD_ATTRIBUTE11,
              NEW_ATTRIBUTE11,
              OLD_ATTRIBUTE12,
              NEW_ATTRIBUTE12,
              OLD_ATTRIBUTE13,
              NEW_ATTRIBUTE13,
              OLD_ATTRIBUTE14,
              NEW_ATTRIBUTE14,
              OLD_ATTRIBUTE15,
              NEW_ATTRIBUTE15,
              FULL_DUMP_FLAG,
              CREATED_BY,
              CREATION_DATE,
              LAST_UPDATED_BY,
              LAST_UPDATE_DATE,
              LAST_UPDATE_LOGIN,
              OBJECT_VERSION_NUMBER
              ) VALUES (
              l_ext_attr_hist_rec_tab.ATTRIBUTE_VALUE_HISTORY_ID(i),
              decode( l_ext_attr_hist_rec_tab.ATTRIBUTE_VALUE_ID(i), FND_API.G_MISS_NUM, NULL, l_ext_attr_hist_rec_tab.ATTRIBUTE_VALUE_ID(i)),
              decode( l_ext_attr_hist_rec_tab.TRANSACTION_ID(i), FND_API.G_MISS_NUM, NULL, l_ext_attr_hist_rec_tab.TRANSACTION_ID(i)),
              decode( l_ext_attr_hist_rec_tab.OLD_ATTRIBUTE_VALUE(i), FND_API.G_MISS_CHAR, NULL, l_ext_attr_hist_rec_tab.OLD_ATTRIBUTE_VALUE(i)),
              decode( l_ext_attr_hist_rec_tab.NEW_ATTRIBUTE_VALUE(i), FND_API.G_MISS_CHAR, NULL, l_ext_attr_hist_rec_tab.NEW_ATTRIBUTE_VALUE(i)),
              decode( l_ext_attr_hist_rec_tab.OLD_ACTIVE_START_DATE(i), FND_API.G_MISS_CHAR, NULL, l_ext_attr_hist_rec_tab.OLD_ACTIVE_START_DATE(i)),
              decode( l_ext_attr_hist_rec_tab.NEW_ACTIVE_START_DATE(i), FND_API.G_MISS_CHAR, NULL, l_ext_attr_hist_rec_tab.NEW_ACTIVE_START_DATE(i)),
              decode( l_ext_attr_hist_rec_tab.OLD_ACTIVE_END_DATE(i), FND_API.G_MISS_CHAR, NULL, l_ext_attr_hist_rec_tab.OLD_ACTIVE_END_DATE(i)),
              decode( l_ext_attr_hist_rec_tab.NEW_ACTIVE_END_DATE(i), FND_API.G_MISS_CHAR, NULL, l_ext_attr_hist_rec_tab.NEW_ACTIVE_END_DATE(i)),
              decode( l_ext_attr_hist_rec_tab.OLD_CONTEXT(i), FND_API.G_MISS_CHAR, NULL, l_ext_attr_hist_rec_tab.OLD_CONTEXT(i)),
              decode( l_ext_attr_hist_rec_tab.NEW_CONTEXT(i), FND_API.G_MISS_CHAR, NULL, l_ext_attr_hist_rec_tab.NEW_CONTEXT(i)),
              decode( l_ext_attr_hist_rec_tab.OLD_ATTRIBUTE1(i), FND_API.G_MISS_CHAR, NULL, l_ext_attr_hist_rec_tab.OLD_ATTRIBUTE1(i)),
              decode( l_ext_attr_hist_rec_tab.NEW_ATTRIBUTE1(i), FND_API.G_MISS_CHAR, NULL, l_ext_attr_hist_rec_tab.NEW_ATTRIBUTE1(i)),
              decode( l_ext_attr_hist_rec_tab.OLD_ATTRIBUTE2(i), FND_API.G_MISS_CHAR, NULL, l_ext_attr_hist_rec_tab.OLD_ATTRIBUTE2(i)),
              decode( l_ext_attr_hist_rec_tab.NEW_ATTRIBUTE2(i), FND_API.G_MISS_CHAR, NULL, l_ext_attr_hist_rec_tab.NEW_ATTRIBUTE2(i)),
              decode( l_ext_attr_hist_rec_tab.OLD_ATTRIBUTE3(i), FND_API.G_MISS_CHAR, NULL, l_ext_attr_hist_rec_tab.OLD_ATTRIBUTE3(i)),
              decode( l_ext_attr_hist_rec_tab.NEW_ATTRIBUTE3(i), FND_API.G_MISS_CHAR, NULL, l_ext_attr_hist_rec_tab.NEW_ATTRIBUTE3(i)),
              decode( l_ext_attr_hist_rec_tab.OLD_ATTRIBUTE4(i), FND_API.G_MISS_CHAR, NULL, l_ext_attr_hist_rec_tab.OLD_ATTRIBUTE4(i)),
              decode( l_ext_attr_hist_rec_tab.NEW_ATTRIBUTE4(i), FND_API.G_MISS_CHAR, NULL, l_ext_attr_hist_rec_tab.NEW_ATTRIBUTE4(i)),
              decode( l_ext_attr_hist_rec_tab.OLD_ATTRIBUTE5(i), FND_API.G_MISS_CHAR, NULL, l_ext_attr_hist_rec_tab.OLD_ATTRIBUTE5(i)),
              decode( l_ext_attr_hist_rec_tab.NEW_ATTRIBUTE5(i), FND_API.G_MISS_CHAR, NULL, l_ext_attr_hist_rec_tab.NEW_ATTRIBUTE5(i)),
              decode( l_ext_attr_hist_rec_tab.OLD_ATTRIBUTE6(i), FND_API.G_MISS_CHAR, NULL, l_ext_attr_hist_rec_tab.OLD_ATTRIBUTE6(i)),
              decode( l_ext_attr_hist_rec_tab.NEW_ATTRIBUTE6(i), FND_API.G_MISS_CHAR, NULL, l_ext_attr_hist_rec_tab.NEW_ATTRIBUTE6(i)),
              decode( l_ext_attr_hist_rec_tab.OLD_ATTRIBUTE7(i), FND_API.G_MISS_CHAR, NULL, l_ext_attr_hist_rec_tab.OLD_ATTRIBUTE7(i)),
              decode( l_ext_attr_hist_rec_tab.NEW_ATTRIBUTE7(i), FND_API.G_MISS_CHAR, NULL, l_ext_attr_hist_rec_tab.NEW_ATTRIBUTE7(i)),
              decode( l_ext_attr_hist_rec_tab.OLD_ATTRIBUTE8(i), FND_API.G_MISS_CHAR, NULL, l_ext_attr_hist_rec_tab.OLD_ATTRIBUTE8(i)),
              decode( l_ext_attr_hist_rec_tab.NEW_ATTRIBUTE8(i), FND_API.G_MISS_CHAR, NULL, l_ext_attr_hist_rec_tab.NEW_ATTRIBUTE8(i)),
              decode( l_ext_attr_hist_rec_tab.OLD_ATTRIBUTE9(i), FND_API.G_MISS_CHAR, NULL, l_ext_attr_hist_rec_tab.OLD_ATTRIBUTE9(i)),
              decode( l_ext_attr_hist_rec_tab.NEW_ATTRIBUTE9(i), FND_API.G_MISS_CHAR, NULL, l_ext_attr_hist_rec_tab.NEW_ATTRIBUTE9(i)),
              decode( l_ext_attr_hist_rec_tab.OLD_ATTRIBUTE10(i), FND_API.G_MISS_CHAR, NULL, l_ext_attr_hist_rec_tab.OLD_ATTRIBUTE10(i)),
              decode( l_ext_attr_hist_rec_tab.NEW_ATTRIBUTE10(i), FND_API.G_MISS_CHAR, NULL, l_ext_attr_hist_rec_tab.NEW_ATTRIBUTE10(i)),
              decode( l_ext_attr_hist_rec_tab.OLD_ATTRIBUTE11(i), FND_API.G_MISS_CHAR, NULL, l_ext_attr_hist_rec_tab.OLD_ATTRIBUTE11(i)),
              decode( l_ext_attr_hist_rec_tab.NEW_ATTRIBUTE11(i), FND_API.G_MISS_CHAR, NULL, l_ext_attr_hist_rec_tab.NEW_ATTRIBUTE11(i)),
              decode( l_ext_attr_hist_rec_tab.OLD_ATTRIBUTE12(i), FND_API.G_MISS_CHAR, NULL, l_ext_attr_hist_rec_tab.OLD_ATTRIBUTE12(i)),
              decode( l_ext_attr_hist_rec_tab.NEW_ATTRIBUTE12(i), FND_API.G_MISS_CHAR, NULL, l_ext_attr_hist_rec_tab.NEW_ATTRIBUTE12(i)),
              decode( l_ext_attr_hist_rec_tab.OLD_ATTRIBUTE13(i), FND_API.G_MISS_CHAR, NULL, l_ext_attr_hist_rec_tab.OLD_ATTRIBUTE13(i)),
              decode( l_ext_attr_hist_rec_tab.NEW_ATTRIBUTE13(i), FND_API.G_MISS_CHAR, NULL, l_ext_attr_hist_rec_tab.NEW_ATTRIBUTE13(i)),
              decode( l_ext_attr_hist_rec_tab.OLD_ATTRIBUTE14(i), FND_API.G_MISS_CHAR, NULL, l_ext_attr_hist_rec_tab.OLD_ATTRIBUTE14(i)),
              decode( l_ext_attr_hist_rec_tab.NEW_ATTRIBUTE14(i), FND_API.G_MISS_CHAR, NULL, l_ext_attr_hist_rec_tab.NEW_ATTRIBUTE14(i)),
              decode( l_ext_attr_hist_rec_tab.OLD_ATTRIBUTE15(i), FND_API.G_MISS_CHAR, NULL, l_ext_attr_hist_rec_tab.OLD_ATTRIBUTE15(i)),
              decode( l_ext_attr_hist_rec_tab.NEW_ATTRIBUTE15(i), FND_API.G_MISS_CHAR, NULL, l_ext_attr_hist_rec_tab.NEW_ATTRIBUTE15(i)),
              'N',
              l_user_id,
              SYSDATE,
              l_user_id,
              SYSDATE,
              l_login_id,
              1
              );
   END IF;
   --
   IF p_asset_tbl.count > 0 THEN
         Build_Asset_Rec_Table
            (
              p_asset_tbl     => p_asset_tbl
             ,p_asset_rec_tab => l_asset_rec_tab
            );
         --
         l_ctr := l_asset_rec_tab.instance_asset_id.count;
         --
         FORALL i in 1 .. l_ctr
          INSERT INTO CSI_I_ASSETS(
           INSTANCE_ASSET_ID,
           INSTANCE_ID,
           FA_ASSET_ID,
           FA_BOOK_TYPE_CODE,
           FA_LOCATION_ID,
           ASSET_QUANTITY,
           UPDATE_STATUS,
           ACTIVE_START_DATE,
           ACTIVE_END_DATE,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN,
           OBJECT_VERSION_NUMBER,
           FA_SYNC_FLAG
           ) VALUES (
           l_asset_rec_tab.INSTANCE_ASSET_ID(i),
           decode( l_asset_rec_tab.INSTANCE_ID(i), FND_API.G_MISS_NUM, NULL, l_asset_rec_tab.INSTANCE_ID(i)),
           decode( l_asset_rec_tab.FA_ASSET_ID(i), FND_API.G_MISS_NUM, NULL, l_asset_rec_tab.FA_ASSET_ID(i)),
           decode( l_asset_rec_tab.FA_BOOK_TYPE_CODE(i), FND_API.G_MISS_CHAR, NULL, l_asset_rec_tab.FA_BOOK_TYPE_CODE(i)),
           decode( l_asset_rec_tab.FA_LOCATION_ID(i), FND_API.G_MISS_NUM, NULL, l_asset_rec_tab.FA_LOCATION_ID(i)),
           decode( l_asset_rec_tab.ASSET_QUANTITY(i), FND_API.G_MISS_NUM, NULL, l_asset_rec_tab.ASSET_QUANTITY(i)),
           decode( l_asset_rec_tab.UPDATE_STATUS(i), FND_API.G_MISS_CHAR, NULL, l_asset_rec_tab.UPDATE_STATUS(i)),
           decode( l_asset_rec_tab.ACTIVE_START_DATE(i), FND_API.G_MISS_DATE, NULL, l_asset_rec_tab.ACTIVE_START_DATE(i)),
           decode( l_asset_rec_tab.ACTIVE_END_DATE(i), FND_API.G_MISS_DATE, NULL, l_asset_rec_tab.ACTIVE_END_DATE(i)),
           l_user_id,
           SYSDATE,
           l_user_id,
           SYSDATE,
           l_login_id,
           1,
           decode( l_asset_rec_tab.FA_SYNC_FLAG(i), FND_API.G_MISS_CHAR, NULL, l_asset_rec_tab.FA_SYNC_FLAG(i))
           );
   END IF;
   --
   IF p_asset_hist_tbl.count > 0 THEN
         Build_Asset_Hist_Rec_Table
            (
              p_asset_hist_tbl      => p_asset_hist_tbl
             ,p_asset_hist_rec_tab  => l_asset_hist_rec_tab
            );
         --
         l_ctr := l_asset_hist_rec_tab.instance_asset_history_id.count;
         --
         FORALL i in 1 .. l_ctr
          INSERT INTO CSI_I_ASSETS_H(
           INSTANCE_ASSET_HISTORY_ID,
           INSTANCE_ASSET_ID,
           TRANSACTION_ID,
           OLD_INSTANCE_ID,
           NEW_INSTANCE_ID,
           OLD_FA_ASSET_ID,
           NEW_FA_ASSET_ID,
           OLD_ASSET_QUANTITY,
           NEW_ASSET_QUANTITY,
           OLD_FA_BOOK_TYPE_CODE,
           NEW_FA_BOOK_TYPE_CODE,
           OLD_FA_LOCATION_ID,
           NEW_FA_LOCATION_ID,
           OLD_UPDATE_STATUS,
           NEW_UPDATE_STATUS,
           OLD_ACTIVE_START_DATE,
           NEW_ACTIVE_START_DATE,
           OLD_ACTIVE_END_DATE,
           NEW_ACTIVE_END_DATE,
           FULL_DUMP_FLAG,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN,
           OBJECT_VERSION_NUMBER,
           OLD_FA_SYNC_FLAG,
           NEW_FA_SYNC_FLAG
           ) VALUES (
           l_asset_hist_rec_tab.INSTANCE_ASSET_HISTORY_ID(i),
           decode( l_asset_hist_rec_tab.INSTANCE_ASSET_ID(i), FND_API.G_MISS_NUM, NULL, l_asset_hist_rec_tab.INSTANCE_ASSET_ID(i)),
           decode( l_asset_hist_rec_tab.TRANSACTION_ID(i), FND_API.G_MISS_NUM, NULL, l_asset_hist_rec_tab.TRANSACTION_ID(i)),
           decode( l_asset_hist_rec_tab.OLD_INSTANCE_ID(i), FND_API.G_MISS_NUM, NULL, l_asset_hist_rec_tab.OLD_INSTANCE_ID(i)),
           decode( l_asset_hist_rec_tab.NEW_INSTANCE_ID(i), FND_API.G_MISS_NUM, NULL, l_asset_hist_rec_tab.NEW_INSTANCE_ID(i)),
           decode( l_asset_hist_rec_tab.OLD_FA_ASSET_ID(i), FND_API.G_MISS_NUM, NULL, l_asset_hist_rec_tab.OLD_FA_ASSET_ID(i)),
           decode( l_asset_hist_rec_tab.NEW_FA_ASSET_ID(i), FND_API.G_MISS_NUM, NULL, l_asset_hist_rec_tab.NEW_FA_ASSET_ID(i)),
           decode( l_asset_hist_rec_tab.OLD_ASSET_QUANTITY(i), FND_API.G_MISS_NUM, NULL, l_asset_hist_rec_tab.OLD_ASSET_QUANTITY(i)),
           decode( l_asset_hist_rec_tab.NEW_ASSET_QUANTITY(i), FND_API.G_MISS_NUM, NULL, l_asset_hist_rec_tab.NEW_ASSET_QUANTITY(i)),
           decode( l_asset_hist_rec_tab.OLD_FA_BOOK_TYPE_CODE(i), FND_API.G_MISS_CHAR, NULL, l_asset_hist_rec_tab.OLD_FA_BOOK_TYPE_CODE(i)),
           decode( l_asset_hist_rec_tab.NEW_FA_BOOK_TYPE_CODE(i), FND_API.G_MISS_CHAR, NULL, l_asset_hist_rec_tab.NEW_FA_BOOK_TYPE_CODE(i)),
           decode( l_asset_hist_rec_tab.OLD_FA_LOCATION_ID(i), FND_API.G_MISS_NUM, NULL, l_asset_hist_rec_tab.OLD_FA_LOCATION_ID(i)),
           decode( l_asset_hist_rec_tab.NEW_FA_LOCATION_ID(i), FND_API.G_MISS_NUM, NULL, l_asset_hist_rec_tab.NEW_FA_LOCATION_ID(i)),
           decode( l_asset_hist_rec_tab.OLD_UPDATE_STATUS(i), FND_API.G_MISS_CHAR, NULL, l_asset_hist_rec_tab.OLD_UPDATE_STATUS(i)),
           decode( l_asset_hist_rec_tab.NEW_UPDATE_STATUS(i), FND_API.G_MISS_CHAR, NULL, l_asset_hist_rec_tab.NEW_UPDATE_STATUS(i)),
           decode( l_asset_hist_rec_tab.OLD_ACTIVE_START_DATE(i), FND_API.G_MISS_DATE, NULL, l_asset_hist_rec_tab.OLD_ACTIVE_START_DATE(i)),
           decode( l_asset_hist_rec_tab.NEW_ACTIVE_START_DATE(i), FND_API.G_MISS_DATE, NULL, l_asset_hist_rec_tab.NEW_ACTIVE_START_DATE(i)),
           decode( l_asset_hist_rec_tab.OLD_ACTIVE_END_DATE(i), FND_API.G_MISS_DATE, NULL, l_asset_hist_rec_tab.OLD_ACTIVE_END_DATE(i)),
           decode( l_asset_hist_rec_tab.NEW_ACTIVE_END_DATE(i), FND_API.G_MISS_DATE, NULL, l_asset_hist_rec_tab.NEW_ACTIVE_END_DATE(i)),
           'N',
           l_user_id,
           SYSDATE,
           l_user_id,
           SYSDATE,
           l_login_id,
           1,
           decode( l_asset_hist_rec_tab.OLD_FA_SYNC_FLAG(i), FND_API.G_MISS_CHAR, NULL, l_asset_hist_rec_tab.OLD_FA_SYNC_FLAG(i)),
           decode( l_asset_hist_rec_tab.NEW_FA_SYNC_FLAG(i), FND_API.G_MISS_CHAR, NULL, l_asset_hist_rec_tab.NEW_FA_SYNC_FLAG(i))
           );
   END IF;
   --
EXCEPTION
   WHEN OTHERS THEN
      FND_File.Put_Line(Fnd_File.LOG,'Into when others of bulk_insert');
      FND_File.Put_Line(Fnd_File.LOG,'SQLERRM:'||substr(SQLERRM,1,200));
      csi_gen_utility_pvt.put_line('SQLERRM:'||substr(SQLERRM,1,200));
      ROLLBACK TO Bulk_Insert;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END Bulk_Insert;
--
--
/*----------------------------------------------------*/
/* procedure name: create_item_instance               */
/* description :   procedure used to                  */
/*                 create item instances              */
/*----------------------------------------------------*/

PROCEDURE create_item_instance
 (
     p_api_version           IN     NUMBER
    ,p_commit                IN     VARCHAR2
    ,p_init_msg_list         IN     VARCHAR2
    ,p_validation_level      IN     NUMBER
    ,p_instance_tbl          IN OUT NOCOPY csi_datastructures_pub.instance_tbl
    ,p_ext_attrib_values_tbl IN OUT NOCOPY csi_datastructures_pub.extend_attrib_values_tbl
    ,p_party_tbl             IN OUT NOCOPY csi_datastructures_pub.party_tbl
    ,p_account_tbl           IN OUT NOCOPY csi_datastructures_pub.party_account_tbl
    ,p_pricing_attrib_tbl    IN OUT NOCOPY csi_datastructures_pub.pricing_attribs_tbl
    ,p_org_assignments_tbl   IN OUT NOCOPY csi_datastructures_pub.organization_units_tbl
    ,p_asset_assignment_tbl  IN OUT NOCOPY csi_datastructures_pub.instance_asset_tbl
    ,p_txn_tbl               IN OUT NOCOPY csi_datastructures_pub.transaction_tbl
    ,p_call_from_bom_expl    IN     VARCHAR2
    ,p_grp_error_tbl         OUT NOCOPY    csi_datastructures_pub.grp_error_tbl
    ,x_return_status         OUT NOCOPY    VARCHAR2
    ,x_msg_count             OUT NOCOPY    NUMBER
    ,x_msg_data              OUT NOCOPY    VARCHAR2
 )
IS
    l_api_name                      CONSTANT VARCHAR2(30)   := 'CREATE_ITEM_INSTANCE';
    l_api_version                   CONSTANT NUMBER         := 1.0;
    l_debug_level                   NUMBER;
    l_flag                          VARCHAR2(1)             := 'N';
    l_serial_control                NUMBER;
    l_msg_data                      VARCHAR2(2000);
    l_msg_index                     NUMBER;
    l_msg_count                     NUMBER;
    l_transaction_type              VARCHAR2(10);
    l_contracts_status              VARCHAR2(3);
    l_account_id                    NUMBER;
    l_party_id                      NUMBER;
    l_party_src_tbl                 VARCHAR2(30);
    l_version_label                 VARCHAR2(30) := FND_PROFILE.VALUE('CSI_DEFAULT_VERSION_LABEL');
    l_temp_party_tbl                csi_datastructures_pub.party_tbl;
    l_temp_account_tbl              csi_datastructures_pub.party_account_tbl;
    l_temp_org_tbl                  csi_datastructures_pub.organization_units_tbl;
    l_temp_asset_tbl                csi_datastructures_pub.instance_asset_tbl;
    l_temp_ext_tbl                  csi_datastructures_pub.extend_attrib_values_tbl;
    l_build_party_tbl               csi_datastructures_pub.party_tbl;
    l_build_account_tbl             csi_datastructures_pub.party_account_tbl;
    l_build_org_tbl                 csi_datastructures_pub.organization_units_tbl;
    l_build_asset_tbl               csi_datastructures_pub.instance_asset_tbl;
    l_build_ext_tbl                 csi_datastructures_pub.extend_attrib_values_tbl;
    l_build_pricing_tbl             csi_datastructures_pub.pricing_attribs_tbl;
    l_build_ctr                     NUMBER := 0;
    l_party_count                   NUMBER;
    l_account_count                 NUMBER;
    l_org_count                     NUMBER;
    l_asset_count                   NUMBER;
    l_ext_count                     NUMBER;
    l_iface_id                      NUMBER;
    l_iface_error_text              VARCHAR2(2000);
    l_item_attribute_tbl            csi_item_instance_pvt.item_attribute_tbl;
    l_location_tbl                  csi_item_instance_pvt.location_tbl;
    l_generic_id_tbl                csi_item_instance_pvt.generic_id_tbl;
    l_lookup_tbl                    csi_item_instance_pvt.lookup_tbl;
    l_ins_count_rec                 csi_item_instance_pvt.ins_count_rec;
    l_internal_party_id             NUMBER;
    l_party_has_correct_acct        BOOLEAN := FALSE;
    l_party_source_tbl              csi_party_relationships_pvt.party_source_tbl;
    l_party_id_tbl                  csi_party_relationships_pvt.party_id_tbl;
    l_contact_tbl                   csi_party_relationships_pvt.contact_tbl;
    l_party_rel_type_tbl            csi_party_relationships_pvt.party_rel_type_tbl;
    l_party_count_rec               csi_party_relationships_pvt.party_count_rec;
    l_inst_party_tbl                csi_party_relationships_pvt.inst_party_tbl;
    l_acct_rel_type_tbl             csi_party_relationships_pvt.acct_rel_type_tbl;
    l_site_use_tbl                  csi_party_relationships_pvt.site_use_tbl;
    l_account_count_rec             csi_party_relationships_pvt.account_count_rec;
    l_acct_id_tbl                   csi_party_relationships_pvt.acct_id_tbl;
    l_grp_error_tbl                 csi_datastructures_pub.grp_error_tbl;
    l_ou_lookup_tbl                 csi_organization_unit_pvt.lookup_tbl;
    l_ou_count_rec                  csi_organization_unit_pvt.ou_count_rec;
    l_ou_id_tbl                     csi_organization_unit_pvt.ou_id_tbl;
    l_ext_id_tbl                    csi_item_instance_pvt.ext_id_tbl;
    l_ext_count_rec                 csi_item_instance_pvt.ext_count_rec;
    l_ext_attr_tbl                  csi_item_instance_pvt.ext_attr_tbl;
    l_ext_cat_tbl                   csi_item_instance_pvt.ext_cat_tbl;
    l_asset_lookup_tbl              csi_asset_pvt.lookup_tbl;
    l_asset_count_rec               csi_asset_pvt.asset_count_rec;
    l_asset_id_tbl                  csi_asset_pvt.asset_id_tbl;
    l_asset_loc_tbl                 csi_asset_pvt.asset_loc_tbl;
    --
    l_bulk_inst_tbl                 csi_datastructures_pub.instance_tbl;
    l_bulk_version_label_tbl        csi_datastructures_pub.version_label_tbl;
    l_bulk_ver_label_hist_tbl       csi_datastructures_pub.version_label_history_tbl;
    l_bulk_inst_hist_tbl            csi_datastructures_pub.instance_history_tbl;
    l_bulk_party_tbl                csi_datastructures_pub.party_tbl;
    l_bulk_party_hist_tbl           csi_datastructures_pub.party_history_tbl;
    l_bulk_acct_tbl                 csi_datastructures_pub.party_account_tbl;
    l_bulk_acct_hist_tbl            csi_datastructures_pub.account_history_tbl;
    l_bulk_txn_tbl                  csi_datastructures_pub.transaction_tbl;
    x_bulk_txn_tbl                  csi_datastructures_pub.transaction_tbl;
    l_owner_pty_acct_tbl            csi_item_instance_pvt.owner_pty_acct_tbl;
    l_bulk_org_units_tbl            csi_datastructures_pub.organization_units_tbl;
    l_bulk_org_units_hist_tbl       csi_datastructures_pub.org_units_history_tbl;
    l_bulk_pricing_tbl              csi_datastructures_pub.pricing_attribs_tbl;
    l_bulk_pricing_hist_tbl         csi_datastructures_pub.pricing_history_tbl;
    l_bulk_ext_attrib_values_tbl    csi_datastructures_pub.extend_attrib_values_tbl;
    l_bulk_ext_attrib_val_hist_tbl  csi_datastructures_pub.ext_attrib_val_history_tbl;
    l_bulk_asset_tbl                csi_datastructures_pub.instance_asset_tbl;
    l_bulk_asset_hist_tbl           csi_datastructures_pub.ins_asset_history_tbl;
    --
    l_bulk_inst_count               NUMBER := 0;
    l_bulk_pty_count                NUMBER := 0;
    l_bulk_acct_count               NUMBER := 0;
    l_bulk_org_count                NUMBER := 0;
    l_bulk_pricing_count            NUMBER := 0;
    l_bulk_ext_count                NUMBER := 0;
    l_bulk_asset_count              NUMBER := 0;
    l_owner_count                   NUMBER := 0;
    --
    l_txn_exists_tbl                dbms_sql.Number_Table;
    l_intf_id_array                 dbms_sql.Number_Table;
    l_inst_id_array                 dbms_sql.Number_Table;
    l_status_array                  dbms_sql.Varchar2_Table;
    l_error_array                   dbms_sql.Varchar2_Table;
    l_num_of_rows                   NUMBER;
    l_upd_stmt                      VARCHAR2(2000);
    l_dummy                         NUMBER;
    l_instance_status               VARCHAR2(50) := FND_PROFILE.VALUE('CSI_DEFAULT_INSTANCE_STATUS');
    l_status_id                     NUMBER;
    l_owner_party_id                NUMBER;
    l_vld_organization_id           NUMBER;
    l_location_id                   NUMBER;

	-- Start of code for Bug 9249563
	l_base_item_id           NUMBER;
	l_counter_flag       NUMBER :=0;
	l_ctr_item_associations_rec csi_ctr_datastructures_pub.ctr_item_associations_rec;

	CURSOR CTR_GROUP(p_src_object_id IN NUMBER) IS
	     SELECT  group_id,
            associated_to_group,
			COUNTER_ID
	      FROM  csi_ctr_item_associations
	      WHERE  inventory_item_id = p_src_object_id;
	-- End of code for Bug 9249563
    --
    TYPE NUMLIST IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    l_del_inst_tbl                  NUMLIST;
    l_del_txn_tbl                   NUMLIST;
    l_del_count                     NUMBER := 0;
    --
    l_error_count                   NUMBER := 0;
    --
    TYPE CTR_REC IS RECORD
       (
         inventory_item_id     NUMBER
        ,ctr_template_exists   VARCHAR2(1)
       );
    TYPE CTR_TBL IS TABLE OF CTR_REC INDEX BY BINARY_INTEGER;
    --
    TYPE CONTACT_PARTY_REC IS RECORD
       (
         party_id         NUMBER
        ,contact_party_id NUMBER
        ,valid_flag       VARCHAR2(1)
       );
    TYPE CONTACT_PARTY_TBL IS TABLE OF CONTACT_PARTY_REC INDEX BY BINARY_INTEGER;
    --
    l_ctr_id                        dbms_sql.Number_Table;
    l_ctr_ins_id                    dbms_sql.Number_Table;
    l_ctr_item_id                   dbms_sql.Number_Table;
    l_ctr_org_id                    dbms_sql.Number_Table;
    l_counter                       NUMBER := 0;
    l_contact_party_tbl             CONTACT_PARTY_TBL;
    l_contact_party_count           NUMBER := 0;
    l_ctr_tbl                       CTR_TBL;
    l_ctr_count                     NUMBER := 0;
    l_exists_flag                   VARCHAR2(1);
    l_exists                        VARCHAR2(1);
    l_txn_ctr                       NUMBER;
    l_valid_flag                    VARCHAR2(1);
    l_ctr_exists_flag               VARCHAR2(1);
    l_ctr_instantiate               VARCHAR2(1);
    l_call_counters                 VARCHAR2(1) := FND_PROFILE.VALUE('CSI_COUNTERS_ENABLED');
    l_ctr_grp_id_template           NUMBER;
    l_ctr_grp_id_instance           NUMBER;
    l_ctr_id_template               csi_counter_template_pub.ctr_template_autoinst_tbl;
    l_ctr_id_instance               csi_counter_template_pub.counter_autoinstantiate_tbl;
    l_user_id                       NUMBER := FND_GLOBAL.USER_ID;
    l_login_id                      NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
    l_upd_txn_count                 NUMBER := 0;
    l_upd_txn_tbl                   dbms_sql.Number_Table;
    l_serial_control_code           number;
    --
    PROCESS_NEXT                    EXCEPTION;
    SKIP_ERROR                      EXCEPTION;
    OTHER_ERROR                     EXCEPTION; -- Added for bug 3579121(rel 11.5.9)

    CURSOR instance_csr (p_ins_id IN NUMBER) IS
    SELECT  *
    FROM    csi_item_instances
    WHERE   instance_id = p_ins_id;
    --
    l_instance_csr    instance_csr%ROWTYPE;
    --
    px_oks_txn_inst_tbl            oks_ibint_pub.txn_instance_tbl;
    l_ctr_group_id                 NUMBER;
    l_eam_item_type                NUMBER;
    --
BEGIN

     -- Standard Start of API savepoint
     -- SAVEPOINT  create_item_instance;

     -- Check for freeze_flag in csi_install_parameters is set to 'Y'
     csi_utility_grp.check_ib_active;

     -- Standard call to check for call compatibility.
     IF NOT FND_API.Compatible_API_Call (l_api_version,
                                         p_api_version,
                                         l_api_name   ,
                                         G_PKG_NAME   )
     THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     -- Initialize message list if p_init_msg_list is set to TRUE.
     IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
     END IF;

     -- Initialize API return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     -- Check the profile option debug_level for debug message reporting
     l_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');

     -- If debug_level = 1 then dump the procedure name
     IF (l_debug_level > 0) THEN
        csi_gen_utility_pvt.put_line( 'create_item_instance');
     END IF;

     -- If the debug level = 2 then dump all the parameters values.
     IF (l_debug_level > 1) THEN

            csi_gen_utility_pvt.put_line( 'create_item_instance' ||
                                          p_api_version         ||'-'||
                                          p_commit              ||'-'||
                                          p_init_msg_list       ||'-'||
                                          p_validation_level );
     END IF;

     /***** srramakr commented for bug # 3304439
     -- Check for the profile option and enable trace
             l_flag:=CSI_GEN_UTILITY_PVT.enable_trace(l_trace_flag => l_flag);
     -- End enable trace
     ****/

    -- Start API body
    l_ext_count_rec.ext_count := 0;
    -- Create an item instance after validating all the instance attributes.
    -- API also validates that exactly one owner is being created for the
    -- item instance
    -- Grab the internal party id from csi_installed paramters
    IF csi_datastructures_pub.g_install_param_rec.fetch_flag IS NULL THEN
       csi_gen_utility_pvt.populate_install_param_rec;
    END IF;
    --
    l_internal_party_id := csi_datastructures_pub.g_install_param_rec.internal_party_id;
    --
    IF l_internal_party_id IS NULL THEN
       FND_MESSAGE.SET_NAME('CSI','CSI_API_UNINSTALLED_PARAMETER');
       FND_MSG_PUB.ADD;
       RAISE OTHER_ERROR;
    END IF;
    --
    BEGIN
	SELECT instance_status_id
	INTO   l_status_id
	FROM   csi_instance_statuses
	WHERE  name = l_instance_status;
	--
    EXCEPTION
	WHEN OTHERS THEN
	   FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_STATUS_ID');
	   FND_MESSAGE.SET_TOKEN('INSTANCE_STATUS',l_instance_status);
	   FND_MSG_PUB.Add;
	  -- RAISE FND_API.G_EXC_ERROR;
       RAISE OTHER_ERROR; -- Added for bug 3579121 (rel 11.5.9)
    END;
    --
    IF (p_instance_tbl.count > 0) THEN
      FOR inst_tab_row IN p_instance_tbl.FIRST .. p_instance_tbl.LAST
      LOOP
      BEGIN
       IF p_instance_tbl.EXISTS(inst_tab_row) THEN
          FND_MSG_PUB.initialize;
          csi_gen_utility_pvt.dump_instance_rec(p_instance_tbl(inst_tab_row));

          -- Standard Start of API savepoint
          SAVEPOINT create_item_instance;
          l_iface_id := p_instance_tbl(inst_tab_row).interface_id;
          l_iface_error_text := NULL;
          l_intf_id_array(inst_tab_row) := p_instance_tbl(inst_tab_row).interface_id;
          l_grp_error_tbl(inst_tab_row).group_inst_num := inst_tab_row;
          --
          l_build_party_tbl.DELETE;
          l_build_account_tbl.DELETE;
          l_build_org_tbl.DELETE;
          l_build_pricing_tbl.DELETE;
          l_build_ext_tbl.DELETE;
          l_build_asset_tbl.DELETE;
          --
          IF NOT p_txn_tbl.EXISTS(inst_tab_row) THEN
             l_iface_error_text := 'Unable to find the corresponding Transaction record';
             RAISE SKIP_ERROR;
          END IF;
          --
          --dump the operating units table associated to the instance
         IF l_debug_level > 0 THEN
	    IF p_org_assignments_tbl.count > 0 THEN
	       FOR tab_row IN p_org_assignments_tbl.FIRST .. p_org_assignments_tbl.LAST
	       LOOP
		  IF p_org_assignments_tbl.EXISTS(tab_row) THEN
		     IF p_org_assignments_tbl(tab_row).parent_tbl_index = inst_tab_row THEN
			csi_gen_utility_pvt.dump_organization_unit_rec(p_org_assignments_tbl(tab_row));
		     END IF;
		  END IF;
	       END LOOP;
	    END IF;
	    --dump the pricing attributes table associated to the instance
	    IF p_pricing_attrib_tbl.count > 0 THEN
	      FOR tab_row IN p_pricing_attrib_tbl.FIRST .. p_pricing_attrib_tbl.LAST
	      LOOP
	       IF p_pricing_attrib_tbl.EXISTS(tab_row) THEN
		IF p_pricing_attrib_tbl(tab_row).parent_tbl_index = inst_tab_row THEN
		   csi_gen_utility_pvt.dump_pricing_attribs_rec(p_pricing_attrib_tbl(tab_row));
		END IF;
	       END IF;
	      END LOOP;
	    END IF;
	    --dump the extended attributes table associated to the instance
	    IF p_ext_attrib_values_tbl.count > 0 THEN
	      FOR tab_row IN p_ext_attrib_values_tbl.FIRST .. p_ext_attrib_values_tbl.LAST
	      LOOP
	       IF p_ext_attrib_values_tbl.EXISTS(tab_row) THEN
		IF p_ext_attrib_values_tbl(tab_row).parent_tbl_index = inst_tab_row THEN
		   csi_gen_utility_pvt.dump_ext_attrib_values_rec(p_ext_attrib_values_tbl(tab_row));
		END IF;
	       END IF;
	      END LOOP;
	    END IF;
	    --dump the assets table associated to the instance
	    IF (p_asset_assignment_tbl.count > 0) THEN
	      FOR tab_row IN p_asset_assignment_tbl.FIRST .. p_asset_assignment_tbl.LAST
	      LOOP
		IF p_asset_assignment_tbl.EXISTS(tab_row) THEN
		 IF p_asset_assignment_tbl(tab_row).parent_tbl_index = inst_tab_row THEN
		    csi_gen_utility_pvt.dump_instance_asset_rec(p_asset_assignment_tbl(tab_row));
		 END IF;
		END IF;
	      END LOOP;
	    END IF;

	    --dump the parties and corresponding accounts table that are associated to an instance
	    IF (p_party_tbl.count > 0) THEN
	      FOR tab_row IN p_party_tbl.FIRST .. p_party_tbl.LAST
	      LOOP
		IF p_party_tbl.EXISTS(tab_row) THEN
		   IF p_party_tbl(tab_row).parent_tbl_index = inst_tab_row THEN
		      csi_gen_utility_pvt.dump_party_rec(p_party_tbl(tab_row));
		      IF p_account_tbl.count > 0 THEN
			 FOR acct_tab_row in p_account_tbl.FIRST .. p_account_tbl.LAST
			 LOOP
			    IF p_account_tbl.EXISTS(acct_tab_row) THEN
			       IF p_account_tbl(acct_tab_row).parent_tbl_index = tab_row THEN
				  csi_gen_utility_pvt.dump_party_account_rec(p_account_tbl(acct_tab_row));
			       END IF;
			    END IF;
			 END LOOP;
		      END IF;
		    END IF;
		 END IF;
	      END LOOP;
	    END IF;
        END IF; -- dump if l_debug_level > 0
         --
       ELSE
          RAISE PROCESS_NEXT;
       END IF; --p_instance_tbl.EXISTS(inst_tab_row)
       -- Compress the Party Tbl and pass it to the Create API.
       l_temp_party_tbl.DELETE;
       l_party_count := 0;
       --
       IF (p_party_tbl.count > 0) THEN
           FOR tab_row IN p_party_tbl.FIRST .. p_party_tbl.LAST
           LOOP
              IF p_party_tbl.EXISTS(tab_row) THEN
                 IF p_party_tbl(tab_row).parent_tbl_index = inst_tab_row THEN
                    l_party_count := l_party_count + 1;
                    l_temp_party_tbl(l_party_count) := p_party_tbl(tab_row);
                 END IF;
              END IF;
           END LOOP;
       END IF;
         --
         -- Compress Asset Tbl and pass it to the Create API.
         l_asset_count := 0;
         l_temp_asset_tbl.DELETE;
         IF (p_asset_assignment_tbl.count > 0) THEN
            FOR tab_row IN p_asset_assignment_tbl.FIRST .. p_asset_assignment_tbl.LAST
            LOOP
               IF p_asset_assignment_tbl.EXISTS(tab_row) THEN
                  IF p_asset_assignment_tbl(tab_row).parent_tbl_index = inst_tab_row THEN
                     l_asset_count := l_asset_count + 1;
                     l_temp_asset_tbl(l_asset_count) := p_asset_assignment_tbl(tab_row);
                  END IF;
               END IF;
            END LOOP;
         END IF;
         --
         IF p_instance_tbl(inst_tab_row).instance_status_id IS NULL OR
            p_instance_tbl(inst_tab_row).instance_status_id = FND_API.G_MISS_NUM THEN
            p_instance_tbl(inst_tab_row).instance_status_id := l_status_id;
         END IF;
         --
         -- If version label is null, then we need read the the default value from the profile option
         IF ((p_instance_tbl(inst_tab_row).version_label IS NULL) OR
             (p_instance_tbl(inst_tab_row).version_label = FND_API.G_MISS_CHAR)) THEN
             IF l_version_label IS NULL THEN
                FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_VERSION_LABEL');
                FND_MSG_PUB.ADD;
                l_msg_index := 1;
                FND_MSG_PUB.Count_And_Get
                    (p_count  =>  x_msg_count,
                     p_data   =>  x_msg_data
                    );
                l_msg_count := x_msg_count;
                WHILE l_msg_count > 0 LOOP
                   x_msg_data := FND_MSG_PUB.GET
		     (  l_msg_index,
			FND_API.G_FALSE );
		   csi_gen_utility_pvt.put_line( ' MESSAGE DATA = '||x_msg_data);
		   l_msg_index := l_msg_index + 1;
		   l_msg_count := l_msg_count - 1;
                END LOOP;
		l_iface_error_text := substr(x_msg_data,1,2000);
		RAISE SKIP_ERROR;
             ELSE
                p_instance_tbl(inst_tab_row).version_label := l_version_label;
             END IF;
         END IF;
         --
         IF p_instance_tbl(inst_tab_row).vld_organization_id IS NULL OR
            p_instance_tbl(inst_tab_row).vld_organization_id = FND_API.G_MISS_NUM THEN
            p_instance_tbl(inst_tab_row).vld_organization_id :=
                                       p_instance_tbl(inst_tab_row).inv_master_organization_id;
         END IF;
         -- Validate Serial uniqueness within this batch
         IF p_instance_tbl(inst_tab_row).serial_number IS NOT NULL AND
            p_instance_tbl(inst_tab_row).serial_number <> FND_API.G_MISS_CHAR AND
            p_instance_tbl(inst_tab_row).vld_organization_id IS NOT NULL AND
            p_instance_tbl(inst_tab_row).vld_organization_id <> FND_API.G_MISS_NUM AND
            p_instance_tbl(inst_tab_row).inventory_item_id IS NOT NULL AND
            p_instance_tbl(inst_tab_row).inventory_item_id <> FND_API.G_MISS_NUM THEN
            IF NOT Valid_Serial_Number
                ( p_instance_rec   =>  p_instance_tbl(inst_tab_row),
                  p_instance_tbl   =>  p_instance_tbl,
                  p_inst_tab_row => inst_tab_row) THEN --bug 9227016
               l_msg_index := 1;
               FND_MSG_PUB.Count_And_Get
                    (p_count  =>  x_msg_count,
                     p_data   =>  x_msg_data
                    );
               l_msg_count := x_msg_count;
               WHILE l_msg_count > 0 LOOP
                     x_msg_data := FND_MSG_PUB.GET
                       (  l_msg_index,
                          FND_API.G_FALSE );
                      csi_gen_utility_pvt.put_line( ' MESSAGE DATA = '||x_msg_data);
                     l_msg_index := l_msg_index + 1;
                     l_msg_count := l_msg_count - 1;
               END LOOP;
               l_iface_error_text := substr(x_msg_data,1,2000);
	       RAISE SKIP_ERROR;
            END IF;
         END IF;
         --
         -- Validate Lot uniqueness within this batch
         IF p_instance_tbl(inst_tab_row).lot_number IS NOT NULL AND
            p_instance_tbl(inst_tab_row).lot_number <> FND_API.G_MISS_CHAR AND
            p_instance_tbl(inst_tab_row).vld_organization_id IS NOT NULL AND
            p_instance_tbl(inst_tab_row).vld_organization_id <> FND_API.G_MISS_NUM AND
            p_instance_tbl(inst_tab_row).inventory_item_id IS NOT NULL AND
            p_instance_tbl(inst_tab_row).inventory_item_id <> FND_API.G_MISS_NUM THEN
            IF NOT Valid_Lot_Number
                ( p_instance_rec   =>  p_instance_tbl(inst_tab_row),
                  p_instance_tbl   =>  p_instance_tbl) THEN
               l_msg_index := 1;
               FND_MSG_PUB.Count_And_Get
                    (p_count  =>  x_msg_count,
                     p_data   =>  x_msg_data
                    );
               l_msg_count := x_msg_count;
               WHILE l_msg_count > 0 LOOP
                     x_msg_data := FND_MSG_PUB.GET
                       (  l_msg_index,
                          FND_API.G_FALSE );
                      csi_gen_utility_pvt.put_line( ' MESSAGE DATA = '||x_msg_data);
                     l_msg_index := l_msg_index + 1;
                     l_msg_count := l_msg_count - 1;
               END LOOP;
               l_iface_error_text := substr(x_msg_data,1,2000);
	       RAISE SKIP_ERROR;
            END IF;
         END IF;
         --

      SELECT eam_item_type,
             serial_number_control_code
      INTO   l_eam_item_type,
             l_serial_control_code
      FROM   mtl_system_items
      WHERE  inventory_item_id = p_instance_tbl(inst_tab_row).inventory_item_id
      AND    organization_id   = p_instance_tbl(inst_tab_row).vld_organization_id;

      IF l_eam_item_type in (1, 3) AND l_serial_control_code <> 1 THEN
         p_instance_tbl(inst_tab_row).instance_condition_id := 1;
      END IF;


        -- Calling Pre Customer User Hook -- added for bug 9146060 by HYONLEE

      BEGIN
        IF JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, l_api_name, 'B', 'C' ) THEN
           csi_gen_utility_pvt.put_line('Calling CSI_ITEM_INSTANCE_CUHK.Create_Item_Instance_Pre ..');
          CSI_ITEM_INSTANCE_CUHK.Create_Item_Instance_Pre
            (
            p_api_version               => 1.0
            ,p_commit                   => fnd_api.g_false
            ,p_init_msg_list            => fnd_api.g_false
            ,p_validation_level         => fnd_api.g_valid_level_full
            ,p_instance_rec             => p_instance_tbl(inst_tab_row)
            ,p_ext_attrib_values_tbl    => p_ext_attrib_values_tbl
            ,p_party_tbl                => l_temp_party_tbl
            ,p_account_tbl              => p_account_tbl
            ,p_pricing_attrib_tbl       => p_pricing_attrib_tbl
            ,p_org_assignments_tbl      => p_org_assignments_tbl
            ,p_asset_assignment_tbl     => p_asset_assignment_tbl
            ,p_txn_rec                  => p_txn_tbl(inst_tab_row)
            ,x_return_status            => x_return_status
            ,x_msg_count                => x_msg_count
            ,x_msg_data                 => x_msg_data
         );
          --
          IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
              l_msg_index := 1;
              l_msg_count := x_msg_count;
              WHILE l_msg_count > 0 LOOP
                      x_msg_data := FND_MSG_PUB.GET
                                  (  l_msg_index,
                                     FND_API.G_FALSE );
                  csi_gen_utility_pvt.put_line('ERROR FROM CSI_ITEM_INSTANCE_CUHK.Create_Item_Instance_Pre API ');
                  csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
                  l_msg_index := l_msg_index + 1;
                  l_msg_count := l_msg_count - 1;
              END LOOP;
             RAISE FND_API.G_EXC_ERROR;
           END IF;
          --
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
           csi_gen_utility_pvt.put_line('ERROR FROM JTF_USR_HKS.Ok_to_execute API Create Pre Customer');
           RAISE FND_API.G_EXC_ERROR;
      END;

     -- Calling Pre Vertical User Hook -- added for bug 9146060 by HYONLEE
      BEGIN

        IF JTF_USR_HKS.Ok_to_execute( G_PKG_NAME, l_api_name, 'B', 'V' )  THEN
           csi_gen_utility_pvt.put_line('Calling CSI_ITEM_INSTANCE_VUHK.Create_Item_Instance_Pre ..');
          CSI_ITEM_INSTANCE_VUHK.Create_Item_Instance_Pre
            (
            p_api_version               => 1.0
            ,p_commit                   => fnd_api.g_false
            ,p_init_msg_list            => fnd_api.g_false
            ,p_validation_level         => fnd_api.g_valid_level_full
            ,p_instance_rec             => p_instance_tbl(inst_tab_row)
            ,p_ext_attrib_values_tbl    => p_ext_attrib_values_tbl
            ,p_party_tbl                => l_temp_party_tbl
            ,p_account_tbl              => p_account_tbl
            ,p_pricing_attrib_tbl       => p_pricing_attrib_tbl
            ,p_org_assignments_tbl      => p_org_assignments_tbl
            ,p_asset_assignment_tbl     => p_asset_assignment_tbl
            ,p_txn_rec                  => p_txn_tbl(inst_tab_row)
            ,x_return_status            => x_return_status
            ,x_msg_count                => x_msg_count
            ,x_msg_data                 => x_msg_data
         );
          --
          IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
              l_msg_index := 1;
              l_msg_count := x_msg_count;
              WHILE l_msg_count > 0 LOOP
                      x_msg_data := FND_MSG_PUB.GET
                                  (  l_msg_index,
                                     FND_API.G_FALSE );
                  csi_gen_utility_pvt.put_line('ERROR FROM CSI_ITEM_INSTANCE_VUHK.Create_Item_Instance_Pre API ');
                  csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
                  l_msg_index := l_msg_index + 1;
                  l_msg_count := l_msg_count - 1;
              END LOOP;
             RAISE FND_API.G_EXC_ERROR;
           END IF;
          --
        END IF;

      EXCEPTION
        WHEN OTHERS THEN
           csi_gen_utility_pvt.put_line('ERROR FROM JTF_USR_HKS.Ok_to_execute API Create Pre Vertical');
           RAISE FND_API.G_EXC_ERROR;
      END;

    -- End of PRE User Hooks
         csi_item_instance_pvt.create_item_instance
           (
            p_api_version        => p_api_version
           ,p_commit             => fnd_api.g_false
           ,p_init_msg_list      => p_init_msg_list
           ,p_validation_level   => p_validation_level
           ,p_instance_rec       => p_instance_tbl(inst_tab_row)
           ,p_txn_rec            => p_txn_tbl(inst_tab_row)
           ,p_party_tbl          => l_temp_party_tbl
           ,p_asset_tbl          => l_temp_asset_tbl
           ,x_return_status      => x_return_status
           ,x_msg_count          => x_msg_count
           ,x_msg_data           => x_msg_data
           ,p_item_attribute_tbl => l_item_attribute_tbl
           ,p_location_tbl       => l_location_tbl
           ,p_generic_id_tbl     => l_generic_id_tbl
           ,p_lookup_tbl         => l_lookup_tbl
           ,p_ins_count_rec      => l_ins_count_rec
           ,p_called_from_grp    => fnd_api.g_true
           ,p_internal_party_id  => l_internal_party_id
           );
         IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
            csi_gen_utility_pvt.put_line( ' Error from CSI_ITEM_INSTANCE_PVT.. ');
            l_msg_index := 1;
            l_msg_count := x_msg_count;
            WHILE l_msg_count > 0 LOOP
                   x_msg_data := FND_MSG_PUB.GET
                       (  l_msg_index,
                          FND_API.G_FALSE );
                      csi_gen_utility_pvt.put_line( ' MESSAGE DATA = '||x_msg_data);
                     l_msg_index := l_msg_index + 1;
                     l_msg_count := l_msg_count - 1;
            END LOOP;
            l_iface_error_text := substr(x_msg_data,1,2000);
            RAISE SKIP_ERROR;
         END IF;

     -- Calling Post Customer User Hook -- added for bug 9146060 by HYONLEE
          BEGIN

             IF JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, l_api_name, 'A', 'C' ) THEN
               csi_gen_utility_pvt.put_line('Calling  CSI_ITEM_INSTANCE_CUHK.Create_Item_Instance_Post ..');
                CSI_ITEM_INSTANCE_CUHK.Create_Item_Instance_Post
                   (
                    p_api_version               => 1.0
                    ,p_commit                   => fnd_api.g_false
                    ,p_init_msg_list            => fnd_api.g_false
                    ,p_validation_level         => fnd_api.g_valid_level_full
                    ,p_instance_rec             => p_instance_tbl(inst_tab_row)
                    ,p_ext_attrib_values_tbl    => p_ext_attrib_values_tbl
                    ,p_party_tbl                => l_temp_party_tbl
                    ,p_account_tbl              => p_account_tbl
                    ,p_pricing_attrib_tbl       => p_pricing_attrib_tbl
                    ,p_org_assignments_tbl      => p_org_assignments_tbl
                    ,p_asset_assignment_tbl     => p_asset_assignment_tbl
                    ,p_txn_rec                  => p_txn_tbl(inst_tab_row)
                    ,x_return_status            => x_return_status
                    ,x_msg_count                => x_msg_count
                    ,x_msg_data                 => x_msg_data
              );
                --
                IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                  l_msg_index := 1;
                  l_msg_count := x_msg_count;
                  WHILE l_msg_count > 0 LOOP
                          x_msg_data := FND_MSG_PUB.GET
                                      (  l_msg_index,
                                         FND_API.G_FALSE );
                      csi_gen_utility_pvt.put_line('ERROR FROM CSI_ITEM_INSTANCE_CUHK.Create_Item_Instance_Post API ');
                      csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
                      l_msg_index := l_msg_index + 1;
                      l_msg_count := l_msg_count - 1;
                  END LOOP;
                 RAISE FND_API.G_EXC_ERROR;
               END IF;
                --
            END IF;
          EXCEPTION
            WHEN OTHERS THEN
               csi_gen_utility_pvt.put_line('ERROR FROM JTF_USR_HKS.Ok_to_execute API Create Post Customer');
               RAISE FND_API.G_EXC_ERROR;
          END;


         -- Call the create_party_relationship API to create instance-to-party
         -- relationships.
         IF ((p_instance_tbl(inst_tab_row).instance_id IS NOT NULL) AND
             (p_instance_tbl(inst_tab_row).instance_id <> FND_API.G_MISS_NUM)) THEN
            IF (p_party_tbl.count > 0) THEN
               FOR tab_row IN p_party_tbl.FIRST .. p_party_tbl.LAST
               LOOP
                  IF p_party_tbl.EXISTS(tab_row) THEN
                    IF p_party_tbl(tab_row).parent_tbl_index = inst_tab_row THEN
                       p_party_tbl(tab_row).instance_id := p_instance_tbl(inst_tab_row).instance_id;
                       IF ((p_party_tbl(tab_row).active_start_date IS NULL) OR
                           (p_party_tbl(tab_row).active_start_date = FND_API.G_MISS_DATE)) THEN
                            p_party_tbl(tab_row).active_start_date := p_instance_tbl(inst_tab_row).active_start_date;
                       END IF;
                       IF ((p_party_tbl(tab_row).party_source_table = 'HZ_PARTIES') AND
                           (p_party_tbl(tab_row).party_id <> l_internal_party_id) AND
                           (p_party_tbl(tab_row).relationship_type_code = 'OWNER')) THEN
                           l_party_has_correct_acct := FALSE;
                          IF p_account_tbl.COUNT > 0 THEN
                             FOR l_acct_row IN  p_account_tbl.FIRST..p_account_tbl.LAST
                             LOOP
                             -- Check if the party and its accounts are mapped
			     --Commenting for bug 7010294
			      --  IF ((p_account_tbl(l_acct_row).parent_tbl_index = tab_row) AND
                               IF (p_account_tbl(l_acct_row).relationship_type_code = 'OWNER') THEN
			            l_party_has_correct_acct := TRUE;
                                    exit;
                                END IF;
                             END LOOP;
                          END IF;
                          -- Raise an exception if external parties don't have an owner account
                          IF NOT l_party_has_correct_acct THEN
                             l_iface_error_text := 'Invalid OWNER Party Account for Party ID '
                                                          ||to_char(p_party_tbl(tab_row).party_id);
                             csi_gen_utility_pvt.put_line(l_iface_error_text);
                             RAISE SKIP_ERROR;
                          END IF;
                       END IF; -- Party source table is HZ_PARITES and External OWNER Party check
                       --
                       -- Use l_temp_party_tbl which belongs to the current instance and validate the
                       -- Instance-Party business rules.
                       IF p_party_tbl(tab_row).contact_flag = 'Y' THEN
                          IF p_party_tbl(tab_row).contact_parent_tbl_index IS NULL OR
                             p_party_tbl(tab_row).contact_parent_tbl_index = FND_API.G_MISS_NUM THEN
                             l_iface_error_text := 'Contact_parent_tbl_index should be passed for contacts';
                             csi_gen_utility_pvt.put_line(l_iface_error_text);
                             RAISE SKIP_ERROR;
                          END IF;
                          --
                          IF p_party_tbl(tab_row).contact_parent_tbl_index = tab_row THEN
                             l_iface_error_text := 'Contact Party cannot be a contact of itself ';
                             csi_gen_utility_pvt.put_line(l_iface_error_text);
                             RAISE SKIP_ERROR;
                          END IF;
                          --
                          IF NOT p_party_tbl.EXISTS((p_party_tbl(tab_row).contact_parent_tbl_index)) THEN
                             l_iface_error_text := 'Contact_parent_tbl_index passed is not valid ';
                             csi_gen_utility_pvt.put_line(l_iface_error_text);
                             RAISE SKIP_ERROR;
                          ELSE
                             -- Check if the contact_party and the current party belong to the same instance
                             IF p_party_tbl((p_party_tbl(tab_row).contact_parent_tbl_index)).parent_tbl_index <>
                                p_party_tbl(tab_row).parent_tbl_index THEN
                                l_iface_error_text := 'Contact Party and the Current Party should belong to the same Instance';
                                csi_gen_utility_pvt.put_line(l_iface_error_text);
                                RAISE SKIP_ERROR;
                             END IF;
                             l_party_id := p_party_tbl((p_party_tbl(tab_row).contact_parent_tbl_index)).party_id;
                             l_party_src_tbl := p_party_tbl((p_party_tbl(tab_row).contact_parent_tbl_index)).party_source_table;
                          END IF;
                          -- check whether the contact_party_id is related to the parent party_id
                          IF p_party_tbl(tab_row).party_source_table = 'HZ_PARTIES' AND
                             l_party_src_tbl = 'HZ_PARTIES' THEN
                             l_exists_flag := 'N';
                             l_valid_flag := 'Y';
                             IF l_contact_party_tbl.count > 0 THEN
                                FOR con_pty_row in l_contact_party_tbl.FIRST .. l_contact_party_tbl.LAST LOOP
                                   IF p_party_tbl(tab_row).party_id = l_contact_party_tbl(con_pty_row).contact_party_id AND
                                      l_party_id = l_contact_party_tbl(con_pty_row).party_id THEN
                                      l_exists_flag := 'Y';
                                      l_valid_flag := l_contact_party_tbl(con_pty_row).valid_flag;
                                      exit;
                                   END IF;
                                END LOOP;
                                --
                                IF l_valid_flag <> 'Y' THEN
                                   l_iface_error_text := 'Invalid Contact Party ID '||to_char(p_party_tbl(tab_row).party_id)
                                                          ||' for party ID '||to_char(l_party_id);
                                   csi_gen_utility_pvt.put_line(l_iface_error_text);
                                   RAISE SKIP_ERROR;
                                END IF;
                             END IF;
                             --
                             IF l_exists_flag <> 'Y' THEN
                                l_contact_party_count := l_contact_party_count + 1;
                                l_contact_party_tbl(l_contact_party_count).contact_party_id := p_party_tbl(tab_row).party_id;
                                l_contact_party_tbl(l_contact_party_count).party_id := l_party_id;
                                l_contact_party_tbl(l_contact_party_count).valid_flag := 'Y';
                             END IF;
                          END IF; -- Both party source tables are 'HZ_PARTIES' check
                       END IF; -- contact_flag check
                       --
                       IF NOT ( Check_Inst_Party_Rules
                                   ( p_party_tbl  => l_temp_party_tbl
                                    ,p_party_rec  => p_party_tbl(tab_row)
                                    ,p_start_date => p_instance_tbl(inst_tab_row).active_start_date
                                    ,p_end_date   => p_instance_tbl(inst_tab_row).active_end_date
                                   ) ) THEN
		          l_msg_index := 1;
                          FND_MSG_PUB.Count_And_Get
                                (p_count  =>  x_msg_count,
                                 p_data   =>  x_msg_data
                                );
			  l_msg_count := x_msg_count;
			  WHILE l_msg_count > 0 LOOP
			      x_msg_data := FND_MSG_PUB.GET
				  (  l_msg_index,
			             FND_API.G_FALSE    );
			      csi_gen_utility_pvt.put_line('message data = '||x_msg_data);
			      l_msg_index := l_msg_index + 1;
			      l_msg_count := l_msg_count - 1;
			  END LOOP;
			  l_iface_error_text := substr(x_msg_data,1,2000);
			  RAISE SKIP_ERROR;
                       END IF;
                       --
                       -- Call Private package to validate and create party relationship
		       csi_party_relationships_pvt.create_inst_party_relationship
		       ( p_api_version      => p_api_version
		        ,p_commit           => fnd_api.g_false
		        ,p_init_msg_list    => p_init_msg_list
		        ,p_validation_level => p_validation_level
		        ,p_party_rec        => p_party_tbl(tab_row)
		        ,p_txn_rec          => p_txn_tbl(inst_tab_row)
		        ,x_return_status    => x_return_status
		        ,x_msg_count        => x_msg_count
		        ,x_msg_data         => x_msg_data
		        ,p_party_source_tbl => l_party_source_tbl
		        ,p_party_id_tbl     => l_party_id_tbl
		        ,p_contact_tbl      => l_contact_tbl
		        ,p_party_rel_type_tbl => l_party_rel_type_tbl
		        ,p_party_count_rec  => l_party_count_rec
                        ,p_called_from_grp  => fnd_api.g_true
                       ) ;

		       IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
		          l_msg_index := 1;
	  	  	  l_msg_count := x_msg_count;
			  WHILE l_msg_count > 0 LOOP
			        x_msg_data := FND_MSG_PUB.GET
			  	  (  l_msg_index,
				     FND_API.G_FALSE    );
			     csi_gen_utility_pvt.put_line('message data = '||x_msg_data);
			     l_msg_index := l_msg_index + 1;
			     l_msg_count := l_msg_count - 1;
			  END LOOP;
			  l_iface_error_text := substr(x_msg_data,1,2000);
			  RAISE SKIP_ERROR;
		       ELSE
			  l_build_ctr := l_build_party_tbl.count + 1;
			  l_build_party_tbl(l_build_ctr) := p_party_tbl(tab_row);
		       END IF;
                       --
                       -- Traverse the account tbl and create the accounts
                       l_temp_account_tbl.DELETE;
                       l_account_count := 0;
                       IF p_account_tbl.count > 0 THEN
                          FOR l_acct_row IN p_account_tbl.FIRST .. p_account_tbl.LAST
                          LOOP
                             IF p_account_tbl.EXISTS(l_acct_row) THEN
                                IF p_account_tbl(l_acct_row).parent_tbl_index = tab_row THEN
                                   p_account_tbl(l_acct_row).instance_party_id :=
                                                      p_party_tbl(tab_row).instance_party_id;
                                   p_account_tbl(l_acct_row).call_contracts := fnd_api.g_false;
                                   p_account_tbl(l_acct_row).vld_organization_id :=
                                                      p_instance_tbl(inst_tab_row).vld_organization_id;
                                   IF p_account_tbl(l_acct_row).active_start_date IS NULL OR
                                      p_account_tbl(l_acct_row).active_start_date = fnd_api.g_miss_date
                                   THEN
                                      p_account_tbl(l_acct_row).active_start_date :=
				   	        p_party_tbl(tab_row).active_start_date;
                                   END IF;
                                   --
                                   IF p_account_tbl(l_acct_row).relationship_type_code = 'OWNER' AND
                                      p_party_tbl(tab_row).relationship_type_code <> 'OWNER' THEN
                                      l_iface_error_text := 'OWNER Account Requires OWNER PARTY ';
                                      csi_gen_utility_pvt.put_line(l_iface_error_text);
                                      RAISE SKIP_ERROR;
                                   END IF;
                                   --
                                   l_account_count := l_account_count + 1;
                                   l_temp_account_tbl(l_account_count) := p_account_tbl(l_acct_row);
                                   -- Check Party Account Business rules
                                   IF NOT ( Check_Party_Acct_Rules
                                     ( p_account_tbl     =>  l_temp_account_tbl
                                      ,p_account_rec     =>  p_account_tbl(l_acct_row)
                                      ,p_pty_src_table   =>  p_party_tbl(tab_row).party_source_table
                                      ,p_party_id        =>  p_party_tbl(tab_row).party_id
                                      ,p_acct_id_tbl     =>  l_acct_id_tbl
                                      ,p_start_date      =>  p_party_tbl(tab_row).active_start_date
                                      ,p_end_date        =>  p_party_tbl(tab_row).active_end_date
                                     ) ) THEN
                                     l_msg_index := 1;
                                     FND_MSG_PUB.Count_And_Get
                                       (p_count  =>  x_msg_count,
                                        p_data   =>  x_msg_data
                                       );
                                     l_msg_count := x_msg_count;
                                     WHILE l_msg_count > 0 LOOP
                                        x_msg_data := FND_MSG_PUB.GET(
                                                              l_msg_index,
                                                              FND_API.G_FALSE );
                                        csi_gen_utility_pvt.put_line( 'message data = '||x_msg_data);
                                        l_msg_index := l_msg_index + 1;
                                        l_msg_count := l_msg_count - 1;
                                     END LOOP;
                                     l_iface_error_text := substr(x_msg_data,1,2000);
                                     RAISE SKIP_ERROR;
                                  END IF;
                                  -- Call Private package to validate and create party accounts
              		          csi_party_relationships_pvt.create_inst_party_account
                                    ( p_api_version         => p_api_version
                                     ,p_commit              => fnd_api.g_false
                                     ,p_init_msg_list       => p_init_msg_list
                                     ,p_validation_level      => p_validation_level
                                     ,p_party_account_rec     => p_account_tbl(l_acct_row)
                                     ,p_txn_rec             => p_txn_tbl(inst_tab_row)
                                     ,x_return_status       => x_return_status
                                     ,x_msg_count           => x_msg_count
                                     ,x_msg_data            => x_msg_data
                                     ,p_inst_party_tbl      => l_inst_party_tbl
                                     ,p_acct_rel_type_tbl   => l_acct_rel_type_tbl
                                     ,p_site_use_tbl        => l_site_use_tbl
                                     ,p_account_count_rec   => l_account_count_rec
                                     ,p_called_from_grp     => fnd_api.g_true
                                     ,p_oks_txn_inst_tbl    => px_oks_txn_inst_tbl
                                    );

                                  IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                                     l_msg_index := 1;
                                     l_msg_count := x_msg_count;
                                     WHILE l_msg_count > 0 LOOP
                                        x_msg_data := FND_MSG_PUB.GET(
                                        l_msg_index,
                                        FND_API.G_FALSE );
                                        csi_gen_utility_pvt.put_line( 'message data = '||x_msg_data);
                                        l_msg_index := l_msg_index + 1;
                                        l_msg_count := l_msg_count - 1;
                                     END LOOP;
                                     l_iface_error_text := substr(x_msg_data,1,2000);
                                     RAISE SKIP_ERROR;
				  ELSE
				     l_build_ctr := l_build_account_tbl.count + 1;
				     l_build_account_tbl(l_build_ctr) := p_account_tbl(l_acct_row);
                                  END IF;
                               END IF; -- If this account belongs to the current Party
                           END IF; -- Account record exists
                        END LOOP; -- Account Loop
                     END IF; -- Account Tbl count
                  END IF; -- If this party belong to the current instance
               END IF; -- Party record exists
            END LOOP; -- Party Loop
          END IF; -- Party Tbl count
       END IF; -- Instance ID exists
       --
       -- Call create_organization_unit API to create instance-
       -- to-organization units associations
       --
       l_temp_org_tbl.DELETE;
       l_org_count := 0;
       IF ((p_instance_tbl(inst_tab_row).instance_id IS NOT NULL) AND
           (p_instance_tbl(inst_tab_row).instance_id <> FND_API.G_MISS_NUM)) THEN
           IF (p_org_assignments_tbl.count > 0) THEN
              FOR tab_row IN p_org_assignments_tbl.FIRST .. p_org_assignments_tbl.LAST
              LOOP
                IF p_org_assignments_tbl.EXISTS(tab_row) THEN
                   IF p_org_assignments_tbl(tab_row).parent_tbl_index = inst_tab_row THEN
                      p_org_assignments_tbl(tab_row).instance_id := p_instance_tbl(inst_tab_row).instance_id;
                      IF p_org_assignments_tbl(tab_row).active_start_date IS NULL OR
                         p_org_assignments_tbl(tab_row).active_start_date = FND_API.G_MISS_DATE THEN
                         p_org_assignments_tbl(tab_row).active_start_date := SYSDATE;
                      END IF;
                      l_org_count := l_org_count + 1;
                      l_temp_org_tbl(l_org_count) := p_org_assignments_tbl(tab_row);
                      IF NOT ( Check_Org_Rules
                                  ( p_org_units_tbl => l_temp_org_tbl
                                   ,p_org_units_rec => p_org_assignments_tbl(tab_row)
                                   ,p_start_date => p_instance_tbl(inst_tab_row).active_start_date
                                   ,p_end_date   => p_instance_tbl(inst_tab_row).active_end_date
                                  ) ) THEN
                         l_msg_index := 1;
                         FND_MSG_PUB.Count_And_Get
                              (p_count  =>  x_msg_count,
                               p_data   =>  x_msg_data
                              );
                         l_msg_count := x_msg_count;
                         WHILE l_msg_count > 0 LOOP
                               x_msg_data := FND_MSG_PUB.GET
                                    (  l_msg_index,
                                       FND_API.G_FALSE        );
                                csi_gen_utility_pvt.put_line( ' MESSAGE DATA = '||x_msg_data);
                                l_msg_index := l_msg_index + 1;
                                l_msg_count := l_msg_count - 1;
                         END LOOP;
                         l_iface_error_text := substr(x_msg_data,1,2000);
                         RAISE SKIP_ERROR;
                      END IF;
                      --
                      csi_organization_unit_pvt.create_organization_unit
                      (
                        p_api_version      => p_api_version
                       ,p_commit           => fnd_api.g_false
                       ,p_init_msg_list    => p_init_msg_list
                       ,p_validation_level => p_validation_level
                       ,p_org_unit_rec     => p_org_assignments_tbl(tab_row)
                       ,p_txn_rec          => p_txn_tbl(inst_tab_row)
                       ,x_return_status    => x_return_status
                       ,x_msg_count        => x_msg_count
                       ,x_msg_data         => x_msg_data
                       ,p_lookup_tbl       => l_ou_lookup_tbl
                       ,p_ou_count_rec     => l_ou_count_rec
                       ,p_ou_id_tbl        => l_ou_id_tbl
                       ,p_called_from_grp  => fnd_api.g_true
                      );

                      IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                          csi_gen_utility_pvt.put_line( ' Error from CSI_ORGANIZATION_UNIT_PVT..');
                          l_msg_index := 1;
                          l_msg_count := x_msg_count;
                          WHILE l_msg_count > 0 LOOP
                                x_msg_data := FND_MSG_PUB.GET
                                    (  l_msg_index,
                                       FND_API.G_FALSE        );
                                csi_gen_utility_pvt.put_line( ' MESSAGE DATA = '||x_msg_data);
                                l_msg_index := l_msg_index + 1;
                                l_msg_count := l_msg_count - 1;
                          END LOOP;
                          l_iface_error_text := substr(x_msg_data,1,2000);
                          RAISE SKIP_ERROR;
		       ELSE
		          l_build_ctr := l_build_org_tbl.count + 1;
		          l_build_org_tbl(l_build_ctr) := p_org_assignments_tbl(tab_row);
                       END IF;
                   END IF; -- Org assignment for the current instance
                END IF; -- Org assignments row EXISTS
             END LOOP;
          END IF; --p_org_assignments_tbl.count > 0
       END IF;

       -- Call create_pricing_attribs to associate any pricing attributes
       -- to the item instance
       IF ((p_instance_tbl(inst_tab_row).instance_id IS NOT NULL) AND
           (p_instance_tbl(inst_tab_row).instance_id <> FND_API.G_MISS_NUM)) THEN
           IF (p_pricing_attrib_tbl.count > 0) THEN
              FOR tab_row IN p_pricing_attrib_tbl.FIRST .. p_pricing_attrib_tbl.LAST
              LOOP
                IF p_pricing_attrib_tbl.EXISTS(tab_row) THEN
                   IF p_pricing_attrib_tbl(tab_row).parent_tbl_index = inst_tab_row THEN
                      p_pricing_attrib_tbl(tab_row).instance_id := p_instance_tbl(inst_tab_row).instance_id;
                      IF p_pricing_attrib_tbl(tab_row).active_start_date IS NULL OR
                         p_pricing_attrib_tbl(tab_row).active_start_date = FND_API.G_MISS_DATE THEN
                         p_pricing_attrib_tbl(tab_row).active_start_date := SYSDATE;
                      END IF;
                      --
                      IF NOT ( Check_Pricing_Rules
                                  ( p_pricing_rec   => p_pricing_attrib_tbl(tab_row)
                                   ,p_start_date    => p_instance_tbl(inst_tab_row).active_start_date
                                   ,p_end_date      => p_instance_tbl(inst_tab_row).active_end_date
                                  ) ) THEN
                         l_msg_index := 1;
                         FND_MSG_PUB.Count_And_Get
                              (p_count  =>  x_msg_count,
                               p_data   =>  x_msg_data
                              );
                         l_msg_count := x_msg_count;
                         WHILE l_msg_count > 0 LOOP
                                x_msg_data := FND_MSG_PUB.GET
                                    (  l_msg_index,
                                       FND_API.G_FALSE        );
                                csi_gen_utility_pvt.put_line( ' MESSAGE DATA = '||x_msg_data);
                                l_msg_index := l_msg_index + 1;
                                l_msg_count := l_msg_count - 1;
                         END LOOP;
                         l_iface_error_text := substr(x_msg_data,1,2000);
                         RAISE SKIP_ERROR;
                      END IF;
                      --
                      csi_pricing_attribs_pvt.create_pricing_attribs
                      (
                        p_api_version         => p_api_version
                       ,p_commit              => fnd_api.g_false
                       ,p_init_msg_list       => p_init_msg_list
                       ,p_validation_level    => p_validation_level
                       ,p_pricing_attribs_rec => p_pricing_attrib_tbl(tab_row)
                       ,p_txn_rec             => p_txn_tbl(inst_tab_row)
                       ,x_return_status       => x_return_status
                       ,x_msg_count           => x_msg_count
                       ,x_msg_data            => x_msg_data
                       ,p_called_from_grp     => fnd_api.g_true
                      );

                      IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                          csi_gen_utility_pvt.put_line( ' Error from CSI_PRICING_ATTRIBS_PUB..');
                          l_msg_index := 1;
                          l_msg_count := x_msg_count;
                          WHILE l_msg_count > 0 LOOP
                                x_msg_data := FND_MSG_PUB.GET
                                    (  l_msg_index,
                                       FND_API.G_FALSE        );
                                csi_gen_utility_pvt.put_line( ' MESSAGE DATA = '||x_msg_data);
                                l_msg_index := l_msg_index + 1;
                                l_msg_count := l_msg_count - 1;
                          END LOOP;
                          l_iface_error_text := substr(x_msg_data,1,2000);
                          RAISE SKIP_ERROR;
		       ELSE
		          l_build_ctr := l_build_pricing_tbl.count + 1;
		          l_build_pricing_tbl(l_build_ctr) := p_pricing_attrib_tbl(tab_row);
                      END IF;
                   END IF; -- Pricing for the current instance
                END IF; -- Pricing row EXISTS.
              END LOOP;
           END IF; --p_pricing_attrib_tbl.count > 0
       END IF;

       -- Call create_extended_attribs to associate any extended attributes
       -- to the item instance
       l_temp_ext_tbl.DELETE;
       l_ext_count := 0;
       IF ((p_instance_tbl(inst_tab_row).instance_id IS NOT NULL) AND
           (p_instance_tbl(inst_tab_row).instance_id <> FND_API.G_MISS_NUM)) THEN
           IF (p_ext_attrib_values_tbl.count > 0) THEN
               FOR tab_row IN p_ext_attrib_values_tbl.FIRST .. p_ext_attrib_values_tbl.LAST
               LOOP
                 IF p_ext_attrib_values_tbl.EXISTS(tab_row) THEN
                    IF p_ext_attrib_values_tbl(tab_row).parent_tbl_index = inst_tab_row THEN
                       p_ext_attrib_values_tbl(tab_row).instance_id := p_instance_tbl(inst_tab_row).instance_id;
                       IF p_ext_attrib_values_tbl(tab_row).active_start_date IS NULL OR
                          p_ext_attrib_values_tbl(tab_row).active_start_date = FND_API.G_MISS_DATE THEN
                          p_ext_attrib_values_tbl(tab_row).active_start_date := SYSDATE;
                       END IF;
                       --
                       l_ext_count_rec.ext_count := l_ext_count_rec.ext_count + 1;
                       l_ext_id_tbl(l_ext_count_rec.ext_count).instance_id := p_instance_tbl(inst_tab_row).instance_id;
                       l_ext_id_tbl(l_ext_count_rec.ext_count).inv_item_id := p_instance_tbl(inst_tab_row).inventory_item_id;
                       l_ext_id_tbl(l_ext_count_rec.ext_count).inv_mast_org_id := p_instance_tbl(inst_tab_row).inv_master_organization_id;
                       l_ext_id_tbl(l_ext_count_rec.ext_count).valid_flag := 'Y';
                       --
                       l_ext_count := l_ext_count + 1;
                       l_temp_ext_tbl(l_ext_count) := p_ext_attrib_values_tbl(tab_row);
                       --
                       IF NOT ( Check_Ext_Rules
                                    ( p_ext_tbl        => l_temp_ext_tbl
                                     ,p_ext_rec        => p_ext_attrib_values_tbl(tab_row)
                                     ,p_start_date     => p_instance_tbl(inst_tab_row).active_start_date
                                     ,p_end_date       => p_instance_tbl(inst_tab_row).active_end_date
                                  ) ) THEN
                          l_msg_index := 1;
                          FND_MSG_PUB.Count_And_Get
                              (p_count  =>  x_msg_count,
                               p_data   =>  x_msg_data
                              );
                          l_msg_count := x_msg_count;
                          WHILE l_msg_count > 0 LOOP
                              x_msg_data := FND_MSG_PUB.GET
                                         (  l_msg_index,
                                            FND_API.G_FALSE        );
                                     csi_gen_utility_pvt.put_line( ' MESSAGE DATA = '||x_msg_data);
                                     l_msg_index := l_msg_index + 1;
                                     l_msg_count := l_msg_count - 1;
                          END LOOP;
                          l_iface_error_text := substr(x_msg_data,1,2000);
                          RAISE SKIP_ERROR;
                       END IF;
                       --
                       csi_item_instance_pvt.create_extended_attrib_values
                       (
                         p_api_version         => p_api_version
                        ,p_commit              => fnd_api.g_false
                        ,p_init_msg_list       => p_init_msg_list
                        ,p_validation_level    => p_validation_level
                        ,p_ext_attrib_rec      => p_ext_attrib_values_tbl(tab_row)
                        ,p_txn_rec             => p_txn_tbl(inst_tab_row)
                        ,x_return_status       => x_return_status
                        ,x_msg_count           => x_msg_count
                        ,x_msg_data            => x_msg_data
                        ,p_ext_id_tbl          => l_ext_id_tbl
                        ,p_ext_count_rec       => l_ext_count_rec
                        ,p_ext_attr_tbl        => l_ext_attr_tbl
                        ,p_ext_cat_tbl         => l_ext_cat_tbl
                        ,p_called_from_grp     => fnd_api.g_true
                       );

                       IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                           csi_gen_utility_pvt.put_line( ' Error from CSI_EXTENDED_ATTRIBS_PUB..');
                           l_msg_index := 1;
                           l_msg_count := x_msg_count;
                           WHILE l_msg_count > 0 LOOP
                               x_msg_data := FND_MSG_PUB.GET
                                         (  l_msg_index,
                                            FND_API.G_FALSE        );
                                     csi_gen_utility_pvt.put_line( ' MESSAGE DATA = '||x_msg_data);
                                     l_msg_index := l_msg_index + 1;
                                     l_msg_count := l_msg_count - 1;
                           END LOOP;
                           l_iface_error_text := substr(x_msg_data,1,2000);
                           RAISE SKIP_ERROR;
		        ELSE
		           l_build_ctr := l_build_ext_tbl.count + 1;
		           l_build_ext_tbl(l_build_ctr) := p_ext_attrib_values_tbl(tab_row);
                       END IF;
                    END IF; -- Ext attribs for the current instance
                 END IF; -- Ext attribs EXISTS.
                END LOOP;
           END IF; --p_ext_attrib_values_tbl.count > 0
       END IF;

       -- Call create_asset_assignments to associate any assets associated
       -- to the item instance
       IF ((p_instance_tbl(inst_tab_row).instance_id IS NOT NULL) AND
           (p_instance_tbl(inst_tab_row).instance_id <> FND_API.G_MISS_NUM)) THEN
           IF (p_asset_assignment_tbl.count > 0) THEN
               FOR tab_row IN p_asset_assignment_tbl.FIRST .. p_asset_assignment_tbl.LAST
               LOOP
                 IF p_asset_assignment_tbl.EXISTS(tab_row) THEN
                    IF p_asset_assignment_tbl(tab_row).parent_tbl_index = inst_tab_row THEN
                       p_asset_assignment_tbl(tab_row).instance_id := p_instance_tbl(inst_tab_row).instance_id;
                       IF p_asset_assignment_tbl(tab_row).active_start_date IS NULL OR
                          p_asset_assignment_tbl(tab_row).active_start_date = FND_API.G_MISS_DATE THEN
                          p_asset_assignment_tbl(tab_row).active_start_date := SYSDATE;
                       END IF;
                       --
                       IF NOT ( Check_Asset_Rules
                                   ( p_asset_rec       => p_asset_assignment_tbl(tab_row)
                                    ,p_start_date     => p_instance_tbl(inst_tab_row).active_start_date
                                    ,p_end_date       => p_instance_tbl(inst_tab_row).active_end_date
                                  ) ) THEN
                          l_msg_index := 1;
                          FND_MSG_PUB.Count_And_Get
                              (p_count  =>  x_msg_count,
                               p_data   =>  x_msg_data
                              );
                          l_msg_count := x_msg_count;
                          WHILE l_msg_count > 0 LOOP
                                     x_msg_data := FND_MSG_PUB.GET
                                         (  l_msg_index,
                                            FND_API.G_FALSE        );
                                     csi_gen_utility_pvt.put_line( ' MESSAGE DATA = '||x_msg_data);
                                     l_msg_index := l_msg_index + 1;
                                     l_msg_count := l_msg_count - 1;
                          END LOOP;
                          l_iface_error_text := substr(x_msg_data,1,2000);
                          RAISE SKIP_ERROR;
                       END IF;
                       --
                       -- Asset Open Interface should have this validation as False
                       --
                       -- Since the item instance is not yet created, the set_fa_sync_flag routine
                       -- that looks at csi_item_instances cannot be used directly. Hence calling the
                       -- same with the location_id.
                       --
                       IF p_asset_assignment_tbl(tab_row).fa_sync_validation_reqd = fnd_api.g_true THEN
                          IF p_instance_tbl(inst_tab_row).location_type_code = 'HZ_PARTY_SITES' THEN
                             Begin
                                select location_id
                                into l_location_id
                                from HZ_PARTY_SITES
                                where party_site_id = p_instance_tbl(inst_tab_row).location_id;
                             Exception
                                when no_data_found then
                                   l_location_id := null;
                             End;
                          ELSE
                             l_location_id := p_instance_tbl(inst_tab_row).location_id;
                          END IF;
                          -- Pass this Location ID to Set_Sync_Flag and validate against CSI_A_LOCATIONS
                          IF l_location_id IS NOT NULL THEN
			     csi_asset_pvt.set_fa_sync_flag (
			       px_instance_asset_rec => p_asset_assignment_tbl(tab_row),
			       p_location_id         => l_location_id,
			       x_return_status       => x_return_status,
			       x_error_msg           => x_msg_data);
                          END IF;
                          --
                          -- The above routine just tries to set the FA Sync Flag. It doesn't retun any error
                       END IF; -- Validation_reqd check
                       --
                       csi_asset_pvt.create_instance_asset
                       (
                         p_api_version         => p_api_version
                        ,p_commit              => fnd_api.g_false
                        ,p_init_msg_list       => p_init_msg_list
                        ,p_instance_asset_rec  => p_asset_assignment_tbl(tab_row)
                        ,p_txn_rec             => p_txn_tbl(inst_tab_row)
                        ,x_return_status       => x_return_status
                        ,x_msg_count           => x_msg_count
                        ,x_msg_data            => x_msg_data
                        ,p_lookup_tbl          => l_asset_lookup_tbl
                        ,p_asset_count_rec     => l_asset_count_rec
                        ,p_asset_id_tbl        => l_asset_id_tbl
                        ,p_asset_loc_tbl       => l_asset_loc_tbl
                        ,p_called_from_grp     => fnd_api.g_true
                       );

                       IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                           csi_gen_utility_pvt.put_line( ' Error from CSI_ASSET_PVT..');
                           l_msg_index := 1;
                           l_msg_count := x_msg_count;
                           WHILE l_msg_count > 0 LOOP
                              x_msg_data := FND_MSG_PUB.GET
                                         (  l_msg_index,
                                            FND_API.G_FALSE        );
                              csi_gen_utility_pvt.put_line( ' MESSAGE DATA = '||x_msg_data);
                              l_msg_index := l_msg_index + 1;
                              l_msg_count := l_msg_count - 1;
                           END LOOP;
                           l_iface_error_text := substr(x_msg_data,1,2000);
                           RAISE SKIP_ERROR;
		        ELSE
		           l_build_ctr := l_build_asset_tbl.count + 1;
		           l_build_asset_tbl(l_build_ctr) := p_asset_assignment_tbl(tab_row);
                        END IF;
                    END IF; -- Asset for the current instance
                 END IF; -- Asset row EXISTS.
                END LOOP;
           END IF; --p_asset_assignment_tbl.count > 0
       END IF;
       --
       -- Version Label tbl will be directly buil from Instance tbl
       --
       -- Call to contracts will be made after Bulk Insert
       --
       -- Update the Interface Table with PROCESSED status.
       p_instance_tbl(inst_tab_row).processed_flag := 'P'; -- Processed
       l_grp_error_tbl(inst_tab_row).process_status := 'S'; -- Success
       l_grp_error_tbl(inst_tab_row).error_message := NULL;
       l_error_array(inst_tab_row) := NULL;
       l_status_array(inst_tab_row) := 'P';
       l_inst_id_array(inst_tab_row) := p_instance_tbl(inst_tab_row).instance_id;

       --
       l_bulk_inst_count := l_bulk_inst_count + 1;
       l_bulk_inst_tbl(l_bulk_inst_count) := p_instance_tbl(inst_tab_row);
       IF p_txn_tbl(inst_tab_row).transaction_id IS NULL OR
          p_txn_tbl(inst_tab_row).transaction_id = FND_API.G_MISS_NUM THEN
          select CSI_TRANSACTIONS_S.nextval
          into p_txn_tbl(inst_tab_row).transaction_id
          from sys.dual;
       END IF;
       --
       l_bulk_txn_tbl(l_bulk_inst_count) := p_txn_tbl(inst_tab_row);
       --
       select CSI_I_VERSION_LABELS_S.nextval
       into l_bulk_version_label_tbl(l_bulk_inst_count).version_label_id
       from sys.dual;
       --
       l_bulk_version_label_tbl(l_bulk_inst_count).version_label := p_instance_tbl(inst_tab_row).version_label;
       l_bulk_version_label_tbl(l_bulk_inst_count).active_start_date := p_instance_tbl(inst_tab_row).active_start_date;
       l_bulk_version_label_tbl(l_bulk_inst_count).date_time_stamp := SYSDATE;
       l_bulk_version_label_tbl(l_bulk_inst_count).instance_id := p_instance_tbl(inst_tab_row).instance_id;
       l_bulk_version_label_tbl(l_bulk_inst_count).description := p_instance_tbl(inst_tab_row).version_label_description;
       --
       Build_Instance_History
          ( p_inst_hist_tbl => l_bulk_inst_hist_tbl
           ,p_inst_rec => l_bulk_inst_tbl(l_bulk_inst_count)
           ,p_txn_id => l_bulk_txn_tbl(l_bulk_inst_count).transaction_id
          );
       --
       Build_Ver_Label_History
          (
            p_ver_label_history_tbl => l_bulk_ver_label_hist_tbl
           ,p_version_label_rec     => l_bulk_version_label_tbl(l_bulk_inst_count)
           ,p_txn_id                => l_bulk_txn_tbl(l_bulk_inst_count).transaction_id
          );
       --
       IF l_build_party_tbl.count > 0 THEN
          FOR pty_row in l_build_party_tbl.FIRST .. l_build_party_tbl.LAST LOOP
             IF l_build_party_tbl(pty_row).contact_flag = 'Y' THEN
                l_build_party_tbl(pty_row).contact_ip_id :=
                       p_party_tbl(l_build_party_tbl(pty_row).contact_parent_tbl_index).instance_party_id;
                FOR src_pty in  p_party_tbl.FIRST .. p_party_tbl.LAST LOOP
                   IF p_party_tbl(src_pty).instance_party_id = l_build_party_tbl(pty_row).instance_party_id
                   THEN
                      p_party_tbl(src_pty).contact_ip_id := l_build_party_tbl(pty_row).contact_ip_id;
                      EXIT;
                   END IF;
                END LOOP;
             END IF;
             l_bulk_pty_count := l_bulk_pty_count + 1;
             l_bulk_party_tbl(l_bulk_pty_count) := l_build_party_tbl(pty_row);
             --
             IF l_build_party_tbl(pty_row).relationship_type_code = 'OWNER' THEN
                l_owner_count := l_owner_count + 1;
                l_owner_pty_acct_tbl(l_owner_count).instance_id := l_build_party_tbl(pty_row).instance_id;
                l_owner_pty_acct_tbl(l_owner_count).party_source_table :=
                                  l_build_party_tbl(pty_row).party_source_table;
                l_owner_pty_acct_tbl(l_owner_count).party_id := l_build_party_tbl(pty_row).party_id;
                l_owner_pty_acct_tbl(l_owner_count).account_id := NULL;
                l_owner_pty_acct_tbl(l_owner_count).vld_organization_id :=
                                           p_instance_tbl(inst_tab_row).vld_organization_id;
             END IF;
             --
             Build_Party_History
                ( p_party_hist_tbl => l_bulk_party_hist_tbl
                 ,p_party_rec => l_bulk_party_tbl(l_bulk_pty_count)
                 ,p_txn_id => l_bulk_txn_tbl(l_bulk_inst_count).transaction_id
                );
          END LOOP;
       END IF;
       --
       IF l_build_account_tbl.count > 0 THEN
          FOR acct_row in l_build_account_tbl.FIRST .. l_build_account_tbl.LAST LOOP
             l_bulk_acct_count := l_bulk_acct_count + 1;
             l_bulk_acct_tbl(l_bulk_acct_count) := l_build_account_tbl(acct_row);
             --
             IF l_build_account_tbl(acct_row).relationship_type_code = 'OWNER' THEN
                l_owner_pty_acct_tbl(l_owner_count).account_id :=
                           l_build_account_tbl(acct_row).party_account_id;
             END IF;
             --
             Build_Account_History
                ( p_acct_hist_tbl => l_bulk_acct_hist_tbl
                 ,p_acct_rec => l_bulk_acct_tbl(l_bulk_acct_count)
                 ,p_txn_id => l_bulk_txn_tbl(l_bulk_inst_count).transaction_id
                );
          END LOOP; -- Account Loop
       END IF; -- Account_tbl count check
       --
       IF l_build_org_tbl.count > 0 THEN
          FOR org_row in l_build_org_tbl.FIRST .. l_build_org_tbl.LAST LOOP
             l_bulk_org_count := l_bulk_org_count + 1;
             l_bulk_org_units_tbl(l_bulk_org_count) := l_build_org_tbl(org_row);
             --
             Build_Org_History
               ( p_org_hist_tbl    => l_bulk_org_units_hist_tbl
                ,p_org_rec         => l_bulk_org_units_tbl(l_bulk_org_count)
                ,p_txn_id          => l_bulk_txn_tbl(l_bulk_inst_count).transaction_id
               );
          END LOOP;
       END IF;
       --
       IF l_build_pricing_tbl.count > 0 THEN
          FOR pricing_row in l_build_pricing_tbl.FIRST .. l_build_pricing_tbl.LAST LOOP
             l_bulk_pricing_count := l_bulk_pricing_count + 1;
             l_bulk_pricing_tbl(l_bulk_pricing_count) := l_build_pricing_tbl(pricing_row);
             --
             Build_Pricing_History
               (
                 p_pricing_hist_tbl  => l_bulk_pricing_hist_tbl
                ,p_pricing_rec       => l_bulk_pricing_tbl(l_bulk_pricing_count)
                ,p_txn_id            => l_bulk_txn_tbl(l_bulk_inst_count).transaction_id
               );
          END LOOP;
       END IF;
       --
       IF l_build_ext_tbl.count > 0 THEN
          FOR ext_row in l_build_ext_tbl.FIRST .. l_build_ext_tbl.LAST LOOP
             l_bulk_ext_count := l_bulk_ext_count + 1;
             l_bulk_ext_attrib_values_tbl(l_bulk_ext_count) := l_build_ext_tbl(ext_row);
             -- Build History
             Build_Ext_Attr_History
                ( p_ext_attr_hist_tbl => l_bulk_ext_attrib_val_hist_tbl
                 ,p_ext_attr_rec    => l_bulk_ext_attrib_values_tbl(l_bulk_ext_count)
                 ,p_txn_id => l_bulk_txn_tbl(l_bulk_inst_count).transaction_id
                );
          END LOOP;
       END IF;
       --
       IF l_build_asset_tbl.count > 0 THEN
          FOR asset_row in l_build_asset_tbl.FIRST .. l_build_asset_tbl.LAST LOOP
             l_bulk_asset_count := l_bulk_asset_count + 1;
             l_bulk_asset_tbl(l_bulk_asset_count) := l_build_asset_tbl(asset_row);
             -- Build History
             Build_Asset_History
                ( p_asset_hist_tbl   => l_bulk_asset_hist_tbl
                 ,p_asset_rec        => l_bulk_asset_tbl(l_bulk_asset_count)
                 ,p_txn_id => l_bulk_txn_tbl(l_bulk_inst_count).transaction_id
                );
          END LOOP;
       END IF;

    -- Calling Post Vertical User Hook
        BEGIN

         IF JTF_USR_HKS.Ok_to_execute( G_PKG_NAME, l_api_name, 'A', 'V' )  THEN
           csi_gen_utility_pvt.put_line('Calling  CSI_ITEM_INSTANCE_VUHK.Create_Item_Instance_Post ..');
            CSI_ITEM_INSTANCE_VUHK.Create_Item_Instance_Post
               (
                p_api_version               => 1.0
                ,p_commit                   => fnd_api.g_false
                ,p_init_msg_list            => fnd_api.g_false
                ,p_validation_level         => fnd_api.g_valid_level_full
                ,p_instance_rec             => p_instance_tbl(inst_tab_row)
                ,p_ext_attrib_values_tbl    => p_ext_attrib_values_tbl
                ,p_party_tbl                => l_temp_party_tbl
                ,p_account_tbl              => p_account_tbl
                ,p_pricing_attrib_tbl       => p_pricing_attrib_tbl
                ,p_org_assignments_tbl      => p_org_assignments_tbl
                ,p_asset_assignment_tbl     => p_asset_assignment_tbl
                ,p_txn_rec                  => p_txn_tbl(inst_tab_row)
                ,x_return_status            => x_return_status
                ,x_msg_count                => x_msg_count
                ,x_msg_data                 => x_msg_data
          );

          IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
              l_msg_index := 1;
              l_msg_count := x_msg_count;
              WHILE l_msg_count > 0 LOOP
                      x_msg_data := FND_MSG_PUB.GET
                                  (  l_msg_index,
                                     FND_API.G_FALSE );
                  csi_gen_utility_pvt.put_line('ERROR FROM CSI_ITEM_INSTANCE_VUHK.Create_Item_Instance_Post API ');
                  csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
                  l_msg_index := l_msg_index + 1;
                  l_msg_count := l_msg_count - 1;
              END LOOP;
            RAISE FND_API.G_EXC_ERROR;
          END IF;
            --
         END IF;
      EXCEPTION
        WHEN OTHERS THEN
           csi_gen_utility_pvt.put_line('ERROR FROM JTF_USR_HKS.Ok_to_execute API Create Post Vertical');
           RAISE FND_API.G_EXC_ERROR;
      END;
     -- End of POST User Hooks

    EXCEPTION
      WHEN PROCESS_NEXT THEN
         NULL;
      WHEN SKIP_ERROR THEN
           ROLLBACK TO create_item_instance;
           p_instance_tbl(inst_tab_row).processed_flag := 'E'; -- Error
           l_grp_error_tbl(inst_tab_row).process_status := 'E';
           l_grp_error_tbl(inst_tab_row).error_message := l_iface_error_text;
           l_error_array(inst_tab_row) := l_iface_error_text;
           l_status_array(inst_tab_row) := 'E';
           l_inst_id_array(inst_tab_row) := NULL;
    END;
  END LOOP; --instance_tbl
  --
  l_temp_party_tbl.DELETE;
  l_temp_account_tbl.DELETE;
  l_temp_org_tbl.DELETE;
  l_temp_asset_tbl.DELETE;
  l_temp_ext_tbl.DELETE;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  --
  --  l_txn_exists_tbl contains those transactions exist in CSI_TRANSACTIONS
  --  x_bulk_txn_tbl contains the transactions that need to be inserted in CSI_TRANSACTIONS
  IF l_bulk_inst_tbl.count > 0 THEN
     -- Loop thru' the l_bulk_txn_tbl and eliminate duplicate txn id's.
     FOR j in l_bulk_txn_tbl.FIRST .. l_bulk_txn_tbl.LAST LOOP
        l_exists := 'N';
        IF l_txn_exists_tbl.count > 0 THEN
           FOR m in l_txn_exists_tbl.FIRST .. l_txn_exists_tbl.LAST LOOP
              IF l_txn_exists_tbl(m) = l_bulk_txn_tbl(j).transaction_id THEN
                 l_exists := 'Y';
                 exit;
              END IF;
           END LOOP;
        END IF;
        --
	IF l_exists <> 'Y' THEN
	   IF x_bulk_txn_tbl.count > 0 THEN
	      FOR k in x_bulk_txn_tbl.FIRST .. x_bulk_txn_tbl.LAST LOOP
                 IF l_bulk_txn_tbl(j).transaction_id = x_bulk_txn_tbl(k).transaction_id THEN
		    l_exists := 'Y';
		    exit;
		 END IF;
              END LOOP;
	   END IF;
	END IF;
        --
        IF l_exists <> 'Y' THEN
           csi_gen_utility_pvt.put_line('Checking against csi_transactions..');
	   Begin
	      select 'Y'
	      into l_exists
	      from csi_transactions
	      where transaction_id = l_bulk_txn_tbl(j).transaction_id;
              --
              l_txn_ctr := l_txn_exists_tbl.count;
              l_txn_ctr := l_txn_ctr + 1;
              l_txn_exists_tbl(l_txn_ctr) := l_bulk_txn_tbl(j).transaction_id;
	   Exception
	      when no_data_found then
		 l_exists := 'N';
	   End;
	   --
	   IF l_exists <> 'Y' THEN
	      l_txn_ctr := x_bulk_txn_tbl.count;
	      l_txn_ctr := l_txn_ctr + 1;
	      x_bulk_txn_tbl(l_txn_ctr) := l_bulk_txn_tbl(j);
	   END IF;
        END IF;
     END LOOP;
     --
     --
     csi_gen_utility_pvt.put_line('Transaction Tbl count before Bulk Insert is '
                                                    ||to_char(x_bulk_txn_tbl.count));
     Bulk_Insert
       ( p_inst_tbl           =>  l_bulk_inst_tbl
        ,p_txn_tbl            =>  x_bulk_txn_tbl
        ,p_inst_hist_tbl      =>  l_bulk_inst_hist_tbl
        ,p_version_label_tbl  =>  l_bulk_version_label_tbl
        ,p_ver_label_hist_tbl =>  l_bulk_ver_label_hist_tbl
        ,p_party_tbl          =>  l_bulk_party_tbl
        ,p_party_hist_tbl     =>  l_bulk_party_hist_tbl
        ,p_account_tbl        =>  l_bulk_acct_tbl
        ,p_acct_hist_tbl      =>  l_bulk_acct_hist_tbl
        ,p_owner_pty_acct_tbl =>  l_owner_pty_acct_tbl
        ,p_org_units_tbl      =>  l_bulk_org_units_tbl
        ,p_org_units_hist_tbl =>  l_bulk_org_units_hist_tbl
        ,p_pricing_tbl        =>  l_bulk_pricing_tbl
        ,p_pricing_hist_tbl   =>  l_bulk_pricing_hist_tbl
        ,p_ext_attr_values_tbl => l_bulk_ext_attrib_values_tbl
        ,p_ext_attr_val_hist_tbl => l_bulk_ext_attrib_val_hist_tbl
        ,p_asset_tbl          =>  l_bulk_asset_tbl
        ,p_asset_hist_tbl     =>  l_bulk_asset_hist_tbl
        ,x_return_status      =>  x_return_status
       );
     --
     IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
        csi_gen_utility_pvt.put_line('Error from Bulk Insert '||substr(sqlerrm,1,200));
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
     --
     csi_gen_utility_pvt.put_line('End of Bulk Insert...');
     --
     -- Call Counters and Instantiate EAM Object
     FOR inst_row in p_instance_tbl.FIRST .. p_instance_tbl.LAST LOOP
        IF p_instance_tbl(inst_row).processed_flag = 'P' THEN
           FOR item_row in l_item_attribute_tbl.FIRST .. l_item_attribute_tbl.LAST LOOP
              IF p_instance_tbl(inst_row).inventory_item_id = l_item_attribute_tbl(item_row).inventory_item_id AND
                 p_instance_tbl(inst_row).vld_organization_id = l_item_attribute_tbl(item_row).organization_id THEN
                 l_serial_control := l_item_attribute_tbl(item_row).serial_number_control_code;
                 l_eam_item_type := l_item_attribute_tbl(item_row).eam_item_type;
                 exit;
              END IF;
           END LOOP;
           --
           -- Call counters if Qty is 1 and other conditions satisfy
           IF p_instance_tbl(inst_row).quantity = 1 THEN
	      IF NOT((l_serial_control IN (1,6)) AND
		     (p_instance_tbl(inst_row).location_type_code = 'INVENTORY')) THEN
		 l_exists_flag := 'N';
		 l_ctr_exists_flag := 'N';
		 l_ctr_instantiate := 'N';
		 IF l_ctr_tbl.count > 0 THEN
		    FOR ctr_row in l_ctr_tbl.FIRST .. l_ctr_tbl.LAST LOOP
		       IF p_instance_tbl(inst_row).inventory_item_id = l_ctr_tbl(ctr_row).inventory_item_id THEN
			  l_ctr_exists_flag := l_ctr_tbl(ctr_row).ctr_template_exists;
			  l_exists_flag := 'Y';
			  exit;
		       END IF;
		    END LOOP;
		    --
		    IF l_ctr_exists_flag = 'Y' THEN
		       l_ctr_instantiate := 'Y';
		    ELSE
		       l_ctr_instantiate := 'N';
		    END IF;
		 END IF;
		 --
		 IF l_exists_flag = 'N' THEN
		    l_ctr_count := l_ctr_count + 1;
		    l_ctr_tbl(l_ctr_count).inventory_item_id := p_instance_tbl(inst_row).inventory_item_id;
		    -- R12 Project. We no longer use CS counters
		    l_ctr_group_id := 0;
		    Begin
                       SELECT COUNT(*)
                       INTO l_ctr_group_id
                       FROM csi_ctr_item_associations
                       WHERE inventory_item_id = p_instance_tbl(inst_row).inventory_item_id
                       AND ROWNUM=1;
		    End;
		    --
		    IF l_ctr_group_id > 0 THEN
		       l_ctr_tbl(l_ctr_count).ctr_template_exists := 'Y';
		       l_ctr_instantiate := 'Y';
		    ELSE
		       -- Added code for Bug 9249563
				l_base_item_id := null;
				 Begin
					select base_item_id
					into l_base_item_id
					from MTL_SYSTEM_ITEMS_B
					where inventory_item_id = p_instance_tbl(inst_row).inventory_item_id
					and   organization_id = p_instance_tbl(inst_row).vld_organization_id;
				 Exception
					when no_data_found then
					   null;
					when others then
					   null;
				 End;
				 --
				 IF l_base_item_id is not null THEN
				   l_counter_flag := 0;
				   For ctr_rec in CTR_GROUP(l_base_item_id)
				   Loop
					  Begin
					  IF(ctr_rec.group_id is not null) THEN
					    l_ctr_item_associations_rec.group_id          := ctr_rec.group_id;
					  END IF;
					  IF(ctr_rec.COUNTER_ID is not null) THEN
					    l_ctr_item_associations_rec.COUNTER_ID := ctr_rec.COUNTER_ID;
					  END IF;
					  l_ctr_item_associations_rec.inventory_item_id := p_instance_tbl(inst_row).inventory_item_id;
					  if(ctr_rec.associated_to_group = 'Y') then
					   l_ctr_item_associations_rec.associated_to_group := ctr_rec.associated_to_group;
					  end if;

					   csi_counter_template_pub.create_item_association
						   (p_api_version               => 1.0
						   ,p_commit                    => fnd_api.g_false
						   ,p_init_msg_list             => fnd_api.g_false
						   ,p_validation_level          => p_validation_level
						   ,p_ctr_item_associations_rec => l_ctr_item_associations_rec
						   ,x_return_status             => x_return_status
						   ,x_msg_count                 => x_msg_count
						   ,x_msg_data                  => x_msg_data
						   );
						l_counter_flag    := 1;
				      End;
				   End Loop;

				   IF l_counter_flag <> 0 THEN
						l_ctr_tbl(l_ctr_count).ctr_template_exists := 'Y';
						l_ctr_instantiate := 'Y';
					ELSE
						l_ctr_tbl(l_ctr_count).ctr_template_exists := 'N';
						l_ctr_instantiate := 'N';
				   END IF;
				 END IF;
		    END IF;
		 END IF;
		 --
		 IF l_ctr_instantiate = 'Y' THEN
		    IF nvl(l_call_counters,'N') = 'Y' THEN
		       csi_counter_template_pub.autoinstantiate_counters
			  ( p_api_version                => 1.0
			   ,p_init_msg_list              => FND_API.G_TRUE
			   ,p_commit                     => FND_API.G_FALSE
			   ,x_return_status              => x_return_status
			   ,x_msg_count                  => x_msg_count
			   ,x_msg_data                   => x_msg_data
			   ,p_source_object_id_template  => p_instance_tbl(inst_row).inventory_item_id
			   ,p_source_object_id_instance  => p_instance_tbl(inst_row).instance_id
                           ,x_ctr_id_template            => l_ctr_id_template
                           ,x_ctr_id_instance            => l_ctr_id_instance
                           ,x_ctr_grp_id_template        => l_ctr_grp_id_template
                           ,x_ctr_grp_id_instance        => l_ctr_grp_id_instance
			   ,p_organization_id            => p_instance_tbl(inst_row).vld_organization_id
			  );

			  --
			  IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
			     l_msg_index := 1;
			     l_msg_count := x_msg_count;
			     WHILE l_msg_count > 0 LOOP
				x_msg_data := FND_MSG_PUB.GET
					   (  l_msg_index,
					      FND_API.G_FALSE        );
				l_msg_index := l_msg_index + 1;
				l_msg_count := l_msg_count - 1;
			     END LOOP;
			     l_iface_error_text := substr(x_msg_data,1,2000);
			     p_instance_tbl(inst_row).processed_flag := 'E';
			     l_grp_error_tbl(inst_row).error_message := l_iface_error_text;
			     l_grp_error_tbl(inst_row).process_status := 'E';
			     l_error_array(inst_row) := l_iface_error_text;
			     l_status_array(inst_row) := 'E';
			     l_inst_id_array(inst_row) := NULL;
			     l_del_count := l_del_count + 1;
			     l_del_inst_tbl(l_del_count) := p_instance_tbl(inst_row).instance_id;
			     l_del_txn_tbl(l_del_count) := p_txn_tbl(inst_row).transaction_id;
			  END IF;
		    ELSE
		       -- Build the PL/SQL table for Inserting into Counters Temp table
		       l_counter := l_counter + 1;
		       select CSI_CTR_UPLOAD_INSTANCES_S.nextval
		       into l_ctr_id(l_counter) from sys.dual;
		       --
		       l_ctr_ins_id(l_counter) := p_instance_tbl(inst_row).instance_id;
		       l_ctr_item_id(l_counter) := p_instance_tbl(inst_row).inventory_item_id;
		       l_ctr_org_id(l_counter) := p_instance_tbl(inst_row).vld_organization_id;
		    END IF;
		 END IF; -- l_ctr_instantiate is Y
	      END IF;
           END IF; -- Qty = 1 check for calling counters
           --
           IF csi_item_instance_vld_pvt.Check_for_EAM_Item
                  ( p_inventory_item_id   => p_instance_tbl(inst_row).inventory_item_id
                   ,p_organization_id     => p_instance_tbl(inst_row).vld_organization_id
                   ,p_eam_item_type       => l_eam_item_type
                  ) THEN
	      EAM_Objectinstantiation_Pub.Instantiate_Object
		  (  p_api_version             => 1.0
		    ,p_init_msg_list           => fnd_api.g_true
		    ,p_commit                  => fnd_api.g_false
		    ,p_validation_level        => p_validation_level
		    ,p_maintenance_object_id   => p_instance_tbl(inst_row).instance_id
		    ,p_maintenance_object_type => 3
		    ,x_return_status           => x_return_status
		    ,x_msg_count               => x_msg_count
		    ,x_msg_data                => x_msg_data
		  );
	      IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
		 l_msg_index := 1;
		 l_msg_count := x_msg_count;
		 WHILE l_msg_count > 0 LOOP
		    x_msg_data := FND_MSG_PUB.GET
			       (  l_msg_index,
				  FND_API.G_FALSE        );
		    l_msg_index := l_msg_index + 1;
		    l_msg_count := l_msg_count - 1;
		 END LOOP;
		 l_iface_error_text := substr(x_msg_data,1,2000);
		 p_instance_tbl(inst_row).processed_flag := 'E';
		 l_grp_error_tbl(inst_row).error_message := l_iface_error_text;
		 l_grp_error_tbl(inst_row).process_status := 'E';
		 l_error_array(inst_row) := l_iface_error_text;
		 l_status_array(inst_row) := 'E';
		 l_inst_id_array(inst_row) := NULL;
		 l_del_count := l_del_count + 1;
		 l_del_inst_tbl(l_del_count) := p_instance_tbl(inst_row).instance_id;
		 l_del_txn_tbl(l_del_count) := p_txn_tbl(inst_row).transaction_id;
	      END IF;
           END IF; -- Check for EAM Item
        END IF; -- Instance is Valid check
     END LOOP;
     --
     IF l_ctr_id.count > 0 THEN
	BEGIN
           FORALL i in 1 .. l_ctr_id.count
              INSERT INTO CSI_CTR_UPLOAD_INSTANCES
                 (
                    UPLOAD_INSTANCE_ID
                   ,SOURCE_OBJECT_ID
                   ,SOURCE_OBJECT_CODE
                   ,ITEM_ID
                   ,ORG_ID
                   ,LAST_UPDATE_DATE
                   ,LAST_UPDATED_BY
                   ,LAST_UPDATE_LOGIN
                   ,CREATION_DATE
                   ,CREATED_BY
                 )
              VALUES
                 (
                    l_ctr_id(i)
                   ,l_ctr_ins_id(i)
                   ,'CP'
                   ,l_ctr_item_id(i)
                   ,l_ctr_org_id(i)
                   ,sysdate
                   ,l_user_id
                   ,l_login_id
                   ,sysdate
                   ,l_user_id
                 );
	EXCEPTION
	   WHEN OTHERS THEN
	      NULL;
	END;
     END IF;
     -- Call contracts
     csi_gen_utility_pvt.put_line('Calling contracts...');
     --
     FOR inst_row in p_instance_tbl.FIRST .. p_instance_tbl.LAST LOOP
        IF p_instance_tbl(inst_row).processed_flag = 'P' AND
           p_instance_tbl(inst_row).call_contracts <> fnd_api.g_false THEN -- honoring the call_contracts
           IF l_owner_pty_acct_tbl.count > 0 THEN
              l_owner_party_id := NULL;
              FOR pty_row in l_owner_pty_acct_tbl.FIRST .. l_owner_pty_acct_tbl.LAST LOOP
                 IF p_instance_tbl(inst_row).instance_id = l_owner_pty_acct_tbl(pty_row).instance_id THEN
                    l_owner_party_id := l_owner_pty_acct_tbl(pty_row).party_id;
                    l_vld_organization_id := l_owner_pty_acct_tbl(pty_row).vld_organization_id;
                    exit;
                 END IF;
              END LOOP;
           END IF;
           --
           IF l_owner_party_id IS NOT NULL AND
              l_owner_party_id <> FND_API.G_MISS_NUM AND
              l_owner_party_id <> l_internal_party_id THEN
	      -- Call API
	      l_transaction_type:= 'NEW';

          IF (p_instance_tbl(inst_row).call_contracts <> fnd_api.g_false AND p_instance_tbl(inst_row).call_contracts <> 'N') --added by HYONLEE on 01/19/10
            THEN

	      csi_item_instance_pvt.Call_to_Contracts(
			       p_transaction_type   =>   l_transaction_type
			      ,p_instance_id        =>   p_instance_tbl(inst_row).instance_id
			      ,p_new_instance_id    =>   NULL
			      ,p_vld_org_id         =>   p_instance_tbl(inst_row).vld_organization_id
			      ,p_quantity           =>   NULL
			      ,p_party_account_id1  =>   NULL
			      ,p_party_account_id2  =>   NULL
			      ,p_transaction_date   =>   p_txn_tbl(inst_row).transaction_date
			      ,p_source_transaction_date   =>   p_txn_tbl(inst_row).source_transaction_date
			      ,p_grp_call_contracts =>   FND_API.G_TRUE
			      ,p_call_from_bom_expl =>   p_call_from_bom_expl
			      ,p_oks_txn_inst_tbl   =>   px_oks_txn_inst_tbl
			      ,x_return_status      =>   x_return_status
			      ,x_msg_count          =>   x_msg_count
			      ,x_msg_data           =>   x_msg_data
			       );
	      IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS)
	      THEN
		 csi_gen_utility_pvt.put_line('Error from Call_to_contracts...');
		 l_msg_index := 1;
		 l_msg_count := x_msg_count;
		 WHILE l_msg_count > 0 LOOP
		   x_msg_data := FND_MSG_PUB.GET
			       (  l_msg_index,
				  FND_API.G_FALSE
				);
		   l_msg_index := l_msg_index + 1;
		   l_msg_count := l_msg_count - 1;
		 END LOOP;
		 l_iface_error_text := substr(x_msg_data,1,2000);
		 p_instance_tbl(inst_row).processed_flag := 'E';
		 l_grp_error_tbl(inst_row).error_message := l_iface_error_text;
		 l_grp_error_tbl(inst_row).process_status := 'E';
		 l_error_array(inst_row) := l_iface_error_text;
		 l_status_array(inst_row) := 'E';
		 l_inst_id_array(inst_row) := NULL;
		 l_del_count := l_del_count + 1;
		 l_del_inst_tbl(l_del_count) := p_instance_tbl(inst_row).instance_id;
		 l_del_txn_tbl(l_del_count) := p_txn_tbl(inst_row).transaction_id;
	      ELSE
		 -- Store the Transactions inorder to Update the Contracts Audit flag later
		 l_upd_txn_count := l_upd_txn_count + 1;
		 l_upd_txn_tbl(l_upd_txn_count) := p_txn_tbl(inst_row).transaction_id;
	      END IF;
	      END IF;
           END IF; -- Onwer party ID check
        END IF; -- Valid Instance check and call_contracts set to True
     END LOOP;
     --
     IF px_oks_txn_inst_tbl.count > 0 THEN
        IF l_debug_level > 1 THEN
           csi_gen_utility_pvt.dump_oks_txn_inst_tbl(px_oks_txn_inst_tbl);
           csi_gen_utility_pvt.put_line('Calling OKS Core API...');
        END IF;
	--
        IF l_upd_txn_tbl.count > 0 THEN
           FORALL K IN l_upd_txn_tbl.FIRST .. l_upd_txn_tbl.LAST
              UPDATE CSI_TRANSACTIONS
              set contracts_invoked = 'Y'
              where transaction_id = l_upd_txn_tbl(K);
        END IF;
        --
	OKS_IBINT_PUB.IB_interface
	   (
	     P_Api_Version           =>  1.0,
	     P_init_msg_list         =>  p_init_msg_list,
	     P_single_txn_date_flag  =>  'N',
	     P_Batch_type            =>  NULL,
	     P_Batch_ID              =>  NULL,
	     P_OKS_Txn_Inst_tbl      =>  px_oks_txn_inst_tbl,
	     x_return_status         =>  x_return_status,
	     x_msg_count             =>  x_msg_count,
	     x_msg_data              =>  x_msg_data
	  );
     csi_gen_utility_pvt.put_line('Status returned from Oks_ibint_pub.IB_interface is :'||x_return_status);
	IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS)
	THEN
	   csi_gen_utility_pvt.put_line('Error from Call_to_contracts...');
	   l_msg_index := 1;
	   l_msg_count := x_msg_count;
	   WHILE l_msg_count > 0 LOOP
	     x_msg_data := FND_MSG_PUB.GET
			 (  l_msg_index,
			    FND_API.G_FALSE
			  );
	       csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
	     l_msg_index := l_msg_index + 1;
	     l_msg_count := l_msg_count - 1;
	   END LOOP;
	   l_iface_error_text := substr(x_msg_data,1,2000);
           --
           FOR inst_row IN p_instance_tbl.FIRST .. p_instance_tbl.LAST LOOP
              IF p_instance_tbl.EXISTS(inst_row) THEN
                 p_instance_tbl(inst_row).processed_flag := 'E';
		 l_grp_error_tbl(inst_row).error_message := l_iface_error_text;
		 l_grp_error_tbl(inst_row).process_status := 'E';
		 l_error_array(inst_row) := l_iface_error_text;
		 l_status_array(inst_row) := 'E';
		 l_inst_id_array(inst_row) := NULL;
              END IF;
           END LOOP;
           -- if OKS returns error then everthing gets rolledback
           p_grp_error_tbl := l_grp_error_tbl;
           RAISE FND_API.G_EXC_ERROR;
	END IF;
     END IF; -- px_oks_txn_inst_tbl count
  END IF; -- Check for l_bulk_inst_tbl count
  --
  -- Delete the Instances failed in Counter and Contracts creation.
  IF l_del_inst_tbl.count > 0 THEN
     BEGIN
        FORALL j in l_del_inst_tbl.FIRST .. l_del_inst_tbl.LAST
           DELETE FROM CSI_ITEM_INSTANCES WHERE instance_id = l_del_inst_tbl(j);
        FORALL j in l_del_inst_tbl.FIRST .. l_del_inst_tbl.LAST
           DELETE FROM CSI_IP_ACCOUNTS WHERE instance_party_id in (SELECT instance_party_id
                                                                   from CSI_I_PARTIES WHERE instance_id = l_del_inst_tbl(j));
        FORALL j in l_del_inst_tbl.FIRST .. l_del_inst_tbl.LAST
           DELETE FROM CSI_I_PARTIES WHERE instance_id = l_del_inst_tbl(j);
        FORALL j in l_del_inst_tbl.FIRST .. l_del_inst_tbl.LAST
           DELETE FROM CSI_I_ORG_ASSIGNMENTS WHERE instance_id = l_del_inst_tbl(j);
        FORALL j in l_del_inst_tbl.FIRST .. l_del_inst_tbl.LAST
           DELETE FROM CSI_I_PRICING_ATTRIBS WHERE instance_id = l_del_inst_tbl(j);
        FORALL j in l_del_inst_tbl.FIRST .. l_del_inst_tbl.LAST
           DELETE FROM CSI_I_VERSION_LABELS WHERE instance_id = l_del_inst_tbl(j);
        FORALL j in l_del_inst_tbl.FIRST .. l_del_inst_tbl.LAST
           DELETE FROM CSI_IEA_VALUES WHERE instance_id = l_del_inst_tbl(j);
        FORALL j in l_del_inst_tbl.FIRST .. l_del_inst_tbl.LAST
           DELETE FROM CSI_I_ASSETS WHERE instance_id = l_del_inst_tbl(j);
        FORALL j in l_del_txn_tbl.FIRST .. l_del_txn_tbl.LAST
           DELETE FROM CSI_ITEM_INSTANCES_H WHERE transaction_id = l_del_txn_tbl(j);
        FORALL j in l_del_txn_tbl.FIRST .. l_del_txn_tbl.LAST
           DELETE FROM CSI_I_PARTIES_H WHERE transaction_id = l_del_txn_tbl(j);
        FORALL j in l_del_txn_tbl.FIRST .. l_del_txn_tbl.LAST
           DELETE FROM CSI_IP_ACCOUNTS_H WHERE transaction_id = l_del_txn_tbl(j);
        FORALL j in l_del_txn_tbl.FIRST .. l_del_txn_tbl.LAST
           DELETE FROM CSI_I_ORG_ASSIGNMENTS_H WHERE transaction_id = l_del_txn_tbl(j);
        FORALL j in l_del_txn_tbl.FIRST .. l_del_txn_tbl.LAST
           DELETE FROM CSI_I_PRICING_ATTRIBS_H WHERE transaction_id = l_del_txn_tbl(j);
        FORALL j in l_del_txn_tbl.FIRST .. l_del_txn_tbl.LAST
           DELETE FROM CSI_I_VERSION_LABELS_H WHERE transaction_id = l_del_txn_tbl(j);
        FORALL j in l_del_txn_tbl.FIRST .. l_del_txn_tbl.LAST
           DELETE FROM CSI_IEA_VALUES_H WHERE transaction_id = l_del_txn_tbl(j);
        FORALL j in l_del_txn_tbl.FIRST .. l_del_txn_tbl.LAST
           DELETE FROM CSI_I_ASSETS_H WHERE transaction_id = l_del_txn_tbl(j);
        FORALL j in l_del_txn_tbl.FIRST .. l_del_txn_tbl.LAST
           DELETE FROM CSI_TRANSACTIONS WHERE transaction_id = l_del_txn_tbl(j);
     END;
  END IF;
  -- Update Interface Table
  IF l_intf_id_array.count > 0 THEN
     BEGIN
        l_upd_stmt := 'UPDATE CSI_INSTANCE_INTERFACE
                     SET instance_id = :ins_id
                        ,error_text = :error_text
                        ,process_status = :status
                     WHERE inst_interface_id = :intf_id';
        l_num_of_rows := dbms_sql.open_cursor;
        dbms_sql.parse(l_num_of_rows,l_upd_stmt,dbms_sql.native);
        dbms_sql.bind_array(l_num_of_rows,':ins_id',l_inst_id_array);
        dbms_sql.bind_array(l_num_of_rows,':intf_id',l_intf_id_array);
        dbms_sql.bind_array(l_num_of_rows,':status',l_status_array);
        dbms_sql.bind_array(l_num_of_rows,':error_text',l_error_array);
        l_dummy := dbms_sql.execute(l_num_of_rows);
        dbms_sql.close_cursor(l_num_of_rows);

        l_upd_stmt := 'UPDATE CSI_I_ASSET_INTERFACE a
                     SET instance_id = :ins_id
		     , instance_asset_id =
		       ( SELECT instance_asset_id
		         FROM   csi_i_assets b
			 WHERE  b.instance_id = :a_ins_id
			 AND    b.fa_asset_id = a.fa_asset_id
			 AND    b.fa_book_type_code = a.fa_book_type_code
			 AND    b.fa_location_id = a.fa_location_id
			 AND    rownum = 1
		        )
                     WHERE inst_interface_id = :intf_id';
        l_num_of_rows := dbms_sql.open_cursor;
        dbms_sql.parse(l_num_of_rows,l_upd_stmt,dbms_sql.native);
        dbms_sql.bind_array(l_num_of_rows,':ins_id',l_inst_id_array);
        dbms_sql.bind_array(l_num_of_rows,':a_ins_id',l_inst_id_array);
        dbms_sql.bind_array(l_num_of_rows,':intf_id',l_intf_id_array);
        l_dummy := dbms_sql.execute(l_num_of_rows);
        dbms_sql.close_cursor(l_num_of_rows);

     EXCEPTION
        WHEN OTHERS THEN
           NULL;
     END;
  END IF;
  --
  p_grp_error_tbl := l_grp_error_tbl;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  --
 END IF; --end of instance_tbl count check
   -- End of API body
   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
        COMMIT WORK;
   END IF;
   /***** srramakr commented for bug # 3304439
   -- Check for the profile option and disable the trace
   IF (l_flag = 'Y') THEN
        dbms_session.set_sql_trace(FALSE);
   END IF;
   -- End disable trace
   ****/

   -- Standard call to get message count and if count is  get message info.
   FND_MSG_PUB.Count_And_Get
               (p_count => x_msg_count ,
                 p_data  => x_msg_data
                );

EXCEPTION
   -- The following other_error exception is added for bug 3579121 (rel 11.5.9)
   WHEN OTHER_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
       (       p_count => x_msg_count,
               p_data  => x_msg_data
        );

   WHEN FND_API.G_EXC_ERROR THEN
                x_return_status := FND_API.G_RET_STS_ERROR ;
                ROLLBACK TO create_item_instance;
                FND_MSG_PUB.Count_And_Get
                (       p_count => x_msg_count,
                        p_data  => x_msg_data
                );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   FND_File.Put_Line(Fnd_File.LOG,'Into unexpected exception of grp.create_item_instance');
   FND_File.Put_Line(Fnd_File.LOG,'SQLERRM:'||substr(SQLERRM,1,200));
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                ROLLBACK TO create_item_instance;
                FND_MSG_PUB.Count_And_Get
                (       p_count => x_msg_count,
                        p_data  => x_msg_data
                );

   WHEN OTHERS THEN
   FND_File.Put_Line(Fnd_File.LOG,'Into when others exception of grp.create_item_instance');
   FND_File.Put_Line(Fnd_File.LOG,'SQLERRM:'||substr(SQLERRM,1,200));
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                ROLLBACK TO create_item_instance;
                IF      FND_MSG_PUB.Check_Msg_Level
                        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                FND_MSG_PUB.Add_Exc_Msg
                (G_PKG_NAME,
                 l_api_name
                );
                END IF;
                FND_MSG_PUB.Count_And_Get
                (       p_count                 =>      x_msg_count,
                        p_data                  =>      x_msg_data
                );

END create_item_instance;

/*----------------------------------------------------*/
/* Procedure name: update_item_instance               */
/* Description :   procedure used to update an Item   */
/*                 Instance                           */
/*----------------------------------------------------*/

PROCEDURE update_item_instance
 (
     p_api_version           IN     NUMBER
    ,p_commit                IN     VARCHAR2
    ,p_init_msg_list         IN     VARCHAR2
    ,p_validation_level      IN     NUMBER
    ,p_instance_tbl          IN OUT NOCOPY csi_datastructures_pub.instance_tbl
    ,p_ext_attrib_values_tbl IN OUT NOCOPY csi_datastructures_pub.extend_attrib_values_tbl
    ,p_party_tbl             IN OUT NOCOPY csi_datastructures_pub.party_tbl
    ,p_account_tbl           IN OUT NOCOPY csi_datastructures_pub.party_account_tbl
    ,p_pricing_attrib_tbl    IN OUT NOCOPY csi_datastructures_pub.pricing_attribs_tbl
    ,p_org_assignments_tbl   IN OUT NOCOPY csi_datastructures_pub.organization_units_tbl
    ,p_asset_assignment_tbl  IN OUT NOCOPY csi_datastructures_pub.instance_asset_tbl
    ,p_txn_rec               IN OUT NOCOPY csi_datastructures_pub.transaction_rec
    ,x_instance_id_lst       OUT NOCOPY    csi_datastructures_pub.id_tbl
    ,p_grp_upd_error_tbl     OUT NOCOPY    csi_datastructures_pub.grp_upd_error_tbl
    ,x_return_status         OUT NOCOPY    VARCHAR2
    ,x_msg_count             OUT NOCOPY    NUMBER
    ,x_msg_data              OUT NOCOPY    VARCHAR2
 )

IS
    l_api_name               CONSTANT VARCHAR2(30)     := 'UPDATE_ITEM_INSTANCE';
    l_api_version            CONSTANT NUMBER           := 1.0;
    l_debug_level            NUMBER;
    l_new_instance_rec       csi_datastructures_pub.instance_rec;
    l_temp_instance_rec      csi_datastructures_pub.instance_rec;
    l_old_instance_tbl       csi_datastructures_pub.instance_tbl;
    l_version_label_rec      csi_datastructures_pub.version_label_rec;
    l_temp_version_label_rec csi_datastructures_pub.version_label_rec;
    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2(2000);
    l_msg_index              NUMBER;
    l_line_count             NUMBER;
    l_flag                   VARCHAR2(1):='N';
    l_transaction_type       VARCHAR2(10) := NULL;
    l_old_oks_cp_rec         oks_ibint_pub.cp_rec_type;
    l_new_oks_cp_rec         oks_ibint_pub.cp_rec_type;
    l_contracts_status       VARCHAR2(3);
    l_owner_party_id         NUMBER;
    l_transaction_date       DATE ;
    l_internal_party_id      NUMBER;
    l_party_id               NUMBER;
    l_active_end_date        DATE;
    l_dummy                  VARCHAR2(1);
    l_item_attribute_tbl     csi_item_instance_pvt.item_attribute_tbl;
    l_location_tbl           csi_item_instance_pvt.location_tbl;
    l_generic_id_tbl         csi_item_instance_pvt.generic_id_tbl;
    l_lookup_tbl             csi_item_instance_pvt.lookup_tbl;
    l_ins_count_rec          csi_item_instance_pvt.ins_count_rec;
    l_ou_lookup_tbl          csi_organization_unit_pvt.lookup_tbl;
    l_ou_count_rec           csi_organization_unit_pvt.ou_count_rec;
    l_ou_id_tbl              csi_organization_unit_pvt.ou_id_tbl;
    l_ext_id_tbl             csi_item_instance_pvt.ext_id_tbl;
    l_ext_count_rec          csi_item_instance_pvt.ext_count_rec;
    l_ext_attr_tbl           csi_item_instance_pvt.ext_attr_tbl;
    l_ext_cat_tbl            csi_item_instance_pvt.ext_cat_tbl;
    l_asset_lookup_tbl       csi_asset_pvt.lookup_tbl;
    l_asset_count_rec        csi_asset_pvt.asset_count_rec;
    l_asset_id_tbl           csi_asset_pvt.asset_id_tbl;
    l_asset_loc_tbl          csi_asset_pvt.asset_loc_tbl;
    --
    CURSOR instance_csr(p_ins_id IN NUMBER) is
    SELECT
		   INSTANCE_ID
		  ,INSTANCE_NUMBER
		  ,EXTERNAL_REFERENCE
		  ,INVENTORY_ITEM_ID
		  ,INVENTORY_REVISION
		  ,INV_MASTER_ORGANIZATION_ID
		  ,SERIAL_NUMBER
		  ,MFG_SERIAL_NUMBER_FLAG
		  ,LOT_NUMBER
		  ,QUANTITY
		  ,UNIT_OF_MEASURE
		  ,ACCOUNTING_CLASS_CODE
		  ,INSTANCE_CONDITION_ID
		  ,INSTANCE_STATUS_ID
		  ,CUSTOMER_VIEW_FLAG
		  ,MERCHANT_VIEW_FLAG
		  ,SELLABLE_FLAG
		  ,SYSTEM_ID
		  ,INSTANCE_TYPE_CODE
		  ,ACTIVE_START_DATE
		  ,ACTIVE_END_DATE
		  ,LOCATION_TYPE_CODE
		  ,LOCATION_ID
		  ,INV_ORGANIZATION_ID
		  ,INV_SUBINVENTORY_NAME
		  ,INV_LOCATOR_ID
		  ,PA_PROJECT_ID
		  ,PA_PROJECT_TASK_ID
		  ,IN_TRANSIT_ORDER_LINE_ID
		  ,WIP_JOB_ID
		  ,PO_ORDER_LINE_ID
		  ,LAST_OE_ORDER_LINE_ID
		  ,LAST_OE_RMA_LINE_ID
		  ,LAST_PO_PO_LINE_ID
		  ,LAST_OE_PO_NUMBER
		  ,LAST_WIP_JOB_ID
		  ,LAST_PA_PROJECT_ID
		  ,LAST_PA_TASK_ID
		  ,LAST_OE_AGREEMENT_ID
		  ,INSTALL_DATE
		  ,MANUALLY_CREATED_FLAG
		  ,RETURN_BY_DATE
		  ,ACTUAL_RETURN_DATE
		  ,CREATION_COMPLETE_FLAG
		  ,COMPLETENESS_FLAG
		  ,CONTEXT
		  ,ATTRIBUTE1
		  ,ATTRIBUTE2
		  ,ATTRIBUTE3
		  ,ATTRIBUTE4
		  ,ATTRIBUTE5
		  ,ATTRIBUTE6
		  ,ATTRIBUTE7
		  ,ATTRIBUTE8
		  ,ATTRIBUTE9
		  ,ATTRIBUTE10
		  ,ATTRIBUTE11
		  ,ATTRIBUTE12
		  ,ATTRIBUTE13
		  ,ATTRIBUTE14
		  ,ATTRIBUTE15
		  ,CREATED_BY
		  ,CREATION_DATE
		  ,LAST_UPDATED_BY
		  ,LAST_UPDATE_DATE
		  ,LAST_UPDATE_LOGIN
		  ,OBJECT_VERSION_NUMBER
		  ,SECURITY_GROUP_ID
		  ,LAST_TXN_LINE_DETAIL_ID
		  ,INSTALL_LOCATION_TYPE_CODE
		  ,INSTALL_LOCATION_ID
		  ,INSTANCE_USAGE_CODE
		  ,OWNER_PARTY_SOURCE_TABLE
		  ,OWNER_PARTY_ID
		  ,OWNER_PARTY_ACCOUNT_ID
		  ,LAST_VLD_ORGANIZATION_ID
		  ,MIGRATED_FLAG
		  ,NULL PROCESSED_FLAG
    from   CSI_ITEM_INSTANCES
    where instance_id = p_ins_id;
    --
    l_instance_csr           instance_csr%ROWTYPE;
    --
    CURSOR old_ins_csr (p_ins_id IN NUMBER) IS
    SELECT
		   INSTANCE_ID
		  ,INSTANCE_NUMBER
		  ,EXTERNAL_REFERENCE
		  ,INVENTORY_ITEM_ID
		  ,INVENTORY_REVISION
		  ,INV_MASTER_ORGANIZATION_ID
		  ,SERIAL_NUMBER
		  ,MFG_SERIAL_NUMBER_FLAG
		  ,LOT_NUMBER
		  ,QUANTITY
		  ,UNIT_OF_MEASURE
		  ,ACCOUNTING_CLASS_CODE
		  ,INSTANCE_CONDITION_ID
		  ,INSTANCE_STATUS_ID
		  ,CUSTOMER_VIEW_FLAG
		  ,MERCHANT_VIEW_FLAG
		  ,SELLABLE_FLAG
		  ,SYSTEM_ID
		  ,INSTANCE_TYPE_CODE
		  ,ACTIVE_START_DATE
		  ,ACTIVE_END_DATE
		  ,LOCATION_TYPE_CODE
		  ,LOCATION_ID
		  ,INV_ORGANIZATION_ID
		  ,INV_SUBINVENTORY_NAME
		  ,INV_LOCATOR_ID
		  ,PA_PROJECT_ID
		  ,PA_PROJECT_TASK_ID
		  ,IN_TRANSIT_ORDER_LINE_ID
		  ,WIP_JOB_ID
		  ,PO_ORDER_LINE_ID
		  ,LAST_OE_ORDER_LINE_ID
		  ,LAST_OE_RMA_LINE_ID
		  ,LAST_PO_PO_LINE_ID
		  ,LAST_OE_PO_NUMBER
		  ,LAST_WIP_JOB_ID
		  ,LAST_PA_PROJECT_ID
		  ,LAST_PA_TASK_ID
		  ,LAST_OE_AGREEMENT_ID
		  ,INSTALL_DATE
		  ,MANUALLY_CREATED_FLAG
		  ,RETURN_BY_DATE
		  ,ACTUAL_RETURN_DATE
		  ,CREATION_COMPLETE_FLAG
		  ,COMPLETENESS_FLAG
		  ,CONTEXT
		  ,ATTRIBUTE1
		  ,ATTRIBUTE2
		  ,ATTRIBUTE3
		  ,ATTRIBUTE4
		  ,ATTRIBUTE5
		  ,ATTRIBUTE6
		  ,ATTRIBUTE7
		  ,ATTRIBUTE8
		  ,ATTRIBUTE9
		  ,ATTRIBUTE10
		  ,ATTRIBUTE11
		  ,ATTRIBUTE12
		  ,ATTRIBUTE13
		  ,ATTRIBUTE14
		  ,ATTRIBUTE15
		  ,CREATED_BY
		  ,CREATION_DATE
		  ,LAST_UPDATED_BY
		  ,LAST_UPDATE_DATE
		  ,LAST_UPDATE_LOGIN
		  ,OBJECT_VERSION_NUMBER
		  ,SECURITY_GROUP_ID
		  ,LAST_TXN_LINE_DETAIL_ID
		  ,INSTALL_LOCATION_TYPE_CODE
		  ,INSTALL_LOCATION_ID
		  ,INSTANCE_USAGE_CODE
		  ,OWNER_PARTY_SOURCE_TABLE
		  ,OWNER_PARTY_ID
		  ,OWNER_PARTY_ACCOUNT_ID
		  ,LAST_VLD_ORGANIZATION_ID
		  ,MIGRATED_FLAG
		  ,NULL PROCESSED_FLAG
    FROM CSI_ITEM_INSTANCES
    WHERE instance_id = p_ins_id;
    l_old_ins_csr           old_ins_csr%ROWTYPE;
    --
    l_iface_error_text       VARCHAR2(2000);
    l_grp_upd_error_tbl      csi_datastructures_pub.grp_upd_error_tbl;
    l_grp_error_count        NUMBER := 0;
    l_order_line_id          NUMBER;
    --
    l_owner_party_tbl          csi_datastructures_pub.party_tbl;
    l_party_tbl                csi_datastructures_pub.party_tbl;
    l_contact_party_tbl        csi_datastructures_pub.party_tbl;
    l_owner_acct_tbl           csi_datastructures_pub.party_account_tbl;
    l_pty_acct_tbl             csi_datastructures_pub.party_account_tbl;
    --
    l_upd_party_tbl            csi_datastructures_pub.party_tbl;
    l_upd_acct_tbl             csi_datastructures_pub.party_account_tbl;
    l_upd_count                NUMBER := 0;
    --
    l_owner_count              NUMBER := 0;
    l_party_count              NUMBER := 0;
    l_contact_count            NUMBER := 0;
    l_owner_acct_count         NUMBER := 0;
    l_pty_acct_count           NUMBER := 0;
    Process_next               EXCEPTION;
    --
    l_party_slot_tbl           T_NUM; -- This will be mapped one-to-one with the l_party_tbl
    --                                -- It contains the p_party_tbl slot#
    l_pty_slot                 NUMBER := 0;
    --
    TYPE exp_rec IS RECORD
       ( instance_id        NUMBER,
         instance_status_id NUMBER,
         active_end_date    DATE
       );
    TYPE exp_tbl IS TABLE OF exp_rec INDEX BY BINARY_INTEGER;
    --
    l_exp_tbl               exp_tbl;
    l_exp_count             NUMBER := 0;
    --
    px_child_inst_tbl        csi_item_instance_grp.child_inst_tbl;
    l_child_exists           VARCHAR2(1);
    --
    px_oks_txn_inst_tbl      oks_ibint_pub.txn_instance_tbl;
    l_batch_id               NUMBER;
    l_batch_type             VARCHAR2(50);
    --
    SKIP_ERROR               EXCEPTION;

    CURSOR non_owner_csr (p_ins_pty_id NUMBER) IS
      SELECT ip_account_id
            ,active_end_date
            ,object_version_number
      from   csi_ip_accounts
      where  instance_party_id=p_ins_pty_id
      and    relationship_type_code<>'OWNER';

BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT       update_item_instance;

    -- Check for freeze_flag in csi_install_parameters is set to 'Y'

    csi_utility_grp.check_ib_active;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
					    p_api_version,
					    l_api_name       ,
					    G_PKG_NAME       )
    THEN
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
	    FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Check the profile option debug_level for debug message reporting
    l_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');

    -- If debug_level = 1 then dump the procedure name
    IF (l_debug_level > 0) THEN
	csi_gen_utility_pvt.put_line( 'update_item_instance');
    END IF;
    --
    /***** srramakr commented for bug # 3304439
    -- Check for the profile option and enable trace
    l_flag:=CSI_GEN_UTILITY_PVT.enable_trace(l_trace_flag => l_flag);
    -- End enable trace
    ****/
    IF csi_datastructures_pub.g_install_param_rec.fetch_flag IS NULL THEN
       csi_gen_utility_pvt.populate_install_param_rec;
    END IF;
    --
    l_internal_party_id := csi_datastructures_pub.g_install_param_rec.internal_party_id;
    --
    IF l_internal_party_id IS NULL THEN
       FND_MESSAGE.SET_NAME('CSI','CSI_API_UNINSTALLED_PARAMETER');
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
    END IF;
    --
    l_old_instance_tbl.DELETE;
    IF (p_instance_tbl.count > 0) THEN
       FOR ins_row IN p_instance_tbl.FIRST .. p_instance_tbl.LAST
       LOOP
	  IF p_instance_tbl.EXISTS(ins_row) THEN
	     -- If the debug level = 2 then dump all the parameters values.
	     IF (l_debug_level > 1) THEN
		csi_gen_utility_pvt.put_line( 'update_item_instance'     ||
					     p_api_version         ||'-'||
					     p_commit              ||'-'||
					     p_init_msg_list       ||'-'||
					     p_validation_level );
		csi_gen_utility_pvt.dump_instance_rec(p_instance_tbl(ins_row));
		csi_gen_utility_pvt.dump_party_tbl(p_party_tbl);
		csi_gen_utility_pvt.dump_txn_rec(p_txn_rec);
		csi_gen_utility_pvt.dump_organization_unit_tbl(p_org_assignments_tbl);
		csi_gen_utility_pvt.dump_pricing_attribs_tbl(p_pricing_attrib_tbl);
		csi_gen_utility_pvt.dump_party_account_tbl(p_account_tbl);
		csi_gen_utility_pvt.dump_ext_attrib_values_tbl(p_ext_attrib_values_tbl);
	     END IF;
	     -- Start API body
	     -- This will fetch old instance data for the purpose of contracts
	     OPEN   old_ins_csr (p_instance_tbl(ins_row).instance_id);
	     FETCH  old_ins_csr INTO l_old_ins_csr;
	     CLOSE  old_ins_csr;
	     -- Following table will be used for calling contracts.
	     l_old_instance_tbl(ins_row).instance_id := p_instance_tbl(ins_row).instance_id;
	     l_old_instance_tbl(ins_row).active_end_date := l_old_ins_csr.active_end_date;
             l_old_instance_tbl(ins_row).quantity := l_old_ins_csr.quantity;
             l_old_instance_tbl(ins_row).install_date := l_old_ins_csr.install_date;
             l_old_instance_tbl(ins_row).last_oe_order_line_id := l_old_ins_csr.last_oe_order_line_id;
             l_old_instance_tbl(ins_row).in_transit_order_line_id := l_old_ins_csr.in_transit_order_line_id;
	     --
	     -- End fetching old instance data for the purpose of contracts
	     --
	     l_new_instance_rec := p_instance_tbl(ins_row);
             --
             -- Check whether the instance is getting expired. If so, then update the other attributes
             -- and then expire the instance.
             IF l_new_instance_rec.active_end_date IS NOT NULL AND
                l_new_instance_rec.active_end_date <> FND_API.G_MISS_DATE AND
                l_new_instance_rec.active_end_date < sysdate THEN
                -- Store the following attributes in a PL/SQL tbl.
                -- ins_row is used as the slot# so that when Update API is called again, the status of
                -- p_instance_tbl can be updated directly using this ins_row.
                l_exp_tbl(ins_row).instance_id := l_new_instance_rec.instance_id;
                l_exp_tbl(ins_row).instance_status_id := l_new_instance_rec.instance_status_id;
                l_exp_tbl(ins_row).active_end_date := l_new_instance_rec.active_end_date;
                l_new_instance_rec.active_end_date := fnd_api.g_miss_date;
                l_new_instance_rec.instance_status_id := fnd_api.g_miss_num;
             END IF;
             --
             -- If any of the attribute values are different from the DB value then call Update API.
	     IF (csi_Item_Instance_Pvt.Anything_To_Update(p_instance_rec => l_new_instance_rec)) THEN
                l_child_exists := 'N';
                IF px_child_inst_tbl.count > 0 THEN
                   FOR k IN px_child_inst_tbl.FIRST .. px_child_inst_tbl.LAST LOOP
                      IF l_new_instance_rec.instance_id = px_child_inst_tbl(k) THEN
                         l_child_exists := 'Y';
                         exit;
                      END IF;
                   END LOOP;
                END IF;
                --
                IF l_child_exists = 'Y' THEN -- Call update API with the New object version Number
                   select object_version_number
                   into l_new_instance_rec.object_version_number
                   from CSI_ITEM_INSTANCES
                   where instance_id = l_new_instance_rec.instance_id;
                END IF;
		-- Call the update_item_instance private API to update the instances
		l_iface_error_text := NULL;
		csi_item_instance_pvt.update_item_instance
			       (
				p_api_version        => p_api_version
			       ,p_commit             => fnd_api.g_false
			       ,p_init_msg_list      => p_init_msg_list
			       ,p_validation_level   => p_validation_level
			       ,p_instance_rec       => l_new_instance_rec
			       ,p_txn_rec            => p_txn_rec
			       ,x_instance_id_lst    => x_instance_id_lst
			       ,x_return_status      => x_return_status
			       ,x_msg_count          => x_msg_count
			       ,x_msg_data           => x_msg_data
			       ,p_item_attribute_tbl => l_item_attribute_tbl
			       ,p_location_tbl       => l_location_tbl
			       ,p_generic_id_tbl     => l_generic_id_tbl
			       ,p_lookup_tbl         => l_lookup_tbl
			       ,p_ins_count_rec      => l_ins_count_rec
                               ,p_oks_txn_inst_tbl   => px_oks_txn_inst_tbl
                               ,p_child_inst_tbl     => px_child_inst_tbl
			      );

                IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
		   csi_gen_utility_pvt.put_line( 'Error from UPDATE_ITEM_INSTANCE_PVT..');
		   l_msg_index := 1;
		   l_msg_count := x_msg_count;
		   WHILE l_msg_count > 0 LOOP
		       x_msg_data := FND_MSG_PUB.GET
					     ( l_msg_index,
					       FND_API.G_FALSE );
		       csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
		       l_msg_index := l_msg_index + 1;
		       l_msg_count := l_msg_count - 1;
                   END LOOP;
		   --  RAISE FND_API.G_EXC_ERROR;
                   p_instance_tbl(ins_row).processed_flag := 'E';
		   l_iface_error_text := substr(x_msg_data,1,2000);
		   l_grp_error_count := l_grp_error_count + 1;
		   l_grp_upd_error_tbl(l_grp_error_count).instance_id := l_new_instance_rec.instance_id;
		   l_grp_upd_error_tbl(l_grp_error_count).entity_name := 'INSTANCE';
		   l_grp_upd_error_tbl(l_grp_error_count).error_message := l_iface_error_text;
                ELSE
                   p_instance_tbl(ins_row).processed_flag := 'P';
                END IF;
             END IF;
	  END IF; -- Check Instance Tbl existance.
       END LOOP;
       --
       px_child_inst_tbl.DELETE;
       --
    END IF;
    --
    px_child_inst_tbl.DELETE;
    --
    IF p_party_tbl.count > 0 THEN
       FOR pty IN p_party_tbl.FIRST .. p_party_tbl.LAST LOOP
	  IF p_party_tbl.EXISTS(pty) THEN
	     IF p_party_tbl(pty).contact_flag <> 'Y' THEN
		IF p_party_tbl(pty).relationship_type_code = 'OWNER' THEN
		   l_owner_count := l_owner_count + 1;
		   l_owner_party_tbl(l_owner_count) := p_party_tbl(pty);
		   IF p_account_tbl.count > 0 THEN
		      FOR acct IN p_account_tbl.FIRST .. p_account_tbl.LAST LOOP
			 IF p_account_tbl.EXISTS(acct) THEN
			    IF p_account_tbl(acct).parent_tbl_index = pty THEN
			       l_owner_acct_count := l_owner_acct_count + 1;
			       l_owner_acct_tbl(l_owner_acct_count) := p_account_tbl(acct);
			       l_owner_acct_tbl(l_owner_acct_count).parent_tbl_index := l_owner_count;
			       l_owner_acct_tbl(l_owner_acct_count).call_contracts := fnd_api.g_true;
			    END IF;
			 END IF;
		      END LOOP; -- Account Loop
		   END IF;
		ELSE -- Non-Owner Party
		   l_party_count := l_party_count + 1;
		   l_party_tbl(l_party_count) := p_party_tbl(pty);
		   l_pty_slot := l_pty_slot +1 ;
		   l_party_slot_tbl(l_pty_slot) := pty;
		   IF p_account_tbl.count > 0 THEN
		      FOR acct IN p_account_tbl.FIRST .. p_account_tbl.LAST LOOP
			 IF p_account_tbl.EXISTS(acct) THEN
			    IF p_account_tbl(acct).parent_tbl_index = pty THEN
			       l_pty_acct_count := l_pty_acct_count + 1;
			       l_pty_acct_tbl(l_pty_acct_count) := p_account_tbl(acct);
			       l_pty_acct_tbl(l_pty_acct_count).parent_tbl_index := l_party_count;
			    END IF;
			 END IF;
		      END LOOP; -- Account Loop
                   END IF;
		END IF; -- Relationship Type check
	     ELSE -- Contact Party
		l_contact_count := l_contact_count + 1;
		l_contact_party_tbl(l_contact_count) := p_party_tbl(pty);
	     END IF; -- Contact flag check
	  END IF;
       END LOOP; -- Party Loop
    END IF;
    --
    -- Owner Party Tbl will always have instance_party_id and hence we need to call Update Party API
    -- If the corresponding account entity is getting created then Update Party API hadles that.
    IF l_owner_party_tbl.count > 0 THEN
       FOR J IN l_owner_party_tbl.FIRST .. l_owner_party_tbl.LAST LOOP
	  l_upd_party_tbl.DELETE;
	  l_upd_acct_tbl.DELETE;
	  l_upd_count := 0;
	  --
	  l_upd_party_tbl(1) := l_owner_party_tbl(J);
	  --
	  IF l_owner_acct_tbl.count > 0 THEN
	     FOR K IN l_owner_acct_tbl.FIRST .. l_owner_acct_tbl.LAST LOOP
		IF l_owner_acct_tbl(K).parent_tbl_index = J THEN
		   l_upd_count := l_upd_count + 1;
		   l_upd_acct_tbl(l_upd_count) := l_owner_acct_tbl(K);
                   l_upd_acct_tbl(l_upd_count).parent_tbl_index := 1; -- Party tbl always contains 1 rec
		END IF;
	     END LOOP;
	  END IF;
	  --
	  -- Call Update Party API for this set
	  csi_party_relationships_pub.update_inst_party_relationship
	    (  p_api_version      => p_api_version
	      ,p_commit           => fnd_api.g_false
	      ,p_init_msg_list    => fnd_api.g_false
	      ,p_validation_level => p_validation_level
	      ,p_party_tbl        => l_upd_party_tbl
	      ,p_party_account_tbl=> l_upd_acct_tbl
	      ,p_txn_rec          => p_txn_rec
	      ,p_oks_txn_inst_tbl => px_oks_txn_inst_tbl
	      ,x_return_status    => x_return_status
	      ,x_msg_count        => x_msg_count
	      ,x_msg_data         => x_msg_data
	    );
	  --
	  IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
	     l_msg_index := 1;
	     l_msg_count := x_msg_count;
	     WHILE l_msg_count > 0
	     LOOP
		x_msg_data := FND_MSG_PUB.GET
				 (  l_msg_index,
				    FND_API.G_FALSE       );
		csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
		l_msg_index := l_msg_index + 1;
		l_msg_count := l_msg_count - 1;
	     END LOOP;
	     l_iface_error_text := substr(x_msg_data,1,2000);
	     l_grp_error_count := l_grp_error_count + 1;
	     l_grp_upd_error_tbl(l_grp_error_count).instance_id := l_upd_party_tbl(1).instance_id;
	     l_grp_upd_error_tbl(l_grp_error_count).entity_name := 'PARTY';
	     l_grp_upd_error_tbl(l_grp_error_count).error_message := l_iface_error_text;
	  END IF;
       END LOOP;
    END IF; -- Owner Party Tbl count check
    --
    IF l_party_tbl.count > 0 THEN
       FOR J IN l_party_tbl.FIRST .. l_party_tbl.LAST LOOP
	  l_upd_party_tbl.DELETE;
	  l_upd_acct_tbl.DELETE;
	  l_upd_count := 0;
	  --
	  l_upd_party_tbl(1) := l_party_tbl(J);
	  --
	  IF l_pty_acct_tbl.count > 0 THEN
	     FOR K IN l_pty_acct_tbl.FIRST .. l_pty_acct_tbl.LAST LOOP
		IF l_pty_acct_tbl(K).parent_tbl_index = J THEN
		   l_upd_count := l_upd_count + 1;
		   l_upd_acct_tbl(l_upd_count) := l_pty_acct_tbl(K);
                   l_upd_acct_tbl(l_upd_count).parent_tbl_index := 1; -- Party tbl always contains 1 record
		END IF;
	     END LOOP;
	  END IF;
	  --
	  IF l_upd_party_tbl(1).instance_party_id IS NULL OR
	     l_upd_party_tbl(1).instance_party_id = FND_API.G_MISS_NUM THEN
	     -- Call Create Party API
	     csi_party_relationships_pub.create_inst_party_relationship
	      ( p_api_version         => p_api_version
	       ,p_commit              => fnd_api.g_false
	       ,p_init_msg_list       => p_init_msg_list
	       ,p_validation_level    => p_validation_level
	       ,p_party_tbl           => l_upd_party_tbl
	       ,p_party_account_tbl   => l_upd_acct_tbl
	       ,p_txn_rec             => p_txn_rec
	       ,p_oks_txn_inst_tbl    => px_oks_txn_inst_tbl
	       ,x_return_status       => x_return_status
	       ,x_msg_count           => x_msg_count
	       ,x_msg_data            => x_msg_data
	     );
	     --
	     IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
		l_msg_index := 1;
		l_msg_count := x_msg_count;
		WHILE l_msg_count > 0
		LOOP
		   x_msg_data := FND_MSG_PUB.GET
				    (  l_msg_index,
				       FND_API.G_FALSE       );
		   csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
		   l_msg_index := l_msg_index + 1;
		   l_msg_count := l_msg_count - 1;
		END LOOP;
		l_iface_error_text := substr(x_msg_data,1,2000);
		l_grp_error_count := l_grp_error_count + 1;
		l_grp_upd_error_tbl(l_grp_error_count).instance_id := l_upd_party_tbl(1).instance_id;
		l_grp_upd_error_tbl(l_grp_error_count).entity_name := 'PARTY';
		l_grp_upd_error_tbl(l_grp_error_count).error_message := l_iface_error_text;
	     ELSE -- Update the instance_party_id for the corresponding p_party_tbl
		IF l_party_slot_tbl.count > 0 THEN
			 p_party_tbl(l_party_slot_tbl(J)).instance_party_id :=
						       l_upd_party_tbl(1).instance_party_id;
		END IF;
	     END IF;
	  ELSE
	     -- Call Update Party API
	     csi_party_relationships_pub.update_inst_party_relationship
	       (  p_api_version      => p_api_version
		 ,p_commit           => fnd_api.g_false
		 ,p_init_msg_list    => fnd_api.g_false
		 ,p_validation_level => p_validation_level
		 ,p_party_tbl        => l_upd_party_tbl
		 ,p_party_account_tbl=> l_upd_acct_tbl
		 ,p_txn_rec          => p_txn_rec
		 ,p_oks_txn_inst_tbl => px_oks_txn_inst_tbl
		 ,x_return_status    => x_return_status
		 ,x_msg_count        => x_msg_count
		 ,x_msg_data         => x_msg_data
	       );
	     --
	     IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
		l_msg_index := 1;
		l_msg_count := x_msg_count;
		WHILE l_msg_count > 0
		LOOP
		   x_msg_data := FND_MSG_PUB.GET
				    (  l_msg_index,
				       FND_API.G_FALSE       );
		   csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
		   l_msg_index := l_msg_index + 1;
		   l_msg_count := l_msg_count - 1;
		END LOOP;
		l_iface_error_text := substr(x_msg_data,1,2000);
		l_grp_error_count := l_grp_error_count + 1;
		l_grp_upd_error_tbl(l_grp_error_count).instance_id := l_upd_party_tbl(1).instance_id;
		l_grp_upd_error_tbl(l_grp_error_count).entity_name := 'PARTY';
		l_grp_upd_error_tbl(l_grp_error_count).error_message := l_iface_error_text;
	     END IF;
	  END IF;
       END LOOP;
    END IF; -- Non-Owner Party Tbl count check
    --
    -- Call Party API for Contacts
    l_upd_acct_tbl.DELETE;
    IF l_contact_party_tbl.count > 0 THEN
       FOR J IN l_contact_party_tbl.FIRST .. l_contact_party_tbl.LAST LOOP
	  Begin
	     l_upd_party_tbl.DELETE;
	     l_upd_party_tbl(1) := l_contact_party_tbl(J);
	     --
	     -- Get the correct contact_ip_id if not passed
	     --
	     IF l_contact_party_tbl(J).contact_ip_id IS NULL OR
		l_contact_party_tbl(J).contact_ip_id = FND_API.G_MISS_NUM THEN
		IF NVL(l_contact_party_tbl(J).contact_parent_tbl_index,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM
		THEN
		   IF p_party_tbl.EXISTS(l_contact_party_tbl(J).contact_parent_tbl_index) THEN
		      l_contact_party_tbl(J).contact_ip_id :=
			    p_party_tbl(l_contact_party_tbl(J).contact_parent_tbl_index).instance_party_id;
                      l_upd_party_tbl(1).contact_ip_id := l_contact_party_tbl(J).contact_ip_id;
		   ELSE
		      l_iface_error_text := 'Invalid contact_parent_tbl_index';
		      l_grp_error_count := l_grp_error_count + 1;
		      l_grp_upd_error_tbl(l_grp_error_count).instance_id := l_upd_party_tbl(1).instance_id;
		      l_grp_upd_error_tbl(l_grp_error_count).entity_name := 'PARTY';
		      l_grp_upd_error_tbl(l_grp_error_count).error_message := l_iface_error_text;
		      Raise Process_next;
		   END IF;
		ELSE
		   l_iface_error_text := 'Either Contact_parent_tbl_index or Contact_Ip_ID should be passed for Contacts';
		   l_grp_error_count := l_grp_error_count + 1;
		   l_grp_upd_error_tbl(l_grp_error_count).instance_id := l_upd_party_tbl(1).instance_id;
		   l_grp_upd_error_tbl(l_grp_error_count).entity_name := 'PARTY';
		   l_grp_upd_error_tbl(l_grp_error_count).error_message := l_iface_error_text;
		   Raise Process_next;
		END IF;
	     END IF;
	     --
	     IF l_upd_party_tbl(1).instance_party_id IS NULL OR
		l_upd_party_tbl(1).instance_party_id = FND_API.G_MISS_NUM THEN
		-- Call Create Party API
		csi_party_relationships_pub.create_inst_party_relationship
		 ( p_api_version         => p_api_version
		  ,p_commit              => fnd_api.g_false
		  ,p_init_msg_list       => p_init_msg_list
		  ,p_validation_level    => p_validation_level
		  ,p_party_tbl           => l_upd_party_tbl
		  ,p_party_account_tbl   => l_upd_acct_tbl
		  ,p_txn_rec             => p_txn_rec
		  ,p_oks_txn_inst_tbl    => px_oks_txn_inst_tbl
		  ,x_return_status       => x_return_status
		  ,x_msg_count           => x_msg_count
		  ,x_msg_data            => x_msg_data
		);
		--
		IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
		   l_msg_index := 1;
		   l_msg_count := x_msg_count;
		   WHILE l_msg_count > 0
		   LOOP
		      x_msg_data := FND_MSG_PUB.GET
				       (  l_msg_index,
					  FND_API.G_FALSE       );
		      csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
		      l_msg_index := l_msg_index + 1;
		      l_msg_count := l_msg_count - 1;
		   END LOOP;
		   l_iface_error_text := substr(x_msg_data,1,2000);
		   l_grp_error_count := l_grp_error_count + 1;
		   l_grp_upd_error_tbl(l_grp_error_count).instance_id := l_upd_party_tbl(1).instance_id;
		   l_grp_upd_error_tbl(l_grp_error_count).entity_name := 'PARTY';
		   l_grp_upd_error_tbl(l_grp_error_count).error_message := l_iface_error_text;
		END IF;
	     ELSE
		-- Call Update Party API
		csi_party_relationships_pub.update_inst_party_relationship
		  (  p_api_version      => p_api_version
		    ,p_commit           => fnd_api.g_false
		    ,p_init_msg_list    => fnd_api.g_false
		    ,p_validation_level => p_validation_level
		    ,p_party_tbl        => l_upd_party_tbl
		    ,p_party_account_tbl=> l_upd_acct_tbl
		    ,p_txn_rec          => p_txn_rec
		    ,p_oks_txn_inst_tbl => px_oks_txn_inst_tbl
		    ,x_return_status    => x_return_status
		    ,x_msg_count        => x_msg_count
		    ,x_msg_data         => x_msg_data
		  );
		--
		IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
		   l_msg_index := 1;
		   l_msg_count := x_msg_count;
		   WHILE l_msg_count > 0
		   LOOP
		      x_msg_data := FND_MSG_PUB.GET
				       (  l_msg_index,
					  FND_API.G_FALSE       );
		      csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
		      l_msg_index := l_msg_index + 1;
		      l_msg_count := l_msg_count - 1;
		   END LOOP;
		   l_iface_error_text := substr(x_msg_data,1,2000);
		   l_grp_error_count := l_grp_error_count + 1;
		   l_grp_upd_error_tbl(l_grp_error_count).instance_id := l_upd_party_tbl(1).instance_id;
		   l_grp_upd_error_tbl(l_grp_error_count).entity_name := 'PARTY';
		   l_grp_upd_error_tbl(l_grp_error_count).error_message := l_iface_error_text;
		END IF;
	     END IF;
	  Exception
	     when Process_next then
		null;
	  End;
       END LOOP;
    END IF; -- l_contact_party_tbl count check
   -- Call update_organization_unit to associate any org. assignments
   -- to the item instance
 IF (p_org_assignments_tbl.count > 0) THEN
    FOR tab_row IN p_org_assignments_tbl.FIRST .. p_org_assignments_tbl.LAST
    LOOP
      l_iface_error_text := NULL;
      IF p_org_assignments_tbl.EXISTS(tab_row) THEN
        IF ((p_org_assignments_tbl(tab_row).instance_ou_id IS NULL)
           OR
           (p_org_assignments_tbl(tab_row).instance_ou_id = FND_API.G_MISS_NUM))
        THEN
            csi_organization_unit_pvt.create_organization_unit
             (p_api_version       => p_api_version
             ,p_commit            => fnd_api.g_false
             ,p_init_msg_list     => p_init_msg_list
             ,p_validation_level  => p_validation_level
             ,p_org_unit_rec      => p_org_assignments_tbl(tab_row)
             ,p_txn_rec           => p_txn_rec
             ,x_return_status     => x_return_status
             ,x_msg_count         => x_msg_count
             ,x_msg_data          => x_msg_data
             ,p_lookup_tbl        => l_ou_lookup_tbl
             ,p_ou_count_rec      => l_ou_count_rec
             ,p_ou_id_tbl         => l_ou_id_tbl
            );
         ELSE
            csi_organization_unit_pvt.update_organization_unit
             (p_api_version       => p_api_version
             ,p_commit            => fnd_api.g_false
             ,p_init_msg_list     => p_init_msg_list
             ,p_validation_level  => p_validation_level
             ,p_org_unit_rec      => p_org_assignments_tbl(tab_row)
             ,p_txn_rec           => p_txn_rec
             ,x_return_status     => x_return_status
             ,x_msg_count         => x_msg_count
             ,x_msg_data          => x_msg_data
             ,p_lookup_tbl        => l_ou_lookup_tbl
             ,p_ou_count_rec      => l_ou_count_rec
             ,p_ou_id_tbl         => l_ou_id_tbl
            );
       END IF;
       IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          csi_gen_utility_pvt.put_line( ' Error from CSI_ORGANIZATION_UNIT_PVT..');
          l_msg_index := 1;
          l_msg_count := x_msg_count;
             WHILE l_msg_count > 0 LOOP
                   x_msg_data := FND_MSG_PUB.GET
                          (  l_msg_index,
                             FND_API.G_FALSE    );
                   csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
              l_msg_index := l_msg_index + 1;
              l_msg_count := l_msg_count - 1;
             END LOOP;
             l_iface_error_text := substr(x_msg_data,1,2000);
             l_grp_error_count := l_grp_error_count + 1;
             l_grp_upd_error_tbl(l_grp_error_count).instance_id := p_org_assignments_tbl(tab_row).instance_id;
             l_grp_upd_error_tbl(l_grp_error_count).entity_name := 'ORG_ASSIGN';
             l_grp_upd_error_tbl(l_grp_error_count).error_message := l_iface_error_text;
             --  RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF;
    END LOOP;
  END IF;

   -- Call update_pricing_attribs to associate any pricing attributes
   -- to the item instance
  IF (p_pricing_attrib_tbl.count > 0) THEN
    FOR tab_row IN p_pricing_attrib_tbl.FIRST .. p_pricing_attrib_tbl.LAST
    LOOP
      l_iface_error_text := NULL;
      IF p_pricing_attrib_tbl.EXISTS(tab_row) THEN
        IF ((p_pricing_attrib_tbl(tab_row).pricing_attribute_id IS NULL)
          OR
           (p_pricing_attrib_tbl(tab_row).pricing_attribute_id = FND_API.G_MISS_NUM))
        THEN
               csi_pricing_attribs_pvt.create_pricing_attribs
                ( p_api_version         => p_api_version
                 ,p_commit              => p_commit
                 ,p_init_msg_list       => p_init_msg_list
                 ,p_validation_level    => p_validation_level
                 ,p_pricing_attribs_rec => p_pricing_attrib_tbl(tab_row)
                 ,p_txn_rec             => p_txn_rec
                 ,x_return_status       => x_return_status
                 ,x_msg_count           => x_msg_count
                 ,x_msg_data            => x_msg_data
                 );
         ELSE
              csi_pricing_attribs_pvt.update_pricing_attribs
               ( p_api_version          => p_api_version
                ,p_commit               => fnd_api.g_false
                ,p_init_msg_list        => p_init_msg_list
                ,p_validation_level     => p_validation_level
                ,p_pricing_attribs_rec  => p_pricing_attrib_tbl(tab_row)
                ,p_txn_rec              => p_txn_rec
                ,x_return_status        => x_return_status
                ,x_msg_count            => x_msg_count
                ,x_msg_data             => x_msg_data
               );
         END IF;

         IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
           csi_gen_utility_pvt.put_line( ' Error from CSI_PRICING_ATTRIBS_PVT..');
           l_msg_index := 1;
           l_msg_count := x_msg_count;
               WHILE l_msg_count > 0 LOOP
                     x_msg_data := FND_MSG_PUB.GET
                              (  l_msg_index,
                                 FND_API.G_FALSE    );
                     csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
                     l_msg_index := l_msg_index + 1;
                     l_msg_count := l_msg_count - 1;
               END LOOP;
             l_iface_error_text := substr(x_msg_data,1,2000);
             l_grp_error_count := l_grp_error_count + 1;
             l_grp_upd_error_tbl(l_grp_error_count).instance_id := p_pricing_attrib_tbl(tab_row).instance_id;
             l_grp_upd_error_tbl(l_grp_error_count).entity_name := 'PRICING';
             l_grp_upd_error_tbl(l_grp_error_count).error_message := l_iface_error_text;
             --  RAISE FND_API.G_EXC_ERROR;
         END IF;
     END IF;
   END LOOP;
 END IF;

-- Call create_extended_attribs to associate any extended attributes
-- to the item instance
 IF (p_ext_attrib_values_tbl.count > 0) THEN
    FOR tab_row IN p_ext_attrib_values_tbl.FIRST .. p_ext_attrib_values_tbl.LAST
    LOOP
      l_iface_error_text := NULL;
      IF p_ext_attrib_values_tbl.EXISTS (tab_row) THEN
        IF ((p_ext_attrib_values_tbl(tab_row).attribute_value_id IS NULL)
          OR
           (p_ext_attrib_values_tbl(tab_row).attribute_value_id = FND_API.G_MISS_NUM))
         THEN
            csi_item_instance_pvt.create_extended_attrib_values
                ( p_api_version         => p_api_version
                 ,p_commit              => fnd_api.g_false
                 ,p_init_msg_list       => p_init_msg_list
                 ,p_validation_level    => p_validation_level
                 ,p_ext_attrib_rec      => p_ext_attrib_values_tbl(tab_row)
                 ,p_txn_rec             => p_txn_rec
                 ,x_return_status       => x_return_status
                 ,x_msg_count           => x_msg_count
                 ,x_msg_data            => x_msg_data
                 ,p_ext_id_tbl          => l_ext_id_tbl
                 ,p_ext_count_rec       => l_ext_count_rec
                 ,p_ext_attr_tbl        => l_ext_attr_tbl
                 ,p_ext_cat_tbl         => l_ext_cat_tbl
                );
        ELSE
           -- call the update extended attributes api
           csi_item_instance_pvt.update_extended_attrib_values
               ( p_api_version          => p_api_version
                ,p_commit               => fnd_api.g_false
                ,p_init_msg_list        => p_init_msg_list
                ,p_validation_level     => p_validation_level
                ,p_ext_attrib_rec       => p_ext_attrib_values_tbl(tab_row)
                ,p_txn_rec              => p_txn_rec
                ,x_return_status        => x_return_status
                ,x_msg_count            => x_msg_count
                ,x_msg_data             => x_msg_data
               );
        END IF;
        IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
            csi_gen_utility_pvt.put_line( ' Error from CSI_ITEM_INSTANCE_PVT.EXTENDED_ATTRIBS..');
            l_msg_index := 1;
            l_msg_count := x_msg_count;
              WHILE l_msg_count > 0 LOOP
                    x_msg_data := FND_MSG_PUB.GET
                              (  l_msg_index,
                                 FND_API.G_FALSE    );
                    csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
                    l_msg_index := l_msg_index + 1;
                    l_msg_count := l_msg_count - 1;
              END LOOP;
             l_iface_error_text := substr(x_msg_data,1,2000);
             l_grp_error_count := l_grp_error_count + 1;
             l_grp_upd_error_tbl(l_grp_error_count).instance_id := p_ext_attrib_values_tbl(tab_row).instance_id;
             l_grp_upd_error_tbl(l_grp_error_count).entity_name := 'EXT_ATTRIBS';
             l_grp_upd_error_tbl(l_grp_error_count).error_message := l_iface_error_text;
             --  RAISE FND_API.G_EXC_ERROR;
        END IF;
     END IF; -- exist if
   END LOOP; -- for loop
 END IF;

   -- Call create_asset_assignments to associate any assets associated
   -- to the item instance
  IF (p_asset_assignment_tbl.count > 0) THEN
    FOR tab_row IN p_asset_assignment_tbl.FIRST .. p_asset_assignment_tbl.LAST
    LOOP
      l_iface_error_text := NULL;
      IF p_asset_assignment_tbl.EXISTS(tab_row) THEN
        IF ((p_asset_assignment_tbl(tab_row).instance_asset_id IS NULL)
          OR
           (p_asset_assignment_tbl(tab_row).instance_asset_id = FND_API.G_MISS_NUM)) THEN
               csi_asset_pvt.create_instance_asset
                (p_api_version          => p_api_version
                ,p_commit               => fnd_api.g_false
                ,p_init_msg_list        => p_init_msg_list
                ,p_validation_level     => p_validation_level
                ,p_instance_asset_rec   => p_asset_assignment_tbl(tab_row)
                ,p_txn_rec              => p_txn_rec
                ,x_return_status        => x_return_status
                ,x_msg_count            => x_msg_count
                ,x_msg_data             => x_msg_data
                ,p_lookup_tbl           => l_asset_lookup_tbl
                ,p_asset_count_rec      => l_asset_count_rec
                ,p_asset_id_tbl         => l_asset_id_tbl
                ,p_asset_loc_tbl        => l_asset_loc_tbl
                );
        ELSE
           --call the update assets api
           csi_asset_pvt.update_instance_asset
                (p_api_version          => p_api_version
                ,p_commit               => fnd_api.g_false
                ,p_init_msg_list        => p_init_msg_list
                ,p_validation_level     => p_validation_level
                ,p_instance_asset_rec   => p_asset_assignment_tbl(tab_row)
                ,p_txn_rec              => p_txn_rec
                ,x_return_status        => x_return_status
                ,x_msg_count            => x_msg_count
                ,x_msg_data             => x_msg_data
                ,p_lookup_tbl           => l_asset_lookup_tbl
                ,p_asset_count_rec      => l_asset_count_rec
                ,p_asset_id_tbl         => l_asset_id_tbl
                ,p_asset_loc_tbl        => l_asset_loc_tbl
                );
        END IF;
        IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          csi_gen_utility_pvt.put_line( ' Error from CSI_ASSET_PVT..');
          l_msg_index := 1;
          l_msg_count := x_msg_count;
              WHILE l_msg_count > 0 LOOP
                    x_msg_data := FND_MSG_PUB.GET
                              (  l_msg_index,
                                 FND_API.G_FALSE  );
                    csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
                    l_msg_index := l_msg_index + 1;
                    l_msg_count := l_msg_count - 1;
              END LOOP;
             l_iface_error_text := substr(x_msg_data,1,2000);
             l_grp_error_count := l_grp_error_count + 1;
             l_grp_upd_error_tbl(l_grp_error_count).instance_id := p_asset_assignment_tbl(tab_row).instance_id;
             l_grp_upd_error_tbl(l_grp_error_count).entity_name := 'ASSET';
             l_grp_upd_error_tbl(l_grp_error_count).error_message := l_iface_error_text;
             --  RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF;
    END LOOP;
  END IF;
  --
  -- Expire the Item Instances
  --
  IF l_exp_tbl.count > 0 THEN
     FOR k IN l_exp_tbl.FIRST .. l_exp_tbl.LAST LOOP -- 'k' will directly map to p_instance_tbl slot#
	IF l_exp_tbl.EXISTS(k) THEN
	   l_new_instance_rec := l_temp_instance_rec;
           Begin
	      select active_end_date,object_version_number
	      into l_new_instance_rec.active_end_date,l_new_instance_rec.object_version_number
	      from CSI_ITEM_INSTANCES
	      where instance_id = l_exp_tbl(k).instance_id;
           Exception
              when no_data_found then
		 p_instance_tbl(k).processed_flag := 'E';
		 l_iface_error_text := 'Instance ID '||to_char(l_exp_tbl(k).instance_id)||
                                       ' Does not exist in Installed Base';
		 l_grp_error_count := l_grp_error_count + 1;
		 l_grp_upd_error_tbl(l_grp_error_count).instance_id := l_exp_tbl(k).instance_id;
		 l_grp_upd_error_tbl(l_grp_error_count).entity_name := 'INSTANCE';
		 l_grp_upd_error_tbl(l_grp_error_count).error_message := l_iface_error_text;
           End;
	   --
	   IF l_new_instance_rec.active_end_date IS NOT NULL AND
	      l_new_instance_rec.active_end_date < SYSDATE THEN
	      Null; -- Instance would have got expired during parent instance expiry
	   ELSE
	      l_new_instance_rec.instance_id := l_exp_tbl(k).instance_id;
	      l_new_instance_rec.active_end_date := l_exp_tbl(k).active_end_date;
	      l_new_instance_rec.instance_status_id := l_exp_tbl(k).instance_status_id;
	      --
	      -- Call the update_item_instance private API to update the instances
	      l_iface_error_text := NULL;
	      csi_item_instance_pvt.update_item_instance
			     (
			      p_api_version        => p_api_version
			     ,p_commit             => fnd_api.g_false
			     ,p_init_msg_list      => p_init_msg_list
			     ,p_validation_level   => p_validation_level
			     ,p_instance_rec       => l_new_instance_rec
			     ,p_txn_rec            => p_txn_rec
			     ,x_instance_id_lst    => x_instance_id_lst
			     ,x_return_status      => x_return_status
			     ,x_msg_count          => x_msg_count
			     ,x_msg_data           => x_msg_data
			     ,p_item_attribute_tbl => l_item_attribute_tbl
			     ,p_location_tbl       => l_location_tbl
			     ,p_generic_id_tbl     => l_generic_id_tbl
			     ,p_lookup_tbl         => l_lookup_tbl
			     ,p_ins_count_rec      => l_ins_count_rec
			     ,p_oks_txn_inst_tbl   => px_oks_txn_inst_tbl
			     ,p_child_inst_tbl     => px_child_inst_tbl
			    );

	      IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
		 csi_gen_utility_pvt.put_line( 'Error from UPDATE_ITEM_INSTANCE_PVT..');
		 l_msg_index := 1;
		 l_msg_count := x_msg_count;
		 WHILE l_msg_count > 0 LOOP
		     x_msg_data := FND_MSG_PUB.GET
					   ( l_msg_index,
					     FND_API.G_FALSE );
		     csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
		     l_msg_index := l_msg_index + 1;
		     l_msg_count := l_msg_count - 1;
		 END LOOP;
		 --  RAISE FND_API.G_EXC_ERROR;
		 p_instance_tbl(k).processed_flag := 'E';
		 l_iface_error_text := substr(x_msg_data,1,2000);
		 l_grp_error_count := l_grp_error_count + 1;
		 l_grp_upd_error_tbl(l_grp_error_count).instance_id := l_new_instance_rec.instance_id;
		 l_grp_upd_error_tbl(l_grp_error_count).entity_name := 'INSTANCE';
		 l_grp_upd_error_tbl(l_grp_error_count).error_message := l_iface_error_text;
	      ELSE
		 p_instance_tbl(k).processed_flag := 'P';
	      END IF;
	   END IF;
	END IF;
     END LOOP;
  END IF; -- l_exp_tbl.count check
  --
   -- Call the Version label API to associate a version label for the updated record
   IF (p_instance_tbl.count > 0) THEN
      FOR ins_row IN p_instance_tbl.FIRST .. p_instance_tbl.LAST
      LOOP
         l_iface_error_text := NULL;
         IF p_instance_tbl.EXISTS(ins_row) AND
            p_instance_tbl(ins_row).processed_flag = 'P' THEN
            -- Added by rtalluri for Bug 2256588 on 03/26/02
            -- Call the Version label API to associate a version label for the updated record
            OPEN  instance_csr (p_instance_tbl(ins_row).instance_id);
            FETCH instance_csr INTO l_instance_csr;
            CLOSE instance_csr;
            --
            IF p_instance_tbl(ins_row).active_end_date = FND_API.G_MISS_DATE
            THEN
               l_active_end_date := l_instance_csr.active_end_date;
            ELSE
              l_active_end_date := p_instance_tbl(ins_row).active_end_date;
            END IF;
            --
            IF  ((l_active_end_date > SYSDATE) OR
                (l_active_end_date IS NULL))
            THEN
               IF    ((p_instance_tbl(ins_row).version_label IS NOT NULL) AND
                     (p_instance_tbl(ins_row).version_label <> FND_API.G_MISS_CHAR))
               THEN
               -- Check if version label already exists in csi_i_version_labels
               -- If exists then raise an error message
                  BEGIN
                     SELECT 'x'
                     INTO   l_dummy
                     FROM   csi_i_version_labels
                     WHERE  instance_id = p_instance_tbl(ins_row).instance_id
                     AND    version_label = p_instance_tbl(ins_row).version_label
                     AND    ROWNUM=1;
                     l_iface_error_text := substr(x_msg_data,1,2000);
                     l_grp_error_count := l_grp_error_count + 1;
                     l_grp_upd_error_tbl(l_grp_error_count).instance_id := p_instance_tbl(ins_row).instance_id;
                     l_grp_upd_error_tbl(l_grp_error_count).entity_name := 'VERSION_LABEL';
                     l_grp_upd_error_tbl(l_grp_error_count).error_message := l_iface_error_text;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        l_version_label_rec := l_temp_version_label_rec;
                        l_version_label_rec.instance_id           := p_instance_tbl(ins_row).instance_id;
                        l_version_label_rec.version_label         := p_instance_tbl(ins_row).version_label;
                        l_version_label_rec.description           := p_instance_tbl(ins_row).version_label_description;
                        l_version_label_rec.date_time_stamp       := SYSDATE;
                        -- calling create version label api
                        csi_item_instance_pvt.create_version_label
                          ( p_api_version         => p_api_version
                           ,p_commit              => p_commit
                           ,p_init_msg_list       => p_init_msg_list
                           ,p_validation_level    => p_validation_level
                           ,p_version_label_rec   => l_version_label_rec
                           ,p_txn_rec             => p_txn_rec
                           ,x_return_status       => x_return_status
                           ,x_msg_count           => x_msg_count
                           ,x_msg_data            => x_msg_data         );

                        IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                           csi_gen_utility_pvt.put_line( ' Error from CSI_ITEM_INSTANCE_PVT.CREATE_VERSION_LABEL..');
                           l_msg_index := 1;
                           l_msg_count := x_msg_count;
                           WHILE l_msg_count > 0 LOOP
                                         x_msg_data := FND_MSG_PUB.GET
                                             (  l_msg_index,
                                                FND_API.G_FALSE        );
                                         csi_gen_utility_pvt.put_line( ' MESSAGE DATA = '||x_msg_data);
                                         l_msg_index := l_msg_index + 1;
                                         l_msg_count := l_msg_count - 1;
                           END LOOP;
                           p_instance_tbl(ins_row).processed_flag := 'E';
                           l_iface_error_text := substr(x_msg_data,1,2000);
                           l_grp_error_count := l_grp_error_count + 1;
                           l_grp_upd_error_tbl(l_grp_error_count).instance_id := p_instance_tbl(ins_row).instance_id;
                           l_grp_upd_error_tbl(l_grp_error_count).entity_name := 'VERSION_LABEL';
                           l_grp_upd_error_tbl(l_grp_error_count).error_message := l_iface_error_text;
                          --  RAISE FND_API.G_EXC_ERROR;
                        ELSE
                           p_instance_tbl(ins_row).processed_flag := 'P';
                        END IF;
                     WHEN OTHERS THEN
                        p_instance_tbl(ins_row).processed_flag := 'E';
                        l_iface_error_text := substr(x_msg_data,1,2000);
                        l_grp_error_count := l_grp_error_count + 1;
                        l_grp_upd_error_tbl(l_grp_error_count).instance_id := p_instance_tbl(ins_row).instance_id;
                        l_grp_upd_error_tbl(l_grp_error_count).entity_name := 'VERSION_LABEL';
                        l_grp_upd_error_tbl(l_grp_error_count).error_message := l_iface_error_text;
                  END;
               END IF; -- p_instance_tbl(ins_row).version_label is not null
            END IF; -- l_active_end_date
            -- Calling Contracts
            -- Added on 02-OCT-01
            l_iface_error_text := NULL;
	    --
	    BEGIN
	       SELECT cip.party_id
	       INTO   l_party_id
	       FROM   csi_i_parties cip
	       WHERE  cip.instance_id = p_instance_tbl(ins_row).instance_id
	       AND    cip.relationship_type_code = 'OWNER';
	    EXCEPTION
	       WHEN OTHERS THEN
	          l_party_id := NULL;
	    END;
            --
            csi_gen_utility_pvt.put_line('Checking for UPD...');
            IF p_instance_tbl(ins_row).quantity IS NOT NULL AND
               p_instance_tbl(ins_row).quantity <> FND_API.G_MISS_NUM AND
               p_instance_tbl(ins_row).quantity <> l_old_instance_tbl(ins_row).quantity THEN
               IF l_party_id IS NOT NULL AND
                  l_party_id <> l_internal_party_id THEN
                  IF p_txn_rec.transaction_type_id <> 7 THEN  -- Added for bug 3973706
		     csi_item_instance_pvt.Call_to_Contracts
		     ( p_transaction_type   =>   'UPD'
		      ,p_instance_id        =>   p_instance_tbl(ins_row).instance_id
		      ,p_new_instance_id    =>   NULL
		      ,p_vld_org_id         =>   l_instance_csr.last_vld_organization_id
		      ,p_quantity           =>   l_old_instance_tbl(ins_row).quantity
		      ,p_party_account_id1  =>   NULL
		      ,p_party_account_id2  =>   NULL
		      ,p_transaction_date   =>   p_txn_rec.transaction_date -- l_transaction_date
		      ,p_source_transaction_date   =>   p_txn_rec.source_transaction_date -- l_transaction_date
		      ,p_grp_call_contracts =>   FND_API.G_TRUE
		      ,p_order_line_id      =>   l_order_line_id
		      ,p_oks_txn_inst_tbl   =>   px_oks_txn_inst_tbl
		      ,x_return_status      =>   x_return_status
		      ,x_msg_count          =>   x_msg_count
		      ,x_msg_data           =>   x_msg_data
		     );
		     --
		     IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
		        l_msg_index := 1;
		        l_msg_count := x_msg_count;
		        WHILE l_msg_count > 0 LOOP
		 	   x_msg_data := FND_MSG_PUB.GET
				      (  l_msg_index,
					 FND_API.G_FALSE
				       );
			   csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
			   l_msg_index := l_msg_index + 1;
			   l_msg_count := l_msg_count - 1;
		        END LOOP;
		        l_iface_error_text := substr(x_msg_data,1,2000);
		        p_instance_tbl(ins_row).processed_flag := 'E';
		        l_grp_error_count := l_grp_error_count + 1;
		        l_grp_upd_error_tbl(l_grp_error_count).instance_id := p_instance_tbl(ins_row).instance_id;
		        l_grp_upd_error_tbl(l_grp_error_count).entity_name := 'INS_CONTRACTS';
		        l_grp_upd_error_tbl(l_grp_error_count).error_message := l_iface_error_text;
		        -- RAISE FND_API.G_EXC_ERROR;
		     ELSE
		        p_instance_tbl(ins_row).processed_flag := 'P';
		     END IF;
                  END IF;
               END IF;
            END IF; -- Qty Update check
            --
            IF p_instance_tbl(ins_row).install_date IS NOT NULL AND
               p_instance_tbl(ins_row).install_date <> FND_API.G_MISS_DATE AND
               p_instance_tbl(ins_row).install_date <>
                               nvl(l_old_instance_tbl(ins_row).install_date,fnd_api.g_miss_date) THEN
               IF l_party_id IS NOT NULL AND
                  l_party_id <> l_internal_party_id THEN
                  IF p_txn_rec.transaction_type_id <> 7 THEN  -- Added for bug 3973706
		     csi_item_instance_pvt.Call_to_Contracts
		     ( p_transaction_type   =>   'IDC'
		      ,p_instance_id        =>   p_instance_tbl(ins_row).instance_id
		      ,p_new_instance_id    =>   NULL
		      ,p_vld_org_id         =>   l_instance_csr.last_vld_organization_id
		      ,p_quantity           =>   l_instance_csr.quantity
		      ,p_party_account_id1  =>   NULL
		      ,p_party_account_id2  =>   NULL
		      ,p_transaction_date   =>   p_txn_rec.transaction_date -- l_transaction_date
		      ,p_source_transaction_date   =>   p_txn_rec.source_transaction_date -- l_transaction_date
		      ,p_grp_call_contracts =>   FND_API.G_TRUE
		      ,p_oks_txn_inst_tbl   =>   px_oks_txn_inst_tbl
		      ,x_return_status      =>   x_return_status
		      ,x_msg_count          =>   x_msg_count
		      ,x_msg_data           =>   x_msg_data
		     );
		     --
		     IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
		        l_msg_index := 1;
		        l_msg_count := x_msg_count;
		        WHILE l_msg_count > 0 LOOP
		 	   x_msg_data := FND_MSG_PUB.GET
				      (  l_msg_index,
					 FND_API.G_FALSE
				       );
			   csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
			   l_msg_index := l_msg_index + 1;
			   l_msg_count := l_msg_count - 1;
		        END LOOP;
		        l_iface_error_text := substr(x_msg_data,1,2000);
		        p_instance_tbl(ins_row).processed_flag := 'E';
		        l_grp_error_count := l_grp_error_count + 1;
		        l_grp_upd_error_tbl(l_grp_error_count).instance_id := p_instance_tbl(ins_row).instance_id;
		        l_grp_upd_error_tbl(l_grp_error_count).entity_name := 'INS_CONTRACTS';
		        l_grp_upd_error_tbl(l_grp_error_count).error_message := l_iface_error_text;
		        -- RAISE FND_API.G_EXC_ERROR;
		     ELSE
		        p_instance_tbl(ins_row).processed_flag := 'P';
		     END IF;
                  END IF;
               END IF;
            END IF; -- Install Date Update check
            --
            IF csi_item_instance_vld_pvt.termination_status
               ( p_instance_status_id => l_instance_csr.instance_status_id )
            THEN
               l_transaction_type := 'TRM';
               l_transaction_date := l_instance_csr.active_end_date;
            END IF;
            --
            IF l_transaction_type IS NULL
            THEN
               IF l_old_instance_tbl(ins_row).active_end_date <= SYSDATE
                  AND (p_instance_tbl(ins_row).active_end_date IS NULL
                  OR p_instance_tbl(ins_row).active_end_date > SYSDATE )
               THEN

                  IF l_party_id IS NOT NULL AND
                     l_internal_party_id IS NOT NULL AND
                     l_party_id <> l_internal_party_id
                  THEN
                     -- End addition by sk for fixing bug 2245976
                     l_transaction_type := 'NEW';
                     l_transaction_date := l_instance_csr.active_end_date;
                     --
	             --  While un-expiring the instance, order Line ID will passed only if it is changing
                     --
                     IF l_instance_csr.location_type_code = 'IN_TRANSIT' THEN
                        IF NVL(l_old_instance_tbl(ins_row).in_transit_order_line_id,FND_API.G_MISS_NUM) <>
                           NVL(l_instance_csr.in_transit_order_line_id,FND_API.G_MISS_NUM) THEN
                           l_order_line_id := l_instance_csr.in_transit_order_line_id;
                        ELSE
                           l_order_line_id := NULL;
                        END IF;
                     ELSE
                        IF NVL(l_old_instance_tbl(ins_row).last_oe_order_line_id,FND_API.G_MISS_NUM) <>
                           NVL(l_instance_csr.last_oe_order_line_id,FND_API.G_MISS_NUM) THEN
                           l_order_line_id := l_instance_csr.last_oe_order_line_id;
                        ELSE
                           l_order_line_id := NULL;
                        END IF;
                     END IF;
                  ELSE
                     l_transaction_type := NULL;
                  END IF;
               END IF;
            END IF;
            --
            IF l_transaction_type IS NOT NULL
            THEN
               csi_item_instance_pvt.Call_to_Contracts
                ( p_transaction_type   =>   l_transaction_type
                 ,p_instance_id        =>   p_instance_tbl(ins_row).instance_id
                 ,p_new_instance_id    =>   NULL
                 ,p_vld_org_id         =>   l_instance_csr.last_vld_organization_id
                 ,p_quantity           =>   NULL
                 ,p_party_account_id1  =>   NULL
                 ,p_party_account_id2  =>   NULL
                 ,p_transaction_date   =>   p_txn_rec.transaction_date -- l_transaction_date
                 ,p_source_transaction_date   =>   p_txn_rec.source_transaction_date -- l_transaction_date
                 ,p_grp_call_contracts =>   FND_API.G_TRUE
                 ,p_order_line_id      =>   l_order_line_id
		 ,p_oks_txn_inst_tbl   =>   px_oks_txn_inst_tbl
                 ,x_return_status      =>   x_return_status
                 ,x_msg_count          =>   x_msg_count
                 ,x_msg_data           =>   x_msg_data
		);
               --
               IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                  l_msg_index := 1;
                  l_msg_count := x_msg_count;
                  WHILE l_msg_count > 0 LOOP
                      x_msg_data := FND_MSG_PUB.GET
                                  (  l_msg_index,
                                     FND_API.G_FALSE
                                   );
                     csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
                     l_msg_index := l_msg_index + 1;
                     l_msg_count := l_msg_count - 1;
                  END LOOP;
                  l_iface_error_text := substr(x_msg_data,1,2000);
                  p_instance_tbl(ins_row).processed_flag := 'E';
                  l_grp_error_count := l_grp_error_count + 1;
                  l_grp_upd_error_tbl(l_grp_error_count).instance_id := p_instance_tbl(ins_row).instance_id;
                  l_grp_upd_error_tbl(l_grp_error_count).entity_name := 'INS_CONTRACTS';
                  l_grp_upd_error_tbl(l_grp_error_count).error_message := l_iface_error_text;
                  -- RAISE FND_API.G_EXC_ERROR;
               ELSE
                  p_instance_tbl(ins_row).processed_flag := 'P';
               END IF;
            END IF; --l_transaction_type is not null
         END IF; --p_instance_tbl.EXISTS(ins_row)
      END LOOP;
   END IF; --p_instance_tbl.count > 0
   --
   IF px_oks_txn_inst_tbl.count > 0 THEN
      IF l_debug_level > 1 THEN
	 csi_gen_utility_pvt.dump_oks_txn_inst_tbl(px_oks_txn_inst_tbl);
	 csi_gen_utility_pvt.put_line('Calling OKS Core API...');
      END IF;
      --
      IF p_txn_rec.transaction_type_id = 3 THEN
         l_batch_id := p_txn_rec.source_header_ref_id;
         l_batch_type := p_txn_rec.source_group_ref;
      ELSE
         l_batch_id := NULL;
         l_batch_type := NULL;
      END IF;
      --
      UPDATE CSI_TRANSACTIONS
      set contracts_invoked = 'Y'
      where transaction_id = p_txn_rec.transaction_id;
      --
      OKS_IBINT_PUB.IB_interface
	 (
	   P_Api_Version           =>  1.0,
	   P_init_msg_list         =>  p_init_msg_list,
	   P_single_txn_date_flag  =>  'N',
	   P_Batch_type            =>  l_batch_type,
	   P_Batch_ID              =>  l_batch_id,
	   P_OKS_Txn_Inst_tbl      =>  px_oks_txn_inst_tbl,
	   x_return_status         =>  x_return_status,
	   x_msg_count             =>  x_msg_count,
	   x_msg_data              =>  x_msg_data
	);
	 csi_gen_utility_pvt.put_line('Status returned from Oks_ibint_pub.IB_interface is :'||x_return_status);
      --
      IF x_return_status = 'W' THEN -- Warning from OKS
         -- Since OKS does not have the ability to pass the instance_id for the warning record(s),
         -- we are not populating the grp error tbl. We are still looping thru' the message stack
         -- just in case IB UI calls group API during Update.
         --
	 l_msg_index := 1;
	 l_msg_count := x_msg_count;
	 WHILE l_msg_count > 0 LOOP
	    x_msg_data := FND_MSG_PUB.GET
		     (  l_msg_index,
			FND_API.G_FALSE
		      );
	    csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
	    l_msg_index := l_msg_index + 1;
	    l_msg_count := l_msg_count - 1;
	 END LOOP;
	 FND_MSG_PUB.Count_And_Get
	 ( p_count                 =>      x_msg_count,
	   p_data                  =>      x_msg_data
	 );
      ELSIF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
	 csi_gen_utility_pvt.put_line('Error from Call_to_contracts...');
	 l_msg_index := 1;
	 l_msg_count := x_msg_count;
	 WHILE l_msg_count > 0 LOOP
	   x_msg_data := FND_MSG_PUB.GET
		       (  l_msg_index,
			  FND_API.G_FALSE
			);
	     csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
	   l_msg_index := l_msg_index + 1;
	   l_msg_count := l_msg_count - 1;
	 END LOOP;
	 l_iface_error_text := substr(x_msg_data,1,2000);
	 --
         IF p_instance_tbl.count > 0 THEN
	    FOR ins_row IN p_instance_tbl.FIRST .. p_instance_tbl.LAST LOOP
	       IF p_instance_tbl.EXISTS(ins_row) THEN
	          p_instance_tbl(ins_row).processed_flag := 'E';
                  l_grp_error_count := l_grp_error_count + 1;
                  l_grp_upd_error_tbl(l_grp_error_count).instance_id := p_instance_tbl(ins_row).instance_id;
                  l_grp_upd_error_tbl(l_grp_error_count).entity_name := 'INS_CONTRACTS';
                  l_grp_upd_error_tbl(l_grp_error_count).error_message := l_iface_error_text;
               END IF;
            END LOOP;
         END IF;
         --
	 -- if OKS returns error then everthing gets rolledback
         p_grp_upd_error_tbl := l_grp_upd_error_tbl;
	 RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;
   --
   p_grp_upd_error_tbl := l_grp_upd_error_tbl;
   --
   -- End of API body
   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;
   /***** srramakr commented for bug # 3304439
   -- Check for the profile option and disable the trace
   IF (l_flag = 'Y') THEN
        dbms_session.set_sql_trace(FALSE);
   END IF;
   -- End disable trace
   ****/
   -- Standard call to get message count and if count is  get message info.
   FND_MSG_PUB.Count_And_Get
         (p_count        =>      x_msg_count ,
          p_data         =>      x_msg_data
         );
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO update_item_instance;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
                (       p_count                 =>      x_msg_count,
                p_data                  =>      x_msg_data
                );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO update_item_instance;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
        (       p_count                 =>      x_msg_count,
                p_data                  =>      x_msg_data
        );

    WHEN OTHERS THEN
       ROLLBACK TO update_item_instance;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       IF FND_MSG_PUB.Check_Msg_Level
          (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
          FND_MSG_PUB.Add_Exc_Msg
                (       G_PKG_NAME          ,
                        l_api_name
                );
       END IF;
       FND_MSG_PUB.Count_And_Get
                (       p_count                 =>      x_msg_count,
                        p_data                  =>      x_msg_data
                );
END update_item_instance;
--
/*----------------------------------------------------*/
/* Procedure name: expire_item_instance               */
/* Description :   procedure for                      */
/*                 Expiring an Item Instance          */
/*----------------------------------------------------*/

PROCEDURE expire_item_instance
 (
      p_api_version         IN      NUMBER
     ,p_commit              IN      VARCHAR2
     ,p_init_msg_list       IN      VARCHAR2
     ,p_validation_level    IN      NUMBER
     ,p_instance_tbl        IN      csi_datastructures_pub.instance_tbl
     ,p_expire_children     IN      VARCHAR2
     ,p_txn_rec             IN OUT NOCOPY  csi_datastructures_pub.transaction_rec
     ,x_instance_id_lst     OUT NOCOPY     csi_datastructures_pub.id_tbl
     ,p_grp_error_tbl       OUT NOCOPY     csi_datastructures_pub.grp_error_tbl
     ,x_return_status       OUT NOCOPY     VARCHAR2
     ,x_msg_count           OUT NOCOPY     NUMBER
     ,x_msg_data            OUT NOCOPY     VARCHAR2
 )
IS
     l_api_name              CONSTANT VARCHAR2(30)     := 'EXPIRE_ITEM_INSTANCE';
     l_api_version           CONSTANT NUMBER                   := 1.0;
     l_debug_level           NUMBER;
     l_flag                  VARCHAR2(1);
     l_msg_index             NUMBER;
     l_msg_count             NUMBER;
     l_iface_error_text      VARCHAR2(2000);
     l_grp_error_tbl         csi_datastructures_pub.grp_error_tbl;
     l_instance_rec          csi_datastructures_pub.instance_rec;
     px_oks_txn_inst_tbl     OKS_IBINT_PUB.TXN_INSTANCE_TBL;
     l_batch_type            VARCHAR2(50);
     l_batch_id              NUMBER;
     --
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT  expire_item_instance;

   -- Check for freeze_flag in csi_install_parameters is set to 'Y'

   csi_utility_grp.check_ib_active;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version,
				       p_api_version,
				       l_api_name   ,
				       G_PKG_NAME   )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Check the profile option debug_level for debug message reporting
   l_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');

   -- If debug_level = 1 then dump the procedure name
   IF (l_debug_level > 0) THEN
       csi_gen_utility_pvt.put_line( 'expire_item_instance');
   END IF;
   --
   IF (p_instance_tbl.count > 0) THEN
       FOR ins_row IN p_instance_tbl.FIRST .. p_instance_tbl.LAST
       LOOP
	  IF p_instance_tbl.EXISTS(ins_row) THEN
	     -- If the debug level = 2 then dump all the parameters values.
	     IF (l_debug_level > 1) THEN
		 csi_gen_utility_pvt.put_line( 'expire_item_instance:'  ||
						p_api_version      ||'-'||
						p_commit           ||'-'||
						p_init_msg_list    ||'-'||
						p_validation_level      );
		   -- Dump the records in the log file
		   csi_gen_utility_pvt.dump_txn_rec(p_txn_rec);
		   csi_gen_utility_pvt.dump_instance_rec(p_instance_tbl(ins_row));
	      END IF;
	      /***** srramakr commented for bug # 3304439
	      -- Check for the profile option and enable trace
	      l_flag:=CSI_GEN_UTILITY_PVT.enable_trace(l_trace_flag => l_flag);
	      -- End enable trace
	      ****/
	      -- Start API body
	      l_iface_error_text := NULL;
	      l_grp_error_tbl(ins_row).group_inst_num := ins_row;
	      l_grp_error_tbl(ins_row).process_status := 'S';
	      l_grp_error_tbl(ins_row).error_message := NULL;
	      l_instance_rec := p_instance_tbl(ins_row);
	      l_instance_rec.grp_call_contracts := FND_API.G_TRUE;
	      csi_item_instance_pvt.expire_item_instance
		      (
		       p_api_version      => p_api_version
		      ,p_commit           => fnd_api.g_false
		      ,p_init_msg_list    => p_init_msg_list
		      ,p_validation_level => p_validation_level
		      ,p_instance_rec     => l_instance_rec
		      ,p_expire_children  => p_expire_children
		      ,p_txn_rec          => p_txn_rec
		      ,x_instance_id_lst  => x_instance_id_lst
		      ,p_oks_txn_inst_tbl => px_oks_txn_inst_tbl
		      ,x_return_status    => x_return_status
		      ,x_msg_count        => x_msg_count
		      ,x_msg_data         => x_msg_data
		      );

		   IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
		     l_msg_index := 1;
		     l_msg_count := x_msg_count;
		     WHILE l_msg_count > 0 LOOP
		     x_msg_data := FND_MSG_PUB.GET
					      (
						l_msg_index,
						FND_API.G_FALSE
					      );
		       csi_gen_utility_pvt.put_line('message data = '||x_msg_data);
		       l_msg_index := l_msg_index + 1;
		       l_msg_count := l_msg_count - 1;
		     END LOOP;
		     --
		     l_iface_error_text := substr(x_msg_data,1,2000);
		     l_grp_error_tbl(ins_row).process_status := 'E';
		     l_grp_error_tbl(ins_row).error_message := l_iface_error_text;
		   END IF;
		   --
	    END IF;
	 END LOOP;
      END IF;
      --
      IF px_oks_txn_inst_tbl.count > 0 THEN
	 IF l_debug_level > 1 THEN
	    csi_gen_utility_pvt.dump_oks_txn_inst_tbl(px_oks_txn_inst_tbl);
	    csi_gen_utility_pvt.put_line('Calling OKS Core API...');
	 END IF;
	 --
	 IF p_txn_rec.transaction_type_id = 3 THEN
	    l_batch_id := p_txn_rec.source_header_ref_id;
	    l_batch_type := p_txn_rec.source_group_ref;
	 ELSE
	    l_batch_id := NULL;
	    l_batch_type := NULL;
	 END IF;
	 --
         UPDATE CSI_TRANSACTIONS
         set contracts_invoked = 'Y'
         where transaction_id = p_txn_rec.transaction_id;
         --
	 OKS_IBINT_PUB.IB_interface
	    (
	      P_Api_Version           =>  1.0,
	      P_init_msg_list         =>  p_init_msg_list,
	      P_single_txn_date_flag  =>  'N',
	      P_Batch_type            =>  l_batch_type,
	      P_Batch_ID              =>  l_batch_id,
	      P_OKS_Txn_Inst_tbl      =>  px_oks_txn_inst_tbl,
	      x_return_status         =>  x_return_status,
	      x_msg_count             =>  x_msg_count,
	      x_msg_data              =>  x_msg_data
	   );
	 csi_gen_utility_pvt.put_line('Status returned from Oks_ibint_pub.IB_interface is :'||x_return_status);
	 --
	 IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS)
	 THEN
	    csi_gen_utility_pvt.put_line('Error from Call_to_contracts...');
	    l_msg_index := 1;
	    l_msg_count := x_msg_count;
	    WHILE l_msg_count > 0 LOOP
	      x_msg_data := FND_MSG_PUB.GET
			  (  l_msg_index,
			     FND_API.G_FALSE
			   );
		csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
	      l_msg_index := l_msg_index + 1;
	      l_msg_count := l_msg_count - 1;
	    END LOOP;
	    l_iface_error_text := substr(x_msg_data,1,2000);
	    --
	    FOR ins_row IN p_instance_tbl.FIRST .. p_instance_tbl.LAST LOOP
	       IF p_instance_tbl.EXISTS(ins_row) THEN
		  l_grp_error_tbl(ins_row).process_status := 'E';
		  l_grp_error_tbl(ins_row).error_message := l_iface_error_text;
	       END IF;
	    END LOOP;
	    -- if OKS returns error then everthing gets rolledback
	    p_grp_error_tbl := l_grp_error_tbl;
	    RAISE FND_API.G_EXC_ERROR;
	 END IF;
      END IF;
      --
      p_grp_error_tbl := l_grp_error_tbl;
      -- End of API body
      -- Standard check of p_commit.
      IF FND_API.To_Boolean( p_commit ) THEN
         COMMIT WORK;
      END IF;

      /***** srramakr commented for bug # 3304439
      -- Check for the profile option and disable the trace
      IF (l_flag = 'Y') THEN
          dbms_session.set_sql_trace(FALSE);
      END IF;
      -- End disable trace
      ****/
      -- Standard call to get message count and if count is  get message info.
      FND_MSG_PUB.Count_And_Get
                (p_count        =>      x_msg_count ,
                 p_data         =>      x_msg_data   );

EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO expire_item_instance;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                FND_MSG_PUB.Count_And_Get
                (       p_count                 =>      x_msg_count,
                        p_data                  =>      x_msg_data
                );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO expire_item_instance;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.Count_And_Get
                (  p_count     =>      x_msg_count,
                   p_data      =>      x_msg_data  );

        WHEN OTHERS THEN
                ROLLBACK TO expire_item_instance;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                IF FND_MSG_PUB.Check_Msg_Level
                     (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                   FND_MSG_PUB.Add_Exc_Msg
                    ( G_PKG_NAME, l_api_name );
                END IF;
                FND_MSG_PUB.Count_And_Get
                (  p_count    =>      x_msg_count,
                   p_data     =>      x_msg_data  );

END  expire_item_instance;
--
/**********************************************************
** This Procedure gets all the parents traversing up     **
** for a given child(subject) with the relationship type **
** COMPONENT-OF. It stops traversing when the top-most   **
** is reached or the relationship is broken.             **
***********************************************************/

PROCEDURE Get_All_Parents
  (
    p_api_version      IN  NUMBER,
    p_commit           IN  VARCHAR2,
    p_init_msg_list    IN  VARCHAR2,
    p_validation_level IN  NUMBER,
    p_subject_id       IN  NUMBER,
    x_rel_tbl          OUT NOCOPY csi_datastructures_pub.ii_relationship_tbl,
    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_count        OUT NOCOPY NUMBER,
    x_msg_data         OUT NOCOPY VARCHAR2
  ) IS
   l_api_version       CONSTANT NUMBER := 1.0;
   l_api_name          CONSTANT VARCHAR2(30) := 'GET_ALL_PARENTS';
   l_ctr               NUMBER := 0;
   l_object_id         NUMBER;
   l_subject_id        NUMBER;
   l_exists            VARCHAR2(1);
   l_relationship_id   NUMBER;
   l_rel_type_code     VARCHAR2(30) := 'COMPONENT-OF';
BEGIN
   -- Check for freeze_flag in csi_install_parameters is set to 'Y'
   csi_utility_grp.check_ib_active;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version,
				       p_api_version,
				       l_api_name,
				       G_PKG_NAME
				     )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   --
   IF p_subject_id IS NULL OR p_subject_id = FND_API.G_MISS_NUM THEN
      fnd_message.set_name('CSI', 'CSI_INVALID_PARAMETERS');
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error;
      RAISE fnd_api.g_exc_error;
   END IF;
   --
   l_subject_id := p_subject_id;
   --
   csi_gen_utility_pvt.put_line('Given Subject ID is '||to_char(l_subject_id));
   --
   LOOP
      Begin
	 select relationship_id,object_id
	 into l_relationship_id,l_object_id
	 from CSI_II_RELATIONSHIPS
	 where subject_id = l_subject_id
	 and   relationship_type_code = l_rel_type_code
	 and   ((active_end_date is null) or (active_end_date > sysdate));
	 --
	 l_ctr := l_ctr + 1;
	 x_rel_tbl(l_ctr).subject_id := l_subject_id;
	 x_rel_tbl(l_ctr).object_id := l_object_id;
	 x_rel_tbl(l_ctr).relationship_id := l_relationship_id;
	 x_rel_tbl(l_ctr).relationship_type_code := l_rel_type_code;
	 --
         -- Just in case a cycle exists because of bad data the following check will break
         -- the loop.
	 l_exists := 'N';
	 IF x_rel_tbl.count > 0 THEN
	    FOR j in x_rel_tbl.FIRST .. x_rel_tbl.LAST Loop
	       IF l_object_id = x_rel_tbl(j).subject_id THEN
		  l_exists := 'Y';
		  exit;
	       END IF;
	    End Loop;
	 END IF;
	 --
	 IF l_exists = 'Y' THEN
	    exit;
	 END IF;
	 --
	 l_subject_id := l_object_id;
      Exception
	 when no_data_found then
	    exit;
      End;
   END LOOP;
   -- End of API body
  -- Standard call to get message count and if count is  get message info.
  FND_MSG_PUB.Count_And_Get
       (p_count        =>      x_msg_count ,
	p_data         =>      x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
	  ( p_count                 =>      x_msg_count,
	    p_data                  =>      x_msg_data
	  );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
	  ( p_count                 =>      x_msg_count,
	    p_data                  =>      x_msg_data
	  );

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      csi_gen_utility_pvt.put_line('Others Error   '||substr(sqlerrm,1,250));
      IF FND_MSG_PUB.Check_Msg_Level
		(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
	 FND_MSG_PUB.Add_Exc_Msg
	   ( G_PKG_NAME          ,
	     l_api_name
	   );
      END IF;
      FND_MSG_PUB.Count_And_Get
	 ( p_count                 =>      x_msg_count,
	   p_data                  =>      x_msg_data
	 );
END Get_All_Parents;
--
PROCEDURE Get_And_Build_Instance_Details
   (p_instance_id            IN         NUMBER
   ,p_txn_rec                IN OUT NOCOPY csi_datastructures_pub.transaction_rec
   ,p_instance_rec           OUT NOCOPY csi_datastructures_pub.instance_rec
   ,p_party_tbl              OUT NOCOPY csi_datastructures_pub.party_tbl
   ,p_party_account_tbl      OUT NOCOPY csi_datastructures_pub.party_account_tbl
   ,p_org_units_tbl          OUT NOCOPY csi_datastructures_pub.organization_units_tbl
   ,p_pricing_attribs_tbl    OUT NOCOPY csi_datastructures_pub.pricing_attribs_tbl
   ,p_ext_attrib_values_tbl  OUT NOCOPY csi_datastructures_pub.extend_attrib_values_tbl
   ,p_instance_asset_tbl     OUT NOCOPY csi_datastructures_pub.instance_asset_tbl
   ,x_return_status          OUT NOCOPY VARCHAR2
   ,x_msg_count              OUT NOCOPY NUMBER
   ,x_msg_data               OUT NOCOPY VARCHAR2
  ) IS
   --
   l_api_name           VARCHAR2(30) := 'Get_And_Build_Instance_Details';
   l_instance_rec       csi_datastructures_pub.instance_header_rec;
   p_party_header_tbl   CSI_DATASTRUCTURES_PUB.PARTY_HEADER_TBL;
   p_account_header_tbl CSI_DATASTRUCTURES_PUB.PARTY_ACCOUNT_HEADER_TBL;
   p_org_header_tbl     CSI_DATASTRUCTURES_PUB.ORG_UNITS_HEADER_TBL;
   p_pricing_attrib_tbl CSI_DATASTRUCTURES_PUB.PRICING_ATTRIBS_TBL;
   p_ext_attrib_tbl     CSI_DATASTRUCTURES_PUB.EXTEND_ATTRIB_VALUES_TBL;
   p_ext_attrib_def_tbl CSI_DATASTRUCTURES_PUB.EXTEND_ATTRIB_TBL;
   p_asset_header_tbl   CSI_DATASTRUCTURES_PUB.INSTANCE_ASSET_HEADER_TBL;
   l_party_tbl          csi_datastructures_pub.party_tbl;
   --
   l_ctr                NUMBER;
   l_found              BOOLEAN;
   l_msg_index          NUMBER;
   l_msg_count          NUMBER;
   --
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   IF p_instance_id IS NULL OR
      p_instance_id = FND_API.G_MISS_NUM THEN
      RETURN;
   END IF;
   --
   SAVEPOINT Get_And_Build_Instance_Details;
   --
   l_instance_rec.instance_id := p_instance_id;
   csi_item_instance_pub.get_item_instance_details
    (
       p_api_version           => 1.0,
       p_commit                => fnd_api.g_false,
       p_init_msg_list         => fnd_api.g_true,
       p_validation_level      => fnd_api.g_valid_level_full,
       p_instance_rec          => l_instance_rec,
       p_get_parties           => fnd_api.g_true,
       p_party_header_tbl      => p_party_header_tbl,
       p_get_accounts          => fnd_api.g_true,
       p_account_header_tbl    => p_account_header_tbl,
       p_get_org_assignments   => fnd_api.g_true,
       p_org_header_tbl        => p_org_header_tbl,
       p_get_pricing_attribs   => fnd_api.g_false, -- No need to get for children
       p_pricing_attrib_tbl    => p_pricing_attrib_tbl,
       p_get_ext_attribs       => fnd_api.g_false, -- No need to get for children
       p_ext_attrib_tbl        => p_ext_attrib_tbl,
       p_ext_attrib_def_tbl    => p_ext_attrib_def_tbl,
       p_get_asset_assignments => fnd_api.g_false, -- No need to get for children
       p_asset_header_tbl      => p_asset_header_tbl,
       p_resolve_id_columns    => fnd_api.g_false,
       p_time_stamp            => fnd_api.g_miss_date,
       x_return_status         => x_return_status,
       x_msg_count             => x_msg_count,
       x_msg_data              => x_msg_data
   );
   --
   IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      l_msg_index := 1;
      l_msg_count := x_msg_count;
      WHILE l_msg_count > 0 LOOP
	       x_msg_data := FND_MSG_PUB.GET
			   (  l_msg_index,
			      FND_API.G_FALSE );
	   l_msg_index := l_msg_index + 1;
	   l_msg_count := l_msg_count - 1;
      END LOOP;
      csi_gen_utility_pvt.put_line('Error from Get Instance Details...');
      RAISE FND_API.G_EXC_ERROR;
   END IF;
   --
   p_instance_rec.instance_id             := l_instance_rec.instance_id;
   p_instance_rec.instance_number         := l_instance_rec.instance_number;
   p_instance_rec.external_reference      := l_instance_rec.external_reference;
   p_instance_rec.inventory_item_id       := l_instance_rec.inventory_item_id;
   p_instance_rec.vld_organization_id     := l_instance_rec.vld_organization_id;
   p_instance_rec.inventory_revision      := l_instance_rec.inventory_revision;
   p_instance_rec.inv_master_organization_id      := l_instance_rec.inv_master_organization_id;
   p_instance_rec.serial_number           := l_instance_rec.serial_number;
   p_instance_rec.mfg_serial_number_flag  := l_instance_rec.mfg_serial_number_flag;
   p_instance_rec.lot_number              := l_instance_rec.lot_number;
   p_instance_rec.quantity                := l_instance_rec.quantity;
   p_instance_rec.unit_of_measure         := l_instance_rec.unit_of_measure;
   p_instance_rec.accounting_class_code   := l_instance_rec.accounting_class_code;
   p_instance_rec.instance_condition_id   := l_instance_rec.instance_condition_id;
   p_instance_rec.instance_status_id      := l_instance_rec.instance_status_id;
   p_instance_rec.customer_view_flag      := l_instance_rec.customer_view_flag;
   p_instance_rec.merchant_view_flag      := l_instance_rec.merchant_view_flag;
   p_instance_rec.sellable_flag           := l_instance_rec.sellable_flag;
   p_instance_rec.system_id               := l_instance_rec.system_id;
   p_instance_rec.instance_type_code      := l_instance_rec.instance_type_code;
   p_instance_rec.active_start_date       := l_instance_rec.active_start_date;
   p_instance_rec.active_end_date         := l_instance_rec.active_end_date;
   p_instance_rec.location_type_code      := l_instance_rec.location_type_code;
   p_instance_rec.location_id             := l_instance_rec.location_id;
   p_instance_rec.inv_organization_id     := l_instance_rec.inv_organization_id;
   p_instance_rec.inv_subinventory_name   := l_instance_rec.inv_subinventory_name;
   p_instance_rec.inv_locator_id          := l_instance_rec.inv_locator_id;
   p_instance_rec.pa_project_id           := l_instance_rec.pa_project_id;
   p_instance_rec.pa_project_task_id      := l_instance_rec.pa_project_task_id;
   p_instance_rec.in_transit_order_line_id        := l_instance_rec.in_transit_order_line_id;
   p_instance_rec.wip_job_id              := l_instance_rec.wip_job_id;
   p_instance_rec.po_order_line_id        := l_instance_rec.po_order_line_id;
   p_instance_rec.last_oe_order_line_id   := l_instance_rec.last_oe_order_line_id;
   p_instance_rec.last_oe_rma_line_id     := l_instance_rec.last_oe_rma_line_id;
   p_instance_rec.last_po_po_line_id      := l_instance_rec.last_po_po_line_id;
   p_instance_rec.last_oe_po_number       := l_instance_rec.last_oe_po_number;
   p_instance_rec.last_wip_job_id         := l_instance_rec.last_wip_job_id;
   p_instance_rec.last_pa_project_id      := l_instance_rec.last_pa_project_id;
   p_instance_rec.last_pa_task_id         := l_instance_rec.last_pa_task_id;
   p_instance_rec.last_oe_agreement_id    := l_instance_rec.last_oe_agreement_id;
   p_instance_rec.install_date            := l_instance_rec.install_date;
   p_instance_rec.manually_created_flag   := l_instance_rec.manually_created_flag;
   p_instance_rec.return_by_date          := l_instance_rec.return_by_date;
   p_instance_rec.actual_return_date      := l_instance_rec.actual_return_date;
   p_instance_rec.creation_complete_flag  := l_instance_rec.creation_complete_flag;
   p_instance_rec.completeness_flag       := l_instance_rec.completeness_flag;
   p_instance_rec.context         := l_instance_rec.context;
   p_instance_rec.attribute1      := l_instance_rec.attribute1;
   p_instance_rec.attribute2      := l_instance_rec.attribute2;
   p_instance_rec.attribute3      := l_instance_rec.attribute3;
   p_instance_rec.attribute4      := l_instance_rec.attribute4;
   p_instance_rec.attribute5      := l_instance_rec.attribute5;
   p_instance_rec.attribute6      := l_instance_rec.attribute6;
   p_instance_rec.attribute7      := l_instance_rec.attribute7;
   p_instance_rec.attribute8      := l_instance_rec.attribute8;
   p_instance_rec.attribute9      := l_instance_rec.attribute9;
   p_instance_rec.attribute10     := l_instance_rec.attribute10;
   p_instance_rec.attribute11     := l_instance_rec.attribute11;
   p_instance_rec.attribute12     := l_instance_rec.attribute12;
   p_instance_rec.attribute13     := l_instance_rec.attribute13;
   p_instance_rec.attribute14     := l_instance_rec.attribute14;
   p_instance_rec.attribute15     := l_instance_rec.attribute15;
   p_instance_rec.object_version_number   := l_instance_rec.object_version_number;
   p_instance_rec.last_txn_line_detail_id         := l_instance_rec.last_txn_line_detail_id;
   p_instance_rec.install_location_type_code      := l_instance_rec.install_location_type_code;
   p_instance_rec.install_location_id     := l_instance_rec.install_location_id;
   p_instance_rec.instance_usage_code     := l_instance_rec.instance_usage_code;
   p_instance_rec.config_inst_hdr_id      := l_instance_rec.config_inst_hdr_id;
   p_instance_rec.config_inst_rev_num     := l_instance_rec.config_inst_rev_num;
   p_instance_rec.config_inst_item_id     := l_instance_rec.config_inst_item_id;
   p_instance_rec.config_valid_status     := l_instance_rec.config_valid_status;
   p_instance_rec.instance_description    := l_instance_rec.instance_description;

   p_instance_rec.network_asset_flag        := l_instance_rec.network_asset_flag;
   p_instance_rec.maintainable_flag         := l_instance_rec.maintainable_flag;
   p_instance_rec.asset_criticality_code    := l_instance_rec.asset_criticality_code;
   p_instance_rec.category_id               := l_instance_rec.category_id ;
   p_instance_rec.equipment_gen_object_id   := l_instance_rec.equipment_gen_object_id ;
   p_instance_rec.instantiation_flag        := l_instance_rec.instantiation_flag;
   p_instance_rec.operational_log_flag      := l_instance_rec.operational_log_flag ;
   p_instance_rec.supplier_warranty_exp_date:= l_instance_rec.supplier_warranty_exp_date ;
   p_instance_rec.attribute16               := l_instance_rec.attribute16     ;
   p_instance_rec.attribute17               := l_instance_rec.attribute17     ;
   p_instance_rec.attribute18               := l_instance_rec.attribute18     ;
   p_instance_rec.attribute19               := l_instance_rec.attribute19     ;
   p_instance_rec.attribute20               := l_instance_rec.attribute20     ;
   p_instance_rec.attribute21               := l_instance_rec.attribute21     ;
   p_instance_rec.attribute22               := l_instance_rec.attribute22     ;
   p_instance_rec.attribute23               := l_instance_rec.attribute23     ;
   p_instance_rec.attribute24               := l_instance_rec.attribute24     ;
   p_instance_rec.attribute25               := l_instance_rec.attribute25     ;
   p_instance_rec.attribute26               := l_instance_rec.attribute26     ;
   p_instance_rec.attribute27               := l_instance_rec.attribute27     ;
   p_instance_rec.attribute28               := l_instance_rec.attribute28     ;
   p_instance_rec.attribute29               := l_instance_rec.attribute29     ;
   p_instance_rec.attribute30               := l_instance_rec.attribute30     ;
   --
   p_instance_rec.purchase_unit_price       := l_instance_rec.purchase_unit_price;
   p_instance_rec.purchase_currency_code    := l_instance_rec.purchase_currency_code;
   p_instance_rec.payables_unit_price       := l_instance_rec.payables_unit_price;
   p_instance_rec.payables_currency_code    := l_instance_rec.payables_currency_code;
   p_instance_rec.sales_unit_price          := l_instance_rec.sales_unit_price;
   p_instance_rec.sales_currency_code       := l_instance_rec.sales_currency_code;
   p_instance_rec.operational_status_code   := l_instance_rec.operational_status_code;
   --
   -- Build Party Table
   csi_gen_utility_pvt.put_line('Building party tbl..');
   IF p_party_header_tbl.count > 0 THEN
      l_ctr := l_party_tbl.count;
      FOR i in p_party_header_tbl.FIRST .. p_party_header_tbl.LAST LOOP
         IF nvl(p_party_header_tbl(i).active_end_date,FND_API.G_MISS_DATE) = FND_API.G_MISS_DATE OR
            p_party_header_tbl(i).active_end_date > sysdate THEN
	    l_ctr := l_ctr + 1;
	    --
	    l_party_tbl(l_ctr).instance_party_id     := p_party_header_tbl(i).instance_party_id;
	    l_party_tbl(l_ctr).instance_id   := p_party_header_tbl(i).instance_id;
	    l_party_tbl(l_ctr).party_source_table    := p_party_header_tbl(i).party_source_table;
	    l_party_tbl(l_ctr).party_id      := p_party_header_tbl(i).party_id;
	    l_party_tbl(l_ctr).relationship_type_code        := p_party_header_tbl(i).relationship_type_code;
	    l_party_tbl(l_ctr).contact_flag          := p_party_header_tbl(i).contact_flag;
	    l_party_tbl(l_ctr).contact_ip_id         := p_party_header_tbl(i).contact_ip_id;
	    l_party_tbl(l_ctr).active_start_date     := p_party_header_tbl(i).active_start_date;
	    l_party_tbl(l_ctr).active_end_date       := p_party_header_tbl(i).active_end_date;
	    l_party_tbl(l_ctr).context       := p_party_header_tbl(i).context;
	    l_party_tbl(l_ctr).attribute1    := p_party_header_tbl(i).attribute1;
	    l_party_tbl(l_ctr).attribute2    := p_party_header_tbl(i).attribute2;
	    l_party_tbl(l_ctr).attribute3    := p_party_header_tbl(i).attribute3;
	    l_party_tbl(l_ctr).attribute4    := p_party_header_tbl(i).attribute4;
	    l_party_tbl(l_ctr).attribute5    := p_party_header_tbl(i).attribute5;
	    l_party_tbl(l_ctr).attribute6    := p_party_header_tbl(i).attribute6;
	    l_party_tbl(l_ctr).attribute7    := p_party_header_tbl(i).attribute7;
	    l_party_tbl(l_ctr).attribute8    := p_party_header_tbl(i).attribute8;
	    l_party_tbl(l_ctr).attribute9    := p_party_header_tbl(i).attribute9;
	    l_party_tbl(l_ctr).attribute10   := p_party_header_tbl(i).attribute10;
	    l_party_tbl(l_ctr).attribute11   := p_party_header_tbl(i).attribute11;
	    l_party_tbl(l_ctr).attribute12   := p_party_header_tbl(i).attribute12;
	    l_party_tbl(l_ctr).attribute13   := p_party_header_tbl(i).attribute13;
	    l_party_tbl(l_ctr).attribute14   := p_party_header_tbl(i).attribute14;
	    l_party_tbl(l_ctr).attribute15   := p_party_header_tbl(i).attribute15;
	    l_party_tbl(l_ctr).object_version_number         := p_party_header_tbl(i).object_version_number;
	    l_party_tbl(l_ctr).primary_flag          := p_party_header_tbl(i).primary_flag;
	    l_party_tbl(l_ctr).preferred_flag        := p_party_header_tbl(i).preferred_flag;
	    l_party_tbl(l_ctr).parent_tbl_index := 1;
         END IF;
      END LOOP;
      --
      -- Following loop cannot be moved inside since contact record could come before the parent party
      --
      -- The reason for having l_party_tbl and later assigning qualifying records to p_party_tbl is
      -- we want to pass back p_party_tbl to the caller without any gaps in the slot#. Moreover, the
      -- same set is copied when the BOM is exploded and multiple instances are created.
      -- During that phase, we have to ignore the gaps which will potentially impact the underlying acct tbl
      --
      -- Scan thru' l_party_tbl and get all non-contact party records first
      --
      l_ctr := p_party_tbl.count;
      --
      IF l_party_tbl.count > 0 THEN
	 FOR i in l_party_tbl.FIRST .. l_party_tbl.LAST LOOP
	    IF l_party_tbl.EXISTS(i) THEN
	       IF nvl(l_party_tbl(i).contact_flag,'N') = 'N' THEN
		  l_ctr := l_ctr + 1;
		  p_party_tbl(l_ctr) := l_party_tbl(i);
		  l_party_tbl.DELETE(i); -- Just to reduce the table size
	       END IF;
	    END IF;
	 END LOOP;
      END IF;
      --
      -- Append this with the contact party record after populating the contact_parent_tbl index
      -- Now, l_party_tbl will be left with only contact party records
      --
      l_ctr := p_party_tbl.count;
      --
      IF l_party_tbl.count > 0 THEN
	 FOR i in l_party_tbl.FIRST .. l_party_tbl.LAST LOOP
	    IF l_party_tbl.EXISTS(i) THEN
	       IF l_party_tbl(i).contact_flag = 'Y' THEN -- Verify if parent party exists in p_party_tbl
		  l_found := FALSE;
		  FOR j in p_party_tbl.FIRST .. p_party_tbl.LAST LOOP
		     IF l_party_tbl(i).contact_ip_id = p_party_tbl(j).instance_party_id THEN
			l_party_tbl(i).contact_parent_tbl_index := j;
			l_ctr := l_ctr + 1;
			p_party_tbl(l_ctr) := l_party_tbl(i);
			exit;
		     END IF;
		  END LOOP;
	       END IF;
	    END IF;
	 END LOOP;
      END IF;
   END IF;
   --
   -- Build Account Table from Account Header Table
   csi_gen_utility_pvt.put_line('Building Account tbl..');
   IF p_account_header_tbl.count > 0 AND
      p_party_tbl.count > 0 THEN
      l_ctr := p_party_account_tbl.count;
      FOR i in p_account_header_tbl.FIRST .. p_account_header_tbl.LAST LOOP
         IF nvl(p_account_header_tbl(i).active_end_date,FND_API.G_MISS_DATE) = FND_API.G_MISS_DATE OR
            p_account_header_tbl(i).active_end_date > sysdate THEN
            l_found := FALSE;
            --
	    FOR j in p_party_tbl.FIRST .. p_party_tbl.LAST LOOP
	       IF p_party_tbl(j).instance_party_id = p_account_header_tbl(i).instance_party_id THEN
	          l_ctr := l_ctr + 1;
		  p_party_account_tbl(l_ctr).parent_tbl_index := j;
                  l_found := TRUE; -- Corresponding party record found
		  exit;
	       END IF;
	    END LOOP;
	    --
            IF l_found = TRUE THEN
               -- l_ctr would have got incremented while setting l_found to TRUE
	       p_party_account_tbl(l_ctr).ip_account_id :=    p_account_header_tbl(i).ip_account_id;
	       p_party_account_tbl(l_ctr).instance_party_id := p_account_header_tbl(i).instance_party_id;
	       p_party_account_tbl(l_ctr).party_account_id := p_account_header_tbl(i).party_account_id;
	       p_party_account_tbl(l_ctr).relationship_type_code := p_account_header_tbl(i).relationship_type_code;
	       p_party_account_tbl(l_ctr).bill_to_address :=  p_account_header_tbl(i).bill_to_address;
	       p_party_account_tbl(l_ctr).ship_to_address :=  p_account_header_tbl(i).ship_to_address;
	       p_party_account_tbl(l_ctr).active_start_date := p_account_header_tbl(i).active_start_date;
	       p_party_account_tbl(l_ctr).active_end_date :=  p_account_header_tbl(i).active_end_date;
	       p_party_account_tbl(l_ctr).context :=  p_account_header_tbl(i).context;
	       p_party_account_tbl(l_ctr).attribute1 :=       p_account_header_tbl(i).attribute1;
	       p_party_account_tbl(l_ctr).attribute2 :=       p_account_header_tbl(i).attribute2;
	       p_party_account_tbl(l_ctr).attribute3 :=       p_account_header_tbl(i).attribute3;
	       p_party_account_tbl(l_ctr).attribute4 :=       p_account_header_tbl(i).attribute4;
	       p_party_account_tbl(l_ctr).attribute5 :=       p_account_header_tbl(i).attribute5;
	       p_party_account_tbl(l_ctr).attribute6 :=       p_account_header_tbl(i).attribute6;
	       p_party_account_tbl(l_ctr).attribute7 :=       p_account_header_tbl(i).attribute7;
	       p_party_account_tbl(l_ctr).attribute8 :=       p_account_header_tbl(i).attribute8;
	       p_party_account_tbl(l_ctr).attribute9 :=       p_account_header_tbl(i).attribute9;
	       p_party_account_tbl(l_ctr).attribute10 :=      p_account_header_tbl(i).attribute10;
	       p_party_account_tbl(l_ctr).attribute11 :=      p_account_header_tbl(i).attribute11;
	       p_party_account_tbl(l_ctr).attribute12 :=      p_account_header_tbl(i).attribute12;
	       p_party_account_tbl(l_ctr).attribute13 :=      p_account_header_tbl(i).attribute13;
	       p_party_account_tbl(l_ctr).attribute14 :=      p_account_header_tbl(i).attribute14;
	       p_party_account_tbl(l_ctr).attribute15 :=      p_account_header_tbl(i).attribute15;
	       p_party_account_tbl(l_ctr).object_version_number :=    p_account_header_tbl(i).object_version_number;
            END IF;
         END IF; -- Active Account record
      END LOOP;
   END IF;
   --
   csi_gen_utility_pvt.put_line('Building Org Assignments tbl..');
   -- Build org Assignments table
   IF p_org_header_tbl.count > 0 THEN
      l_ctr := p_org_units_tbl.count;
      FOR i in p_org_header_tbl.FIRST .. p_org_header_tbl.LAST LOOP
         IF nvl(p_org_header_tbl(i).active_end_date,FND_API.G_MISS_DATE) = FND_API.G_MISS_DATE OR
            p_org_header_tbl(i).active_end_date > sysdate THEN
	    l_ctr := l_ctr + 1;
	    --
	    p_org_units_tbl(l_ctr).instance_ou_id :=       p_org_header_tbl(i).instance_ou_id;
	    p_org_units_tbl(l_ctr).instance_id :=  p_org_header_tbl(i).instance_id;
	    p_org_units_tbl(l_ctr).operating_unit_id :=    p_org_header_tbl(i).operating_unit_id;
	    p_org_units_tbl(l_ctr).relationship_type_code := p_org_header_tbl(i).relationship_type_code;
	    p_org_units_tbl(l_ctr).active_start_date :=    p_org_header_tbl(i).active_start_date;
	    p_org_units_tbl(l_ctr).active_end_date :=      p_org_header_tbl(i).active_end_date;
	    p_org_units_tbl(l_ctr).context :=      p_org_header_tbl(i).context;
	    p_org_units_tbl(l_ctr).attribute1 :=   p_org_header_tbl(i).attribute1;
	    p_org_units_tbl(l_ctr).attribute2 :=   p_org_header_tbl(i).attribute2;
	    p_org_units_tbl(l_ctr).attribute3 :=   p_org_header_tbl(i).attribute3;
	    p_org_units_tbl(l_ctr).attribute4 :=   p_org_header_tbl(i).attribute4;
	    p_org_units_tbl(l_ctr).attribute5 :=   p_org_header_tbl(i).attribute5;
	    p_org_units_tbl(l_ctr).attribute6 :=   p_org_header_tbl(i).attribute6;
	    p_org_units_tbl(l_ctr).attribute7 :=   p_org_header_tbl(i).attribute7;
	    p_org_units_tbl(l_ctr).attribute8 :=   p_org_header_tbl(i).attribute8;
	    p_org_units_tbl(l_ctr).attribute9 :=   p_org_header_tbl(i).attribute9;
	    p_org_units_tbl(l_ctr).attribute10 :=  p_org_header_tbl(i).attribute10;
	    p_org_units_tbl(l_ctr).attribute11 :=  p_org_header_tbl(i).attribute11;
	    p_org_units_tbl(l_ctr).attribute12 :=  p_org_header_tbl(i).attribute12;
	    p_org_units_tbl(l_ctr).attribute13 :=  p_org_header_tbl(i).attribute13;
	    p_org_units_tbl(l_ctr).attribute14 :=  p_org_header_tbl(i).attribute14;
	    p_org_units_tbl(l_ctr).attribute15 :=  p_org_header_tbl(i).attribute15;
	    p_org_units_tbl(l_ctr).object_version_number := p_org_header_tbl(i).object_version_number;
	    p_org_units_tbl(l_ctr).parent_tbl_index := 1;
         END IF;
      END LOOP;
   END IF;
   -- Build Pricing Attrib Table
   csi_gen_utility_pvt.put_line('Building Pricing tbl..');
   IF p_pricing_attrib_tbl.count > 0 THEN
      l_ctr := p_pricing_attribs_tbl.count;
      FOR i in p_pricing_attrib_tbl.FIRST .. p_pricing_attrib_tbl.LAST LOOP
         IF nvl(p_pricing_attrib_tbl(i).active_end_date,FND_API.G_MISS_DATE) = FND_API.G_MISS_DATE OR
            p_pricing_attrib_tbl(i).active_end_date > sysdate THEN
	    l_ctr := l_ctr + 1;
	    p_pricing_attribs_tbl(l_ctr) := p_pricing_attrib_tbl(i);
	    p_pricing_attribs_tbl(l_ctr).parent_tbl_index := 1;
         END IF;
      END LOOP;
   END IF;
   -- Build Extended Attributes Table
   csi_gen_utility_pvt.put_line('Building Ext Attribs tbl..');
   IF p_ext_attrib_tbl.count > 0 THEN
      l_ctr := p_ext_attrib_values_tbl.count;
      FOR i in p_ext_attrib_tbl.FIRST .. p_ext_attrib_tbl.LAST LOOP
         IF nvl(p_ext_attrib_tbl(i).active_end_date,FND_API.G_MISS_DATE) = FND_API.G_MISS_DATE OR
            p_ext_attrib_tbl(i).active_end_date > sysdate THEN
	    l_ctr := l_ctr + 1;
	    p_ext_attrib_values_tbl(l_ctr) := p_ext_attrib_tbl(i);
	    p_ext_attrib_values_tbl(l_ctr).parent_tbl_index := 1;
         END IF;
      END LOOP;
   END IF;
   -- Build Instance Asset Table
   csi_gen_utility_pvt.put_line('Building Instance Asset tbl..');
   IF p_asset_header_tbl.count > 0 THEN
      l_ctr := p_instance_asset_tbl.count;
      FOR i in p_asset_header_tbl.FIRST .. p_asset_header_tbl.LAST LOOP
         IF nvl(p_asset_header_tbl(i).active_end_date,FND_API.G_MISS_DATE) = FND_API.G_MISS_DATE OR
            p_asset_header_tbl(i).active_end_date > sysdate THEN
	    l_ctr := l_ctr + 1;
	    --
	    p_instance_asset_tbl(l_ctr).instance_asset_id := p_asset_header_tbl(i).instance_asset_id;
	    p_instance_asset_tbl(l_ctr).instance_id :=     p_asset_header_tbl(i).instance_id;
	    p_instance_asset_tbl(l_ctr).fa_asset_id :=     p_asset_header_tbl(i).fa_asset_id;
	    p_instance_asset_tbl(l_ctr).fa_book_type_code := p_asset_header_tbl(i).fa_book_type_code;
	    p_instance_asset_tbl(l_ctr).fa_location_id :=  p_asset_header_tbl(i).fa_location_id;
	    p_instance_asset_tbl(l_ctr).asset_quantity :=  p_asset_header_tbl(i).asset_quantity;
	    p_instance_asset_tbl(l_ctr).update_status :=   p_asset_header_tbl(i).update_status;
	    p_instance_asset_tbl(l_ctr).active_start_date := p_asset_header_tbl(i).active_start_date;
	    p_instance_asset_tbl(l_ctr).active_end_date := p_asset_header_tbl(i).active_end_date;
	    p_instance_asset_tbl(l_ctr).object_version_number := p_asset_header_tbl(i).object_version_number;
	    p_instance_asset_tbl(l_ctr).parent_tbl_index := 1;
         END IF;
      END LOOP;
   END IF;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
            ROLLBACK TO Get_And_Build_Instance_Details;
            x_return_status := FND_API.G_RET_STS_ERROR ;
            FND_MSG_PUB.Count_And_Get
                (  p_count               =>      x_msg_count,
                    p_data                =>      x_msg_data
                 );
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            ROLLBACK TO Get_And_Build_Instance_Details;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            FND_MSG_PUB.Count_And_Get
                (  p_count               =>      x_msg_count,
                    p_data                =>      x_msg_data
                 );
      WHEN OTHERS THEN
            ROLLBACK TO  Get_And_Build_Instance_Details;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
              IF       FND_MSG_PUB.Check_Msg_Level
                  (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
                    FND_MSG_PUB.Add_Exc_Msg
                    (      G_PKG_NAME            ,
                          l_api_name
                     );
            END IF;
            FND_MSG_PUB.Count_And_Get
                (  p_count               =>      x_msg_count,
                    p_data                =>      x_msg_data
                );
END Get_And_Build_Instance_Details;
--
/*---------------------------------------------------------*/
/* Procedure name:  Explode_Bom                            */
/* Description :    This procudure explodes the BOM and    */
/*                  creates instances and relationships    */
/* Author      :    Srinivasan Ramakrishnan                */
/*---------------------------------------------------------*/
PROCEDURE Explode_Bom
 (
   p_api_version            IN     NUMBER
  ,p_commit                 IN     VARCHAR2
  ,p_init_msg_list          IN     VARCHAR2
  ,p_validation_level       IN     NUMBER
  ,p_source_instance_tbl    IN     csi_datastructures_pub.instance_tbl
  ,p_explosion_level        IN     NUMBER
  ,p_txn_rec                IN OUT NOCOPY csi_datastructures_pub.transaction_rec
  ,x_return_status          OUT    NOCOPY VARCHAR2
  ,x_msg_count              OUT    NOCOPY NUMBER
  ,x_msg_data               OUT    NOCOPY VARCHAR2
 )
IS
   --
   l_api_name                    CONSTANT VARCHAR2(30) := 'explode_bom';
   l_api_version                 CONSTANT NUMBER      := 1.0;
   l_debug_level                 NUMBER;
   l_msg_index                   NUMBER;
   l_msg_count                   NUMBER;
   x_ins_tbl                     csi_datastructures_pub.instance_tbl;
   x_rel_tbl                     csi_datastructures_pub.ii_relationship_tbl;
   l_ins_tbl                     csi_datastructures_pub.instance_tbl;
   l_rel_ctr                     NUMBER := 0;
   x_new_ins_tbl                 csi_datastructures_pub.instance_tbl;
   l_rel_tbl                     csi_datastructures_pub.ii_relationship_tbl;
   p_instance_rec                csi_datastructures_pub.instance_rec;
   l_prev_item                   NUMBER := -9999;
   x_msg_index_out               NUMBER;
   --
   p_party_tbl                   csi_datastructures_pub.party_tbl;
   p_party_account_tbl           csi_datastructures_pub.party_account_tbl;
   p_org_units_tbl               csi_datastructures_pub.organization_units_tbl;
   p_pricing_attribs_tbl         csi_datastructures_pub.pricing_attribs_tbl;
   p_ext_attrib_values_tbl       csi_datastructures_pub.extend_attrib_values_tbl;
   p_instance_asset_tbl          csi_datastructures_pub.instance_asset_tbl;
   l_version_label               VARCHAR2(240);
   l_ver_label_desc              VARCHAR2(240);
   --
   p_grp_error_tbl               csi_datastructures_pub.grp_error_tbl;
   p_txn_tbl                     csi_datastructures_pub.transaction_tbl;
   l_grp_ins_tbl                 csi_datastructures_pub.instance_tbl;
   l_grp_ctr                     NUMBER := 0;
   l_grp_rel_tbl                 csi_datastructures_pub.ii_relationship_tbl;
   l_grp_party_tbl               csi_datastructures_pub.party_tbl;
   l_grp_account_tbl             csi_datastructures_pub.party_account_tbl;
   l_grp_org_units_tbl           csi_datastructures_pub.organization_units_tbl;
   l_grp_pricing_attribs_tbl     csi_datastructures_pub.pricing_attribs_tbl;
   l_grp_ext_attrib_values_tbl   csi_datastructures_pub.extend_attrib_values_tbl;
   l_grp_instance_asset_tbl      csi_datastructures_pub.instance_asset_tbl;
   l_party_ctr                   NUMBER;
   l_ctr                         NUMBER;
   --
BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT      explode_bom;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_api_name ,
                                        G_PKG_NAME)
    THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
       FND_MSG_PUB.initialize;
    END IF;
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    -- Check the profile option debug_level for debug message reporting
    l_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');
    -- If debug_level = 1 then dump the procedure name
    IF (l_debug_level > 0) THEN
        csi_gen_utility_pvt.put_line( 'explode_bom (Group)');
    END IF;
    -- Start API body
    IF p_source_instance_tbl.count > 0 THEN
       FOR src_rec in  p_source_instance_tbl.FIRST ..  p_source_instance_tbl.LAST LOOP
          IF p_source_instance_tbl.EXISTS(src_rec) THEN
	     -- Verify instance quantity
	     IF ((p_source_instance_tbl(src_rec).QUANTITY IS NULL)
		   OR (p_source_instance_tbl(src_rec).QUANTITY = FND_API.G_MISS_NUM )
		   OR (p_source_instance_tbl(src_rec).QUANTITY <> 1)) THEN
		FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_QUANTITY');
		FND_MESSAGE.SET_TOKEN('QUANTITY',p_source_instance_tbl(src_rec).QUANTITY);
		FND_MSG_PUB.Add;
		RAISE FND_API.G_EXC_ERROR;
	     END IF;
	     --
	     IF (p_source_instance_tbl(src_rec).instance_id IS NULL) OR
		(p_source_instance_tbl(src_rec).instance_id = FND_API.G_MISS_NUM) THEN
		FND_MESSAGE.SET_NAME('CSI','CSI_API_INSTANCE_ID_NULL');
		FND_MSG_PUB.Add;
		RAISE FND_API.G_EXC_ERROR;
	     END IF;
	     --
	     -- Verify if configruation has been exploded before
	     IF (csi_Item_Instance_Vld_pvt.Is_config_exploded
		( p_source_instance_tbl(src_rec).INSTANCE_ID)) THEN
		csi_gen_utility_pvt.put_line('Configuration already Exploded');
		RAISE FND_API.G_EXC_ERROR;
	     END IF;
             --
             IF l_prev_item = -9999 OR
                l_prev_item <> p_source_instance_tbl(src_rec).inventory_item_id THEN
                l_prev_item := p_source_instance_tbl(src_rec).inventory_item_id;
                -- Call Explode BOM
		csi_item_instance_pvt.Explode_Bom
		 (
		   p_api_version            => 1.0
		  ,p_commit                 => p_commit
		  ,p_init_msg_list          => p_init_msg_list
		  ,p_validation_level       => p_validation_level
		  ,p_source_instance_rec    => p_source_instance_tbl(src_rec)
		  ,p_explosion_level        => p_explosion_level
		  ,p_item_tbl               => x_ins_tbl
		  ,p_item_relation_tbl      => x_rel_tbl
		  ,p_create_instance        => FND_API.G_FALSE -- Since we just need the output
		  ,p_txn_rec                => p_txn_rec
		  ,x_return_status          => x_return_status
		  ,x_msg_count              => x_msg_count
		  ,x_msg_data               => x_msg_data
		 );
		 IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
		    csi_gen_utility_pvt.put_line('Error in Explode_BOM Regular Routine..');
		     FOR i in 1..x_msg_Count LOOP
		       FND_MSG_PUB.Get(p_msg_index     => i,
				       p_encoded       => 'F',
				       p_data          => x_msg_data,
				       p_msg_index_out => x_msg_index_out );
		       csi_gen_utility_pvt.put_line('message data = '||x_msg_data);
		    End LOOP;
		    RAISE FND_API.G_EXC_ERROR;
		END IF;
             END IF;
             --
	     -- Get the instance and other entities info
             IF x_ins_tbl.count > 0 THEN
		csi_gen_utility_pvt.put_line('Calling Get_And_Build_Instance_Details...');
		Get_And_Build_Instance_Details
		   (p_instance_id            => p_source_instance_tbl(src_rec).instance_id
		   ,p_txn_rec                => p_txn_rec
		   ,p_instance_rec           => p_instance_rec
		   ,p_party_tbl              => p_party_tbl
		   ,p_party_account_tbl      => p_party_account_tbl
		   ,p_org_units_tbl          => p_org_units_tbl
		   ,p_pricing_attribs_tbl    => p_pricing_attribs_tbl
		   ,p_ext_attrib_values_tbl  => p_ext_attrib_values_tbl
		   ,p_instance_asset_tbl     => p_instance_asset_tbl
		   ,x_return_status          => x_return_status
		   ,x_msg_count              => x_msg_count
		   ,x_msg_data               => x_msg_data
		  );
		IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		   l_msg_index := 1;
		   l_msg_count := x_msg_count;
		   WHILE l_msg_count > 0 LOOP
			   x_msg_data := FND_MSG_PUB.GET
				       (  l_msg_index,
					  FND_API.G_FALSE );
		       l_msg_index := l_msg_index + 1;
		       l_msg_count := l_msg_count - 1;
		   END LOOP;
		   csi_gen_utility_pvt.put_line('Error from Get_And_Build_Instance_Details...');
		   RAISE FND_API.G_EXC_ERROR;
                ELSE
                   csi_gen_utility_pvt.put_line('Count After Get_And_Build_Instance_Details...');
                   csi_gen_utility_pvt.put_line('p_party_tbl Count is '||to_char(p_party_tbl.count));
                   csi_gen_utility_pvt.put_line('p_party_account_tbl Count is '||to_char(p_party_account_tbl.count));
                   csi_gen_utility_pvt.put_line('p_org_units_tbl Count is '||to_char(p_org_units_tbl.count));
                   csi_gen_utility_pvt.put_line('p_pricing_attribs_tbl Count is '||to_char(p_pricing_attribs_tbl.count));
                   csi_gen_utility_pvt.put_line('p_ext_attrib_values_tbl Count is '||to_char(p_ext_attrib_values_tbl.count));
                   csi_gen_utility_pvt.put_line('p_instance_asset_tbl Count is '||to_char(p_instance_asset_tbl.count));
		END IF;
		--
		l_version_label := null;
		l_ver_label_desc := null;
		Begin
		   select version_label,description
		   into l_version_label,l_ver_label_desc
		   from CSI_I_VERSION_LABELS
		   where instance_id = p_source_instance_tbl(src_rec).instance_id
		   and   rownum < 2;
		Exception
		   when no_data_found then
		      null;
	        End;
             END IF; -- x_ins_tbl count
             --
	     l_ins_tbl.DELETE;
	     l_rel_tbl.DELETE;
             l_party_ctr := p_party_tbl.count;
	     l_ins_tbl := x_ins_tbl;
	     l_rel_tbl := x_rel_tbl;
	     IF l_ins_tbl.count > 0 THEN
		For ins_tab in l_ins_tbl.FIRST .. l_ins_tbl.LAST
		Loop
                   l_grp_ctr := l_grp_ctr + 1;
                   l_grp_ins_tbl(l_grp_ctr) := p_instance_rec;
                   select CSI_ITEM_INSTANCES_S.nextval
                   into l_grp_ins_tbl(l_grp_ctr).instance_id
                   from dual;
                   --
                   l_grp_ins_tbl(l_grp_ctr).instance_number := l_grp_ins_tbl(l_grp_ctr).instance_id;
                   l_grp_ins_tbl(l_grp_ctr).external_reference := fnd_api.g_miss_char;
                   l_grp_ins_tbl(l_grp_ctr).object_version_number := fnd_api.g_miss_num;
                   l_grp_ins_tbl(l_grp_ctr).inventory_item_id := l_ins_tbl(ins_tab).inventory_item_id;
                   l_grp_ins_tbl(l_grp_ctr).inventory_revision := fnd_api.g_miss_char;
                   l_grp_ins_tbl(l_grp_ctr).quantity := l_ins_tbl(ins_tab).quantity;
                   l_grp_ins_tbl(l_grp_ctr).mfg_serial_number_flag := 'N';
                   l_grp_ins_tbl(l_grp_ctr).unit_of_measure := l_ins_tbl(ins_tab).unit_of_measure;
                   l_grp_ins_tbl(l_grp_ctr).lot_number := NULL;
                   l_grp_ins_tbl(l_grp_ctr).serial_number := NULL;
                   l_grp_ins_tbl(l_grp_ctr).creation_complete_flag := fnd_api.g_miss_char;
                   l_grp_ins_tbl(l_grp_ctr).completeness_flag := fnd_api.g_miss_char;
                   l_grp_ins_tbl(l_grp_ctr).version_label := l_version_label;
                   l_grp_ins_tbl(l_grp_ctr).version_label_description := l_ver_label_desc;
		   --
		   -- On success Populate the relationship_tbl with the new instance_id
		   IF l_rel_tbl.count > 0 THEN
		      For rel_tab in l_rel_tbl.FIRST .. l_rel_tbl.LAST
		      Loop
			 IF l_rel_tbl(rel_tab).object_id = 0 THEN -- Top Most
			    l_rel_tbl(rel_tab).object_id := p_source_instance_tbl(src_rec).instance_id;
			 END IF;
			 --
			 IF l_rel_tbl(rel_tab).subject_id = ins_tab THEN
			    l_rel_tbl(rel_tab).subject_id := l_grp_ins_tbl(l_grp_ctr).instance_id;
			 END IF;
			 --
			 IF l_rel_tbl(rel_tab).object_id = ins_tab THEN
			    l_rel_tbl(rel_tab).object_id := l_grp_ins_tbl(l_grp_ctr).instance_id;
			 END IF;
		      End Loop;
		   END IF;
                   --
                   -- One Txn per Instance for calling Group API
                   -- We pass the same txn id for all the txns. Group API will insert only distinct values.
                   p_txn_tbl(l_grp_ctr) := p_txn_rec;
                  -- p_txn_tbl(l_grp_ctr).transaction_id := fnd_api.g_miss_num;
                  -- p_txn_tbl(l_grp_ctr).object_version_number := fnd_api.g_miss_num;
                   --
                   -- Build Party Tbl
		   l_ctr := l_grp_party_tbl.count;
		   IF p_party_tbl.count > 0 THEN
		      FOR j in p_party_tbl.FIRST .. p_party_tbl.LAST LOOP
			 l_ctr := l_ctr + 1;
			 l_grp_party_tbl(l_ctr) := p_party_tbl(j);
			 l_grp_party_tbl(l_ctr).instance_party_id := fnd_api.g_miss_num;
			 l_grp_party_tbl(l_ctr).instance_id := l_grp_ins_tbl(l_grp_ctr).instance_id;
			 l_grp_party_tbl(l_ctr).object_version_number := fnd_api.g_miss_num;
			 l_grp_party_tbl(l_ctr).parent_tbl_index := l_grp_ctr;
			 l_grp_party_tbl(l_ctr).contact_ip_id := fnd_api.g_miss_num;
			 IF l_grp_ctr > 1 THEN
			    IF p_party_tbl(j).contact_flag = 'Y' THEN
			       l_grp_party_tbl(l_ctr).contact_parent_tbl_index :=
				  p_party_tbl(j).contact_parent_tbl_index + ((l_grp_ctr-1) * l_party_ctr);
			    END IF;
			 END IF;
		      END LOOP;
		   END IF;
		   --
                   -- Build Account Tbl
		   l_ctr := l_grp_account_tbl.count;
		   IF p_party_account_tbl.count > 0 THEN
		      FOR j in p_party_account_tbl.FIRST .. p_party_account_tbl.LAST LOOP
			 l_ctr := l_ctr + 1;
			 l_grp_account_tbl(l_ctr) := p_party_account_tbl(j);
			 l_grp_account_tbl(l_ctr).ip_account_id := fnd_api.g_miss_num;
			 l_grp_account_tbl(l_ctr).instance_party_id := fnd_api.g_miss_num;
			 l_grp_account_tbl(l_ctr).object_version_number := fnd_api.g_miss_num;
			 IF l_grp_ctr > 1 THEN
			    l_grp_account_tbl(l_ctr).parent_tbl_index :=
				  p_party_account_tbl(j).parent_tbl_index + ((l_grp_ctr-1) * l_party_ctr);
			 END IF;
		      END LOOP;
		   END IF;
		   --
		   l_ctr := l_grp_org_units_tbl.count;
		   IF p_org_units_tbl.count > 0 THEN
		      FOR j in p_org_units_tbl.FIRST .. p_org_units_tbl.LAST LOOP
			 l_ctr := l_ctr + 1;
			 l_grp_org_units_tbl(l_ctr) := p_org_units_tbl(j);
			 l_grp_org_units_tbl(l_ctr).parent_tbl_index := l_grp_ctr;
			 l_grp_org_units_tbl(l_ctr).instance_id := l_grp_ins_tbl(l_grp_ctr).instance_id;
			 l_grp_org_units_tbl(l_ctr).instance_ou_id := fnd_api.g_miss_num;
			 l_grp_org_units_tbl(l_ctr).object_version_number := fnd_api.g_miss_num;
		      END LOOP;
		   END IF;
		   --
		   l_ctr := l_grp_pricing_attribs_tbl.count;
		   IF p_pricing_attribs_tbl.count > 0 THEN
		      FOR j in p_pricing_attribs_tbl.FIRST .. p_pricing_attribs_tbl.LAST LOOP
			 l_ctr := l_ctr + 1;
			 l_grp_pricing_attribs_tbl(l_ctr) := p_pricing_attribs_tbl(j);
			 l_grp_pricing_attribs_tbl(l_ctr).parent_tbl_index := l_grp_ctr;
			 l_grp_pricing_attribs_tbl(l_ctr).instance_id := l_grp_ins_tbl(l_grp_ctr).instance_id;
			 l_grp_pricing_attribs_tbl(l_ctr).pricing_attribute_id := fnd_api.g_miss_num;
			 l_grp_pricing_attribs_tbl(l_ctr).object_version_number := fnd_api.g_miss_num;
		      END LOOP;
		   END IF;
		   --
		   l_ctr := l_grp_ext_attrib_values_tbl.count;
		   IF p_ext_attrib_values_tbl.count > 0 THEN
		      FOR j in p_ext_attrib_values_tbl.FIRST .. p_ext_attrib_values_tbl.LAST LOOP
			 l_ctr := l_ctr + 1;
			 l_grp_ext_attrib_values_tbl(l_ctr) := p_ext_attrib_values_tbl(j);
			 l_grp_ext_attrib_values_tbl(l_ctr).parent_tbl_index := l_grp_ctr;
			 l_grp_ext_attrib_values_tbl(l_ctr).attribute_value_id := fnd_api.g_miss_num;
			 l_grp_ext_attrib_values_tbl(l_ctr).instance_id := l_grp_ins_tbl(l_grp_ctr).instance_id;
			 l_grp_ext_attrib_values_tbl(l_ctr).object_version_number := fnd_api.g_miss_num;
		      END LOOP;
		   END IF;
		   --
		   l_ctr := l_grp_instance_asset_tbl.count;
		   IF p_instance_asset_tbl.count > 0 THEN
		      FOR j in p_instance_asset_tbl.FIRST .. p_instance_asset_tbl.LAST LOOP
			 l_ctr := l_ctr + 1;
			 l_grp_instance_asset_tbl(l_ctr) := p_instance_asset_tbl(j);
			 l_grp_instance_asset_tbl(l_ctr).parent_tbl_index := l_grp_ctr;
			 l_grp_instance_asset_tbl(l_ctr).instance_id := l_grp_ins_tbl(l_grp_ctr).instance_id;
			 l_grp_instance_asset_tbl(l_ctr).object_version_number := fnd_api.g_miss_num;
			 l_grp_instance_asset_tbl(l_ctr).instance_asset_id := fnd_api.g_miss_num;
                      END LOOP;
                   END IF;
		End Loop; -- l_ins_tbl (components) loop
		--
                -- At the end of this loop all the relationship records
                -- will have the right subject and object
                -- Add the l_rel_tbl into l_grp_rel_tbl
		IF l_rel_tbl.count > 0 THEN
                   l_rel_ctr := l_grp_rel_tbl.count;
                   FOR rel_rec in l_rel_tbl.FIRST .. l_rel_tbl.LAST LOOP
                      l_rel_ctr := l_rel_ctr + 1;
                      l_grp_rel_tbl(l_rel_ctr).object_id := l_rel_tbl(rel_rec).object_id;
                      l_grp_rel_tbl(l_rel_ctr).subject_id := l_rel_tbl(rel_rec).subject_id;
                      l_grp_rel_tbl(l_rel_ctr).relationship_type_code := 'COMPONENT-OF';
                   END LOOP;
		END IF;
	     END IF; -- End of l_ins_tbl_count
          END IF; -- p_source_instance_tbl exists
       END LOOP; -- p_source_instance_tbl loop
    END IF; -- p_src_instance_tbl count
    --
    -- Call Create Item Instance Group API
    csi_gen_utility_pvt.put_line('Instance count is '||to_char(l_grp_ins_tbl.count));
    csi_gen_utility_pvt.put_line('Party count is '||to_char(l_grp_party_tbl.count));
    csi_gen_utility_pvt.put_line('Account count is '||to_char(l_grp_account_tbl.count));
    csi_gen_utility_pvt.put_line('Pricing count is '||to_char(l_grp_pricing_attribs_tbl.count));
    csi_gen_utility_pvt.put_line('Ext Attribs count is '||to_char(l_grp_ext_attrib_values_tbl.count));
    csi_gen_utility_pvt.put_line('Org Units count is '||to_char(l_grp_org_units_tbl.count));
    csi_gen_utility_pvt.put_line('Asset count is '||to_char(l_grp_instance_asset_tbl.count));
    csi_gen_utility_pvt.put_line('Transaction count is '||to_char(p_txn_tbl.count));
    --
    csi_item_instance_grp.create_item_instance
       ( p_api_version           => 1.0
	,p_commit                => p_commit
	,p_init_msg_list         => p_init_msg_list
	,p_validation_level      => p_validation_level
	,p_instance_tbl          => l_grp_ins_tbl
	,p_ext_attrib_values_tbl => l_grp_ext_attrib_values_tbl
	,p_party_tbl             => l_grp_party_tbl
	,p_account_tbl           => l_grp_account_tbl
	,p_pricing_attrib_tbl    => l_grp_pricing_attribs_tbl
	,p_org_assignments_tbl   => l_grp_org_units_tbl
	,p_asset_assignment_tbl  => l_grp_instance_asset_tbl
	,p_txn_tbl               => p_txn_tbl
        ,p_call_from_bom_expl    => fnd_api.g_true
	,p_grp_error_tbl         => p_grp_error_tbl
	,x_return_status         => x_return_status
	,x_msg_count             => x_msg_count
	,x_msg_data              => x_msg_data
      );
      --
      IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
	 csi_gen_utility_pvt.put_line('Error from Group Create_item_instance..');
	  FOR i in 1..x_msg_Count LOOP
	    FND_MSG_PUB.Get(p_msg_index     => i,
			    p_encoded       => 'F',
			    p_data          => x_msg_data,
			    p_msg_index_out => x_msg_index_out );
	    csi_gen_utility_pvt.put_line('message data = '||x_msg_data);
	 End LOOP;
	 RAISE FND_API.G_EXC_ERROR;
     END IF;
    --
    csi_gen_utility_pvt.put_line('Relationship Count is '||to_char(l_grp_rel_tbl.count));
    IF l_grp_rel_tbl.count > 0 THEN
       csi_gen_utility_pvt.put_line('Calling Create Relationship PUB...');
       csi_ii_relationships_pub.create_relationship
	   (
	     p_api_version         => 1.0,
	     p_commit              => fnd_api.g_false,
	     p_init_msg_list       => fnd_api.g_true,
	     p_validation_level    => fnd_api.g_valid_level_full,
	     p_relationship_tbl    => l_grp_rel_tbl,
	     p_txn_rec             => p_txn_rec,
	     x_return_status       => x_return_status,
	     x_msg_count           => x_msg_count,
	     x_msg_data            => x_msg_data
	   );
         csi_gen_utility_pvt.put_line('End of Create Relationship...');
	 IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
	    csi_gen_utility_pvt.put_line('Error while trying to Create II Relationships..');
	     FOR i in 1..x_msg_Count LOOP
	       FND_MSG_PUB.Get(p_msg_index     => i,
			       p_encoded       => 'F',
			       p_data          => x_msg_data,
			       p_msg_index_out => x_msg_index_out );
	       csi_gen_utility_pvt.put_line('message data = '||x_msg_data);
	    End LOOP;
	    RAISE FND_API.G_EXC_ERROR;
	END IF;
    END IF;
    -- End of API body
    -- Standard check of p_commit
    IF FND_API.To_Boolean( p_commit ) THEN
       COMMIT WORK;
    END IF;
    -- Standard call to get message count and if count is  get message info.
    FND_MSG_PUB.Count_And_Get
        ( p_count       =>       x_msg_count ,
          p_data       =>       x_msg_data
        );
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
            ROLLBACK TO explode_bom;
            x_return_status := FND_API.G_RET_STS_ERROR ;
            FND_MSG_PUB.Count_And_Get
                (  p_count               =>      x_msg_count,
                    p_data                =>      x_msg_data
                 );
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            ROLLBACK TO explode_bom;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            FND_MSG_PUB.Count_And_Get
                (  p_count               =>      x_msg_count,
                    p_data                =>      x_msg_data
                 );
      WHEN OTHERS THEN
            ROLLBACK TO  explode_bom;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
              IF       FND_MSG_PUB.Check_Msg_Level
                  (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
                    FND_MSG_PUB.Add_Exc_Msg
                    (      G_PKG_NAME            ,
                          l_api_name
                     );
            END IF;
            FND_MSG_PUB.Count_And_Get
                (  p_count               =>      x_msg_count,
                    p_data                =>      x_msg_data
                );
END Explode_Bom;
--
PROCEDURE lock_item_instances
 (
     p_api_version           IN   NUMBER
    ,p_commit                IN   VARCHAR2 := fnd_api.g_false
    ,p_init_msg_list         IN   VARCHAR2 := fnd_api.g_false
    ,p_validation_level      IN   NUMBER := fnd_api.g_valid_level_full
    ,px_config_tbl           IN   OUT NOCOPY csi_cz_int.config_tbl
   -- ,p_txn_rec               IN   OUT NOCOPY csi_datastructures_pub.transaction_rec
    ,x_return_status         OUT  NOCOPY VARCHAR2
    ,x_msg_count             OUT  NOCOPY NUMBER
    ,x_msg_data              OUT  NOCOPY VARCHAR2
 )
AS
l_api_name         CONSTANT VARCHAR2(30)   := 'LOCK_ITEM_INSTANCES';
l_api_version      CONSTANT NUMBER         := 1.0;
l_csi_debug_level  NUMBER;
l_msg_data         VARCHAR2(2000);
l_msg_index        NUMBER;
l_msg_count        NUMBER;
BEGIN

  SAVEPOINT    csi_lock_item_grp;


        -- Check for freeze_flag in csi_install_parameters is set to 'Y'

     csi_utility_grp.check_ib_active;

        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call (    l_api_version           ,
                                                p_api_version           ,
                                                l_api_name              ,
                                                g_pkg_name              )
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list ) THEN
                FND_MSG_PUB.initialize;
        END IF;

        --  Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        -- Check the profile option CSI_DEBUG_LEVEL for debug message reporting
        l_csi_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');

        -- If CSI_DEBUG_LEVEL = 1 then dump the procedure name
        IF (l_csi_debug_level > 0) THEN
            csi_gen_utility_pvt.put_line( 'lock_item_instances');
        END IF;


        -- If the debug level = 2 then dump all the parameters values.
        IF (l_csi_debug_level > 1) THEN
               csi_gen_utility_pvt.put_line( 'lock_item_instances'||
                                                   p_api_version           ||'-'||
                                                   p_commit                ||'-'||
                                                   p_init_msg_list         ||'-'||
                                                   p_validation_level            );
               -- Dump the records in the log file
              -- csi_gen_utility_pvt.dump_txn_rec(p_txn_rec);
        END IF;

       csi_item_instance_pvt.lock_item_instances
         (p_api_version      => p_api_version
         ,p_commit           => fnd_api.g_false
         ,p_init_msg_list    => p_init_msg_list
         ,p_validation_level => p_validation_level
         ,px_config_tbl      => px_config_tbl
       --  ,p_txn_rec          => p_txn_rec
         ,x_return_status    => x_return_status
         ,x_msg_count        => x_msg_count
         ,x_msg_data         => x_msg_data
         );
      IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          l_msg_index := 1;
          l_msg_count := x_msg_count;
          WHILE l_msg_count > 0 LOOP
                x_msg_data := FND_MSG_PUB.GET
                      (  l_msg_index,
                         FND_API.G_FALSE );
              csi_gen_utility_pvt.put_line('Error while locking item instances..');
              csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
              l_msg_index := l_msg_index + 1;
              l_msg_count := l_msg_count - 1;
          END LOOP;
         RAISE FND_API.G_EXC_ERROR;
       END IF;

        IF FND_API.To_Boolean( p_commit ) THEN
            COMMIT WORK;
        END IF;

        -- Standard call to get message count and if count is  get message info.
        FND_MSG_PUB.Count_And_Get
                (p_count        =>      x_msg_count ,
                 p_data         =>      x_msg_data   );

EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO csi_lock_item_grp;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                FND_MSG_PUB.Count_And_Get
                (       p_count   =>      x_msg_count,
                        p_data    =>      x_msg_data    );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO csi_lock_item_grp;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.Count_And_Get
                ( p_count     =>      x_msg_count,
                  p_data      =>      x_msg_data  );
        WHEN OTHERS THEN
                ROLLBACK TO csi_lock_item_grp;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                IF FND_MSG_PUB.Check_Msg_Level
                     (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                   FND_MSG_PUB.Add_Exc_Msg
                    ( g_pkg_name, l_api_name );
                END IF;
                FND_MSG_PUB.Count_And_Get
                (  p_count   =>      x_msg_count,
                   p_data    =>      x_msg_data   );
END lock_item_instances;

PROCEDURE unlock_item_instances
 (
     p_api_version           IN   NUMBER
    ,p_commit                IN   VARCHAR2
    ,p_init_msg_list         IN   VARCHAR2
    ,p_validation_level      IN   NUMBER
    ,p_config_tbl            IN   csi_cz_int.config_tbl
   -- ,p_txn_rec               IN   OUT NOCOPY csi_datastructures_pub.transaction_rec
    ,x_return_status         OUT  NOCOPY VARCHAR2
    ,x_msg_count             OUT  NOCOPY NUMBER
    ,x_msg_data              OUT  NOCOPY VARCHAR2
 )
AS
l_api_name         CONSTANT VARCHAR2(30)   := 'UNLOCK_ITEM_INSTANCES';
l_api_version      CONSTANT NUMBER         := 1.0;
l_csi_debug_level  NUMBER;
l_msg_data         VARCHAR2(2000);
l_msg_index        NUMBER;
l_msg_count        NUMBER;
BEGIN

  SAVEPOINT csi_unlock_item_grp;

        -- Check for freeze_flag in csi_install_parameters is set to 'Y'

     csi_utility_grp.check_ib_active;

        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call (    l_api_version           ,
                                                p_api_version           ,
                                                l_api_name              ,
                                                g_pkg_name              )
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list ) THEN
                FND_MSG_PUB.initialize;
        END IF;

        --  Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        -- Check the profile option CSI_DEBUG_LEVEL for debug message reporting
        l_csi_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');

        -- If CSI_DEBUG_LEVEL = 1 then dump the procedure name
        IF (l_csi_debug_level > 0) THEN
            csi_gen_utility_pvt.put_line( 'unlock_item_instances');
        END IF;


        -- If the debug level = 2 then dump all the parameters values.
        IF (l_csi_debug_level > 1) THEN
               csi_gen_utility_pvt.put_line( 'unlock_item_instances'||
                                                   p_api_version           ||'-'||
                                                   p_commit                ||'-'||
                                                   p_init_msg_list         ||'-'||
                                                   p_validation_level            );
               -- Dump the records in the log file
              -- csi_gen_utility_pvt.dump_txn_rec(p_txn_rec);
        END IF;


       csi_item_instance_pvt.unlock_item_instances
         (p_api_version      => p_api_version
         ,p_commit           => fnd_api.g_false
         ,p_init_msg_list    => p_init_msg_list
         ,p_validation_level => p_validation_level
         ,p_config_tbl       => p_config_tbl
         ,p_unlock_all       => fnd_api.g_false
        -- ,p_txn_rec          => p_txn_rec
         ,x_return_status    => x_return_status
         ,x_msg_count        => x_msg_count
         ,x_msg_data         => x_msg_data
         );
      IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          l_msg_index := 1;
          l_msg_count := x_msg_count;
          WHILE l_msg_count > 0 LOOP
                x_msg_data := FND_MSG_PUB.GET
                      (  l_msg_index,
                         FND_API.G_FALSE );
              csi_gen_utility_pvt.put_line('Error while unlocking item instances..');
              csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
              l_msg_index := l_msg_index + 1;
              l_msg_count := l_msg_count - 1;
          END LOOP;
         RAISE FND_API.G_EXC_ERROR;
       END IF;


        IF FND_API.To_Boolean( p_commit ) THEN
            COMMIT WORK;
        END IF;

        -- Standard call to get message count and if count is  get message info.
        FND_MSG_PUB.Count_And_Get
                (p_count        =>      x_msg_count ,
                 p_data         =>      x_msg_data   );

EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO csi_unlock_item_grp;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                FND_MSG_PUB.Count_And_Get
                (       p_count   =>      x_msg_count,
                        p_data    =>      x_msg_data    );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO csi_unlock_item_grp;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.Count_And_Get
                ( p_count     =>      x_msg_count,
                  p_data      =>      x_msg_data  );
        WHEN OTHERS THEN
                ROLLBACK TO csi_unlock_item_grp;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                IF FND_MSG_PUB.Check_Msg_Level
                     (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                   FND_MSG_PUB.Add_Exc_Msg
                    ( g_pkg_name, l_api_name );
                END IF;
                FND_MSG_PUB.Count_And_Get
                (  p_count   =>      x_msg_count,
                   p_data    =>      x_msg_data   );
END unlock_item_instances;

FUNCTION check_item_instance_lock
(    p_instance_id         IN  NUMBER ,
     p_config_inst_hdr_id  IN  NUMBER ,
     p_config_inst_item_id IN  NUMBER ,
     p_config_inst_rev_num IN  NUMBER
) RETURN BOOLEAN IS
 l_return_value  BOOLEAN := TRUE;
 l_lock_id       NUMBER;
 l_lock_status   NUMBER :=0;
BEGIN
 l_return_value:= csi_item_instance_pvt.check_item_instance_lock
                                      ( p_instance_id         => p_instance_id
                                       ,p_config_inst_hdr_id  => p_config_inst_hdr_id
                                       ,p_config_inst_item_id => p_config_inst_item_id
                                       ,p_config_inst_rev_num => p_config_inst_rev_num
                                       );

 RETURN l_return_value;
END check_item_instance_lock;

END CSI_ITEM_INSTANCE_GRP;

/
