--------------------------------------------------------
--  DDL for Package INVKBCGN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INVKBCGN" AUTHID CURRENT_USER as
/* $Header: INVKBCGS.pls 115.5 2002/12/30 10:01:00 jsugumar ship $ */
 Procedure Create_Kanban_Cards(
                               ERRBUF                OUT NOCOPY VARCHAR2,
                               RETCODE               OUT NOCOPY NUMBER,
                               X_ORG_ID              IN  NUMBER,
                               X_ITEM_LO             IN  VARCHAR2,
                               X_ITEM_HI             IN  VARCHAR2,
                               X_SUBINV              IN  VARCHAR2,
                               X_LOCATOR_LO          IN  VARCHAR2,
                               X_LOCATOR_HI          IN  VARCHAR2,
                               X_SOURCE_TYPE         IN  NUMBER,
                               X_SUPPLIER_ID         IN  NUMBER,
                               X_SUPPLIER_SITE_ID    IN  NUMBER,
                               X_SOURCING_ORG_ID     IN  NUMBER,
                               X_SOURCING_SUBINV     IN  VARCHAR2,
                               X_SOURCING_LOC_ID     IN  NUMBER,
                               X_WIP_LINE_ID         IN  NUMBER,
                               X_STATUS              IN  NUMBER,
                               X_PULL_SEQ_ID         IN  NUMBER,
                               X_PRINT_KANBAN_CARD   IN  NUMBER,
	                       X_REPORT_ID           IN  NUMBER  );

 function  resolve_pullseq_all_null(
                               X_ORG_ID              IN  NUMBER,
                               X_ITEM_LO             IN  VARCHAR2,
                               X_ITEM_HI             IN  VARCHAR2,
                               X_SUBINV              IN  VARCHAR2,
                               X_LOCATOR_LO          IN  VARCHAR2,
                               X_LOCATOR_HI          IN  VARCHAR2,
                               X_SOURCE_TYPE         IN  NUMBER,
                               X_SUPPLIER_ID         IN  NUMBER,
                               X_SUPPLIER_SITE_ID    IN  NUMBER,
                               X_SOURCING_ORG_ID     IN  NUMBER,
                               X_SOURCING_SUBINV     IN  VARCHAR2,
                               X_SOURCING_LOC_ID     IN  NUMBER,
                               X_WIP_LINE_ID         IN  NUMBER,
                               X_STATUS              IN  NUMBER,
                               X_PRINT_KANBAN_CARD   IN  NUMBER  )
           return Number;

 function  resolve_pullseq_with_pull(
                               X_STATUS              IN  NUMBER,
                               X_PULL_SEQ_ID         IN  NUMBER,
                               X_PRINT_KANBAN_CARD   IN  NUMBER,
        	               X_REPORT_ID           IN  NUMBER )
           return Number;

 function  resolve_pullseq_with_loc(
                               X_ORG_ID              IN  NUMBER,
                               X_ITEM_LO             IN  VARCHAR2,
                               X_ITEM_HI             IN  VARCHAR2,
                               X_SUBINV              IN  VARCHAR2,
                               X_LOCATOR_LO          IN  VARCHAR2,
                               X_LOCATOR_HI          IN  VARCHAR2,
                               X_SOURCE_TYPE         IN  NUMBER,
                               X_SUPPLIER_ID         IN  NUMBER,
                               X_SUPPLIER_SITE_ID    IN  NUMBER,
                               X_SOURCING_ORG_ID     IN  NUMBER,
                               X_SOURCING_SUBINV     IN  VARCHAR2,
                               X_SOURCING_LOC_ID     IN  NUMBER,
                               X_WIP_LINE_ID         IN  NUMBER,
                               X_STATUS              IN  NUMBER,
                               X_PRINT_KANBAN_CARD   IN  NUMBER  )
           return Number;

 function  resolve_pullseq_no_loc(
                               X_ORG_ID              IN  NUMBER,
                               X_ITEM_LO             IN  VARCHAR2,
                               X_ITEM_HI             IN  VARCHAR2,
                               X_SUBINV              IN  VARCHAR2,
                               X_LOCATOR_LO          IN  VARCHAR2,
                               X_LOCATOR_HI          IN  VARCHAR2,
                               X_SOURCE_TYPE         IN  NUMBER,
                               X_SUPPLIER_ID         IN  NUMBER,
                               X_SUPPLIER_SITE_ID    IN  NUMBER,
                               X_SOURCING_ORG_ID     IN  NUMBER,
                               X_SOURCING_SUBINV     IN  VARCHAR2,
                               X_SOURCING_LOC_ID     IN  NUMBER,
                               X_WIP_LINE_ID         IN  NUMBER,
                               X_STATUS              IN  NUMBER,
                               X_PRINT_KANBAN_CARD   IN  NUMBER  )
           return Number;


 procedure  card_check_and_create(  X_PULL_SEQUENCE_ID    IN  NUMBER,
                                    X_ORG_ID              IN  NUMBER,
                                    X_ITEM_ID             IN  NUMBER,
                                    X_SUBINV              IN  VARCHAR2,
                                    X_LOC_ID              IN  NUMBER,
                                    X_SOURCE_TYPE         IN  NUMBER,
                                    X_KANBAN_SIZE         IN  NUMBER,
                                    X_NO_OF_CARDS         IN  NUMBER,
				    X_SUPPLIER_ID         IN  NUMBER,
                                    X_SUPPLIER_SITE_ID    IN  NUMBER,
                                    X_SOURCING_ORG_ID     IN  NUMBER,
                                    X_SOURCING_SUBINV     IN  VARCHAR2,
                                    X_SOURCING_LOC_ID     IN  NUMBER,
                                    X_WIP_LINE_ID         IN  NUMBER,
                                    X_STATUS              IN  NUMBER,
   X_PRINT_KANBAN_CARD   IN  NUMBER,
   p_release_kanban_flag IN NUMBER,
                                    X_REPORT_ID        IN OUT NOCOPY NUMBER  );


 procedure  query_range_loc(   X_ORG_ID      IN  NUMBER,
                               X_LOCATOR_LO  IN  VARCHAR2,
                               X_LOCATOR_HI  IN  VARCHAR2,
                               X_WHERE       OUT NOCOPY VARCHAR2   );

 procedure  query_range_itm(   X_ITEM_LO     IN  VARCHAR2,
                               X_ITEM_HI     IN  VARCHAR2,
                               X_WHERE       OUT NOCOPY VARCHAR2   );

 procedure  print_kanban_report ( X_REPORT_ID   IN NUMBER );

 procedure  print_error;

 procedure  kb_get_conc_segments(  X_ORG_ID         IN  NUMBER,
                                   X_LOC_ID         IN  NUMBER,
                                   X_CONC_SEGS      OUT NOCOPY VARCHAR2
                                 );
END INVKBCGN;

 

/
