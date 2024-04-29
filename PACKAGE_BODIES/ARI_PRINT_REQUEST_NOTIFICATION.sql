--------------------------------------------------------
--  DDL for Package Body ARI_PRINT_REQUEST_NOTIFICATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARI_PRINT_REQUEST_NOTIFICATION" as
/* $Header: ARIPRNTB.pls 120.2 2006/06/21 07:52:12 abathini noship $ */

/*=======================================================================+
 |  Package Global Constants
 +=======================================================================*/
G_PKG_NAME CONSTANT VARCHAR2(30)    := 'ARI_PRINT_REQUEST_NOTIFICATION';
PG_DEBUG   VARCHAR2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

/*============================================================
  | PUBLIC notify
  |
  | DESCRIPTION
  |   PL/SQL Concurrent Program to send a single workflow notification
  |   on submission of multiple print requests in iReceivables
  |
  | PSEUDO CODE/LOGIC
  |
  | PARAMETERS
  |   p_requests              IN NUMBER
  |   p_max_wait_time         IN NUMBER DEFAULT 21600
  |   p_requests_list         IN VARCHAR2
  |   p_user_name             IN VARCHAR2
  |   p_customer_name         IN VARCHAR2
  |
  | KNOWN ISSUES
  |
  |
  |
  | NOTES
  |
  |
  |
  | MODIFICATION HISTORY
  | Date          Author       Description of Changes
  | 19-OCT-2004   vnb          Created
  +============================================================*/

PROCEDURE notify(
                    errbuf	                OUT NOCOPY VARCHAR2,
                    retcode                 OUT NOCOPY NUMBER,
                    p_requests              IN NUMBER,
                    p_max_wait_time         IN NUMBER DEFAULT 21600,
                    p_requests_list         IN VARCHAR2,
                    p_user_name             IN VARCHAR2,
                    p_customer_name         IN VARCHAR2

                ) IS

    l_request_id       NUMBER(30);
    l_requests_number  NUMBER;
    l_request_status   BOOLEAN;

    l_rphase           VARCHAR2(255);
    l_dphase           VARCHAR2(255);
    l_rstatus          VARCHAR2(255);
    l_dstatus          VARCHAR2(255);
    l_message          VARCHAR2(32000);

    l_procedure_name           VARCHAR2(50);
    l_debug_info	 	       VARCHAR2(200);

BEGIN
    l_procedure_name := '.notify';
     -- Initialize FND Global
    FND_MSG_PUB.INITIALIZE;

    ----------------------------------------------------------------------------------------
    l_debug_info := 'Get the first Request Id to be polled for';
    -----------------------------------------------------------------------------------------
    IF (PG_DEBUG = 'Y') THEN
        arp_standard.debug('Max Wait Time : '||p_max_wait_time);
        arp_standard.debug('No of requests: '||p_requests);
        arp_standard.debug('User Name     : '||p_user_name);
        arp_standard.debug(l_debug_info);
    END IF;

    IF (p_requests = 1) THEN
        l_request_id := p_requests_list;
    ELSE
        l_request_id := SUBSTR(p_requests_list, 1, INSTR(p_requests_list,',',1,1)-1);
    END IF;


    FOR l_requests_number IN 1..p_requests LOOP

        IF (PG_DEBUG = 'Y') THEN
            arp_standard.debug('Polling Request Id: '||l_request_id);
        END IF;

        l_request_status := FND_CONCURRENT.wait_for_request(
                                request_id => l_request_id,
		                        max_wait   => p_max_wait_time,
		                        phase      => l_rphase,
		                        status     => l_rstatus,
		                        dev_phase  => l_dphase,
                                dev_status => l_dstatus,
		                        message    => l_message);

        IF (p_requests > 1) THEN

            ----------------------------------------------------------------------------------------
            l_debug_info := 'Get the next Request Id to be polled for';
            -----------------------------------------------------------------------------------------
            IF (PG_DEBUG = 'Y') THEN
                arp_standard.debug(l_debug_info);
            END IF;

            IF (l_requests_number = p_requests-1) THEN
                l_request_id     := SUBSTR(p_requests_list, INSTR(p_requests_list,',',1,p_requests-1)+1,
                                            length(p_requests_list)- INSTR(p_requests_list,',',1,p_requests-1));
            ELSE
                l_request_id     := SUBSTR(p_requests_list, INSTR(p_requests_list,',',1,l_requests_number-1),
                                            INSTR(p_requests_list,',',1,l_requests_number));
            END IF;

        END IF;

    END LOOP;

    ----------------------------------------------------------------------------------------
    l_debug_info := 'Send Workflow notification';
    -----------------------------------------------------------------------------------------
    IF (PG_DEBUG = 'Y') THEN
        arp_standard.debug(l_debug_info);
    END IF;

    ARI_UTILITIES.send_notification(
                        p_user_name         => p_user_name,
                        p_customer_name     => p_customer_name,
                        p_request_id        => fnd_global.conc_request_id,
                        p_requests          => p_requests,
                        p_parameter         => p_requests_list,
                        p_subject_msg_name  => 'ARI_PRINT_NOTIFICATION_SUBJ',
                        p_subject_msg_appl  => 'AR');

EXCEPTION
    WHEN OTHERS THEN
      IF (PG_DEBUG = 'Y') THEN
        arp_standard.debug('Unexpected Exception in ' || G_PKG_NAME || l_procedure_name);
        arp_standard.debug(' - Max Wait Time : '||p_max_wait_time);
        arp_standard.debug(' - No of requests: '||p_requests);
        arp_standard.debug(' - User Name     : '||p_user_name);
        arp_standard.debug(' - Customer Name : '||p_customer_name);
        arp_standard.debug(' - Requests List : '||p_requests_list);
        arp_standard.debug('ERROR =>'|| SQLERRM);
      END IF;

      FND_MESSAGE.SET_NAME ('AR','ARI_REG_DISPLAY_UNEXP_ERROR');
      FND_MESSAGE.SET_TOKEN('PROCEDURE', G_PKG_NAME || l_procedure_name);
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO', l_debug_info);
      FND_MSG_PUB.ADD;

END notify;

/*============================================================
  | PUBLIC submit_notification_request
  |
  | DESCRIPTION
  |   Wrapper to submit the Concurrent Program to send a single workflow notification
  |   on submission of multiple print requests in iReceivables
  |
  | PSEUDO CODE/LOGIC
  |
  | PARAMETERS
  |   p_requests              IN NUMBER
  |   p_max_wait_time         IN NUMBER DEFAULT 21600
  |   p_requests_list         IN VARCHAR2
  |   p_user_name             IN VARCHAR2
  |   p_customer_name         IN VARCHAR2
  |
  | KNOWN ISSUES
  |
  |
  |
  | NOTES
  |
  |
  |
  | MODIFICATION HISTORY
  | Date          Author       Description of Changes
  | 19-OCT-2004   vnb          Created
  +============================================================*/
PROCEDURE submit_notification_request(p_requests              IN NUMBER,
                    p_max_wait_time         IN NUMBER DEFAULT 21600,
                    p_requests_list         IN VARCHAR2,
                    p_user_name             IN VARCHAR2,
                    p_customer_name         IN VARCHAR2) IS

    m_request_id  NUMBER;

    l_procedure_name           VARCHAR2(50);
    l_debug_info	 	       VARCHAR2(200);

BEGIN
    l_procedure_name := '.notify';

    savepoint start_notify;

    ----------------------------------------------------------------------------------------
    l_debug_info := 'Submit the iReceivables Print Notification Concurrent Program';
    -----------------------------------------------------------------------------------------
    IF (PG_DEBUG = 'Y') THEN
        arp_standard.debug(l_debug_info);
    END IF;

    m_request_id := FND_REQUEST.SUBMIT_REQUEST(
                  application   => 'AR'
                , program       => 'ARI_PRINT_NOTIFY'
                , description   => ''
                , start_time    => ''
                , sub_request   => FALSE
                , argument1     => p_requests
                , argument2     => p_max_wait_time
                , argument3     => p_requests_list
                , argument4     => p_user_name
                , argument5     => p_customer_name
                );

    IF m_request_id <> 0 THEN
        COMMIT;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
      IF (PG_DEBUG = 'Y') THEN
        arp_standard.debug('Unexpected Exception in ' || G_PKG_NAME || l_procedure_name);
        arp_standard.debug(' - Max Wait Time : '||p_max_wait_time);
        arp_standard.debug(' - No of requests: '||p_requests);
        arp_standard.debug(' - User Name     : '||p_user_name);
        arp_standard.debug(' - Customer Name : '||p_customer_name);
        arp_standard.debug(' - Requests List : '||p_requests_list);
        arp_standard.debug('ERROR =>'|| SQLERRM);
      END IF;

      FND_MESSAGE.SET_NAME ('AR','ARI_REG_DISPLAY_UNEXP_ERROR');
      FND_MESSAGE.SET_TOKEN('PROCEDURE', G_PKG_NAME || l_procedure_name);
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO', l_debug_info);
      FND_MSG_PUB.ADD;

      ROLLBACK TO SAVEPOINT start_notify;

END submit_notification_request;

END;


/
