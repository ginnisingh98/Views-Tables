--------------------------------------------------------
--  DDL for Package Body INV_TXNSTUB_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_TXNSTUB_PUB" AS
/* $Header: INVTPUBB.pls 120.5 2006/06/23 06:55:34 pannapra noship $ */
  /**
   *  p_header_id         = TRANSACTION_HEADER_ID
   *  p_transaction_id    = TRANSACTION_ID
   *  x_return_status     = FND_API.G_RET_STS_*;
   *  in case of an error, the error should be put onto the message stake
   *  using fnd_message.set_name and fnd_msg_pub.add functions or similar
   *  functions in those packages. The caller would then retrieve the
   *  messages. If the return status is a normal (predicted) error or
   *  an unexpected error, then the transaction is aborted.
     */

 /** Global added to cache the value of fnd_installation for
     * perfromance bug 3176229*/

     g_fnd_install_status VARCHAR2(10) := NULL;

  /*Bug#5349268. Modified the below procedure not to return with error when
    'NO_DATA_FOUND' exception is raised during the execution of the query which
    finds if the item is installbase trackable. In such case, the procedure does
    not call 'CSI_INV_TXN_HOOK_PKG.postTransaction' but returns with a return
    status of 'Success'. */
  PROCEDURE postTransaction(p_header_id IN NUMBER,
                            p_transaction_id IN NUMBER,
                            x_return_status OUT NOCOPY VARCHAR2)
  IS
		l_install_base_id number := 542 ; -- ApplicationId of Oracle-Install-Base
		l_status             varchar2(10);
		l_industry           varchar2(10);
		l_return_val         boolean := FALSE;
		--l_plsql_blk          varchar2(2000);
		l_ret_status         varchar2(255);
		l_debug              number;--Bug#5194809
                l_ib_trackable       varchar2(1); --Bug#5208421 -Part 2
  BEGIN
     -- Check if Oracle-Install-Base is installed in this instance
     -- If Install-Base is installed then call the stub of Install-Base,
     -- otherwise return success

     l_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0); --Bug#5194809

     IF (l_debug = 1) THEN
	inv_log_util.trace('Entered INV_TXNSTUB_PUB.postTransaction', 'INV_TXNSTUB_PUB', 9);
     END IF;


     l_ib_trackable := 'N'; --Bug#5349268

     IF ( g_fnd_install_status IS NULL) THEN

	l_return_val := fnd_installation.get(
					     appl_id       => l_install_base_id,
					     dep_appl_id   => l_install_base_id,
					     status        => l_status,
					     industry      => l_industry );
	g_fnd_install_status :=l_status;--set the global
     END IF;


     IF (g_fnd_install_status = 'I') THEN
       /*Bug#5208421 -Part 2. Added the following query, to find if the item is installbase
         trackable*/
       BEGIN
         SELECT NVL(comms_nl_trackable_flag,'N') into l_ib_trackable
         FROM   mtl_system_items a, mtl_material_transactions b
         WHERE  a.organization_id = b.organization_id
 	   AND  a.inventory_item_id = b.inventory_item_id
 	   AND  Nvl(b.inventory_item_id,-1) <> -1
 	   AND  enabled_flag = 'Y'
 	   AND  Nvl(start_date_active, sysdate) <= sysdate
 	   AND  Nvl(end_date_active, sysdate+1) > sysdate
 	   AND  b.transaction_id = p_transaction_id;

       IF (l_debug = 1) THEN
         inv_log_util.trace('InstallBase Trackable: '||l_ib_trackable, 'INV_TXNSTUB_PUB', 9);
       END IF;
       EXCEPTION
       WHEN NO_DATA_FOUND THEN
         IF (l_debug = 1) THEN
 	   inv_log_util.trace('No Data Found Exception raised', 'INV_TXNSTUB_PUB', 9);
	          END IF;
         l_ib_trackable := 'N';
       WHEN OTHERS THEN
         IF (l_debug = 1) THEN
 	   inv_log_util.trace('Exception while finding the InstallBase Trackable flag '||sqlerrm, 'INV_TXNSTUB_PUB', 9);
         END IF;
         x_return_status := FND_API.G_RET_STS_ERROR;
         return;
       END;
     END IF;

     if (g_fnd_install_status = 'I' AND l_ib_trackable = 'Y' ) then --Bug#5208421 -Part 2
         /*Bug#5194809. Changed the call of 'CSI_INV_TXN_HOOK_PKG.postTransaction'
	 from dyanamic style to static style. */
       IF (l_debug = 1) THEN
	 inv_log_util.trace('Calling CSI_INV_TXN_HOOK_PKG.postTransaction', 'INV_TXNSTUB_PUB', 9);
       END IF;
       CSI_INV_TXN_HOOK_PKG.postTransaction(  p_header_id =>  p_header_id
					    , p_transaction_id => p_transaction_id
					    , x_return_status   => l_ret_status );
       IF (l_debug = 1) THEN
	  inv_log_util.trace('Return Status from CSI_INV_TXN_HOOK_PKG.postTransaction: '||l_ret_status, 'INV_TXNSTUB_PUB', 9);
       END IF;

       x_return_status := l_ret_status;
      else
        IF (l_debug = 1) THEN
 	  inv_log_util.trace('g_fnd_install_status is not I or item is not installbase trackable' , 'INV_TXNSTUB_PUB', 9);
 	END IF;
    	x_return_status := FND_API.G_RET_STS_SUCCESS;
      end if;
  END;
END INV_TXNSTUB_PUB;

/
