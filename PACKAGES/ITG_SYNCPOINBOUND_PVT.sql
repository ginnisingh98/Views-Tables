--------------------------------------------------------
--  DDL for Package ITG_SYNCPOINBOUND_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ITG_SYNCPOINBOUND_PVT" AUTHID CURRENT_USER AS
/* ARCS: $Header: itgvspis.pls 120.1 2005/10/06 02:09:19 bsaratna noship $
 * CVS:  itgvspis.pls,v 1.6 2002/12/23 21:20:30 ecoe Exp
 */

  /* Update a po line.
   * Current API version: 1.0
   *
   * Standard Business Object Input Arguments:
   *   p_api_version      => 1.0         Requires current API Version #.
   *   p_init_msg_list    => <bool>      FND_API bool controlling init of
   *                                     the message list within this proc.
   *   p_commit           => <bool>      FND_API bool controlling commit
   *                                     of work within this proc.
   *   p_validation_level => <num>       A FND_API validation level indicating
   *                                     the amount of optional validaton on
   *                                     the input values should be performed.
   *
   * Standard Business Object Output Arguments:
   *   x_return_status    VARCHAR2(1)    A FND_API return status char.
   *   x_msg_count        NUMBER         The number of error/trace messages.
   *   x_msg_data         VARCHAR2(2000) The message text if x_msg_count = 1,
   *					 otherwise use functions in FND_MSG_PUB
   *                                     to read each line of text.
   *
   * Functional Input Arguments (and SYNC_PO XML tags):
   *   p_po_code          => <POID>      Find the PO based on the string.
   *   p_org_id           => <SITELEVEL> The organization id.
   *   p_release_id       => <PORELEASE> If not NULL or 0, the release ID -
   *                                     indicating a RELEASE against the BPO
   *   p_line_num         => <POLINENUM> PO line number of row to be updatd.
   *   p_doc_type         => <DOCTYPE>   The 'document type' - action flag:
   *                                     RECEIPT, INSPECTION or INVOICE.
   *   p_quanity          => <QUANITY>   Quanity of items for row.
   *   p_amount           => <AMOUNT>    If doc type is 'INVOICE', the amount
   *                                     to invoice.
   */
  PROCEDURE Update_PoLine(
    x_return_status    OUT NOCOPY VARCHAR2,           /* VARCHAR2(1) */
    x_msg_count        OUT NOCOPY NUMBER,
    x_msg_data         OUT NOCOPY VARCHAR2,           /* VARCHAR2(2000) */

    p_po_code          IN         VARCHAR2,           /* VARCHAR2(20) */
    p_org_id           IN         VARCHAR2,
    p_release_id       IN         VARCHAR2 := NULL,

    p_line_num         IN         NUMBER,
    p_doc_type         IN         VARCHAR2,           /* VARCHAR2(40) */
    p_quantity         IN         NUMBER,
    p_amount           IN         NUMBER);

END ITG_SyncPoInbound_PVT;

 

/
