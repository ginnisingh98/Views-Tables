--------------------------------------------------------
--  DDL for Package CSI_CTR_INTERFACE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_CTR_INTERFACE_PUB" AUTHID CURRENT_USER as
/* $Header: csipcois.pls 120.0 2005/06/10 08:47 srramakr noship $ */

/*-----------------------------------------------------------*/
/* procedure name: Execute_Open_Interface                    */
/* description :   procedure used to capture                 */
/*                 counter readings from the Open Interface  */
/*-----------------------------------------------------------*/

PROCEDURE Execute_Open_Interface
 (
     errbuf                  OUT NOCOPY VARCHAR2
    ,retcode                 OUT NOCOPY NUMBER
    ,p_batch_name            IN         VARCHAR2
    ,p_src_txn_from_date     IN         DATE
    ,p_src_txn_to_date       IN         DATE
    ,p_purge_processed_recs  IN         VARCHAR2
    ,p_reprocess_option      IN         VARCHAR2
 );

END CSI_CTR_INTERFACE_PUB;

 

/
