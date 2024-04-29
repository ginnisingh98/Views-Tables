--------------------------------------------------------
--  DDL for Package Body AR_BR_CANCEL_UNPAID_API_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_BR_CANCEL_UNPAID_API_PUB" AS
/* $Header: ARBRUOCB.pls 120.6 2004/04/07 21:53:53 anukumar ship $*/
/*#
* Unpaid Bill API sets the status for each unpaid bill receivable to
* Unpaid or Canceled based on the Cancel Bill Receivable Flag value.
* It validates the BR number and status and calls the accounting engine
* to perform the appropriate accounting.
* @rep:scope public
* @rep:lifecycle active
* @rep:displayname Unpaid Bill API
* @rep:category BUSINESS_ENTITY AR_BILLS_RECEIVABLE
*/


PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

/*#
 * This procedure is the main procedure for the Unpaid Bill API.
 * @param p_api_version API version
 * @param p_init_msg_list Initialization of the message list
 * @param p_commit Commit
 * @param p_validation_level Validation level
 * @param p_customer_trx_id  Bill Receivable transaction ID
 * @param p_cancel_flag      Cancel Bill Receivable flag
 * @param p_reason     Reason
 * @param p_gl_date   GL date
 * @param p_comments   Comments
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Set Bill Receivable  as Canceled or Unpaid
  */


PROCEDURE CANCEL_OR_UNPAID(
    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_count        OUT NOCOPY NUMBER,
    x_msg_data         OUT NOCOPY VARCHAR2,
    p_api_version      IN  NUMBER,
    p_init_msg_list    IN  VARCHAR2 default FND_API.G_FALSE,
    p_commit           IN  VARCHAR2 default FND_API.G_FALSE,
    p_validation_level IN  NUMBER   default FND_API.G_VALID_LEVEL_FULL,

    p_customer_trx_id  IN  NUMBER,
    p_cancel_flag      IN  VARCHAR2,
    p_reason           IN  VARCHAR2,
    p_gl_date          IN  DATE,
    p_comments         IN  VARCHAR2,
    p_org_id           IN  NUMBER default null,
    x_bill_status      OUT NOCOPY VARCHAR2

)

IS

unpaid_br_error     EXCEPTION;
cancel_br_error     EXCEPTION;
no_setup_error      EXCEPTION;
invalid_flag        EXCEPTION;
l_error_code        NUMBER;
l_error_msg         VARCHAR2(255);
l_org_return_status VARCHAR2(1);
l_org_id                           NUMBER;
BEGIN



   GL_MC_CURRENCY_PKG.g_ar_upgrade_mode := TRUE;

   SAVEPOINT BR_B4;



/* SSA change */
       l_org_id            := p_org_id;
       l_org_return_status := FND_API.G_RET_STS_SUCCESS;
       ar_mo_cache_utils.set_org_context_in_api(p_org_id =>l_org_id,
                                                p_return_status =>l_org_return_status);
 IF l_org_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
           FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                     p_count => x_msg_count,
                                     p_data  => x_msg_data);
 ELSE
 IF p_cancel_flag ='N' then
        /*======================================+
        |                                       |
        |   Update BR to UNPAID                 |
        |                                       |
        +=======================================*/
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('CANCEL_OR_UNPAID: ' || '>>> Calling AR_BILLS_MAINTAIN_PUB.unpaid_br');
  END IF;
        AR_BILLS_MAINTAIN_PUB.unpaid_BR (

                p_api_version           =>  1.0         ,
                x_return_status         =>  x_return_status     ,
                x_msg_count             =>  x_msg_count         ,
                x_msg_data              =>  x_msg_data          ,

                p_customer_trx_id       =>  p_customer_trx_id   ,
                p_unpaid_date           =>  SYSDATE             ,
                p_unpaid_gl_date        =>  p_gl_date           ,
                p_unpaid_comments       =>  p_comments          ,
                p_unpaid_reason         =>  p_reason            ,
                p_status                =>  x_bill_status      );

       IF (x_return_status <> 'S') then
          IF PG_DEBUG in ('Y', 'C') THEN
             arp_standard.debug('CANCEL_OR_UNPAID: ' || '>>>>>>>>>> PROBLEM DURING BR unpaid');
          END IF;
          IF      (x_msg_count > 1) then
            x_msg_data := FND_MSG_PUB.Get(FND_MSG_PUB.G_NEXT,FND_API.G_FALSE);
          END IF;

          IF PG_DEBUG in ('Y', 'C') THEN
             arp_standard.debug('CANCEL_OR_UNPAID: ' || 'x_msg_data : '|| x_msg_data);
          END IF;
          RAISE unpaid_br_error;
       END IF;
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('CANCEL_OR_UNPAID: ' || '>>> Finished UNPAID CALL, new status '||x_bill_status);
     arp_standard.debug('CANCEL_OR_UNPAID: ' || '>>> Successfully Unpaid');
  END IF;

ELSIF p_cancel_flag ='Y'then
        /*======================================+
        |                                       |
        |   Update BR to CANCELLED              |
        |                                       |
        +=======================================*/
  IF p_reason IS NOT NULL then
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('CANCEL_OR_UNPAID: ' || '>>> WARNING >>> Cancel_BR requires no reason, Bill '||p_customer_trx_id||' reason not used.');
    END IF;
  END IF;
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('CANCEL_OR_UNPAID: ' || '>>> Calling AR_BILLS_MAINTAIN_PUB.cancel_br');
  END IF;
       AR_BILLS_MAINTAIN_PUB.Cancel_BR (

                p_api_version           =>  1.0         ,
                x_return_status         =>  x_return_status     ,
                x_msg_count             =>  x_msg_count         ,
                x_msg_data              =>  x_msg_data          ,

                p_customer_trx_id       =>  p_customer_trx_id   ,
                p_cancel_date           =>  SYSDATE             ,
                p_cancel_gl_date        =>  p_gl_date           ,
                p_cancel_comments       =>  p_comments          ,
                p_status                =>  x_bill_status      );

       IF (x_return_status <> 'S') then
          IF PG_DEBUG in ('Y', 'C') THEN
             arp_standard.debug('CANCEL_OR_UNPAID: ' || '>>>>>>>>>> PROBLEM DURING BR Cancel');
          END IF;
          IF      (x_msg_count > 1) then
            x_msg_data := FND_MSG_PUB.Get(FND_MSG_PUB.G_NEXT,FND_API.G_FALSE);
          END IF;

          IF PG_DEBUG in ('Y', 'C') THEN
             arp_standard.debug('CANCEL_OR_UNPAID: ' || 'x_msg_data : '|| x_msg_data);
          END IF;
          RAISE cancel_br_error;
       END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('CANCEL_OR_UNPAID: ' || '>>> Successfully Cancelled');
  END IF;
 ELSE
  RAISE invalid_flag;
 END IF;

 IF PG_DEBUG in ('Y', 'C') THEN
    arp_standard.debug('------ END OF  AR_BR_CANCEL_UNPAID_PKG.Cancel_or_unpaid -------');
    arp_standard.debug('CANCEL_OR_UNPAID: ' || 'RETURN STATUS      : ' || x_return_status);
    arp_standard.debug('CANCEL_OR_UNPAID: ' || 'BR IDENTIFIER      : ' || p_customer_trx_id);
    arp_standard.debug('CANCEL_OR_UNPAID: ' || 'STATUS             : ' || x_bill_status);
 END IF;
END IF;

EXCEPTION
   WHEN unpaid_BR_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       IF PG_DEBUG in ('Y', 'C') THEN
          arp_standard.debug('>>>>> CANCEL_OR_UNPAID, Unpaid BR EXCEPTION - ROLLBACK, return_status ='||x_return_status);
       END IF;
       Rollback to BR_B4;
       app_exception.raise_exception;

   WHEN cancel_BR_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       IF PG_DEBUG in ('Y', 'C') THEN
          arp_standard.debug('>>>>> CANCEL_OR_UNPAID, Cancel BR EXCEPTION - ROLLBACK, return_status ='||x_return_status);
       END IF;
       Rollback to BR_B4;
       app_exception.raise_exception;

   WHEN invalid_flag THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('>>>>> CANCEL_OR_UNPAID, Invalid value for p_cancel_flag - ROLLBACK');
      END IF;
      Rollback to BR_B4;
      app_exception.raise_exception;

   WHEN no_setup_error THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('>>>>> CANCEL_OR_UNPAID, Setup of org id not correctly performed');
      END IF;
      app_exception.raise_exception;

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('>>>>> CANCEL_OR_UNPAID, Others EXCEPTION - ROLLBACK, return_status ='||x_return_status);
      END IF;
      Rollback to BR_B4;
      l_error_code := SQLCODE;
      l_error_msg  := substr(SQLERRM,1,255);
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('CANCEL_OR_UNPAID: ' || '>>> Code: '||l_error_code||' Msg: '||l_error_msg);
      END IF;
      app_exception.raise_exception;


END CANCEL_OR_UNPAID;

end AR_BR_CANCEL_UNPAID_API_PUB;


/
