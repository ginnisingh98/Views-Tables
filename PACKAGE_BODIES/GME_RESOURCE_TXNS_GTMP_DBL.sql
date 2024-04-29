--------------------------------------------------------
--  DDL for Package Body GME_RESOURCE_TXNS_GTMP_DBL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GME_RESOURCE_TXNS_GTMP_DBL" AS
/* $Header: GMEVGRGB.pls 120.2.12010000.2 2009/10/09 11:51:23 gmurator ship $ */

   /* Global Variables */
   g_table_name   VARCHAR2 (80) DEFAULT 'GME_RESOURCE_TXNS_GTMP';

/*============================================================================
 |                         Copyright (c) 2001 Oracle Corporation
 |                                 TVP, Reading
 |                                  All rights reserved
 =============================================================================
 |   FILENAME
 |      GMEVGRGB.pls
 |
 |   DESCRIPTION
 |
 |
 |
 |
 |   NOTES
 |
 |   HISTORY
 |   26-MAR-01 Thomas Daniel   Created
 |
 |      - insert_row
 |      - fetch_row
 |      - update_row
 |
 |
 =============================================================================
*/

   /* Api start of comments
 +============================================================================
 |   FUNCTION NAME
 |      insert_row
 |
 |   TYPE
 |      Private
 |   USAGE
 |      Insert_Row will insert a row in gme_resource_txns_gtmp
 |
 |
 |   DESCRIPTION
 |      Insert_Row will insert a row in gme_resource_txns_gtmp
 |
 |
 |
 |   PARAMETERS
 |     p_resource_txns IN            gme_resource_txns_gtmp%ROWTYPE
 |     x_resource_txns IN OUT NOCOPY gme_resource_txns_gtmp%ROWTYPE
 |
 |   RETURNS
 |      BOOLEAN
 |   HISTORY
 |   12-MAR-01 Thomas Daniel   Created
 |
 |   16-March-2005   Punit Kumar Convergence changes
 |
 |   10-Oct-2009   G. Muratore   Bug 8978768
 |      Add attribute_category column.
 +=============================================================================
 Api end of comments
*/
   FUNCTION insert_row (
      p_resource_txns   IN              gme_resource_txns_gtmp%ROWTYPE
     ,x_resource_txns   IN OUT NOCOPY   gme_resource_txns_gtmp%ROWTYPE)
      RETURN BOOLEAN
   IS
   BEGIN
      x_resource_txns := p_resource_txns;

      INSERT INTO gme_resource_txns_gtmp
                  (poc_trans_id
                  /*start Punit Kumar*/
      ,            organization_id
                  /*end*/

      --,ORGN_CODE
      ,            doc_type, doc_id
                  ,line_type, line_id
                  ,resources
                  ,resource_usage, trans_um
                  ,trans_date
                  ,completed_ind, event_id
                  ,instance_id
                  ,sequence_dependent_ind
                  ,posted_ind
                  ,overrided_protected_ind
                  ,reason_code, reason_id, start_date
                  ,end_date, delete_mark
                  ,text_code, action_code
                  ,transaction_no
                  ,attribute_category        -- Bug 8978768
                  /*start Punit Kumar*/
      ,            attribute1, attribute2
                  ,attribute3, attribute4
                  ,attribute5, attribute6
                  ,attribute7, attribute8
                  ,attribute9, attribute10
                  ,attribute11, attribute12
                  ,attribute13, attribute14
                  ,attribute15, attribute16
                  ,attribute17, attribute18
                  ,attribute19, attribute20
                  ,attribute21, attribute22
                  ,attribute23, attribute24
                  ,attribute25, attribute26
                  ,attribute27, attribute28
                  ,attribute29, attribute30
                                           /*end */
                  )
           VALUES (gem5_poc_trans_id_s.NEXTVAL
                  /*start Punit Kumar*/
      ,            x_resource_txns.organization_id
                  /*end*/

      --,x_resource_txns.ORGN_CODE
      ,            x_resource_txns.doc_type, x_resource_txns.doc_id
                  ,x_resource_txns.line_type, x_resource_txns.line_id
                  ,x_resource_txns.resources
                  ,x_resource_txns.resource_usage, x_resource_txns.trans_um
                  ,x_resource_txns.trans_date
                  ,x_resource_txns.completed_ind, x_resource_txns.event_id
                  ,x_resource_txns.instance_id
                  ,x_resource_txns.sequence_dependent_ind
                  ,x_resource_txns.posted_ind
                  ,x_resource_txns.overrided_protected_ind
                  ,x_resource_txns.reason_code, x_resource_txns.reason_id, x_resource_txns.start_date
                  ,x_resource_txns.end_date, x_resource_txns.delete_mark
                  ,x_resource_txns.text_code, x_resource_txns.action_code
                  ,x_resource_txns.transaction_no
                  ,x_resource_txns.attribute_category        -- Bug 8978768
                  /*start Punit Kumar*/
      ,            x_resource_txns.attribute1, x_resource_txns.attribute2
                  ,x_resource_txns.attribute3, x_resource_txns.attribute4
                  ,x_resource_txns.attribute5, x_resource_txns.attribute6
                  ,x_resource_txns.attribute7, x_resource_txns.attribute8
                  ,x_resource_txns.attribute9, x_resource_txns.attribute10
                  ,x_resource_txns.attribute11, x_resource_txns.attribute12
                  ,x_resource_txns.attribute13, x_resource_txns.attribute14
                  ,x_resource_txns.attribute15, x_resource_txns.attribute16
                  ,x_resource_txns.attribute17, x_resource_txns.attribute18
                  ,x_resource_txns.attribute19, x_resource_txns.attribute20
                  ,x_resource_txns.attribute21, x_resource_txns.attribute22
                  ,x_resource_txns.attribute23, x_resource_txns.attribute24
                  ,x_resource_txns.attribute25, x_resource_txns.attribute26
                  ,x_resource_txns.attribute27, x_resource_txns.attribute28
                  ,x_resource_txns.attribute29, x_resource_txns.attribute30
                                                                           /*end */
                  )
        RETURNING poc_trans_id
             INTO x_resource_txns.poc_trans_id;

      IF SQL%FOUND THEN
         RETURN TRUE;
      ELSE
         RETURN FALSE;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         gme_common_pvt.log_message ('GME_UNEXPECTED_ERROR', 'ERROR'
                                    ,SQLERRM);
         RETURN FALSE;
   END insert_row;

/* Api start of comments
 +============================================================================
 |   FUNCTION NAME
 |      fetch_row
 |
 |   TYPE
 |      Private
 |   USAGE
 |      Fetch_Row will fetch a row in gme_resource_txns_gtmp
 |
 |
 |   DESCRIPTION
 |      Fetch_Row will fetch a row in gme_resource_txns_gtmp
 |
 |
 |
 |   PARAMETERS
 |     p_resource_txns IN            gme_resource_txns_gtmp%ROWTYPE
 |     x_resource_txns IN OUT NOCOPY gme_resource_txns_gtmp%ROWTYPE
 |
 |   RETURNS
 |      BOOLEAN
 |   HISTORY
 |   12-MAR-01 Thomas Daniel   Created
 |
 |   16-March-2005 Punit Kumar Convergence changes
 |
 |   10-Oct-2009   G. Muratore   Bug 8978768
 |      Add attribute_category column.
 +=============================================================================
 Api end of comments
*/
   FUNCTION fetch_row (
      p_resource_txns   IN              gme_resource_txns_gtmp%ROWTYPE
     ,x_resource_txns   IN OUT NOCOPY   gme_resource_txns_gtmp%ROWTYPE)
      RETURN BOOLEAN
   IS
   BEGIN
      IF p_resource_txns.poc_trans_id IS NOT NULL THEN
         SELECT poc_trans_id
               /*start Punit Kumar*/
         ,      organization_id
                               /*end*/

         --,ORGN_CODE
         ,      doc_type
               ,doc_id, line_type
               ,line_id, resources
               ,resource_usage, trans_um
               ,trans_date, completed_ind
               ,event_id, instance_id
               ,sequence_dependent_ind
               ,posted_ind
               ,overrided_protected_ind
               ,reason_code, reason_id, start_date
               ,end_date, delete_mark
               ,text_code, action_code
               ,transaction_no
               ,attribute_category        -- Bug 8978768
                              /*start Punit Kumar*/
         ,      attribute1
               ,attribute2, attribute3
               ,attribute4, attribute5
               ,attribute6, attribute7
               ,attribute8, attribute9
               ,attribute10, attribute11
               ,attribute12, attribute13
               ,attribute14, attribute15
               ,attribute16, attribute17
               ,attribute18, attribute19
               ,attribute20, attribute21
               ,attribute22, attribute23
               ,attribute24, attribute25
               ,attribute26, attribute27
               ,attribute28, attribute29
               ,attribute30
           /*end */
         INTO   x_resource_txns.poc_trans_id
               /*start Punit Kumar*/
         ,      x_resource_txns.organization_id
                                               /*end*/

         --,x_resource_txns.ORGN_CODE
         ,      x_resource_txns.doc_type
               ,x_resource_txns.doc_id, x_resource_txns.line_type
               ,x_resource_txns.line_id, x_resource_txns.resources
               ,x_resource_txns.resource_usage, x_resource_txns.trans_um
               ,x_resource_txns.trans_date, x_resource_txns.completed_ind
               ,x_resource_txns.event_id, x_resource_txns.instance_id
               ,x_resource_txns.sequence_dependent_ind
               ,x_resource_txns.posted_ind
               ,x_resource_txns.overrided_protected_ind
               ,x_resource_txns.reason_code, x_resource_txns.reason_id, x_resource_txns.start_date
               ,x_resource_txns.end_date, x_resource_txns.delete_mark
               ,x_resource_txns.text_code, x_resource_txns.action_code
               ,x_resource_txns.transaction_no
               ,x_resource_txns.attribute_category        -- Bug 8978768
                                              /*start Punit Kumar*/
         ,      x_resource_txns.attribute1
               ,x_resource_txns.attribute2, x_resource_txns.attribute3
               ,x_resource_txns.attribute4, x_resource_txns.attribute5
               ,x_resource_txns.attribute6, x_resource_txns.attribute7
               ,x_resource_txns.attribute8, x_resource_txns.attribute9
               ,x_resource_txns.attribute10, x_resource_txns.attribute11
               ,x_resource_txns.attribute12, x_resource_txns.attribute13
               ,x_resource_txns.attribute14, x_resource_txns.attribute15
               ,x_resource_txns.attribute16, x_resource_txns.attribute17
               ,x_resource_txns.attribute18, x_resource_txns.attribute19
               ,x_resource_txns.attribute20, x_resource_txns.attribute21
               ,x_resource_txns.attribute22, x_resource_txns.attribute23
               ,x_resource_txns.attribute24, x_resource_txns.attribute25
               ,x_resource_txns.attribute26, x_resource_txns.attribute27
               ,x_resource_txns.attribute28, x_resource_txns.attribute29
               ,x_resource_txns.attribute30
           /*end */
         FROM   gme_resource_txns_gtmp
          WHERE poc_trans_id = p_resource_txns.poc_trans_id;
      ELSE
         gme_common_pvt.log_message ('GME_NO_KEYS'
                                    ,'TABLE_NAME'
                                    ,g_table_name);
         RETURN FALSE;
      END IF;

      RETURN TRUE;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         gme_common_pvt.log_message ('GME_NO_DATA_FOUND'
                                    ,'TABLE_NAME'
                                    ,g_table_name);
         RETURN FALSE;
      WHEN OTHERS THEN
         gme_common_pvt.log_message ('GME_UNEXPECTED_ERROR', 'ERROR'
                                    ,SQLERRM);
         RETURN FALSE;
   END fetch_row;

/* Api start of comments
 +============================================================================
 |   FUNCTION NAME
 |      delete_row
 |
 |   TYPE
 |      Private
 |   USAGE
 |      Delete_Row will delete a row in gme_resource_txns_gtmp
 |
 |
 |   DESCRIPTION
 |      Delete_Row will delete a row in gme_resource_txns_gtmp
 |
 |
 |
 |   PARAMETERS
 |     p_resource_txns IN  gme_resource_txns_gtmp%ROWTYPE
 |
 |   RETURNS
 |      BOOLEAN
 |   HISTORY
 |   12-MAR-01 Thomas Daniel   Created
 |
 |
 |
 +=============================================================================
 Api end of comments
*/
   FUNCTION delete_row (p_resource_txns IN gme_resource_txns_gtmp%ROWTYPE)
      RETURN BOOLEAN
   IS
   BEGIN
      IF p_resource_txns.poc_trans_id IS NOT NULL THEN
         UPDATE gme_resource_txns_gtmp
            SET delete_mark = 1
          WHERE poc_trans_id = p_resource_txns.poc_trans_id;
      ELSE
         gme_common_pvt.log_message ('GME_NO_KEYS'
                                    ,'TABLE_NAME'
                                    ,g_table_name);
         RETURN FALSE;
      END IF;

      IF SQL%FOUND THEN
         RETURN TRUE;
      ELSE
         gme_common_pvt.log_message ('GME_NO_DATA_FOUND'
                                    ,'TABLE_NAME'
                                    ,g_table_name);
         RETURN FALSE;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         gme_common_pvt.log_message ('GME_UNEXPECTED_ERROR', 'ERROR'
                                    ,SQLERRM);
         RETURN FALSE;
   END delete_row;

/* Api start of comments
 +============================================================================
 |   FUNCTION NAME
 |      update_row
 |
 |   TYPE
 |      Private
 |   USAGE
 |      Update_Row will update a row in gme_resource_txns_gtmp
 |
 |
 |   DESCRIPTION
 |      Update_Row will update a row in gme_resource_txns_gtmp
 |
 |
 |
 |   PARAMETERS
 |     p_resource_txns IN  gme_resource_txns_gtmp%ROWTYPE
 |
 |   RETURNS
 |      BOOLEAN
 |   HISTORY
 |   12-MAR-01 Thomas Daniel   Created
 |
 |
 |  16-March-2005 Punit Kumar Convergence changes
 |
 |  10-Oct-2009   G. Muratore   Bug 8978768
 |     Add attribute_category column.
 +=============================================================================
 Api end of comments
*/
   FUNCTION update_row (p_resource_txns IN gme_resource_txns_gtmp%ROWTYPE)
      RETURN BOOLEAN
   IS
   BEGIN
      IF p_resource_txns.poc_trans_id IS NOT NULL THEN
         UPDATE gme_resource_txns_gtmp
            SET
                --ORGN_CODE     = p_resource_txns.ORGN_CODE

                /* start , Punit Kumar */
                organization_id = p_resource_txns.organization_id
               /*end */
         ,      doc_type = p_resource_txns.doc_type
               ,doc_id = p_resource_txns.doc_id
               ,line_type = p_resource_txns.line_type
               ,line_id = p_resource_txns.line_id
               ,resources = p_resource_txns.resources
               ,resource_usage = p_resource_txns.resource_usage
               ,trans_um = p_resource_txns.trans_um
               ,trans_date = p_resource_txns.trans_date
               ,completed_ind = p_resource_txns.completed_ind
               ,event_id = p_resource_txns.event_id
               ,instance_id = p_resource_txns.instance_id
               ,sequence_dependent_ind =
                                        p_resource_txns.sequence_dependent_ind
               ,posted_ind = p_resource_txns.posted_ind
               ,overrided_protected_ind =
                                       p_resource_txns.overrided_protected_ind
               ,reason_code = p_resource_txns.reason_code
               ,reason_id = p_resource_txns.reason_id
               ,start_date = p_resource_txns.start_date
               ,end_date = p_resource_txns.end_date
               ,delete_mark = p_resource_txns.delete_mark
               ,text_code = p_resource_txns.text_code
               ,action_code = p_resource_txns.action_code
               ,transaction_no = p_resource_txns.transaction_no
               ,attribute_category = p_resource_txns.attribute_category      -- Bug 8978768
               /*start Punit Kumar*/
         ,      attribute1 = p_resource_txns.attribute1
               ,attribute2 = p_resource_txns.attribute2
               ,attribute3 = p_resource_txns.attribute3
               ,attribute4 = p_resource_txns.attribute4
               ,attribute5 = p_resource_txns.attribute5
               ,attribute6 = p_resource_txns.attribute6
               ,attribute7 = p_resource_txns.attribute7
               ,attribute8 = p_resource_txns.attribute8
               ,attribute9 = p_resource_txns.attribute9
               ,attribute10 = p_resource_txns.attribute10
               ,attribute11 = p_resource_txns.attribute11
               ,attribute12 = p_resource_txns.attribute12
               ,attribute13 = p_resource_txns.attribute13
               ,attribute14 = p_resource_txns.attribute14
               ,attribute15 = p_resource_txns.attribute15
               ,attribute16 = p_resource_txns.attribute16
               ,attribute17 = p_resource_txns.attribute17
               ,attribute18 = p_resource_txns.attribute18
               ,attribute19 = p_resource_txns.attribute19
               ,attribute20 = p_resource_txns.attribute20
               ,attribute21 = p_resource_txns.attribute21
               ,attribute22 = p_resource_txns.attribute22
               ,attribute23 = p_resource_txns.attribute23
               ,attribute24 = p_resource_txns.attribute24
               ,attribute25 = p_resource_txns.attribute25
               ,attribute26 = p_resource_txns.attribute26
               ,attribute27 = p_resource_txns.attribute27
               ,attribute28 = p_resource_txns.attribute28
               ,attribute29 = p_resource_txns.attribute29
               ,attribute30 = p_resource_txns.attribute30
          /*end */
         WHERE  poc_trans_id = p_resource_txns.poc_trans_id;
      ELSE
         gme_common_pvt.log_message ('GME_NO_KEYS'
                                    ,'TABLE_NAME'
                                    ,g_table_name);
         RETURN FALSE;
      END IF;

      IF SQL%FOUND THEN
         RETURN TRUE;
      ELSE
         gme_common_pvt.log_message ('GME_NO_DATA_FOUND'
                                    ,'TABLE_NAME'
                                    ,g_table_name);
         RETURN FALSE;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         gme_common_pvt.log_message ('GME_UNEXPECTED_ERROR', 'ERROR'
                                    ,SQLERRM);
         RETURN FALSE;
   END update_row;
END gme_resource_txns_gtmp_dbl;

/
