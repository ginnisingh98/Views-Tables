--------------------------------------------------------
--  DDL for Package Body GML_REQIMPORT_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GML_REQIMPORT_GRP" AS
/* $Header: GMLGREQB.pls 115.2 2003/11/05 18:34:07 pbamb noship $*/

-----------------------------------------------------------------------
--Start of Comments
--Name: Validate_Requisition_Grp
--Pre-reqs:
--Modifies: po_requisitions_interface
--Locks:
--  None
--Function: validates OPM columns of interface records in po_requisitions_interface
--Parameters:
--IN:
--p_api_version
--  API Version the caller thinks this API is on
--p_init_msg_list
--  Whether the message stack should get initialized within the procedure
--p_commit
--  Whether the API should commit
--p_request_id
--  group of records to be validated per concurrent request identified by this id
--IN OUT:
--OUT:
--x_return_status
--  status of the procedure (FND_API.G_RET_STS_SUCCESS indicates a success,
--  otherwise there is an error occurred)
--x_msg_count
--  Number of messages in the stack
--x_msg_data
--  If x_msg_count is 1, this out parameter will be populated with that msg
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------

PROCEDURE Validate_Requisition_Grp
( p_api_version         IN               NUMBER
, p_init_msg_list    	IN  VARCHAR2 :=  FND_API.G_FALSE
, p_validation_level 	IN  NUMBER   :=  FND_API.G_VALID_LEVEL_FULL
, p_commit           	IN  VARCHAR2 :=  FND_API.G_FALSE
, p_request_id		IN 		 NUMBER
, x_return_status       OUT NOCOPY       VARCHAR2
, x_msg_count           OUT NOCOPY       NUMBER
, x_msg_data            OUT NOCOPY       VARCHAR2
)


IS
  l_api_name            CONSTANT VARCHAR2(30)   := 'Validate_Requisiton_Grp';
  l_api_version         CONSTANT NUMBER         := 1.0 ;



  l_secondary_unit_of_measure VARCHAR2(25);
  l_passed_secondary_uom VARCHAR2(25);
  l_secondary_quantity  NUMBER;
  l_ret_val	        NUMBER;
  l_opm_status		VARCHAR2(2);
  l_opm_ind		VARCHAR2(2);
  l_opm_ora_schema	VARCHAR2(31);
  l_return_val	        BOOLEAN;

  l_rec PO_INTERFACE_ERRORS%ROWTYPE;
  l_rtn_status VARCHAR2(1);
  l_msg_count NUMBER;
  l_msg_data VARCHAR2(2000);
  l_row_id ROWID;

  v_item_no		VARCHAR(32);
  v_item_um		VARCHAR(25);
  v_item_um2		VARCHAR(25);
  v_opm_item_id		NUMBER;
  v_dualum_ind		NUMBER;
  v_grade_ctl		NUMBER;
  v_qc_grade		VARCHAR2(4);

  v_dummy		VARCHAR2(100);

  v_opm_item	        BOOLEAN := FALSE;
  v_process_dest_org    VARCHAR2(2) := 'N';
  v_process_source_org  VARCHAR2(2) := 'N';
  v_header_processable_flag VARCHAR2(1) := 'N';

  v_uom_error		BOOLEAN := FALSE;

Cursor Cr_int_req IS
Select	pri.rowid,
        pri.transaction_id,
        pri.source_type_code,
	pri.source_organization_id,
	pri.destination_organization_id,
	pri.item_id,
	pri.secondary_unit_of_measure,
	pri.secondary_uom_code,
	pri.secondary_quantity,
	pri.quantity,
	pri.preferred_grade
From	po_requisitions_interface pri
Where   pri.request_id = p_request_id
FOR UPDATE OF pri.secondary_unit_of_measure;

Cursor Cr_opm_item_attr(p_inv_item_id IN NUMBER,p_organization_id IN NUMBER) IS
Select	i.item_id,
	i.item_no,
	i.dualum_ind,
	i.grade_ctl,
	i.item_um,
	i.item_um2
From	ic_item_mst i,
	mtl_system_items m
Where	m.inventory_item_id = p_inv_item_id
And	m.segment1 = i.item_no
And     m.organization_id = p_organization_id;

BEGIN

  IF FND_API.to_boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (   l_api_version,
                                         p_api_version,
                                         l_api_name   ,
                                         G_PKG_NAME
                                     ) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  x_return_status :=FND_API.G_RET_STS_SUCCESS;

  --cache in the opm installed status
  IF G_OPM_INSTALLED IS NULL THEN
     l_return_val := fnd_installation.get_app_info ('GMI',l_opm_status,l_opm_ind, l_opm_ora_schema);
     G_OPM_INSTALLED := l_opm_status;
  END IF;

  --do validations only if opm and common receiving are installed
  --return true if in case opm is not installed or common receiving is not installed
  IF G_OPM_INSTALLED <> 'I' OR NOT gml_po_for_process.check_po_for_proc THEN
     RETURN;
  END IF;

--Loop for every record in the interface table for the current concurrent request.
FOR Cr_rec IN Cr_int_req LOOP

  l_secondary_unit_of_measure := NULL;
  l_passed_secondary_uom := NULL;
  l_secondary_quantity  := NULL;
  l_ret_val	        := NULL;

  v_item_no		:= NULL;
  v_item_um		:= NULL;
  v_item_um2		:= NULL;
  v_opm_item_id		:= NULL;
  v_dualum_ind		:= NULL;
  v_grade_ctl		:= NULL;
  v_qc_grade		:= NULL;

  v_dummy		:= NULL;

  v_opm_item	        := FALSE;
  v_process_dest_org    := 'N';
  v_process_source_org  := 'N';

  --Only where item_id is specified.
  IF Cr_rec.item_id IS NOT NULL THEN

    --initialize uom error flag
    v_uom_error := FALSE;

    -- Check if item is OPM
    BEGIN
       OPEN Cr_opm_item_attr(cr_rec.item_id, cr_rec.destination_organization_id);
       FETCH Cr_opm_item_attr INTO v_opm_item_id,
       				   v_item_no,
       				   v_dualum_ind,
  	       			   v_grade_ctl,
  	       			   v_item_um,
  	       			   v_item_um2;
       IF  Cr_opm_item_attr%NOTFOUND THEN
  	v_opm_item := FALSE;
       ELSE
  	v_opm_item := TRUE;
       END IF;

       CLOSE Cr_opm_item_attr;
    END;

    --check whether destination organization is process.
    v_process_dest_org   := po_gml_db_common.check_process_org(cr_rec.destination_organization_id);

    -- Error out if discrete items ordered in process organizations.
    IF NOT v_opm_item and v_process_dest_org = 'Y' THEN
       l_rec.interface_type     := 'REQIMPORT';
       l_rec.interface_transaction_id       := cr_rec.transaction_id;
       l_rec.column_name        := 'ITEM_ID';
       l_rec.table_name        := 'PO_REQUISITIONS_INTERFACE';
       l_rec.error_message_name := 'GML_OPM_ITEM_NOT_EXIST';

       fnd_message.set_name('GML', l_rec.error_message_name);
       l_rec.error_message := FND_MESSAGE.get;

       PO_INTERFACE_ERRORS_GRP.log_error
       ( p_api_version => 1.0,
         p_init_msg_list => FND_API.G_TRUE,
         x_return_status => l_rtn_status,
         x_msg_count => l_msg_count,
         x_msg_data => l_msg_data,
         p_rec => l_rec,
         x_row_id => l_row_id);

       IF (l_rtn_status <> FND_API.G_RET_STS_SUCCESS) THEN
         x_msg_count := l_msg_count;
         x_msg_data  := l_msg_data;
         x_return_status := l_rtn_status;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
    END IF;

    --Internal Orders
    --Validate that if destination org is discrete
    --then the source organization is also discrete else log exception
    --validate source and destination organization to be both either process or discrete
    --validate source and destination organization are process and not same
    IF cr_rec.source_type_code = 'INVENTORY' THEN

       v_process_source_org   := po_gml_db_common.check_process_org(cr_rec.source_organization_id);

       IF (v_process_dest_org = 'N' AND v_process_source_org = 'Y' )
        OR (v_process_dest_org = 'Y' AND v_process_source_org = 'N' )
       THEN
          l_rec.interface_type 	  := 'REQIMPORT';
          l_rec.interface_transaction_id 	  := cr_rec.transaction_id;
          l_rec.column_name        := 'SOURCE_ORGANIZATION_ID';
          l_rec.table_name         := 'PO_REQUISITIONS_INTERFACE';
          l_rec.error_message_name := 'GML_INVALID_ORG_TYPE_COMB';

          fnd_message.set_name('GML', l_rec.error_message_name);
          l_rec.error_message := FND_MESSAGE.get;

          PO_INTERFACE_ERRORS_GRP.log_error
          ( p_api_version => 1.0,
            p_init_msg_list => FND_API.G_TRUE,
            x_return_status => l_rtn_status,
            x_msg_count => l_msg_count,
            x_msg_data => l_msg_data,
            p_rec => l_rec,
            x_row_id => l_row_id);

          IF (l_rtn_status <> FND_API.G_RET_STS_SUCCESS) THEN
             x_msg_count := l_msg_count;
             x_msg_data  := l_msg_data;
             x_return_status := l_rtn_status;
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;

       ELSIF  (v_process_dest_org = 'Y' AND v_process_source_org = 'Y' )
       THEN
          IF cr_rec.destination_organization_id = cr_rec.source_organization_id
          THEN
             l_rec.interface_type     := 'REQIMPORT';
             l_rec.interface_transaction_id 	     := cr_rec.transaction_id;
             l_rec.column_name        := 'SOURCE_ORGANIZATION_ID';
             l_rec.table_name         := 'PO_REQUISITIONS_INTERFACE';
             l_rec.error_message_name := 'GML_SAME_SOURCE_DEST_ORG';

             fnd_message.set_name('GML', l_rec.error_message_name);
             l_rec.error_message := FND_MESSAGE.get;

             PO_INTERFACE_ERRORS_GRP.log_error
              ( p_api_version => 1.0,
                p_init_msg_list => FND_API.G_TRUE,
                x_return_status => l_rtn_status,
                x_msg_count => l_msg_count,
                x_msg_data => l_msg_data,
                p_rec => l_rec,
                x_row_id => l_row_id);

             IF (l_rtn_status <> FND_API.G_RET_STS_SUCCESS) THEN
                x_msg_count := l_msg_count;
                x_msg_data  := l_msg_data;
                x_return_status := l_rtn_status;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             END IF;
           END IF; /*cr_rec.destination_organization_id = cr_rec.source_organization_id */
        END IF; /*(v_process_dest_org = 'Y' AND v_process_source_org = 'Y' )*/
     END IF; /*cr_rec.source_type = 'INVENTORY'*/

      --If destination is process then check
      --1. if either secondary unit of measure is specified or secondary uom code is specified then derive the other
      --2. if secondary unit of measure and secondary quantity are null for opm item with dual type
      --   greater than 1 then populate secondary unit of measure and compute secondary quantity
      --3. if either secondary unit of measure or secondary quantity is null then populate or compute the other
      --4. if item is dual uom type 2 or 3 then check for deviation between secondary and transaction qty
      --5. if item is not grade controlled and preferred_grade is populated then log error for that transaction
      --6. if secondary unit of measure is specified then check its validity

      IF v_opm_item AND v_process_dest_org = 'Y' THEN

         --get secondary_unit_of_measure from secondary_uom_code
         IF cr_rec.secondary_uom_code IS NOT NULL and cr_rec.secondary_unit_of_measure is NULL
            AND v_dualum_ind > 0
         THEN
            l_secondary_unit_of_measure := po_gml_db_common.get_apps_uom_code(v_item_um2);

            BEGIN
               SELECT mum.unit_of_measure
               INTO   l_passed_secondary_uom
               FROM   mtl_units_of_measure mum
               WHERE  mum.uom_code = cr_rec.secondary_uom_code;

               EXCEPTION WHEN NO_DATA_FOUND THEN
    	          --mark that there is an error	to avoid quantity validations.
    	          v_uom_error := TRUE;
            END;

            --Invalid secondary uom_code or the secondary uom code is not of the item specified.
            IF (l_passed_secondary_uom <> l_secondary_unit_of_measure) OR v_uom_error THEN
               l_rec.interface_type     := 'REQIMPORT';
               l_rec.interface_transaction_id 	     := cr_rec.transaction_id;
               l_rec.column_name        := 'SECONDARY_UOM_CODE';
               l_rec.table_name         := 'PO_REQUISITIONS_INTERFACE';
               l_rec.error_message_name := 'GML_INVALID_SECONDARY_UOM';

               fnd_message.set_name('GML', l_rec.error_message_name);
               l_rec.error_message := FND_MESSAGE.get;

               PO_INTERFACE_ERRORS_GRP.log_error
                 ( p_api_version => 1.0,
                   p_init_msg_list => FND_API.G_TRUE,
                   x_return_status => l_rtn_status,
                   x_msg_count => l_msg_count,
                   x_msg_data => l_msg_data,
                   p_rec => l_rec,
                   x_row_id => l_row_id);

               IF (l_rtn_status <> FND_API.G_RET_STS_SUCCESS) THEN
                  x_msg_count := l_msg_count;
                  x_msg_data  := l_msg_data;
                  x_return_status := l_rtn_status;
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;
  	       --mark that there is an error	to avoid quantity validations.
  	       v_uom_error := TRUE;

            ELSE

               --if uom code is correct update the unit of measure.
               UPDATE po_requisitions_interface pri
               SET    pri.secondary_unit_of_measure = l_secondary_unit_of_measure
               WHERE  rowid = cr_rec.rowid;

            END IF;

         --If both secondary uom and unit of measure are null then populate unit of measure
         ELSIF cr_rec.secondary_uom_code IS NULL and cr_rec.secondary_unit_of_measure is NULL
           AND v_dualum_ind > 0
         THEN

            l_secondary_unit_of_measure := po_gml_db_common.get_apps_uom_code(v_item_um2);

            UPDATE po_requisitions_interface pri
            SET pri.secondary_unit_of_measure = l_secondary_unit_of_measure
            WHERE  rowid = cr_rec.rowid;

            --If unit of measure is provided then validate it.
         ELSIF cr_rec.secondary_unit_of_measure is NOT NULL
         THEN
            l_secondary_unit_of_measure := po_gml_db_common.get_apps_uom_code(v_item_um2);

            --validate secondary_unit_of_measure
            --error if its not valid or its different than Items secondary unit of measure
            IF  cr_rec.secondary_unit_of_measure <> l_secondary_unit_of_measure THEN
               --log error that unit of measure is not correct.
               l_rec.interface_type     := 'REQIMPORT';
               l_rec.interface_transaction_id 	     := cr_rec.transaction_id;
               l_rec.column_name        := 'SECONDARY_UNIT_OF_MEASURE';
               l_rec.table_name         := 'PO_REQUISITIONS_INTERFACE';
               l_rec.error_message_name := 'GML_INVALID_SECONDARY_UOM';

               fnd_message.set_name('GML', l_rec.error_message_name);
               l_rec.error_message := FND_MESSAGE.get;

               PO_INTERFACE_ERRORS_GRP.log_error
                 ( p_api_version => 1.0,
                   p_init_msg_list => FND_API.G_TRUE,
                   x_return_status => l_rtn_status,
                   x_msg_count => l_msg_count,
                   x_msg_data => l_msg_data,
                   p_rec => l_rec,
                   x_row_id => l_row_id);

                IF (l_rtn_status <> FND_API.G_RET_STS_SUCCESS) THEN
                   x_msg_count := l_msg_count;
                   x_msg_data  := l_msg_data;
                   x_return_status := l_rtn_status;
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
    	      --mark that there is an error	to avoid quantity validations.
    	      v_uom_error := TRUE;

             END IF;
          END IF;

          --If secondary quantity is not provided and compute it and update interface table.
          --only if the unit of measure is correctly validated 0 use falg v_uom_error
          IF cr_rec.secondary_quantity IS NULL AND v_dualum_ind > 0 AND NOT v_uom_error THEN

                po_gml_db_common.VALIDATE_QUANTITY(
                                  v_opm_item_id,
                                  v_dualum_ind,
                                  cr_rec.quantity,
                                  v_item_um,
                                  v_item_um2,
                                  l_secondary_quantity) ;

                UPDATE po_requisitions_interface
                SET  secondary_unit_of_measure = nvl(secondary_unit_of_measure,l_secondary_unit_of_measure),
                     secondary_quantity = l_secondary_quantity
                WHERE  rowid = cr_rec.rowid;

          --Else if secondary qty is provided then in case of duam um 1 just update it
          --and incase of dual um 2,3 check for deviation and log error if out of deviation.
          ELSIF cr_rec.secondary_quantity IS NOT NULL AND v_dualum_ind > 0 AND NOT v_uom_error THEN

              l_secondary_quantity := NULL;

              IF v_dualum_ind in (2,3) THEN
                  l_ret_val := gmicval.dev_validation (
                  			      v_opm_item_id,
                                              0,
					      cr_rec.quantity,
                                              v_item_um,
					      cr_rec.secondary_quantity,
                                              v_item_um2,
		                              0 );
		  --If sec qty is out of deviation then log error. (hi or low).
	          IF ( l_ret_val = -68 ) THEN
	             l_rec.interface_type     := 'REQIMPORT';
                     l_rec.interface_transaction_id       := cr_rec.transaction_id;
                     l_rec.column_name        := 'SECONDARY_QUANTITY';
                     l_rec.table_name         := 'PO_REQUISITIONS_INTERFACE';
                     l_rec.error_message_name := 'IC_DEVIATION_HI_ERR';

                     fnd_message.set_name('GMI', l_rec.error_message_name);
                     l_rec.error_message := FND_MESSAGE.get;

                     PO_INTERFACE_ERRORS_GRP.log_error
                       ( p_api_version => 1.0,
                         p_init_msg_list => FND_API.G_TRUE,
                         x_return_status => l_rtn_status,
                         x_msg_count => l_msg_count,
                         x_msg_data => l_msg_data,
                         p_rec => l_rec,
                         x_row_id => l_row_id);

                     IF (l_rtn_status <> FND_API.G_RET_STS_SUCCESS) THEN
                        x_msg_count := l_msg_count;
                        x_msg_data  := l_msg_data;
                        x_return_status := l_rtn_status;
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                     END IF;
	          ELSIF ( l_ret_val = -69 ) OR cr_rec.secondary_quantity <= 0 THEN
		     l_rec.interface_type     := 'REQIMPORT';
                     l_rec.interface_transaction_id       := cr_rec.transaction_id;
                     l_rec.column_name        := 'SECONDARY_QUANTITY';
                     l_rec.table_name         := 'PO_REQUISITIONS_INTERFACE';
                     l_rec.error_message_name := 'IC_DEVIATION_LO_ERR';

                     fnd_message.set_name('GMI', l_rec.error_message_name);
                     l_rec.error_message := FND_MESSAGE.get;

                     PO_INTERFACE_ERRORS_GRP.log_error
                      ( p_api_version => 1.0,
                        p_init_msg_list => FND_API.G_TRUE,
                        x_return_status => l_rtn_status,
                        x_msg_count => l_msg_count,
                        x_msg_data => l_msg_data,
                        p_rec => l_rec,
                        x_row_id => l_row_id);

                     IF (l_rtn_status <> FND_API.G_RET_STS_SUCCESS) THEN
                        x_msg_count := l_msg_count;
                        x_msg_data  := l_msg_data;
                        x_return_status := l_rtn_status;
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                     END IF;
	          END IF ;

	      --if dual um 1 then update the secondary quantity since its fixed conversion.
	      ELSIF  v_dualum_ind = 1 THEN

	         po_gml_db_common.VALIDATE_QUANTITY(
                                v_opm_item_id,
                                v_dualum_ind,
                                cr_rec.quantity,
                                v_item_um,
                                v_item_um2,
                                l_secondary_quantity) ;

                 UPDATE po_requisitions_interface
                 SET    secondary_quantity = l_secondary_quantity
                 WHERE  rowid = cr_rec.rowid;

	      END IF; /*v_dualum_ind in (2,3) */
        END IF;/*cr_rec.secondary_quantity IS NULL */

        -- Check if item is not grade controlled and grade is specified then log error
        IF v_grade_ctl = 0 and cr_rec.preferred_grade IS NOT NULL
        THEN

	   l_rec.interface_type     := 'REQIMPORT';
           l_rec.interface_transaction_id       := cr_rec.transaction_id;
           l_rec.column_name        := 'PREFFERED_GRADE';
           l_rec.table_name         := 'PO_REQUISITIONS_INTERFACE';
           l_rec.error_message_name := 'GML_NO_OPM_PREFERRED_GRADE';

           fnd_message.set_name('GML', l_rec.error_message_name);
           l_rec.error_message := FND_MESSAGE.get;

           PO_INTERFACE_ERRORS_GRP.log_error
            ( p_api_version => 1.0,
              p_init_msg_list => FND_API.G_TRUE,
              x_return_status => l_rtn_status,
              x_msg_count => l_msg_count,
              x_msg_data => l_msg_data,
              p_rec => l_rec,
              x_row_id => l_row_id);

           IF (l_rtn_status <> FND_API.G_RET_STS_SUCCESS) THEN
              x_msg_count := l_msg_count;
              x_msg_data  := l_msg_data;
              x_return_status := l_rtn_status;
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;

           --if item is grade controlled and grade is speicified then validate grade.
        ELSIF  v_grade_ctl = 1 and cr_rec.preferred_grade IS NOT NULL
        THEN

           BEGIN
              Select	qc_grade
              Into      v_qc_grade
              From 	qc_grad_mst
              Where	qc_grade = cr_rec.preferred_grade
              And       delete_mark <> 1;

              EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                      l_rec.interface_type     := 'REQIMPORT';
                      l_rec.interface_transaction_id       := cr_rec.transaction_id;
                      l_rec.column_name        := 'PREFFERED_GRADE';
                      l_rec.table_name         := 'PO_REQUISITIONS_INTERFACE';
                      l_rec.error_message_name := 'GML_NO_OPM_PREFERRED_GRADE';

                      fnd_message.set_name('GML', l_rec.error_message_name);
                      l_rec.error_message := FND_MESSAGE.get;

                      PO_INTERFACE_ERRORS_GRP.log_error
                       ( p_api_version => 1.0,
                         p_init_msg_list => FND_API.G_TRUE,
                         x_return_status => l_rtn_status,
                         x_msg_count => l_msg_count,
                         x_msg_data => l_msg_data,
                         p_rec => l_rec,
                         x_row_id => l_row_id);

                      IF (l_rtn_status <> FND_API.G_RET_STS_SUCCESS) THEN
                         x_msg_count := l_msg_count;
                         x_msg_data  := l_msg_data;
                         x_return_status := l_rtn_status;
                         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                      END IF;
                  END;
  	END IF;/*v_grade_ctl = 0 */

        --Since item is not dual um controlled update all secondary attributes to NULL
        IF v_dualum_ind  = 0 THEN

           UPDATE po_requisitions_interface
           SET    secondary_quantity = NULL,
                  secondary_uom_code = NULL,
                  secondary_unit_of_measure = NULL
           WHERE  rowid = cr_rec.rowid;
        END IF;

      ELSE /*either item is discrete or destination organization is discrete */

         --since item is discrete or destination organization is discrete
         --update all process attributes to NULL.
         UPDATE po_requisitions_interface
         SET    secondary_quantity = NULL,
                secondary_uom_code = NULL,
                secondary_unit_of_measure = NULL,
                preferred_grade = NULL
         WHERE  rowid = cr_rec.rowid;

      END IF; /* v_opm_item AND v_process_dest_org = 'Y' */

  ELSE /*cr_rec.item_id IS NULL */

     --since its a one time item update all process attributes to NULL.
     UPDATE po_requisitions_interface
     SET    secondary_quantity = NULL,
            secondary_uom_code = NULL,
            secondary_unit_of_measure = NULL,
            preferred_grade = NULL
     WHERE  rowid = cr_rec.rowid;

  END IF;

END LOOP;

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Validate_Requisition_Grp;

END;

/
