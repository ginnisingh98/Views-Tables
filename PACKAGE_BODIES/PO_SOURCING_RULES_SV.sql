--------------------------------------------------------
--  DDL for Package Body PO_SOURCING_RULES_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_SOURCING_RULES_SV" AS
/*$Header: POXPISRB.pls 120.3.12010000.12 2014/05/22 04:29:37 zhijfeng ship $*/

-- Read the profile option that enables/disables the debug log
g_po_pdoi_write_to_file VARCHAR2(1) := NVL(FND_PROFILE.VALUE('PO_PDOI_WRITE_TO_FILE'),'N');

--<Shared Proc FPJ START>
-------------------------------------------------------------------------------
--Start of Comments
--Name: create_update_sourcing_rules
--Pre-reqs:
--  None
--Modifies:
--  This API inserts row into mrp_sr_assignments, mrp_sourcing_rules,
--   mrp_sr_receipt_org, mrp_sr_source_org depending on the create or update
--   flag from the approval flag.
--Locks:
--  None.
--Function:
--  This API creates Sourcing Rules. The validations of start_date,end_date
--   not being null and the approved_status being approved are done here and
--   then create_sourcing_rule is called. If p_create_update_code is UPDATE
--   then update_sourcing_rule is called.
--Parameters:
--IN:
--p_interface_header_id
--  sequence generated unique identifier of interface headers table. Used for
--  insertion into po_interface_errors
--p_interface_line_id
--  sequence generated unique identifier of interface line table. Used for
--  insertion into po_interface_errors
--p_item_id
--  unique identifier of item of the document for which the sourcing
--  rule is created or updated.
--p_vendor_product_num
--  supplier provided product number
--p_vendor_id
--  unique identifier of vendor of the document for which the sourcing
--  rule is created or updated
--p_po_header_id
--  unique identifier of the document for which the sourcing
--  rule is created or updated
--p_po_line_id
--  unique identifier of the document for which the sourcing
--  rule is created or updated
--p_document_type
--  The type of document being created. Should be Blanket/GA
--p_approval_status
--  The approval status of the document for which the sourcing
--  rule is created or updated
--p_rule_name
--  The name of Sourcing Rule being created/updated. Can be NULL.
--p_rule_name_prefix
--  Prefix that will be used to create a name for new sourcing rule.
--   The name is p_rule_name_prefix_<SR Sequence number);
--p_start_date
--   The start date of Sourcing Rule
--p_end_date
--   The disable date of Sourcing Rule
--p_create_update_code
--  Valid values are   CREATE/CREATE_UPDATE
--p_organization_id
--   organization_id to be inserted in mrp_sr_assignments
--p_assignment_type_id
--   Type of Assignment.
--p_po_interface_error_code
--  This is the code used to populate interface_type field in po_interface_errors table.
--IN OUT:
--x_header_processable_flag
--  Running parameter which decides whether to do further processing or error out
--  Value is set to N if there was any error encountered. This is set in the procedure
--  PO_INTERFACE_ERRORS_SV1.handle_interface_errors

--<LOCAL SR/ASL PROJECT 11i11 START>
--p_assigment_set_id
--  Specifies the assignment set to which the created sourcing rule
--  should be assigned.
--p_vendor_site_id
--  Specifies the Supplier Site Id Enabled corresponding to the owining
--  org/Purchasing Org
--<LOCAL SR/ASL PROJECT 11i11 END>
--OUT:
--x_return_status
--   Standard API parameter. Returns status of API call.
--   Valid values are FND_API.G_RET_STS_SUCCESS, FND_API.G_RET_STS_ERROR,
--   FND_API.G_RET_STS_UNEXP_ERROR
--Notes:
--  This procedure is now called from both Approval Window and PDOI
--Testing:
--  None
--End of Comments
-------------------------------------------------------------------------------

/*
Assignment Type => Assignment Type ID Mapping

Assignment Type            Assignment Type Id
--------------------------------------------
--------------------------------------------
Global              =>         1
Item                =>         3
Organization        =>         4
Category-Org        =>         5
Item-Organization   =>         6

*/

PROCEDURE create_update_sourcing_rule  (
                   p_interface_header_id 	IN 	NUMBER,
                   p_interface_line_id     	IN 	NUMBER,
                   p_item_id               	IN 	NUMBER,
                   p_vendor_id             	IN 	NUMBER,
                   p_po_header_id          	IN 	NUMBER,
                   p_po_line_id            	IN 	NUMBER,
                   p_document_type         	IN 	VARCHAR2,
                   p_approval_status       	IN 	VARCHAR2,
                   p_rule_name             	IN 	VARCHAR2,
                   p_rule_name_prefix           IN 	VARCHAR2,
                   p_start_date            	IN 	DATE,
                   p_end_date              	IN 	DATE,
                   p_create_update_code    	IN 	VARCHAR2,
                   p_organization_id            IN 	NUMBER,
                   p_assignment_type_id    	IN 	NUMBER,
 		           p_po_interface_error_code 	IN 	VARCHAR2,
                   x_header_processable_flag    IN OUT NOCOPY VARCHAR2,
                   x_return_status   	OUT NOCOPY VARCHAR2,
----<LOCAL SR/ASL PROJECT 11i11 START>
                   p_assignment_set_id  IN NUMBER DEFAULT NULL,
                   p_vendor_site_id     IN NUMBER DEFAULT NULL
----<LOCAL SR/ASL PROJECT 11i11 END>
                   ) IS

X_process_flag              varchar2(1) := 'Y';
X_progress      VARCHAR2(3) := NULL;
x_assignment_set_id number := null;
X_temp_sourcing_rule_id     number := null;
x_sourcing_rule_id number := null;
--Variable to keep track of return statuses of private procedures called
l_running_status   VARCHAR2(1); --<Shared Proc FPJ>

begin

--Setting of this flag is now done before the call to the procedure.
--X_header_processable_flag := 'Y'; --<Shared Proc FPJ>
  IF (g_po_pdoi_write_to_file = 'Y') THEN
     PO_DEBUG.put_line(' Creating sourcing rule for the item ...');
  END IF;


----<LOCAL SR/ASL PROJECT 11i11 START>
/*
     If the calling program is POASLGEN the value of p_assignment_set_id would be
     populated in this case we should initialize the value of x_assignment_set_id with
     p_assignment_set_id.
*/

    IF p_assignment_set_id is not null THEN
        x_assignment_set_id :=p_assignment_set_id;
    END IF;
----<LOCAL SR/ASL PROJECT 11i11 END>


  X_progress := '010';
  --Make sure parameters are valid for sourcing rule creation/updation
  PO_SOURCING_RULES_SV.validate_sourcing_rule(
               x_interface_header_id 	 =>p_interface_header_id,
               x_interface_line_id       =>p_interface_line_id,
               x_approval_status 	     =>p_approval_status,
               x_rule_name 		         =>p_rule_name,
               x_start_date              =>p_start_date,
               x_end_date		         =>p_end_date,
               x_assignment_type_id 	 =>p_assignment_type_id,
               x_organization_id         =>p_organization_id,
               x_assignment_set_id       =>x_assignment_set_id,
               x_process_flag       	 =>x_process_flag,
               x_running_status          =>l_running_status,
               x_header_processable_flag =>x_header_processable_flag,
               x_po_interface_error_code =>p_po_interface_error_code);

  X_progress := '020';
  IF (X_process_flag = 'Y') THEN

	IF ((X_header_processable_flag = 'Y') and
		((p_create_update_code = 'CREATE')
			OR (p_create_update_code ='CREATE_UPDATE'))) THEN
  		IF (g_po_pdoi_write_to_file = 'Y') THEN
     		PO_DEBUG.put_line(' Creating call rule for the item ...');
  		END IF;
		PO_SOURCING_RULES_SV.create_sourcing_rule(
               x_interface_header_id   	=>p_interface_header_id,
               x_interface_line_id      =>p_interface_line_id,
               x_item_id                =>p_item_id,
               x_vendor_id           	=>p_vendor_id,
               x_po_header_id 	        =>p_po_header_id,
               x_po_line_id            =>p_po_line_id,
               x_document_type          =>p_document_type,
               x_rule_name              =>p_rule_name,
               x_rule_name_prefix       =>p_rule_name_prefix,
               x_start_Date             =>p_start_Date,
               x_end_date               =>p_end_date,
               x_organization_id        =>p_organization_id,
               x_assignment_type_id     =>p_assignment_type_id,
               x_assignment_set_id      =>x_assignment_set_id,
               x_sourcing_rule_id       =>x_sourcing_rule_id,
               x_temp_sourcing_rule_id  =>x_temp_sourcing_rule_id,
               x_process_flag           =>x_process_flag ,
               x_running_status         =>l_running_status,
               x_header_processable_flag =>x_header_processable_flag,
----<LOCAL SR/ASL PROJECT 11i11 START>
               p_vendor_site_id         =>p_vendor_site_id
----<LOCAL SR/ASL PROJECT 11i11 END>

               );

	END IF; -- p_create_update_code is create

  	X_progress := '030';
	IF ((X_process_flag = 'Y') and
			 (p_create_update_code ='CREATE_UPDATE')) THEN

		--validate to throw errors on some sure overlap failure cases
		PO_SOURCING_RULES_SV.validate_update_sourcing_rule(
               	x_interface_header_id 	 =>p_interface_header_id,
               	x_interface_line_id      =>p_interface_line_id,
                x_sourcing_rule_id		 =>x_sourcing_rule_id,
               	x_start_date             =>p_start_date,
               	x_end_date		         =>p_end_date,
               	x_assignment_type_id 	 =>p_assignment_type_id,
               	x_organization_id        =>p_organization_id,
               	x_assignment_set_id      =>x_assignment_set_id,
               	x_process_flag           =>x_process_flag,
               	x_running_status         =>l_running_status,
               	x_header_processable_flag =>x_header_processable_flag,
               	x_po_interface_error_code =>p_po_interface_error_code);

         if (x_process_flag = 'Y') then
                PO_SOURCING_RULES_SV.update_sourcing_rule(
                        x_interface_header_id  =>p_interface_header_id,
                        x_interface_line_id    =>p_interface_line_id,
                        x_item_id              =>p_item_id,
                        x_vendor_id            =>p_vendor_id,
                        x_po_header_id 	       =>p_po_header_id,
                        x_po_line_id          =>p_po_line_id,
                        x_document_type        =>p_document_type,
                        x_sourcing_rule_id     =>x_sourcing_rule_id,
                        x_temp_sourcing_rule_id	=>x_temp_sourcing_rule_id,
                        x_start_Date           =>p_start_Date,
                        x_end_date             =>p_end_date,
                        x_organization_id      =>p_organization_id,
                        x_assignment_type_id   =>p_assignment_type_id,
                        x_assignment_set_id    =>x_assignment_set_id,
                        x_running_status       =>l_running_status,
                        x_header_processable_flag =>x_header_processable_flag,
                 	    x_po_interface_error_code =>p_po_interface_error_code,
----<LOCAL SR/ASL PROJECT 11i11 START>
                        p_vendor_site_id         =>p_vendor_site_id
----<LOCAL SR/ASL PROJECT 11i11 END>
                        );
         end if;
	END IF;  -- X_create_update_flag is update

  END IF; --x_process_flag = 'Y'
  --<Shared Proc FPJ START>
  IF (l_running_status = 'N' or x_header_processable_flag = 'N') THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  ELSE
         x_return_status := FND_API.G_RET_STS_SUCCESS;
  END IF;
  --<Shared Proc FPJ END>
EXCEPTION
WHEN OTHERS THEN
	x_header_processable_flag := 'N';
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR; --<Shared Proc FPJ>
        --dbms_output.put_line('...1');
	po_message_s.sql_error('create_update_sourcing_rule', x_progress, sqlcode);
END create_update_sourcing_rule;

/*
Assignment Type => Assignment Type ID Mapping

Assignment Type         Assignment Type Id
--------------------------------------------
--------------------------------------------
Global              =>         1
Item                =>         3
Organization        =>         4
Category-Org        =>         5
Item-Organization   =>         6

*/

PROCEDURE create_sourcing_rule(X_interface_header_id   IN NUMBER,
                                     X_interface_line_id     IN NUMBER,
                                     X_item_id               IN NUMBER,
                                     X_vendor_id             IN NUMBER,
                                     X_po_header_id          IN NUMBER,
                                     X_po_line_id            IN NUMBER,
                                     X_document_type         IN VARCHAR2,
                                     X_rule_name             IN VARCHAR2,
                        			 X_rule_name_prefix      IN VARCHAR2,
                                     X_start_date            IN DATE,
                                     X_end_date              IN DATE,
                    				 X_organization_id	     IN NUMBER,
                                     X_assignment_type_id    IN NUMBER,
                                     x_assignment_set_id     IN NUMBER,
                                     x_sourcing_rule_id	     IN OUT NOCOPY NUMBER,
                                     x_temp_sourcing_rule_id IN OUT NOCOPY NUMBER,
                                     x_process_flag IN OUT NOCOPY VARCHAR2,
                				     X_running_status IN OUT NOCOPY VARCHAR2, --<Shared Proc FPJ>
                                     X_header_processable_flag IN OUT NOCOPY VARCHAR2,
----<LOCAL SR/ASL PROJECT 11i11 START>
                                     p_vendor_site_id       IN NUMBER DEFAULT NULL
----<LOCAL SR/ASL PROJECT 11i11 END>
                                     ) IS
X_progress      VARCHAR2(3) := NULL;
x_vendor_site_id            number := null;
x_last_update_date          date := sysdate;
x_last_updated_by           number := fnd_global.user_id ;
x_creation_date             date := sysdate;
x_created_by                number := fnd_global.user_id;
x_last_update_login         number := fnd_global.user_id;
x_sr_receipt_id             number := null;
x_sr_source_id              number := null;
X_ASSIGNMENT_ID             number := null;
--
-- SKG
--
 v_error_code            NUMBER              := 0;
  v_error_msg             VARCHAR2(2000)      := NULL;
--
-- SKG
--
----<LOCAL SR/ASL PROJECT 11i11 START>
l_organization_id NUMBER;
l_sourcing_rule_type NUMBER;
l_inv_org_id NUMBER;
l_item_exists varchar2(20);

----<LOCAL SR/ASL PROJECT 11i11 END>

begin

     X_progress := '010';

     --<Shared Proc FPJ START>
     -- Get the vendor site information from the Source Doc.
     --If the doc is GA then get it from Org Assignment otherwise from header

----<LOCAL SR/ASL PROJECT 11i11 START>

    /*
        The possible values for sourcing_rule_type are :
          Sourcing Rule           =>  1
          Bill Of Distributions   =>  2

        By Default we create only sourcing rules and hence the value of l_sourcing_rule_type
        would have to be 1.

        If the value of x_assignment_type_id is null (x_assignment_type_id is null
        when called from PDOI/WORKFLOW)  we would default the x_assignment_type_id to
        3(This implies sourcing level 'ITEM').

        If the value of x_assignment_type_id is 3 it implies 'ITEM' assignment. In this
        case the organization_id would be null.

        If the value of x_assignment_type_id is 6 it implies 'ITEM-ORGANIZATION' assignment. In this
        case the organization_id/receipt_organization_id would be x_organization_id.
    */
     l_sourcing_rule_type:=1;
     IF nvl(x_assignment_type_id,3)=6 THEN
        l_organization_id:=x_organization_id;
     ELSE
        l_organization_id:=null;
     END IF;

/*
    If the calling program is PDOI/Workflow we do not have the vendor_site_id
    and we need to derive it. POASLGEN would pass the vendor site id by default.
*/

     IF p_vendor_site_id is NULL THEN
            get_vendor_site_id(
                                p_po_header_id 	 =>x_po_header_id,
                                x_vendor_site_id =>x_vendor_site_id
                              );
     ELSE
                x_vendor_site_id:=p_vendor_site_id;
     END IF;
----<LOCAL SR/ASL PROJECT 11i11 END>

     --<Shared Proc FPJ END>

     IF (g_po_pdoi_write_to_file = 'Y') THEN
        PO_DEBUG.put_line(' Vendor Site from doc: ' || to_char (x_vendor_site_id));
     END IF;


     -- Check to see if there is an item level assignment for
     -- this item at the ITEM level
/* Bug 1969613: Before this fix, an incoming line carrying a sourcing rule name
 which was already existing but a new item used to error out.
                This happened since for a new item the code always fetched a
                new sourcing rule id and tried to attach the new rule but with
                the existing sourcing rule name.The following piece of code now
                brings up the sourcing rule id for a new item also and in the
                end the item will be assigned to the assignment set for this
                sourcing rule id.Also no new sourcing rule will be created
                in such a case. */
/* Bug#3184990 Added the condition 'organization_id is null' to the below
** sql to avoid the ORA-1422 error as PDOI should always consider the
** Global Sourcing Rules only and not the local Sourcing Rules which are
** defined specific to the organization. */

     X_progress := '020';
     If X_rule_name is not null then
         BEGIN

    ----<LOCAL SR/ASL PROJECT 11i11 START>
             select sourcing_rule_id into X_temp_sourcing_rule_id
             from mrp_sourcing_rules where
             sourcing_rule_name = X_rule_name and
             sourcing_rule_type =l_sourcing_rule_type and     ----<LOCAL SR/ASL PROJECT 11i11>
             nvl(organization_id,-999) = nvl(l_organization_id,-999);      ----<LOCAL SR/ASL PROJECT 11i11>
    ----<LOCAL SR/ASL PROJECT 11i11 END>
          /*Bug 12755392 : The x_sourcing_rule was not populated with the sourcing_rule_id.
          Ahead in the code checks were made with respect to x_sourcing_rule_id and since it was not populated
          the code flow was failing.We have to update both x_temp_sourcing_rule_id and x_sourcing_rule id with the same value.*/
          x_sourcing_rule_id := x_temp_sourcing_rule_id;--bug12755392
    -- Bug#3184990
         EXCEPTION
         WHEN no_data_found THEN
             X_temp_sourcing_rule_id := null;
             x_sourcing_rule_id := x_temp_sourcing_rule_id;--bug12755392
         END;
     END IF;

 If X_rule_name is null then

     BEGIN

/* Bug No:1515981 Forcing the use of following hint to improve the performance*/

    ----<LOCAL SR/ASL PROJECT 11i11 START>
         SELECT /*+ INDEX(MRP_SR_ASSIGNMENTS MRP_SR_ASSIGNMENTS_N3) */
                 sourcing_rule_id
         INTO    x_sourcing_rule_id
         FROM    mrp_sr_assignments
         WHERE   inventory_item_id = X_item_id
         AND     assignment_set_id = x_assignment_set_id
         AND sourcing_rule_type =l_sourcing_rule_type
         AND assignment_type=nvl(x_assignment_type_id,3)
         AND decode(x_assignment_type_id,6,organization_id,-1)=decode(x_assignment_type_id,6,l_organization_id,-1);
         ----<LOCAL SR/ASL PROJECT 11i11>
         EXCEPTION
         WHEN no_data_found THEN
                x_sourcing_rule_id := X_temp_sourcing_rule_id;  -- bug 1969613
         END;
END IF;

     X_progress := '030';
     IF (x_sourcing_rule_id is NULL) THEN
          IF (g_po_pdoi_write_to_file = 'Y') THEN
             PO_DEBUG.put_line(' Inserting Record in Mrp Sourcing Rules');
          END IF;

          SELECT  MRP_SOURCING_RULES_S.NEXTVAL
          INTO    x_sourcing_rule_id
          FROM    SYS.DUAL;

          INSERT INTO MRP_SOURCING_RULES(
                sourcing_rule_id,
                sourcing_rule_name,
                status,
                sourcing_rule_type,
        		organization_id,
                last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                last_update_login,
                planning_active
                ) VALUES (
                x_sourcing_rule_id,
                nvl(x_rule_name,nvl(X_rule_name_prefix,'PURCH')||'_'||to_char(x_sourcing_rule_id)),----<LOCAL SR/ASL PROJECT 11i11>
                1,                      -- status
                l_sourcing_rule_type,  --<LOCAL SR/ASL PROJECT 11i11>
       		    l_organization_id, --<LOCAL SR/ASL PROJECT 11i11>
                x_last_update_date,
                x_last_updated_by,
                x_creation_date,
                x_created_by,
                x_last_update_login,
                1                       -- planning_active (1=ACTIVE)
          );

         IF (g_po_pdoi_write_to_file = 'Y') THEN
            PO_DEBUG.put_line(' Inserting Record in Mrp Sr Receipt Org');
         END IF;

         SELECT  MRP_SR_RECEIPT_ORG_S.NEXTVAL
         INTO    x_sr_receipt_id
         FROM    SYS.DUAL;


        X_progress := '040';
        INSERT INTO MRP_SR_RECEIPT_ORG(
                sr_receipt_id,
                sourcing_rule_id,
                effective_date,
                disable_date,
                last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                last_update_login,
                receipt_organization_id----<LOCAL SR/ASL PROJECT 11i11>
        ) VALUES (
                x_sr_receipt_id,
                x_sourcing_rule_id,
                x_start_date,
                x_end_date,
                x_last_update_date,
                x_last_updated_by,
                x_creation_date,
                x_created_by,
                x_last_update_login,
                l_organization_id----<LOCAL SR/ASL PROJECT 11i11>
        );

        IF (g_po_pdoi_write_to_file = 'Y') THEN
           PO_DEBUG.put_line(' Inserting Record in Mrp Sr Source Org');
        END IF;

        X_progress := '050';
        SELECT  MRP_SR_SOURCE_ORG_S.NEXTVAL
        INTO    x_sr_source_id
        FROM    SYS.DUAL;


        INSERT INTO MRP_SR_SOURCE_ORG(
                sr_source_id,
                sr_receipt_id,
                vendor_id,
                vendor_site_id,
                source_type,
                allocation_percent,
                rank,
                last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                last_update_login
        ) VALUES (
                x_sr_source_id,
                x_sr_receipt_id,
                x_vendor_id,
                x_vendor_site_id,
                3,              -- source_type
                100,            -- bug 605898, allocation_percent should be 100 instead of 0
                1,              -- rank should be 1
                x_last_update_date,
                x_last_updated_by,
                x_creation_date,
                x_created_by,
                x_last_update_login
        );

        IF (g_po_pdoi_write_to_file = 'Y') THEN
           PO_DEBUG.put_line(' Assigning Sourcing Rule at Item level');
        END IF;

        X_progress := '060';
        -- Assign at Item level
----<LOCAL SR/ASL PROJECT 11i11 START>
     --Validate and ensure that the item is enabled for the given inventory
     --org. This is to ensure that the correct assignment goes in the
     --MRP_SR_ASSIGNMENTS

         IF nvl(x_assignment_type_id,3)=6 THEN
              l_inv_org_id :=x_organization_id;
              BEGIN

              SELECT 'Item Exists'
                INTO l_item_exists
                FROM mtl_system_items
               WHERE inventory_item_id = x_item_id
                 AND organization_id = l_inv_org_id;

              EXCEPTION
              WHEN NO_DATA_FOUND THEN
                  IF (g_po_pdoi_write_to_file = 'Y') THEN
                      PO_DEBUG.put_line('Cannot create ASL entry; item not defined in inv org. Insert warning msg');
                  END IF;
                  PO_INTERFACE_ERRORS_SV1.handle_interface_errors
                      ( x_interface_type          => 'PO_DOCS_OPEN_INTERFACE'
                      , x_error_type              => 'WARNING'
                      , x_batch_id                => NULL
                      , x_interface_header_id     => x_interface_header_id
                      , x_interface_line_id       => x_interface_line_id
                      , x_error_message_name      => 'PO_PDOI_CREATE_SR_NO_ITEM'
                      , x_table_name              => 'PO_LINES_INTERFACE'
                      , x_column_name             => 'ITEM_ID'
                      , x_tokenname1              => 'ORG_NAME'
                      , x_tokenname2              => NULL
                      , x_tokenname3              => NULL
                      , x_tokenname4              => NULL
                      , x_tokenname5              => NULL
                      , x_tokenname6              => NULL
                      , x_tokenvalue1             => PO_GA_PVT.get_org_name(p_org_id => x_organization_id)
                      , x_tokenvalue2             => NULL
                      , x_tokenvalue3             => NULL
                      , x_tokenvalue4             => NULL
                      , x_tokenvalue5             => NULL
                      , x_tokenvalue6             => NULL
                      , x_header_processable_flag => x_header_processable_flag
                      , x_interface_dist_id       => NULL
                      );
                  x_header_processable_flag := 'Y';
                  return;
            END;
        ----<LOCAL SR/ASL PROJECT 11i11 END>
         END IF;



        SELECT  MRP_SR_ASSIGNMENTS_S.NEXTVAL
        INTO    x_assignment_id
        FROM    SYS.DUAL;

        INSERT INTO MRP_SR_ASSIGNMENTS(
                assignment_id,
                assignment_type,
                sourcing_rule_id,
                sourcing_rule_type,
                assignment_set_id,
                last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                last_update_login,
                organization_id,
                inventory_item_id
        ) VALUES (
                x_assignment_id,
                NVL(x_assignment_type_id,3), ----<LOCAL SR/ASL PROJECT 11i11>
                x_sourcing_rule_id,
                l_sourcing_rule_type,                      -- sourcing_rule_type (1=SOURCING RULE)
                x_assignment_set_id,
                x_last_update_date,
                x_last_updated_by,
                x_creation_date,
                x_created_by,
                x_last_update_login,
                -- Bug 3692799: organization_id should be null
		-- when assignment_type is 3 (item assignment)
                l_organization_id, ----<LOCAL SR/ASL PROJECT 11i11>
                x_item_id
        );
----<LOCAL SR/ASL PROJECT 11i11 END>

        /* FPH We have created the sourcing rule. So set the flag to N.
	 * This will prevent us to call the update_sourcing_rule
	 * procedure.
	*/
	x_process_flag := 'N';
     END IF;


EXCEPTION
WHEN OTHERS THEN
--
         v_error_code := SQLCODE;
         v_error_msg := SUBSTR (SQLERRM, 1, 2000);
  IF (g_po_pdoi_write_to_file = 'Y') THEN
     PO_DEBUG.put_line(v_error_msg);
     PO_DEBUG.put_line(v_error_code);
  END IF;
--

        --dbms_output.put_line('...2');
	x_running_status := 'N';
	X_header_processable_flag := 'N';
	po_message_s.sql_error('create_sourcing_rule', x_progress, sqlcode);
END create_sourcing_rule;


/*
Assignment Type => Assignment Type ID Mapping

Assignment Type	        Assignment Type Id
--------------------------------------------
--------------------------------------------
Global	            =>         1
Item	            =>         3
Organization	    =>         4
Category-Org	    =>         5
Item-Organization	=>         6

*/

PROCEDURE update_sourcing_rule  (X_interface_header_id   IN NUMBER,
                                     X_interface_line_id     IN NUMBER,
                                     X_item_id               IN NUMBER,
                                     X_vendor_id             IN NUMBER,
                                     X_po_header_id          IN NUMBER,
                                     X_po_line_id            IN NUMBER,
                                     X_document_type         IN VARCHAR2,
                                     x_sourcing_rule_id      IN NUMBER,
				                     x_temp_sourcing_rule_id IN NUMBER,
                                     X_start_date            IN DATE,
                                     X_end_date              IN DATE,
                		             X_organization_id	     IN NUMBER,
                		             X_assignment_type_id    IN NUMBER,
                			         x_assignment_set_id     IN NUMBER,
			                         X_running_status IN OUT NOCOPY VARCHAR2, --<Shared Proc FPJ>
                                     X_header_processable_flag IN OUT NOCOPY VARCHAR2,
			                         X_po_interface_error_code IN VARCHAR2,
----<LOCAL SR/ASL PROJECT 11i11 START>
                                     p_vendor_site_id     IN NUMBER DEFAULT NULL
----<LOCAL SR/ASL PROJECT 11i11 END>

                                     ) IS

X_progress      VARCHAR2(3) := NULL;
X_process_flag              varchar2(1) := 'Y';
x_sr_source_id              number := null;
x_sr_receipt_id             number := null;
x_org varchar2(10);
x_item_assignment_count     number := null;
x_assignment_count          number := null;
x_within_vendor_cnt         number := null;
X_VENDOR_SITE_ID            number;
X_vendor_rank               number := 1;
x_set_new_bpa_rank_1        VARCHAR2(1) := NULL;
x_vendor_count              number := null;
x_vendor_count_on_sr        number := null;
x_sourcing_name             varchar2(50);
x_sourcing_rule_within      number := 0;
x_last_update_date          date := sysdate;
x_last_updated_by           number := fnd_global.user_id ;
x_creation_date             date := sysdate;
x_created_by                number := fnd_global.user_id;
x_last_update_login         number := fnd_global.user_id;
x_effective_date            date ;
x_disable_date              date;
x_cnt_srdate                number := null;
v_error_code            	NUMBER              := 0;
v_error_msg             	VARCHAR2(2000)      := NULL;


   /* This select statement first finds out if the combination of X_item_id and
   X_vendor_id already exists in PO_AUTOSOURCE_VENDORS */

   /* cursor c1 is to make sure if we can find the exact
      match in the sourcing rule effectivity dates */

   cursor C1 is
          SELECT sr_receipt_id
          FROM mrp_sr_receipt_org msro,
               mrp_sourcing_rules msr
          WHERE msr.sourcing_rule_id = msro.sourcing_rule_id
          AND   msr.sourcing_rule_id = x_sourcing_rule_id
          AND  trunc(nvl(msro.effective_date,x_start_date)) = trunc(x_start_date)--bug12755392
          AND   trunc(NVL(msro.disable_date,x_end_date)) = trunc(x_end_date);--bug12755392
          /*Bug 12755392 : While comparing Trunc should be on both sides of equality.
          If not there is a possibility that the where clause will fail*/
   /* cursor c2 is used to see if we can find any
      overlaps
    */

   /* ER - 1743024 - Now Overlapping of dates for an existing sourcing rule is allowed
   if
   1.  The start date is not before the start date of the sourcing rule.
   2.  The start date is >= start date of sourcing rule and the end date is
       after the end date of the sourcing rule.
   3.  There is only 1 Vendor , Vendor Site for that effectivity date range
   4.  The end date does not overlap in another effectivity date range for the
       same sourcing rule.

   Look for code after Cursor C2 is opened and fetched for this logic
   */

   cursor C2 is
          SELECT sr_receipt_id, msro.effective_date, msro.disable_date
          FROM mrp_sr_receipt_org msro,
               mrp_sourcing_rules msr
          WHERE msr.sourcing_rule_id = msro.sourcing_rule_id
          AND   msr.sourcing_rule_id = x_sourcing_rule_id
          AND   (trunc(nvl(msro.effective_date,x_start_date)) between  trunc(x_start_date) and
                                                     trunc(x_end_date)--bug12755392
                OR   trunc(NVL(msro.disable_date,x_end_date)) between
                                                     trunc(x_start_date) and
                                                     trunc(x_end_date));--bug12755392
/*Bug 12755392 : While comparing Trunc should be on both sides of equality.
          If not there is a possibility that the where clause will fail*/


----<LOCAL SR/ASL PROJECT 11i11 START>
l_organization_id NUMBER;
l_sourcing_rule_type NUMBER;
l_inv_org_id NUMBER;
l_item_exists varchar2(20);

----<LOCAL SR/ASL PROJECT 11i11 END>

--bug10330313
resource_busy_exc   EXCEPTION;
PRAGMA EXCEPTION_INIT(resource_busy_exc,-00054);
l_locked_doc boolean := FALSE;
--bug10330313

begin

--bug10330313<START>
--lock the sourcing rule in mrp_sourcing rules before proceeding
--we ll loop 1000 times to try and lock the mrp_sourcing_rules record
--If locked, we continue to process the record.
--If not we exit the procedure raising an error.
  FOR i IN 1..1000
    LOOP
      BEGIN
        X_progress := '000';
      PO_DEBUG.put_line('Trying to lock the sourcing rule');
        PO_LOCKS.lock_sourcing_rules(
           p_sourcing_rule_id          => x_sourcing_rule_id
                                    );
        l_locked_doc := TRUE;
        EXIT;
      EXCEPTION
        WHEN resource_busy_exc THEN
          NULL;
      END;

    END LOOP;  -- for i in 1..1000

    IF (NOT l_locked_doc)
    THEN
       PO_DEBUG.put_line('failed to lock the sourcing rule after 1000 tries');
       RAISE PO_CORE_S.g_early_return_exc;
    END IF;

--bug10330313<END>

      -- Check to see if that sourcing rule is assigned elsewhere
       /* If the sourcing rule has more than one row in the
       mrp_sr_assignments table then we should not be proceeding with the
       creation/updation of the sourcing rule bcos multiple planners could
       be operating on the sourcing rule and we should not be modifying
       the sourcing rule via PDOI */

        X_progress := '010';
       select sourcing_rule_name, organization_id
        into  x_sourcing_name, x_org
       from mrp_sourcing_rules
       where sourcing_rule_id = x_sourcing_rule_id;

       if (x_org is NULL) then
          x_org := 'ALL';
       end if;

        X_progress := '030';


/* Bug: 2215958 I am reverting whatever the fix made in 2160710 and writing this new query
   Added the following query to check if there is an effectivity period in this rule which
   encompasses the Blanket effectivity period and include blanket supplier and supplier site
   as a source in that period. Now this check in addition to the above mentioned completes
   the logic for the creation/updation of sourcing rule.
*/

----<LOCAL SR/ASL PROJECT 11i11 START>
    /*
        The possible values for sourcing_rule_type are :
          Sourcing Rule           =>  1
          Bill Of Distributions   =>  2

        By Default we create only sourcing rules and hence the value of l_sourcing_rule_type
        would have to be 1.

        If the value of x_assignment_type_id is null (x_assignment_type_id is null
        when called from PDOI/WORKFLOW)  we would default the x_assignment_type_id to
        3(This implies sourcing level 'ITEM').

        If the value of x_assignment_type_id is 3 it implies 'ITEM' assignment. In this
        case the organization_id would be null.

        If the value of x_assignment_type_id is 6 it implies 'ITEM-ORGANIZATION' assignment. In this
        case the organization_id/receipt_organization_id would be x_organization_id.
    */
     l_sourcing_rule_type:=1;

     IF nvl(x_assignment_type_id,3)=6 THEN
        l_organization_id:=x_organization_id;
     ELSE
        l_organization_id:=null;
     END IF;

    /*
        If the calling program is PDOI/Workflow we do not have the vendor_site_id
        and we need to derive it.
    */
      --<Shared Proc FPJ START>
     -- Get the vendor site information from the Source Doc.
     --If the doc is GA then get it from Org Assignment otherwise from header

     IF p_vendor_site_id is NULL THEN
         get_vendor_site_id(
                p_po_header_id 		=>x_po_header_id,
                x_vendor_site_id		=>x_vendor_site_id);
     ELSE
                x_vendor_site_id:=p_vendor_site_id;
     END IF;
----<LOCAL SR/ASL PROJECT 11i11 END>

    --<Shared Proc FPJ END>

     IF (g_po_pdoi_write_to_file = 'Y') THEN
        PO_DEBUG.put_line(' Vendor Site: ' || to_char (x_vendor_site_id));
     END IF;

     /* Bug 12344417 Added nvl clause in effective_date and disable_date */
        SELECT count(*) into x_within_vendor_cnt
        FROM
        mrp_sr_receipt_org msro,
        mrp_sourcing_rules msr,
        mrp_sr_source_org msso
        WHERE   msr.sourcing_rule_id = msro.sourcing_rule_id
        AND   msro.sr_receipt_id = msso.sr_receipt_id
        AND   msr.sourcing_rule_id = x_sourcing_rule_id
        AND   trunc(x_start_date) between trunc(nvl(msro.effective_date,x_start_date)) and trunc(nvl(msro.disable_date,x_end_date))--bug12755392
        AND   trunc(x_end_date) between trunc(nvl(msro.effective_date,x_start_date)) and trunc(nvl(msro.disable_date,x_end_date))--bug12755392
        AND   msso.vendor_id        = x_vendor_id
        AND   (msso.vendor_site_id   = x_vendor_site_id or
              (msso.vendor_site_id is NULL and x_vendor_site_id is null));
/*Bug 12755392 : While comparing Trunc should be on both sides of equality.
          If not there is a possibility that the where clause will fail*/


       IF (g_po_pdoi_write_to_file = 'Y') THEN
          PO_DEBUG.put_line(' x_within_vendor_cnt: ' || to_char (x_within_vendor_cnt));
       END IF;

       SELECT count(*)
       INTO x_assignment_count
       FROM mrp_sr_assignments
       WHERE sourcing_rule_id = x_sourcing_rule_id;

       IF (g_po_pdoi_write_to_file = 'Y') THEN
          PO_DEBUG.put_line(' x_assignment_count: ' || to_char(x_assignment_count));
       END IF;

	SELECT count(*)
       INTO x_item_assignment_count
       FROM mrp_sr_assignments
       WHERE sourcing_rule_id = x_sourcing_rule_id
 /* Bug 2160710 solved. Added the below two 'AND' conditions */
       AND   inventory_item_id = X_item_id
       AND   assignment_set_id = X_assignment_set_id ;

       IF (g_po_pdoi_write_to_file = 'Y') THEN
          PO_DEBUG.put_line(' x_item_assignment_count: ' || to_char (x_item_assignment_count));
       END IF;

       /* If x_within_vendor_cnt is 0, then it means that there is no
	* sourcing rule with the same encompassing effective dates and
	* the vendor. This inturn means that that the sourcing rule that
	* is coming in irrespective of the vendor needs to updated.
	* Now we need to consider whether this sourcing rule is assigned
	* to any other item. We can update only if there is either no
	* assignment or if there is an assignment to an item, it should
	* be this item on the blanket in this assignment set. If not,
	* we should not be changing since this would mean that we are
	* updating a sourcing rule used by other planner. This check is
	* done by getting X_assignment_count which is the number of times
	* this sourcing rule is assigned to any item in any assignment set.
	* x_item_assignment_count gets the number of times it is assigned
	* to the item in the default assignment set(which can be 0 or 1).
	* If they are the same, then it means that this sourcing rule is
	* assigned only to this item in this assignment set only and
	* hence can be changed. FPH change
       */
       --IF (x_dummy_count > 0) and  (x_within_vendor_cnt = 0 ) THEN
       IF ((x_within_vendor_cnt = 0) AND
	   ((x_assignment_count > 1) OR
	    (x_assignment_count =1 and x_item_assignment_count <> 1 ))) THEN

          -- insert into  po interface errors

          IF (g_po_pdoi_write_to_file = 'Y') THEN
             PO_DEBUG.put_line(' The existing sourcing rule is assgned elsewhere and does not
                               match with the vendor provided in the blanket');
          END IF;

          X_process_flag := 'N';
          po_interface_errors_sv1.handle_interface_errors(
                                  X_po_interface_error_code,
                                  'FATAL',
                                  null,
                                   X_interface_header_id,
                                   X_interface_line_id,
                                   'PO_PDOI_SR_ASSIGNED',
                                   'PO_HEADERS_INTERFACE',
                                   'APPROVAL_STATUS',
                                   null, null,null,null,null,null,
                                   null, null,null, null,null,null,
                                   X_header_processable_flag);


      ELSE -- x_within_vendor_cnt

        X_progress := '040';
         OPEN C1;
         FETCH C1
          INTO x_sr_receipt_id;

         IF C1%NOTFOUND THEN
            OPEN C2;
            FETCH C2 INTO x_sr_receipt_id, x_effective_date, x_disable_date;

            IF (g_po_pdoi_write_to_file = 'Y') THEN
               PO_DEBUG.put_line(' Startdate' || to_char(x_start_date,'dd-mon-yy'));
               PO_DEBUG.put_line(' End date' || to_char (x_end_date,'dd-mon-yy'));
            END IF;


            IF C2%FOUND THEN

               if (trunc(x_effective_date) > trunc(x_start_date)) then


                  -- insert into  po interface errors

                  IF (g_po_pdoi_write_to_file = 'Y') THEN
                     PO_DEBUG.put_line(' The effectivity dates do not match');
                  END IF;

                  X_process_flag := 'N';
                  po_interface_errors_sv1.handle_interface_errors(
                                         X_po_interface_error_code,
                                         'FATAL',
                                         null,
                                         X_interface_header_id,
                                         X_interface_line_id,
                                         'PO_PDOI_OVERLAP_START_DATE',
                                         'PO_LINES_INTERFACE',
                                         'START_DATE',
                                         'SR_NAME','ORG',null,null,null,null,
                                         x_sourcing_name,x_org, null, null,null,null,
                                         X_header_processable_flag);
               elsif

               --bug12591815 disable date on Sourcing rule was not getting updated
	       --when new end date was less than old end date.
                  ((trunc(x_start_date) >= trunc(x_effective_date))
                    AND (trunc(x_start_date) <= trunc(x_disable_date)) --FPH
                   ) then


                    /* Check if there is only one Vendor   */
				-- bug fix 2320143 Throw error if vendor is different or vendor and site is different
        	    X_progress := '050';

                    --bug10637307 if the vendor site is that of an enabled OU on the same blanket then
		    --we can exclude the error. i.e an error should be raised only when there exists a
		    --vendor/site from a blanket other than current blanket in the same SR and we are trying
		    --to update its date.

			SELECT COUNT(*)
			INTO   x_vendor_count
			FROM   mrp_sr_source_org
			WHERE  sr_receipt_id = x_sr_receipt_id
			       AND ( ( vendor_id <> x_vendor_id )
				      OR ( ( vendor_id = x_vendor_id )
					   AND ( ( x_vendor_site_id IS NOT NULL
						   AND x_vendor_site_id <> vendor_site_id   ---12591815
						   AND x_vendor_site_id NOT IN (SELECT vendor_site_id
										FROM po_ga_org_assignments
										WHERE po_header_id = x_po_header_id)
						  )
						  OR ( x_vendor_site_id IS NULL
						       AND vendor_site_id IS NULL ))));


                     if (x_vendor_count >= 1) then

                       /* Error - Multiple Vendors assigned */

                       X_process_flag := 'N';
                       po_interface_errors_sv1.handle_interface_errors(
                                              X_po_interface_error_code,
                                               'FATAL',
                                               null,
                                               X_interface_header_id,
                                               X_interface_line_id,
                                               'PO_PDOI_OVERLAP_MORE_VENDORS',
                                               'PO_HEADERS_INTERFACE',
                                               'APPROVAL_STATUS',
                                              'SR_NAME','ORG',null,null,null,null,
                                              x_sourcing_name, x_org,null,null,null,null,
                                              X_header_processable_flag);

                      else

                        /* Check if the end_date is in another date
                         range, if so, error    */
               --bug12591815 disable date on Sourcing rule was not getting updated
	       --when new end date was less than old end date.
        	    	  X_progress := '060';
                          select count(*)
                            into x_cnt_srdate
                            from mrp_sr_receipt_org
                            where x_end_date between
                                  effective_date and disable_date
                              and sourcing_rule_id = x_sourcing_rule_id
			      and sr_receipt_id <> x_sr_receipt_id;

                          if (x_cnt_srdate >= 1) then

                              X_process_flag := 'N';
                              po_interface_errors_sv1.handle_interface_errors(
                                                  X_po_interface_error_code,
                                                  'FATAL',
                                                  null,
                                                  X_interface_header_id,
                                                  X_interface_line_id,
                                                  'PO_PDOI_OVERLAP_START_END_DATE',
                                                  'PO_LINES_INTERFACE',
                                                  'START_DATE',
                                                 'SR_NAME','ORG', null,null,null,null,
                                                 x_sourcing_name, x_org,null,null,null,null,
                                                 X_header_processable_flag) ;


                          else

                              /* Update the Effective End date   */

                             if (x_start_date = x_effective_date) then

        	    	  	X_progress := '070';
                                update mrp_sr_receipt_org
                                  set disable_date = x_end_date
                                 where sr_receipt_id = x_sr_receipt_id;

                             elsif (x_start_date > x_effective_date) then

                               /* Update the current record's disable date
                                  to start date - 1  */

                                 update mrp_sr_receipt_org
                                   set disable_date = x_start_date - 1
                                  where sr_receipt_id = x_sr_receipt_id;

    /*

        If the value of x_assignment_type_id is null (x_assignment_type_id is null
        when called from PDOI/WORKFLOW)  we would default the x_assignment_type_id to
        3(This implies sourcing level 'ITEM').

    */
                               /* Create a new record for the new start and
                                  end dates */

                                 SELECT  MRP_SR_RECEIPT_ORG_S.NEXTVAL
                                   INTO    x_sr_receipt_id
                                   FROM    SYS.DUAL;

                                 INSERT INTO MRP_SR_RECEIPT_ORG(
                                    sr_receipt_id,
                                    sourcing_rule_id,
                                    effective_date,
                                    disable_date,
                                    last_update_date,
                                    last_updated_by,
                                    creation_date,
                                    created_by,
                                    last_update_login,
                                    receipt_organization_id----<LOCAL SR/ASL PROJECT 11i11>
                                  )
                                 VALUES (
                                    x_sr_receipt_id,
                                    x_sourcing_rule_id,
                                    x_start_date,
                                    x_end_date,
                                    x_last_update_date,
                                    x_last_updated_by,
                                    x_creation_date,
                                    x_created_by,
                                    x_last_update_login,
                                    l_organization_id----<LOCAL SR/ASL PROJECT 11i11>
                                    );

                                  -- update existing links to sourcing rule

                                  SELECT  MRP_SR_SOURCE_ORG_S.NEXTVAL
                                    INTO    x_sr_source_id
                                    FROM    SYS.DUAL;

                                  SELECT nvl(max(rank),0) +1
                                    INTO   x_vendor_rank
                                    FROM   MRP_SR_SOURCE_ORG MSSO
                                    WHERE  sr_receipt_id = x_sr_receipt_id;

                                  INSERT INTO MRP_SR_SOURCE_ORG(
                                   sr_source_id,
                                   sr_receipt_id,
                                   vendor_id,
                                   vendor_site_id,
                                   source_type,
                                   allocation_percent,
                                   rank,
                                   last_update_date,
                                   last_updated_by,
                                   creation_date,
                                   created_by,
                                   last_update_login )
                                 VALUES (
                                   x_sr_source_id,
                                   x_sr_receipt_id,
                                   x_vendor_id,
                                   x_vendor_site_id,
                                   3,         -- source_type
                                   100,
                                   x_vendor_rank,
                                   x_last_update_date,
                                   x_last_updated_by,
                                   x_creation_date,
                                   x_created_by,
                                   x_last_update_login );

                              end if;

                           end if; /* End of x_cnt_srdate   */

                     end if;  /* End of vendor_count  */

              end if;   /* End of elsif    */

            ELSE

             /*Bug 1608608
             Check to see if the effectivity dates of new sourcing rule falls
             within the exisiting sourcing rule's effectivity dates.
             If it does then dont do anything and proceed further else
             insert into mrp_sr_receipt_org */

             IF (g_po_pdoi_write_to_file = 'Y') THEN
                PO_DEBUG.put_line(' Check to see if the effectivity dates of new sourcing rule falls within the existing sourcing rules effectivity dates');
             END IF;


             IF (g_po_pdoi_write_to_file = 'Y') THEN
                PO_DEBUG.put_line(' Inserting Record MSRO for existing rule');
             END IF;

             X_progress := '080';
             SELECT count(*) into x_sourcing_rule_within
               FROM mrp_sr_receipt_org msro,
                    mrp_sourcing_rules msr
               WHERE msr.sourcing_rule_id = msro.sourcing_rule_id
                 AND   msr.sourcing_rule_id = x_sourcing_rule_id
                 AND   x_start_date between msro.effective_date and msro.disable_date
                 AND   x_end_date between msro.effective_date and msro.disable_date;

              if (x_sourcing_rule_within = 0) then

                 SELECT  MRP_SR_RECEIPT_ORG_S.NEXTVAL
                   INTO    x_sr_receipt_id
                   FROM    SYS.DUAL;


                 INSERT INTO MRP_SR_RECEIPT_ORG(
                  sr_receipt_id,
                  sourcing_rule_id,
                  effective_date,
                  disable_date,
                  last_update_date,
                  last_updated_by,
                  creation_date,
                  created_by,
                  last_update_login,
                  receipt_organization_id   ----<LOCAL SR/ASL PROJECT 11i11>
                  )
                  VALUES (
                  x_sr_receipt_id,
                  x_sourcing_rule_id,
                  x_start_date,
                  x_end_date,
                  x_last_update_date,
                  x_last_updated_by,
                  x_creation_date,
                  x_created_by,
                  x_last_update_login,
                  l_organization_id----<LOCAL SR/ASL PROJECT 11i11>
                   );

                  -- update existing links to sourcing rule

                  SELECT  MRP_SR_SOURCE_ORG_S.NEXTVAL
                    INTO    x_sr_source_id
                    FROM    SYS.DUAL;

                  SELECT nvl(max(rank),0) +1
                    INTO   x_vendor_rank
                    FROM   MRP_SR_SOURCE_ORG MSSO
                    WHERE  sr_receipt_id = x_sr_receipt_id;

                   IF (g_po_pdoi_write_to_file = 'Y') THEN
                      PO_DEBUG.put_line(' Vendor Rank' || to_char(x_vendor_rank));
                      PO_DEBUG.put_line(' Inserting Record MSSO for existing rule');
                   END IF;

                  INSERT INTO MRP_SR_SOURCE_ORG(
                    sr_source_id,
                    sr_receipt_id,
                    vendor_id,
                    vendor_site_id,
                    source_type,
                    allocation_percent,
                    rank,
                    last_update_date,
                    last_updated_by,
                    creation_date,
                    created_by,
                    last_update_login
                    )
                   VALUES (
                    x_sr_source_id,
                    x_sr_receipt_id,
                    x_vendor_id,
                    x_vendor_site_id,
                    3,              -- source_type
                    100,
                    x_vendor_rank,
                    x_last_update_date,
                    x_last_updated_by,
                    x_creation_date,
                    x_created_by,
                    x_last_update_login
                          );

              end if;-- end of x_sourcing_rule_within

            END IF; -- C2%FOUND

      ELSE -- if c1%notfound
                       IF (g_po_pdoi_write_to_file = 'Y') THEN
                          PO_DEBUG.put_line(' New Vendor Rank ' || to_char(x_vendor_rank));
                       END IF;
             	       X_progress := '090';

                       -- Check to see if the item already has a sourcing rule with the same
                       -- vendor and vendor site at a effectivity period

                       -- bug 607343, change the check for unique vendor here
/*BUG No.1541387:For the case when the sourcing rule is purged and the
 corresponding ASL consists of no supplier_site_code - making the provision for
 vendor_site_id and x_vendor_site_id to be null without an error.*/
                       SELECT count(*)
                       INTO x_vendor_count_on_sr
                       FROM mrp_sr_source_org msso
                       WHERE
                            sr_receipt_id    = x_sr_receipt_id
                       AND  vendor_id        = x_vendor_id
                       AND  (vendor_site_id   = x_vendor_site_id
                        OR (vendor_site_id is NULL
                                AND x_vendor_site_id is NULL));

                       IF x_vendor_count_on_sr > 0 THEN

                           IF (g_po_pdoi_write_to_file = 'Y') THEN
                              PO_DEBUG.put_line(' The sourcing rule for this effectivity date already has this vendor');
                           END IF;

                           -- It is Not an error as we may still need to add the
                           -- document to the ASL.

                       ELSE

             	           X_progress := '100';
                           -- update existing links to sourcing rule

                           SELECT  MRP_SR_SOURCE_ORG_S.NEXTVAL
                              INTO    x_sr_source_id
                           FROM    SYS.DUAL;

                           -- Bug 18657764, check for the profile option 'PO: Set New BPA as Rank 1'
                           -- 'Yes': Using the new BPA as rank 1
                           -- 'No' : Keeping original rank, default

                          fnd_profile.get('PO_SET_NEW_BPA_RANK_1', x_set_new_bpa_rank_1);

                          IF nvl(x_set_new_bpa_rank_1, 'N') = 'N' THEN

                           X_progress := '101';
                           SELECT nvl(max(rank),0) +1
                           INTO   x_vendor_rank
                           FROM   MRP_SR_SOURCE_ORG MSSO
                           WHERE  sr_receipt_id = x_sr_receipt_id;

                           IF (g_po_pdoi_write_to_file = 'Y') THEN
                              PO_DEBUG.put_line(' New Vendor Rank ' || to_char(x_vendor_rank));
                           END IF;

                          ELSE

                           -- #13961772 POASLGEN IS NOT PROPERLY UPDATING SOURCING RULES
                           -- the new source org has the top rank, always set the
                           -- rank to 1, and update the existings to self increasing 1
                           -- respectively.

                           X_progress := '102';
                           x_vendor_rank := 1 ;
                           Update Mrp_Sr_Source_Org
                              Set Rank = Rank + 1
                            Where Sr_Receipt_Id = X_Sr_Receipt_Id;
                           --End 13961772

                           END IF;
                           -- End Bug 18657764

			   --bug9854697 we need to make a 100% allocation for the rule with a new vendor with same effective dates also
			   --Since the ranks are anyway different making it a 100% is correct. PO and Planning will pick up the correct
			   --record.
			   --If it is 0%, the assignment set becomes invalid and also planning active was checked for this record which is
			   --an inconsistent behaviour. Making it 100 resolved both these issues.
			   --Also if it is a new vendor/new OU, making 0% allocation is not correct, as the entire purpose of sourcing is
			   --defeated.
			   --The user can anytime manually change the allocation percentage as per their business requirements.

                           INSERT INTO MRP_SR_SOURCE_ORG(
                                   sr_source_id,
                                   sr_receipt_id,
                                   vendor_id,
                                   vendor_site_id,
                                   source_type,
                                   allocation_percent,
                                   rank,
                                   last_update_date,
                                   last_updated_by,
                                   creation_date,
                                   created_by,
                                   last_update_login
                           ) VALUES (
                                   x_sr_source_id,
                                   x_sr_receipt_id,
                                   x_vendor_id,
                                   x_vendor_site_id,
                                   3,              -- source_type
                                   100,            --bug9854697
                                   x_vendor_rank,  --x_vendor_rank, Bug 18657764
                                   x_last_update_date,
                                   x_last_updated_by,
                                   x_creation_date,
                                   x_created_by,
                                   x_last_update_login
                           );

                      END IF; -- x_vendor_count_on_sr > 0

                  END IF; -- C1%NOTFOUND

           END IF; -- x_within_vendor_cnt = 0 ....

/*Bug 1969613: For the case explained in the bug note above assigning the
             item to the assignment set below. */
	if ((X_temp_sourcing_rule_id is not null) and
		(X_header_processable_flag = 'Y')) then
		IF (g_po_pdoi_write_to_file = 'Y') THEN
   		PO_DEBUG.put_line('Assigning Sourcing Rule at Item level');
		END IF;

             	X_progress := '110';
		/* FPH. In the where claue below we used to check
		 * sourcing_rule_id=X_temp_sourcing_rule_id. Since we
		 * override x_temp_sourcing_rule_id with
		 * X_sourcing_rule_id, we should be checking
		 * with this.
		*/

----<LOCAL SR/ASL PROJECT 11i11 START>
     --Validate and ensure that the item is enabled for the given inventory
     --org. This is to ensure that the correct assignment goes in the
     --MRP_SR_ASSIGNMENTS

         IF nvl(x_assignment_type_id,3)=6 THEN
              l_inv_org_id :=x_organization_id;

              BEGIN

              SELECT 'Item Exists'
                INTO l_item_exists
                FROM mtl_system_items
               WHERE inventory_item_id = x_item_id
                 AND organization_id = l_inv_org_id;

              EXCEPTION
              WHEN NO_DATA_FOUND THEN
                  IF (g_po_pdoi_write_to_file = 'Y') THEN
                      PO_DEBUG.put_line('Cannot create ASL entry; item not defined in inv org. Insert warning msg');
                  END IF;
                  PO_INTERFACE_ERRORS_SV1.handle_interface_errors
                      ( x_interface_type          => 'PO_DOCS_OPEN_INTERFACE'
                      , x_error_type              => 'WARNING'
                      , x_batch_id                => NULL
                      , x_interface_header_id     => x_interface_header_id
                      , x_interface_line_id       => x_interface_line_id
                      , x_error_message_name      => 'PO_PDOI_CREATE_SR_NO_ITEM'
                      , x_table_name              => 'PO_LINES_INTERFACE'
                      , x_column_name             => 'ITEM_ID'
                      , x_tokenname1              => 'ORG_NAME'
                      , x_tokenname2              => NULL
                      , x_tokenname3              => NULL
                      , x_tokenname4              => NULL
                      , x_tokenname5              => NULL
                      , x_tokenname6              => NULL
                      , x_tokenvalue1             => PO_GA_PVT.get_org_name(p_org_id => x_organization_id)
                      , x_tokenvalue2             => NULL
                      , x_tokenvalue3             => NULL
                      , x_tokenvalue4             => NULL
                      , x_tokenvalue5             => NULL
                      , x_tokenvalue6             => NULL
                      , x_header_processable_flag => x_header_processable_flag
                      , x_interface_dist_id       => NULL
                      );
                  x_header_processable_flag := 'Y';
                  return;
            END;
        ----<LOCAL SR/ASL PROJECT 11i11 END>
         END IF;

        INSERT INTO MRP_SR_ASSIGNMENTS(
			assignment_id,
			assignment_type,
			sourcing_rule_id,
			sourcing_rule_type,
			assignment_set_id,
			last_update_date,
			last_updated_by,
			creation_date,
			created_by,
			last_update_login,
			organization_id,
			inventory_item_id
		)  select
		       MRP_SR_ASSIGNMENTS_S.NEXTVAL,
               nvl(x_assignment_type_id,3), ----<LOCAL SR/ASL PROJECT 11i11>
			x_sourcing_rule_id,
			l_sourcing_rule_type, ----<LOCAL SR/ASL PROJECT 11i11>
		       x_assignment_set_id,
			x_last_update_date,
			x_last_updated_by,
			x_creation_date,
			x_created_by,
			x_last_update_login,
			 -- Bug 3692799: organization_id should be null
			 -- when assignment_type is 3 (item assignment)
			l_organization_id, ----<LOCAL SR/ASL PROJECT 11i11>
            x_item_id
		  from dual where not exists
		  (select 'The item has to be attached to the assignment set' from
		   mrp_sr_assignments where
		   sourcing_rule_id=X_sourcing_rule_id --FPH
		   and inventory_item_id= X_item_id);
		end if;


EXCEPTION
WHEN OTHERS THEN
	v_error_code := SQLCODE;
	v_error_msg := SUBSTR (SQLERRM, 1, 2000);
	IF (g_po_pdoi_write_to_file = 'Y') THEN
   	PO_DEBUG.put_line(v_error_msg);
   	PO_DEBUG.put_line(v_error_code);
	END IF;
	x_running_status := 'N';
	x_header_processable_flag := 'N';
	po_message_s.sql_error('update_sourcing_rule', x_progress, sqlcode);
END update_sourcing_rule;

PROCEDURE validate_sourcing_rule  (
                  X_interface_header_id   IN NUMBER,
                  X_interface_line_id     IN NUMBER,
                  X_approval_status       IN VARCHAR2,
                  X_rule_name             IN VARCHAR2,
                  X_start_date            IN DATE,
                  X_end_date              IN DATE,
		          X_assignment_type_id    IN NUMBER,
                  X_organization_id       IN NUMBER,
                  x_assignment_set_id     IN OUT NOCOPY NUMBER,
                  X_process_flag          IN OUT NOCOPY VARCHAR2,
        		  X_running_status	     IN OUT NOCOPY VARCHAR2, --<Shared Proc FPJ>
                  X_header_processable_flag IN OUT NOCOPY VARCHAR2,
        		  X_po_interface_error_code IN VARCHAR2) IS

x_asl_status_id             number := null;
X_progress      VARCHAR2(3) := NULL;
begin
  IF (g_po_pdoi_write_to_file = 'Y') THEN
     PO_DEBUG.put_line(' Validating sourcing rule Inputs ...');
  END IF;

  X_progress := '020';
  IF (X_start_date is not null) AND (X_end_date is not null) THEN
     IF (X_start_date > X_end_date) THEN
        X_process_flag := 'N';
        po_interface_errors_sv1.handle_interface_errors(
                                                X_po_interface_error_code,
                                                'FATAL',
                                                 null,
                                                 X_interface_header_id,
                                                 X_interface_line_id,
                                                 'PO_PDOI_INVALID_START_DATE',
                                                 'PO_LINES_INTERFACE',
                                                 'START_DATE',
                                                'VALUE',
                                                 null,null,null,null,null,
                                                 X_start_date,
                                                 null,null, null,null,null,
                                                 X_header_processable_flag);
     END IF;
  END IF;


  IF (X_start_date is null) THEN
     X_progress := '030';
    /* do not create autosource rule rec if one of the date
       is null */
     X_process_flag := 'N';
     po_interface_errors_sv1.handle_interface_errors(
                                                X_po_interface_error_code,
                                                'FATAL',
                                                 null,
                                                 X_interface_header_id,
                                                 X_interface_line_id,
                                                 'PO_PDOI_COLUMN_NOT_NULL',
                                                 'PO_LINES_INTERFACE',
                                                 'START_DATE',
                                                'COLUMN_NAME',
                                                 null,null,null,null,null,
                                                 'START_DATE',
                                                 null,null, null,null,null,
                                                 X_header_processable_flag);
  END IF;

  IF (X_end_date is null) THEN
     X_progress := '040';
    /* do not create autosource rule rec if one of the date
       is null */
     X_process_flag := 'N';
     po_interface_errors_sv1.handle_interface_errors(
                                                X_po_interface_error_code,
                                                'FATAL',
                                                 null,
                                                 X_interface_header_id,
                                                 X_interface_line_id,
                                                 'PO_PDOI_COLUMN_NOT_NULL',
                                                 'PO_LINES_INTERFACE',
                                                 'END_DATE',
                                                'COLUMN_NAME',
                                                 null,null,null,null,null,
                                                 'END_DATE',
                                                 null,null, null,null,null,
                                                 X_header_processable_flag);
  END IF;


  IF (X_approval_status <> 'APPROVED') THEN
     X_progress := '045';
     /*** cannot create autosource rule unless the document loaded is in
     approved status ***/

     X_process_flag := 'N';
     po_interface_errors_sv1.handle_interface_errors(
                                               X_po_interface_error_code,
                                               'FATAL',
                                                null,
                                                X_interface_header_id,
                                                X_interface_line_id,
                                                'PO_PDOI_INVALID_DOC_STATUS',
                                                'PO_HEADERS_INTERFACE',
                                                'APPROVAL_STATUS',
                                                null, null,null,null,null,null,
                                                null, null,null, null,null,null,
                                                X_header_processable_flag);

  END IF;


  -- The profile option MRP_DEFAULT_ASSIGNMENT_SET specifies the default
  -- assignment set used for PO.  If user has not set this profile option
  -- then terminate the transaction.

     X_progress := '050';
----<LOCAL SR/ASL PROJECT 11i11 START>
    /*
        If the calling program is 'POASLGEN' then the value of assignment set id would
        not be null. In this case we should not override the value of assignment_set_id.
    */

      IF x_assignment_set_id IS NULL THEN
          fnd_profile.get('MRP_DEFAULT_ASSIGNMENT_SET', x_assignment_set_id);
      END IF;

----<LOCAL SR/ASL PROJECT 11i11 END>
  IF x_assignment_set_id IS NULL THEN
      IF (g_po_pdoi_write_to_file = 'Y') THEN
         PO_DEBUG.put_line(' ** ERROR: Please set the following site level profile option');
         PO_DEBUG.put_line(' ** before proceeding with this upgrade: ');
         PO_DEBUG.put_line(' **        MRP: Default Sourcing Assignment Set');
      END IF;
      X_process_flag := 'N';
      po_interface_errors_sv1.handle_interface_errors(
                                               X_po_interface_error_code,
                                               'FATAL',
                                                null,
                                                X_interface_header_id,
                                                X_interface_line_id,
                                                'PO_PDOI_NO_ASSGNMT_SET',
                                                'PO_HEADERS_INTERFACE',
                                                'APPROVAL_STATUS',
                                                null, null,null,null,null,null,
                                                null, null,null, null,null,null,
                                                X_header_processable_flag);
  END IF;

--
EXCEPTION
WHEN OTHERS THEN
	x_running_status := 'N';
        --dbms_output.put_line('...4');
	X_header_processable_flag := 'N';
	po_message_s.sql_error('validate_sourcing_rule', x_progress, sqlcode);
END validate_sourcing_rule;


-- procedure to put future validations related to update_sourcing_rule
PROCEDURE validate_update_sourcing_rule  (X_interface_header_id   IN NUMBER,
                     X_interface_line_id     IN NUMBER,
		     X_sourcing_rule_id      IN NUMBER,
                     X_start_date            IN DATE,
                     X_end_date              IN DATE,
		     X_assignment_type_id    IN NUMBER,
                     X_organization_id       IN NUMBER,
                     x_assignment_set_id     IN OUT NOCOPY NUMBER,
		     X_process_flag		 IN OUT NOCOPY VARCHAR2,
                     X_running_status	     IN OUT NOCOPY VARCHAR2, --<Shared Proc FPJ>
                     X_header_processable_flag IN OUT NOCOPY VARCHAR2,
		     X_po_interface_error_code IN VARCHAR2) IS
x_overlap_count				NUMBER:= 0;
x_sourcing_name             VARCHAR2(50);
x_org						VARCHAR2(10);
begin
	-- bug 2310660. There are some sure fail conditions that would
	-- be missed because we are not looping through the cursor to fish out overlapped dates correctly

	BEGIN
		SELECT count(*) into x_overlap_count
		FROM mrp_sr_receipt_org msro, mrp_sourcing_rules msr
		WHERE msr.sourcing_rule_id = msro.sourcing_rule_id
		AND   msr.sourcing_rule_id = x_sourcing_rule_id
		AND trunc(msro.effective_date) > trunc(x_start_date)
		AND (
				(trunc(NVL(msro.disable_date,sysdate)) between
					trunc(x_start_date) and  trunc(x_end_date)
				)
				or
				( trunc(x_end_date) between
					trunc(msro.effective_Date) and trunc(NVL(msro.disable_date,sysdate))
				)
			);
	EXCEPTION
		WHEN no_data_found THEN
			x_overlap_count := 0;
	END;

	SELECT sourcing_rule_name, organization_id
	INTO x_sourcing_name, x_org
	FROM mrp_sourcing_rules
	WHERE sourcing_rule_id = x_sourcing_rule_id;

	IF (x_org is NULL) THEN
		x_org := 'ALL';
	END IF;


	IF (x_overlap_count > 0) THEN
		po_interface_errors_sv1.handle_interface_errors(
									X_po_interface_error_code,
									'FATAL',
									null,
									X_interface_header_id,
									X_interface_line_id,
									'PO_PDOI_OVERLAP_START_DATE',
									'PO_LINES_INTERFACE',
									'START_DATE',
									'SR_NAME','ORG',null,null,null,null,
									x_sourcing_name,x_org, null, null,null,null,
									X_header_processable_flag);
		X_process_flag := 'N';
	ELSE
		X_process_flag := 'Y';
	END IF;

EXCEPTION
WHEN OTHERS THEN
	x_running_status := 'N';
	X_process_flag := 'Y';
END validate_update_sourcing_rule;

--<Shared Proc FPJ START>
-------------------------------------------------------------------------------
--Start of Comments
--Name: GET_VENDOR_SITE_ID
--Pre-reqs:
--  Assumes that parameter p_po_header_id is a valid document id
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  If the document is GA then this procedure gets the purchasing site
--  from the enabled org form otherwise gets the site from doc header
--Parameters:
--IN:
--p_po_header_id
--  Document unique identifier whose vendor site is desired
--OUT:
--x_vendor_site_id
--  the site on the document
--Notes:
--  None
--Testing:
--  None
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE get_vendor_site_id (
   p_po_header_id     IN          NUMBER,
   x_vendor_site_id   OUT NOCOPY  NUMBER
) IS
   l_ga_flag   po_headers_all.global_agreement_flag%TYPE   := 'N';
BEGIN
    --If the Doc is GA then get_vendor_site returns vendor_site_id
    --Else returns NULL
    x_vendor_site_id := PO_GA_PVT.get_vendor_site_id(p_po_header_id);

   --Either the doc is not GA or the current org is not enabled.
   --For both of these cases, select site from the header
   IF x_vendor_site_id is NULL then
	   x_vendor_site_id := PO_VENDOR_SITES_SV.get_vendor_site_id(
                                                     p_po_header_id);
   END IF;
EXCEPTION
   WHEN OTHERS THEN
        x_vendor_site_id := NULL;
END get_vendor_site_id;
--<Shared Proc FPJ END>

END PO_SOURCING_RULES_SV;

/
