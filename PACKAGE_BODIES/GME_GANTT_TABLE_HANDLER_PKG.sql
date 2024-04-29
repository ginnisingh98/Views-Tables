--------------------------------------------------------
--  DDL for Package Body GME_GANTT_TABLE_HANDLER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GME_GANTT_TABLE_HANDLER_PKG" AS
/* $Header: GMEGNTTB.pls 120.2 2006/04/06 06:48:29 svgonugu noship $  */

   g_debug               VARCHAR2 (5)
                               := NVL (fnd_profile.VALUE ('AFLOG_LEVEL'), 99);
   g_pkg_name   CONSTANT VARCHAR2 (30) := 'GME_GANTT_TABLE_HANDLER_PKG';

   /***********************************************************/
   /* Oracle Process Manufacturing Process Execution APIs     */
   /*                                                         */
   /* File Name: GMEGNTTB.pls                                 */
   /* Contents:  Table handler for gme_gantt_document_filter  */
   /* HISTORY                                                 */
   /* SivakumarG 05-APR-2006 Bug#4867640                      */
   /*  Added To Document No in all procedures                 */
   /***********************************************************/
   /**
    * Insert a row into the Document Filter table.
    */
   PROCEDURE insert_row (
      p_user_id             IN              NUMBER
     ,p_organization_id     IN              NUMBER
     ,p_from_date           IN              DATE
     ,p_to_date             IN              DATE
     ,p_resource            IN              VARCHAR2
     ,p_prim_resource_ind   IN              NUMBER
     ,p_document_no         IN              VARCHAR2
     ,p_to_document_no      IN              VARCHAR2  --Bug#4867640
     ,p_document_type       IN              NUMBER
     ,p_product_code        IN              VARCHAR2
     ,p_ingredient_code     IN              VARCHAR2
     ,p_batch_status        IN              NUMBER
     ,x_return_code         OUT NOCOPY      VARCHAR2
     ,x_error_msg           OUT NOCOPY      VARCHAR2)
   IS
   BEGIN
      x_return_code := 'S';

      INSERT INTO gme_gantt_document_filter
                  (user_id, organization_id, from_date, TO_DATE
                  ,resource_consumed, resource_ind, document_no, to_doc_no --Bug#4867640
                  ,document_type, product_yielded, ingredient_consumed
                  ,batch_status)
           VALUES (p_user_id, p_organization_id, p_from_date, p_to_date
                  ,p_resource, p_prim_resource_ind, p_document_no, p_to_document_no --Bug#4867640
                  ,p_document_type, p_product_code, p_ingredient_code
                  ,p_batch_status);

      COMMIT;
   EXCEPTION
      WHEN OTHERS THEN
         fnd_message.set_name ('GME', 'GME_UNEXPECTED_ERROR');
         fnd_message.set_token ('ERROR', SQLERRM);
         x_return_code := 'F';
         x_error_msg := fnd_message.get;
   END insert_row;

   /**
    * Update a row into the Document Filter table.
    */
   PROCEDURE update_row (
      p_user_id             IN              NUMBER
     ,p_organization_id     IN              NUMBER
     ,p_from_date           IN              DATE
     ,p_to_date             IN              DATE
     ,p_resource            IN              VARCHAR2
     ,p_prim_resource_ind   IN              NUMBER
     ,p_document_no         IN              VARCHAR2
     ,p_to_document_no      IN              VARCHAR2 --Bug#4867640
     ,p_document_type       IN              NUMBER
     ,p_product_code        IN              VARCHAR2
     ,p_ingredient_code     IN              VARCHAR2
     ,p_batch_status        IN              NUMBER
     ,x_return_code         OUT NOCOPY      VARCHAR2
     ,x_error_msg           OUT NOCOPY      VARCHAR)
   IS
   BEGIN
      x_return_code := 'S';

      UPDATE gme_gantt_document_filter
         SET from_date = p_from_date
            ,TO_DATE = p_to_date
            ,resource_consumed = p_resource
            ,resource_ind = p_prim_resource_ind
            ,document_no = p_document_no
	    ,to_doc_no = p_to_document_no --Bug#4867640
            ,document_type = p_document_type
            ,product_yielded = p_product_code
            ,ingredient_consumed = p_ingredient_code
            ,batch_status = p_batch_status
       WHERE user_id = p_user_id AND organization_id = p_organization_id;

      IF (SQL%NOTFOUND) THEN
         insert_row (p_user_id
                    ,p_organization_id
                    ,p_from_date
                    ,p_to_date
                    ,p_resource
                    ,p_prim_resource_ind
                    ,p_document_no
		    ,p_to_document_no --Bug#4867640
                    ,p_document_type
                    ,p_product_code
                    ,p_ingredient_code
                    ,p_batch_status
                    ,x_return_code
                    ,x_error_msg);
      END IF;

      COMMIT WORK;
   EXCEPTION
      WHEN OTHERS THEN
         fnd_message.set_name ('GME', 'GME_UNEXPECTED_ERROR');
         fnd_message.set_token ('ERROR', SQLERRM);
         x_return_code := 'F';
         x_error_msg := fnd_message.get;
   END update_row;

   /**
    * Select a row from the Document Filter table.
    */
   PROCEDURE select_row (
      p_user_id            IN              NUMBER
     ,p_organization_id    IN              NUMBER
     ,x_return_code        OUT NOCOPY      VARCHAR2
     ,x_error_msg          OUT NOCOPY      VARCHAR2
     ,x_filter_table_rec   OUT NOCOPY      gme_gantt_document_filter%ROWTYPE)
   IS
      CURSOR c_doc_filter
      IS
         SELECT *
           FROM gme_gantt_document_filter
          WHERE user_id = p_user_id AND organization_id = p_organization_id;
   BEGIN
      x_return_code := 'S';

      OPEN c_doc_filter;

      FETCH c_doc_filter
       INTO x_filter_table_rec;

      CLOSE c_doc_filter;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         NULL;
      WHEN OTHERS THEN
         fnd_message.set_name ('GME', 'GME_UNEXPECTED_ERROR');
         fnd_message.set_token ('ERROR', SQLERRM);
         x_return_code := 'F';
         x_error_msg := fnd_message.get;
   END select_row;
END;

/
