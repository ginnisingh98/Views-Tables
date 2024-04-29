--------------------------------------------------------
--  DDL for Package GME_GANTT_TABLE_HANDLER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GME_GANTT_TABLE_HANDLER_PKG" AUTHID CURRENT_USER AS
/* $Header: GMEGNTTS.pls 120.2 2006/04/06 06:42:59 svgonugu noship $  */

   /***********************************************************/
   /* Oracle Process Manufacturing Process Execution APIs     */
   /*                                                         */
   /* File Name: GMEGNTTS.pls                                 */
   /* Contents:  Package specification of Table handler for   */
   /*            gme_gantt_document_filter                    */
   /* HISTORY                                                 */
   /* SivakumarG 05-APR-2006 Bug#4867640                      */
   /*  Added to_document_no parameter                         */
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
     ,p_to_document_no      IN              VARCHAR2 --Bug#4867640
     ,p_document_type       IN              NUMBER
     ,p_product_code        IN              VARCHAR2
     ,p_ingredient_code     IN              VARCHAR2
     ,p_batch_status        IN              NUMBER
     ,x_return_code         OUT NOCOPY      VARCHAR2
     ,x_error_msg           OUT NOCOPY      VARCHAR2);

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
     ,x_error_msg           OUT NOCOPY      VARCHAR);

   /**
    * Select a row from the Document Filter table.
    */
   PROCEDURE select_row (
      p_user_id            IN              NUMBER
     ,p_organization_id    IN              NUMBER
     ,x_return_code        OUT NOCOPY      VARCHAR2
     ,x_error_msg          OUT NOCOPY      VARCHAR2
     ,x_filter_table_rec   OUT NOCOPY      gme_gantt_document_filter%ROWTYPE);
END;

 

/
