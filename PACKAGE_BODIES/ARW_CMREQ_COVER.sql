--------------------------------------------------------
--  DDL for Package Body ARW_CMREQ_COVER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARW_CMREQ_COVER" AS
/* $Header: ARWCMRQB.pls 120.39.12010000.11 2009/10/28 11:04:28 pnallabo ship $ */


PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

FUNCTION ar_request_cm(
     p_customer_trx_id      IN  ra_customer_trx.customer_trx_id%type,
     p_line_credits_flag    IN  ra_cm_requests.line_credits_flag%type,
     p_line_amount	    IN  number,
     p_tax_amount           IN  number,
     p_freight_amount       IN  number,
     p_cm_lines_tbl         IN  Cm_Line_Tbl_Type_Cover,
     p_cm_reason_code       IN  varchar2,
     p_comments             IN  varchar2,
     p_url                  IN  ra_cm_requests.url%TYPE,
     p_transaction_url      IN  ra_cm_requests.transaction_url%TYPE,
     p_trans_act_url        IN  ra_cm_requests.activities_url%TYPE,
     p_orig_trx_number      IN  varchar2,
     p_tax_ex_cert_num	    IN  varchar2,
     p_skip_workflow_flag   IN VARCHAR2,
     p_trx_number           IN ra_customer_trx.trx_number%type   DEFAULT NULL,
     p_credit_method_installments IN VARCHAR2,
     p_credit_method_rules  IN VARCHAR2,
     p_batch_source_name    IN VARCHAR2,
     /*4556000-4606558*/
     pq_attribute_rec           IN pq_attribute_rec_type DEFAULT pq_attribute_rec_const,
     pq_interface_attribute_rec IN pq_interface_rec_type DEFAULT pq_interface_rec_const,
     pq_global_attribute_rec    IN pq_global_attribute_rec_type DEFAULT
                                        pq_global_attribute_const,
     p_dispute_date		IN DATE DEFAULT NULL, -- Bug 6358930
     p_internal_comment IN VARCHAR2 DEFAULT NULL  /*7367350*/
      ) RETURN varchar2
IS
/* org_id is not needed
     l_org_id		number := 204;*/
     l_customer_trx_id number(15);
     l_line_amount number;
     l_line_credits_flag varchar2(1);
     l_request_id number;
     /* Bug 3206020 Changed comments width from 240 to 1760. */
     l_comments varchar2(1760);
     l_error_code  number;
     l_error_msg  varchar2(2000);
     l_error_tab  arp_trx_validate.Message_Tbl_Type;
     l_num_lines   number;
     l_total_amount number;
     l_total_line_amount number;
     l_dispute_amount number;
     l_url      ra_cm_requests.url%TYPE;
     l_status	varchar2(255);
     l_profile_value fnd_profile_option_values.profile_option_value%TYPE;
/*Bug 5481525 variables to hold status of CM creation*/
     l_credit_memo_id                number;
     l_result                        VARCHAR2(10);
     l_threshold            NUMBER;
     /*4220382 */

CURSOR ps_cur IS
      SELECT payment_schedule_id , due_date , dispute_date , amount_in_dispute
         FROM  ar_payment_schedules ps
         WHERE  ps.customer_trx_id = p_customer_trx_id;

BEGIN
IF PG_DEBUG in ('Y', 'C') THEN
   arp_util.debug('arw_cmreq_cover.ar_request_cm(+)' );
END IF;

    /*---------------------+
     | Set the Org Context |
     +---------------------*/

      /*fnd_client_info.set_org_context(to_char(l_org_id));*/

    /*---------------------+
     | Check Exceptions    |
     +---------------------*/


     -- Total Credit Memo Header Amount
     l_total_amount := nvl(p_line_amount,0)+nvl(p_tax_amount,0)
			+ nvl(p_freight_amount,0);

 /* Insert Request information into Candidate table */

    /*-----------------------------------------+
     | Get the unique identifier for request_id|
     +-----------------------------------------*/

  select ra_cm_requests_s.nextval
  into l_request_id
  from sys.dual;


-- The users of the CMWF API have to pass in the url for the request
-- confirmation page, which will be used to display the page from the
-- notifications screen in worflow. The request_id has to be a parameter for
-- the confirmation page. However, the request_id will not be available to the
-- calling program at the time the CMWF API is called and cannot be passed along
-- with the url. We need to append the req_id before the url is stored in
-- the db
   l_url := replace (p_url,'req_id=', 'req_id='||l_request_id);

   -- Bug 2105483 : rather then calling arp_global at the start
   -- of the package, where it can error out NOCOPY since org_id is not yet set,
   -- do the call right before it is needed
   arp_global.init_global;

    /*-----------------------------------------+
     | Insert Record into Request Table        |
     +-----------------------------------------*/

  /*4556000-4606558 added additional columns*/
  INSERT INTO ra_cm_requests
            (request_id,
             customer_trx_id,
             cm_customer_trx_id,
             url,
             line_credits_flag,
             line_amount,
             tax_amount,
             freight_amount,
             cm_reason_code,
             comments,
             status,
             approval_date,
             last_update_date,
             last_updated_by,
             creation_date,
             created_by,
             last_update_login,
             transaction_url,
	     activities_url,
             orig_trx_number,
 	     tax_ex_cert_num,
             org_id,
	     INTERFACE_HEADER_CONTEXT,
	     INTERFACE_HEADER_ATTRIBUTE1,
	     INTERFACE_HEADER_ATTRIBUTE2,
	     INTERFACE_HEADER_ATTRIBUTE3,
	     INTERFACE_HEADER_ATTRIBUTE4,
	     INTERFACE_HEADER_ATTRIBUTE5,
	     INTERFACE_HEADER_ATTRIBUTE6,
	     INTERFACE_HEADER_ATTRIBUTE7,
	     INTERFACE_HEADER_ATTRIBUTE8,
	     INTERFACE_HEADER_ATTRIBUTE9,
	     INTERFACE_HEADER_ATTRIBUTE10,
	     INTERFACE_HEADER_ATTRIBUTE11,
	     INTERFACE_HEADER_ATTRIBUTE12,
	     INTERFACE_HEADER_ATTRIBUTE13,
	     INTERFACE_HEADER_ATTRIBUTE14,
	     INTERFACE_HEADER_ATTRIBUTE15,
	     ATTRIBUTE_CATEGORY,
	     ATTRIBUTE1,
	     ATTRIBUTE2,
	     ATTRIBUTE3,
	     ATTRIBUTE4,
	     ATTRIBUTE5,
	     ATTRIBUTE6,
	     ATTRIBUTE7,
	     ATTRIBUTE8,
	     ATTRIBUTE9,
	     ATTRIBUTE10,
	     ATTRIBUTE11,
	     ATTRIBUTE12,
	     ATTRIBUTE13,
	     ATTRIBUTE14,
	     ATTRIBUTE15,
	     GLOBAL_ATTRIBUTE_CATEGORY,
	     GLOBAL_ATTRIBUTE1,
	     GLOBAL_ATTRIBUTE2,
	     GLOBAL_ATTRIBUTE3,
	     GLOBAL_ATTRIBUTE4,
	     GLOBAL_ATTRIBUTE5,
	     GLOBAL_ATTRIBUTE6,
	     GLOBAL_ATTRIBUTE7,
	     GLOBAL_ATTRIBUTE8,
	     GLOBAL_ATTRIBUTE9,
	     GLOBAL_ATTRIBUTE10,
	     GLOBAL_ATTRIBUTE11,
	     GLOBAL_ATTRIBUTE12,
	     GLOBAL_ATTRIBUTE13,
	     GLOBAL_ATTRIBUTE14,
	     GLOBAL_ATTRIBUTE15,
	     GLOBAL_ATTRIBUTE16,
	     GLOBAL_ATTRIBUTE17,
	     GLOBAL_ATTRIBUTE18,
	     GLOBAL_ATTRIBUTE19,
	     GLOBAL_ATTRIBUTE20,
	     GLOBAL_ATTRIBUTE21,
	     GLOBAL_ATTRIBUTE22,
	     GLOBAL_ATTRIBUTE23,
	     GLOBAL_ATTRIBUTE24,
	     GLOBAL_ATTRIBUTE25,
	     GLOBAL_ATTRIBUTE26,
	     GLOBAL_ATTRIBUTE27,
	     GLOBAL_ATTRIBUTE28,
	     GLOBAL_ATTRIBUTE29,
	     GLOBAL_ATTRIBUTE30,
	     DISPUTE_DATE,
             INTERNAL_COMMENT,
	     RESPONSIBILITY_ID   /* Bug 8832584 */
            )
         VALUES
           (
            l_request_id,
            p_customer_trx_id,
            NULL,
            l_url,
            p_line_credits_flag,
            p_line_amount,
            p_tax_amount,
            p_freight_amount,
            p_cm_reason_code,
            p_comments,
            'PENDING_APPROVAL',
                 NULL,
	    arp_global.last_update_date,
	    arp_global.last_updated_by,
	    arp_global.creation_date,
	    arp_global.created_by,
	    arp_global.last_update_login,
            p_transaction_url,
	    p_trans_act_url,
	    p_orig_trx_number,
            p_tax_ex_cert_num,
            arp_standard.sysparm.org_id,
            pq_interface_attribute_rec.interface_header_context,
            pq_interface_attribute_rec.interface_header_attribute1,
            pq_interface_attribute_rec.interface_header_attribute2,
            pq_interface_attribute_rec.interface_header_attribute3,
            pq_interface_attribute_rec.interface_header_attribute4,
            pq_interface_attribute_rec.interface_header_attribute5,
            pq_interface_attribute_rec.interface_header_attribute6,
            pq_interface_attribute_rec.interface_header_attribute7,
            pq_interface_attribute_rec.interface_header_attribute8,
            pq_interface_attribute_rec.interface_header_attribute9,
            pq_interface_attribute_rec.interface_header_attribute10,
            pq_interface_attribute_rec.interface_header_attribute11,
            pq_interface_attribute_rec.interface_header_attribute12,
            pq_interface_attribute_rec.interface_header_attribute13,
            pq_interface_attribute_rec.interface_header_attribute14,
            pq_interface_attribute_rec.interface_header_attribute15,
	    pq_attribute_rec.attribute_category,
	    pq_attribute_rec.attribute1,
	    pq_attribute_rec.attribute2,
	    pq_attribute_rec.attribute3,
	    pq_attribute_rec.attribute4,
	    pq_attribute_rec.attribute5,
	    pq_attribute_rec.attribute6,
	    pq_attribute_rec.attribute7,
	    pq_attribute_rec.attribute8,
	    pq_attribute_rec.attribute9,
	    pq_attribute_rec.attribute10,
	    pq_attribute_rec.attribute11,
	    pq_attribute_rec.attribute12,
	    pq_attribute_rec.attribute13,
	    pq_attribute_rec.attribute14,
	    pq_attribute_rec.attribute15,
            pq_global_attribute_rec.global_attribute_category,
            pq_global_attribute_rec.global_attribute1,
            pq_global_attribute_rec.global_attribute2,
            pq_global_attribute_rec.global_attribute3,
            pq_global_attribute_rec.global_attribute4,
            pq_global_attribute_rec.global_attribute5,
            pq_global_attribute_rec.global_attribute6,
            pq_global_attribute_rec.global_attribute7,
            pq_global_attribute_rec.global_attribute8,
            pq_global_attribute_rec.global_attribute9,
            pq_global_attribute_rec.global_attribute10,
            pq_global_attribute_rec.global_attribute11,
            pq_global_attribute_rec.global_attribute12,
            pq_global_attribute_rec.global_attribute13,
            pq_global_attribute_rec.global_attribute14,
            pq_global_attribute_rec.global_attribute15,
            pq_global_attribute_rec.global_attribute16,
            pq_global_attribute_rec.global_attribute17,
            pq_global_attribute_rec.global_attribute18,
            pq_global_attribute_rec.global_attribute19,
            pq_global_attribute_rec.global_attribute20,
            pq_global_attribute_rec.global_attribute21,
            pq_global_attribute_rec.global_attribute22,
            pq_global_attribute_rec.global_attribute23,
            pq_global_attribute_rec.global_attribute24,
            pq_global_attribute_rec.global_attribute25,
            pq_global_attribute_rec.global_attribute26,
            pq_global_attribute_rec.global_attribute27,
            pq_global_attribute_rec.global_attribute28,
            pq_global_attribute_rec.global_attribute29,
            pq_global_attribute_rec.global_attribute30,
	    p_dispute_date,
	    p_internal_comment,
	    FND_GLOBAL.RESP_ID   /* Bug 8832584 */
	    );

     IF p_line_credits_flag IN ('Y','L')  THEN
         l_num_lines := p_cm_lines_tbl.count;

        For i in 1..l_num_lines
        LOOP
             l_total_line_amount := nvl(l_total_line_amount,0)+
					nvl(p_cm_lines_tbl(i).extended_amount,0);
	     /*4556000-4606558 additional columns added here*/
             INSERT into ra_cm_request_lines
             ( request_id,
               customer_trx_line_id,
               extended_amount,
               last_update_date,
               last_updated_by,
               creation_date,
               created_by,
               last_update_login,
	       quantity,
	       price,
	       org_id,
	      INTERFACE_LINE_CONTEXT,
	      INTERFACE_LINE_ATTRIBUTE1,
	      INTERFACE_LINE_ATTRIBUTE2,
	      INTERFACE_LINE_ATTRIBUTE3,
	      INTERFACE_LINE_ATTRIBUTE4,
	      INTERFACE_LINE_ATTRIBUTE5,
	      INTERFACE_LINE_ATTRIBUTE6,
	      INTERFACE_LINE_ATTRIBUTE7,
	      INTERFACE_LINE_ATTRIBUTE8,
	      INTERFACE_LINE_ATTRIBUTE9,
	      INTERFACE_LINE_ATTRIBUTE10,
	      INTERFACE_LINE_ATTRIBUTE11,
	      INTERFACE_LINE_ATTRIBUTE12,
	      INTERFACE_LINE_ATTRIBUTE13,
	      INTERFACE_LINE_ATTRIBUTE14,
	      INTERFACE_LINE_ATTRIBUTE15,
	      ATTRIBUTE_CATEGORY        ,
	      ATTRIBUTE1                ,
	      ATTRIBUTE2                ,
	      ATTRIBUTE3                ,
	      ATTRIBUTE4                ,
	      ATTRIBUTE5                ,
	      ATTRIBUTE6                ,
	      ATTRIBUTE7                ,
	      ATTRIBUTE8                ,
	      ATTRIBUTE9                ,
	      ATTRIBUTE10               ,
	      ATTRIBUTE11               ,
	      ATTRIBUTE12               ,
	      ATTRIBUTE13               ,
	      ATTRIBUTE14               ,
	      ATTRIBUTE15               ,
	      GLOBAL_ATTRIBUTE_CATEGORY ,
	      GLOBAL_ATTRIBUTE1         ,
	      GLOBAL_ATTRIBUTE2         ,
	      GLOBAL_ATTRIBUTE3         ,
	      GLOBAL_ATTRIBUTE4         ,
	      GLOBAL_ATTRIBUTE5         ,
	      GLOBAL_ATTRIBUTE6         ,
	      GLOBAL_ATTRIBUTE7         ,
	      GLOBAL_ATTRIBUTE8         ,
	      GLOBAL_ATTRIBUTE9         ,
	      GLOBAL_ATTRIBUTE10        ,
	      GLOBAL_ATTRIBUTE11        ,
	      GLOBAL_ATTRIBUTE12        ,
	      GLOBAL_ATTRIBUTE13        ,
	      GLOBAL_ATTRIBUTE14        ,
	      GLOBAL_ATTRIBUTE15        ,
	      GLOBAL_ATTRIBUTE16        ,
	      GLOBAL_ATTRIBUTE17        ,
	      GLOBAL_ATTRIBUTE18        ,
	      GLOBAL_ATTRIBUTE19        ,
	      GLOBAL_ATTRIBUTE20
	       )
             VALUES
              (l_request_id,
               p_cm_lines_tbl(i).customer_trx_line_id,
               p_cm_lines_tbl(i).extended_amount,
	       arp_global.last_update_date,
	       arp_global.last_updated_by,
	       arp_global.creation_date,
	       arp_global.created_by,
	       arp_global.last_update_login,
	       p_cm_lines_tbl(i).quantity_credited,
	       p_cm_lines_tbl(i).price,
               arp_standard.sysparm.org_id,
	      p_cm_lines_tbl(i).INTERFACE_LINE_CONTEXT,
	      p_cm_lines_tbl(i).INTERFACE_LINE_ATTRIBUTE1,
	      p_cm_lines_tbl(i).INTERFACE_LINE_ATTRIBUTE2,
	      p_cm_lines_tbl(i).INTERFACE_LINE_ATTRIBUTE3,
	      p_cm_lines_tbl(i).INTERFACE_LINE_ATTRIBUTE4,
	      p_cm_lines_tbl(i).INTERFACE_LINE_ATTRIBUTE5,
	      p_cm_lines_tbl(i).INTERFACE_LINE_ATTRIBUTE6,
	      p_cm_lines_tbl(i).INTERFACE_LINE_ATTRIBUTE7,
	      p_cm_lines_tbl(i).INTERFACE_LINE_ATTRIBUTE8,
	      p_cm_lines_tbl(i).INTERFACE_LINE_ATTRIBUTE9,
	      p_cm_lines_tbl(i).INTERFACE_LINE_ATTRIBUTE10,
	      p_cm_lines_tbl(i).INTERFACE_LINE_ATTRIBUTE11,
	      p_cm_lines_tbl(i).INTERFACE_LINE_ATTRIBUTE12,
	      p_cm_lines_tbl(i).INTERFACE_LINE_ATTRIBUTE13,
	      p_cm_lines_tbl(i).INTERFACE_LINE_ATTRIBUTE14,
	      p_cm_lines_tbl(i).INTERFACE_LINE_ATTRIBUTE15,
	      p_cm_lines_tbl(i).ATTRIBUTE_CATEGORY        ,
	      p_cm_lines_tbl(i).ATTRIBUTE1                ,
	      p_cm_lines_tbl(i).ATTRIBUTE2                ,
	      p_cm_lines_tbl(i).ATTRIBUTE3                ,
	      p_cm_lines_tbl(i).ATTRIBUTE4                ,
	      p_cm_lines_tbl(i).ATTRIBUTE5                ,
	      p_cm_lines_tbl(i).ATTRIBUTE6                ,
	      p_cm_lines_tbl(i).ATTRIBUTE7                ,
	      p_cm_lines_tbl(i).ATTRIBUTE8                ,
	      p_cm_lines_tbl(i).ATTRIBUTE9                ,
	      p_cm_lines_tbl(i).ATTRIBUTE10               ,
	      p_cm_lines_tbl(i).ATTRIBUTE11               ,
	      p_cm_lines_tbl(i).ATTRIBUTE12               ,
	      p_cm_lines_tbl(i).ATTRIBUTE13               ,
	      p_cm_lines_tbl(i).ATTRIBUTE14               ,
	      p_cm_lines_tbl(i).ATTRIBUTE15               ,
	      p_cm_lines_tbl(i).GLOBAL_ATTRIBUTE_CATEGORY ,
	      p_cm_lines_tbl(i).GLOBAL_ATTRIBUTE1         ,
	      p_cm_lines_tbl(i).GLOBAL_ATTRIBUTE2         ,
	      p_cm_lines_tbl(i).GLOBAL_ATTRIBUTE3         ,
	      p_cm_lines_tbl(i).GLOBAL_ATTRIBUTE4         ,
	      p_cm_lines_tbl(i).GLOBAL_ATTRIBUTE5         ,
	      p_cm_lines_tbl(i).GLOBAL_ATTRIBUTE6         ,
	      p_cm_lines_tbl(i).GLOBAL_ATTRIBUTE7         ,
	      p_cm_lines_tbl(i).GLOBAL_ATTRIBUTE8         ,
	      p_cm_lines_tbl(i).GLOBAL_ATTRIBUTE9         ,
	      p_cm_lines_tbl(i).GLOBAL_ATTRIBUTE10        ,
	      p_cm_lines_tbl(i).GLOBAL_ATTRIBUTE11        ,
	      p_cm_lines_tbl(i).GLOBAL_ATTRIBUTE12        ,
	      p_cm_lines_tbl(i).GLOBAL_ATTRIBUTE13        ,
	      p_cm_lines_tbl(i).GLOBAL_ATTRIBUTE14        ,
	      p_cm_lines_tbl(i).GLOBAL_ATTRIBUTE15        ,
	      p_cm_lines_tbl(i).GLOBAL_ATTRIBUTE16        ,
	      p_cm_lines_tbl(i).GLOBAL_ATTRIBUTE17        ,
	      p_cm_lines_tbl(i).GLOBAL_ATTRIBUTE18        ,
	      p_cm_lines_tbl(i).GLOBAL_ATTRIBUTE19        ,
	      p_cm_lines_tbl(i).GLOBAL_ATTRIBUTE20
	       );
         END LOOP;
      END IF;


    /* Calculate total Dispute Amount  */

       IF p_line_credits_flag IN ('Y','L')

       THEN
		l_dispute_amount := l_total_line_amount;
       ELSE
	        l_dispute_amount := l_total_amount;
       END IF;

       UPDATE ra_cm_requests
       SET total_amount = l_dispute_amount
       WHERE request_id = l_request_id;


-- Put Invoice in Dispute before instantiation of Workflow Approval
   /*4220382 */

   IF NVL(p_skip_workflow_flag,'N') = 'N' THEN
      BEGIN
         l_dispute_amount := l_dispute_amount * -1;   /*4469239 */

         FOR ps_rec  IN ps_cur
         LOOP

                ps_rec.amount_in_dispute := NVL(ps_rec.amount_in_dispute,0) + NVL(l_dispute_amount,0);
               IF p_dispute_date IS NOT NULL AND
                           p_dispute_date >= NVL(ps_rec.dispute_date, p_dispute_date)
                   THEN
                   ps_rec.dispute_date := p_dispute_date;
                ELSIF p_dispute_date IS NULL AND
                      (ps_rec.dispute_date IS NULL OR
                      NVL(ps_rec.dispute_date,trunc(sysdate)) <= trunc(sysdate))
                   THEN
                   ps_rec.dispute_date := arp_global.last_update_date;
                END IF;
                arp_process_cutil.update_ps
                     (p_ps_id=> ps_rec.payment_schedule_id,
	              p_due_date=> ps_rec.due_date,
	              p_amount_in_dispute=> ps_rec.amount_in_dispute,
	              p_dispute_date=> ps_rec.dispute_date,
                      p_update_dff => 'N',
	              p_attribute_category=>NULL,
	              p_attribute1=>NULL,
	              p_attribute2=>NULL,
	              p_attribute3=>NULL,
	              p_attribute4=>NULL,
	              p_attribute5=>NULL,
	              p_attribute6=>NULL,
	              p_attribute7=>NULL,
	              p_attribute8=>NULL,
	              p_attribute9=>NULL,
	              p_attribute10=>NULL,
	              p_attribute11=>NULL,
	              p_attribute12=>NULL,
	              p_attribute13=>NULL,
	              p_attribute14=>NULL,
	              p_attribute15=>NULL );

         END LOOP;
      END;
   END IF;

   IF p_skip_workflow_flag = 'Y' THEN
     -- CALL CM API DIRECTLY
        BEGIN

        -- bug 2290738, add p_status to capture status of CM creation

        arw_cmreq_cover.ar_autocreate_cm(
     	   p_request_id                    => l_request_id,
           p_batch_source_name             => p_batch_source_name,
           p_credit_method_rules           => p_credit_method_rules,
           p_credit_method_installments    => p_credit_method_installments,
           p_trx_number                    => p_trx_number,
           p_error_tab                     => l_error_tab,
           p_status                        => l_status);
        END;

        /*Bug 5481525 get if CM is created and update status accordingly*/
        l_credit_memo_id :=-99;
        begin
          select cm_customer_trx_id
          into l_credit_memo_id
          from ra_cm_requests
          where request_id = l_request_id;
        exception
          when others then
            l_result := 'FALSE';
        end;

        update ra_cm_requests
        set status= DECODE(nvl(l_credit_memo_id,-99),-99,'APPROVED_PEND_COMP','COMPLETE'),
            approval_date = SYSDATE,
            last_updated_by = arp_global.last_updated_by,
            last_update_date = arp_global.last_update_date,
            last_update_login = arp_global.last_update_login
        where request_id = l_request_id;

        if l_status is not null then
           IF PG_DEBUG in ('Y', 'C') THEN
              arp_util.debug('error encountered in arw_cmreq_cover.ar_autocreate_cm, return -1');
              arp_util.debug('arw_cmreq_cover.ar_request_cm(-)');
           END IF;
           return('-1');
        end if;
   ELSE
      fnd_profile.get('AR_USE_OAM_IN_CMWF', l_profile_value);
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug('arw_cmreq_cover.ar_request_cm(-)' || l_profile_value);
      END IF;
      IF (l_profile_value = 'Y') Then
        BEGIN
        l_threshold := WF_ENGINE.threshold;
        WF_ENGINE.threshold :=50;
        wf_engine.createprocess('ARAMECM', l_request_id, 'CMREQ_APPROVAL');
        wf_engine.startprocess ('ARAMECM', l_request_id);
        WF_ENGINE.threshold :=l_threshold;
        END;
      ELSE
        BEGIN
        l_threshold := WF_ENGINE.threshold;
        WF_ENGINE.threshold :=50;
        wf_engine.createprocess('ARCMREQ', l_request_id, 'CMREQ_APPROVAL');
        wf_engine.startprocess ('ARCMREQ', l_request_id);
        WF_ENGINE.threshold :=l_threshold;
        END;
      END IF;

    END IF;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('arw_cmreq_cover.ar_request_cm(-)');
    END IF;
    RETURN l_request_id;

EXCEPTION
    WHEN OTHERS THEN
          return('-1'); /*Bug3041195*/
END ar_request_cm;

-- bug 2290738 : added p_status to capture error status

PROCEDURE ar_autocreate_cm(
     p_request_id          IN  ra_cm_requests.request_id%type,
     p_batch_source_name   IN  ra_batch_sources.name%type,
     p_credit_method_rules IN  varchar2,
     p_credit_method_installments  IN  varchar2,
     p_trx_number          IN  ra_customer_trx.trx_number%type DEFAULT NULL,
     p_error_tab           OUT NOCOPY arp_trx_validate.Message_Tbl_Type,
     p_status	           OUT NOCOPY varchar2)
IS

-- declare Local Variables

l_customer_trx_id number;
l_cm_customer_trx_id number;
l_line_credits_flag	varchar2(1);
l_line_amount     number;
l_tax_amount      number;
l_freight_amount  number;
l_reason_code     varchar2(30);
/* Bug 3206020 Changed comments width from 240 to 1760. */
l_comments        varchar2(1760);
l_batch_source_id  number;
l_cm_cust_trx_type_id number;
l_batch_source_name varchar2(30);
l_trx_batch_rec         ra_batches%rowtype;
l_trx_header_rec    ra_customer_trx%rowtype;
l_cm_header_rec     ra_customer_trx%rowtype;
p_cm_header_rec     ra_customer_trx%rowtype;
l_trx_rec_gl_date   DATE;
l_status	varchar2(255);
l_trx_number	ra_customer_trx.trx_number%type;
l_computed_tax_percent	number;
l_computed_tax_amount	ra_customer_trx_lines.extended_amount%type;
l_compute_tax_flag  varchar2(1);
-- TDEY : bug 1272415 changed type of l_credit_line_table
--        to remove trx api dependency
l_credit_line_table	arw_cm_cover.credit_lines_table_type;
i			number :=0;

/*4606558*/
pqa_attribute_rec           pq_attribute_rec_type;
pqa_interface_attribute_rec pq_interface_rec_type;
pqa_global_attribute_rec    pq_global_attribute_rec_type;

l_dispute_date		ra_cm_requests.dispute_date%type;
l_responsibility_id	ra_cm_requests.responsibility_id%type;

CURSOR line_cur IS
SELECT customer_trx_line_id, extended_amount, quantity, price,
	      INTERFACE_LINE_CONTEXT, INTERFACE_LINE_ATTRIBUTE1, INTERFACE_LINE_ATTRIBUTE2,
	      INTERFACE_LINE_ATTRIBUTE3, INTERFACE_LINE_ATTRIBUTE4, INTERFACE_LINE_ATTRIBUTE5,
	      INTERFACE_LINE_ATTRIBUTE6, INTERFACE_LINE_ATTRIBUTE7, INTERFACE_LINE_ATTRIBUTE8,
	      INTERFACE_LINE_ATTRIBUTE9, INTERFACE_LINE_ATTRIBUTE10, INTERFACE_LINE_ATTRIBUTE11,
	      INTERFACE_LINE_ATTRIBUTE12, INTERFACE_LINE_ATTRIBUTE13, INTERFACE_LINE_ATTRIBUTE14,
	      INTERFACE_LINE_ATTRIBUTE15, ATTRIBUTE_CATEGORY        , ATTRIBUTE1                ,
	      ATTRIBUTE2                , ATTRIBUTE3                , ATTRIBUTE4                ,
	      ATTRIBUTE5                , ATTRIBUTE6                , ATTRIBUTE7                ,
	      ATTRIBUTE8                , ATTRIBUTE9                , ATTRIBUTE10               ,
	      ATTRIBUTE11               , ATTRIBUTE12               , ATTRIBUTE13               ,
	      ATTRIBUTE14               , ATTRIBUTE15               , GLOBAL_ATTRIBUTE_CATEGORY ,
	      GLOBAL_ATTRIBUTE1         , GLOBAL_ATTRIBUTE2         , GLOBAL_ATTRIBUTE3         ,
	      GLOBAL_ATTRIBUTE4         , GLOBAL_ATTRIBUTE5         , GLOBAL_ATTRIBUTE6         ,
	      GLOBAL_ATTRIBUTE7         , GLOBAL_ATTRIBUTE8         , GLOBAL_ATTRIBUTE9         ,
	      GLOBAL_ATTRIBUTE10        , GLOBAL_ATTRIBUTE11        , GLOBAL_ATTRIBUTE12        ,
	      GLOBAL_ATTRIBUTE13        , GLOBAL_ATTRIBUTE14        , GLOBAL_ATTRIBUTE15        ,
	      GLOBAL_ATTRIBUTE16        , GLOBAL_ATTRIBUTE17        , GLOBAL_ATTRIBUTE18        ,
	      GLOBAL_ATTRIBUTE19        , GLOBAL_ATTRIBUTE20
FROM ra_cm_request_lines
WHERE request_id=p_request_id;

BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('arw_cmreq_cover.ar_autocreate_cm(+)');
      arp_util.debug(  'in parameters are : ');
      arp_util.debug(  'p_request_id = ' || to_char(p_request_id));
      arp_util.debug(  'p_batch_source_name = ' || p_batch_source_name);
      arp_util.debug(  'p_credit_method_rules = ' || p_credit_method_rules);
      arp_util.debug(  'p_credit_method_installments = ' || p_credit_method_installments);
   END IF;

   /* 5885313 - Initialize cached values in pls packages */
   arp_global.init_global(mo_global.GET_CURRENT_ORG_ID);
   ARP_STANDARD.INIT_STANDARD(mo_global.GET_CURRENT_ORG_ID);
   arp_cache_util.refresh_cache;
  /*----------------------------------------------+
   |Get request information from  CM request table|
   +----------------------------------------------*/

-- Bug # 983278

  select customer_trx_id,
	  line_credits_flag,
          line_amount,
          tax_amount,
          freight_amount,
          cm_reason_code,
          comments ,
	  /*4556000-4606558 added few columns in our select statement*/
	  INTERFACE_HEADER_CONTEXT, INTERFACE_HEADER_ATTRIBUTE1, INTERFACE_HEADER_ATTRIBUTE2,
	  INTERFACE_HEADER_ATTRIBUTE3,INTERFACE_HEADER_ATTRIBUTE4,INTERFACE_HEADER_ATTRIBUTE5,
	  INTERFACE_HEADER_ATTRIBUTE6,INTERFACE_HEADER_ATTRIBUTE7,INTERFACE_HEADER_ATTRIBUTE8,
	  INTERFACE_HEADER_ATTRIBUTE9,INTERFACE_HEADER_ATTRIBUTE10,INTERFACE_HEADER_ATTRIBUTE11,
	  INTERFACE_HEADER_ATTRIBUTE12,INTERFACE_HEADER_ATTRIBUTE13,INTERFACE_HEADER_ATTRIBUTE14,
	  INTERFACE_HEADER_ATTRIBUTE15, ATTRIBUTE_CATEGORY, ATTRIBUTE1, ATTRIBUTE2, ATTRIBUTE3,
	  ATTRIBUTE4, ATTRIBUTE5, ATTRIBUTE6, ATTRIBUTE7, ATTRIBUTE8, ATTRIBUTE9, ATTRIBUTE10,
	  ATTRIBUTE11, ATTRIBUTE12, ATTRIBUTE13, ATTRIBUTE14, ATTRIBUTE15, GLOBAL_ATTRIBUTE_CATEGORY,
	  GLOBAL_ATTRIBUTE1, GLOBAL_ATTRIBUTE2, GLOBAL_ATTRIBUTE3, GLOBAL_ATTRIBUTE4, GLOBAL_ATTRIBUTE5,
	  GLOBAL_ATTRIBUTE6, GLOBAL_ATTRIBUTE7, GLOBAL_ATTRIBUTE8, GLOBAL_ATTRIBUTE9,
	  GLOBAL_ATTRIBUTE10, GLOBAL_ATTRIBUTE11, GLOBAL_ATTRIBUTE12, GLOBAL_ATTRIBUTE13,
	  GLOBAL_ATTRIBUTE14, GLOBAL_ATTRIBUTE15, GLOBAL_ATTRIBUTE16, GLOBAL_ATTRIBUTE17,
	  GLOBAL_ATTRIBUTE18, GLOBAL_ATTRIBUTE19, GLOBAL_ATTRIBUTE20, GLOBAL_ATTRIBUTE21,
	  GLOBAL_ATTRIBUTE22, GLOBAL_ATTRIBUTE23, GLOBAL_ATTRIBUTE24, GLOBAL_ATTRIBUTE25,
	  GLOBAL_ATTRIBUTE26, GLOBAL_ATTRIBUTE27, GLOBAL_ATTRIBUTE28, GLOBAL_ATTRIBUTE29,
	  GLOBAL_ATTRIBUTE30, DISPUTE_DATE, RESPONSIBILITY_ID
  into   l_customer_trx_id,l_line_credits_flag, l_line_amount,l_tax_amount,l_freight_amount,l_reason_code,
         l_comments,
	 /*4556000-4606558 added few columns*/
        pqa_interface_attribute_rec.interface_header_context,
        pqa_interface_attribute_rec.interface_header_attribute1,
        pqa_interface_attribute_rec.interface_header_attribute2,
        pqa_interface_attribute_rec.interface_header_attribute3,
        pqa_interface_attribute_rec.interface_header_attribute4,
        pqa_interface_attribute_rec.interface_header_attribute5,
        pqa_interface_attribute_rec.interface_header_attribute6,
        pqa_interface_attribute_rec.interface_header_attribute7,
        pqa_interface_attribute_rec.interface_header_attribute8,
        pqa_interface_attribute_rec.interface_header_attribute9,
        pqa_interface_attribute_rec.interface_header_attribute10,
        pqa_interface_attribute_rec.interface_header_attribute11,
        pqa_interface_attribute_rec.interface_header_attribute12,
        pqa_interface_attribute_rec.interface_header_attribute13,
        pqa_interface_attribute_rec.interface_header_attribute14,
        pqa_interface_attribute_rec.interface_header_attribute15,
	pqa_attribute_rec.attribute_category, pqa_attribute_rec.attribute1,
	pqa_attribute_rec.attribute2, pqa_attribute_rec.attribute3, pqa_attribute_rec.attribute4,
	pqa_attribute_rec.attribute5,pqa_attribute_rec.attribute6, pqa_attribute_rec.attribute7,
	pqa_attribute_rec.attribute8, pqa_attribute_rec.attribute9,pqa_attribute_rec.attribute10,
	pqa_attribute_rec.attribute11,pqa_attribute_rec.attribute12,pqa_attribute_rec.attribute13,
	pqa_attribute_rec.attribute14, pqa_attribute_rec.attribute15,
        pqa_global_attribute_rec.global_attribute_category, pqa_global_attribute_rec.global_attribute1,
        pqa_global_attribute_rec.global_attribute2, pqa_global_attribute_rec.global_attribute3,
        pqa_global_attribute_rec.global_attribute4, pqa_global_attribute_rec.global_attribute5,
        pqa_global_attribute_rec.global_attribute6, pqa_global_attribute_rec.global_attribute7,
        pqa_global_attribute_rec.global_attribute8, pqa_global_attribute_rec.global_attribute9,
        pqa_global_attribute_rec.global_attribute10, pqa_global_attribute_rec.global_attribute11,
        pqa_global_attribute_rec.global_attribute12, pqa_global_attribute_rec.global_attribute13,
        pqa_global_attribute_rec.global_attribute14, pqa_global_attribute_rec.global_attribute15,
        pqa_global_attribute_rec.global_attribute16, pqa_global_attribute_rec.global_attribute17,
        pqa_global_attribute_rec.global_attribute18, pqa_global_attribute_rec.global_attribute19,
        pqa_global_attribute_rec.global_attribute20, pqa_global_attribute_rec.global_attribute21,
        pqa_global_attribute_rec.global_attribute22, pqa_global_attribute_rec.global_attribute23,
        pqa_global_attribute_rec.global_attribute24, pqa_global_attribute_rec.global_attribute25,
 	pqa_global_attribute_rec.global_attribute26, pqa_global_attribute_rec.global_attribute27,
	pqa_global_attribute_rec.global_attribute28, pqa_global_attribute_rec.global_attribute29,
	pqa_global_attribute_rec.global_attribute30, l_dispute_date, l_responsibility_id /*Bug 8832584*/
  from   ra_cm_requests
  where  request_id = p_request_id;

  /* Bug 8832584 */
  IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('Responsibility Id stored in ra_cm_requests table : ' || l_responsibility_id);
  END IF;

  IF l_responsibility_id IS NOT NULL THEN

    IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('Setting responsibility Id by calling FND routine.');
    END IF;

	fnd_global.apps_initialize( user_id => FND_GLOBAL.USER_ID,
				    resp_id  => l_responsibility_id,
				    resp_appl_id => 222 );

  END IF;

--
-- TDEY 09/14/99 : defaulting l_computed_tax_amount to l_tax_amount
--                 l_tax_amount is the amount of tax credit being
--                 requested by the user
--
   l_computed_tax_amount := l_tax_amount ;

  /* Bug 2637404 : retrieve fields that should default from trx being
     credited */

  select *
  into l_trx_header_rec
  from ra_customer_trx
  where customer_trx_id = l_customer_trx_id;

   /* 5041175 - obsoleting ar_transaction_pub and associated
      routines.  Replaced with inline sql logic to fetch
      batch source */
/*6010707 As per doc when using AME the batch source name can be null*/
    IF NOT (nvl(fnd_profile.value('AR_USE_OAM_IN_CMWF'),'N') = 'Y' and p_batch_source_name is NULL ) THEN
    select batch_source_id
    into   l_batch_source_id
    from   ra_batch_sources
    where  name = p_batch_source_name
    and    org_id = l_trx_header_rec.org_id;
    END IF;

  l_trx_number := p_trx_number;

  IF l_line_credits_flag = 'N' THEN

   /*------------------------------------------------------------------------
   Bug # 983278

   TDEY 09/14/99 : Need to pass in p_line_amount   => l_line_amount,
                                   p_freight_amount => l_freight_amount,
   Currently it is passing NULL which means we are always seeking a 100%
   credit. This is obviuosly not true.


   TDEY 09/09/29 : For both header and line level credit_transaction,
                   need to add     p_errors  => p_error_tab,
   Without this, all error messages are basically evaporating into thin air.


   TDEY  02/23/00 : Bug 1272415 : replaced calls to ar_transaction_pub.
                    credit_transaction
                    with arw_cm_cover.create_header_cm

   VCRISOST 09/18/02 : Bug 2507329/2580574 : instead of NULL, pass actual
                       values to p_reason_code and p_internal_notes

   VCRISOST 10/08/02 : Bug 2609465 : l_comments should populate p_comments
                       rather than p_internal_notes

   Bug 2637404 : pass attribute* / interface_header_attribute* from transaction
   being credited to the credit memo
   -------------------------------------------------------------------------- */
     arw_cm_cover.create_header_cm(
	p_prev_customer_trx_id 		=> l_customer_trx_id ,
	p_batch_id 			=> NULL,
	p_trx_date 			=> NULL,
	p_gl_date			=> NULL,
	p_complete_flag			=> 'Y',
	p_batch_source_id		=> l_batch_source_id,
	p_cust_trx_type_id		=> NULL,
	p_currency_code			=> NULL,
	p_exchange_date			=> NULL,
	p_exchange_rate_type		=> NULL,
	p_exchange_rate			=> NULL,
	p_invoicing_rule_id		=> NULL,
	p_method_for_rules		=> p_credit_method_rules,
	p_split_term_method		=> p_credit_method_installments,
	p_initial_customer_trx_id	=> l_trx_header_rec.initial_customer_trx_id,
	p_primary_salesrep_id		=> NULL,
	p_bill_to_customer_id		=> NULL,
	p_bill_to_address_id		=> NULL,
	p_bill_to_site_use_id		=> NULL,
	p_bill_to_contact_id		=> NULL,
	p_ship_to_customer_id		=> NULL,
	p_ship_to_address_id		=> NULL,
	p_ship_to_site_use_id		=> NULL,
	p_ship_to_contact_id		=> NULL,
	p_receipt_method_id		=> NULL,
	p_paying_customer_id		=> NULL,
	p_paying_site_use_id		=> NULL,
	p_customer_bank_account_id	=> NULL,
	p_printing_option		=> NULL,
	p_printing_last_printed		=> NULL,
	p_printing_pending		=> NULL,
	p_doc_sequence_value  		=> NULL,
  	p_doc_sequence_id      		=> NULL,
  	p_reason_code               	=> l_reason_code,
  	p_customer_reference        	=> NULL,
  	p_customer_reference_date   	=> NULL,
  	p_internal_notes		=> NULL,
	p_set_of_books_id		=> NULL,
	p_created_from			=> NULL,
	p_old_trx_number	        => NULL,
        /*4606558*/
	p_attribute_category		=> pqa_attribute_rec.attribute_category,
	p_attribute1			=> pqa_attribute_rec.attribute1,
  	p_attribute2   			=> pqa_attribute_rec.attribute2,
  	p_attribute3   			=> pqa_attribute_rec.attribute3,
  	p_attribute4   			=> pqa_attribute_rec.attribute4,
  	p_attribute5   			=> pqa_attribute_rec.attribute5,
  	p_attribute6   			=> pqa_attribute_rec.attribute6,
 	p_attribute7   			=> pqa_attribute_rec.attribute7,
  	p_attribute8   			=> pqa_attribute_rec.attribute8,
  	p_attribute9   			=> pqa_attribute_rec.attribute9,
  	p_attribute10  			=> pqa_attribute_rec.attribute10,
  	p_attribute11  			=> pqa_attribute_rec.attribute11,
  	p_attribute12  			=> pqa_attribute_rec.attribute12,
  	p_attribute13  			=> pqa_attribute_rec.attribute13,
  	p_attribute14  			=> pqa_attribute_rec.attribute14,
  	p_attribute15  			=> pqa_attribute_rec.attribute15,
  	p_interface_header_context 	=> pqa_interface_attribute_rec.interface_header_context,
	p_interface_header_attribute1 	=> pqa_interface_attribute_rec.interface_header_attribute1,
  	p_interface_header_attribute2 	=> pqa_interface_attribute_rec.interface_header_attribute2,
  	p_interface_header_attribute3	=> pqa_interface_attribute_rec.interface_header_attribute3,
	p_interface_header_attribute4 	=> pqa_interface_attribute_rec.interface_header_attribute4,
  	p_interface_header_attribute5	=> pqa_interface_attribute_rec.interface_header_attribute5,
  	p_interface_header_attribute6	=> pqa_interface_attribute_rec.interface_header_attribute6,
  	p_interface_header_attribute7	=> pqa_interface_attribute_rec.interface_header_attribute7,
  	p_interface_header_attribute8	=> pqa_interface_attribute_rec.interface_header_attribute8,
  	p_interface_header_attribute9	=> pqa_interface_attribute_rec.interface_header_attribute9,
  	p_interface_header_attribute10	=> pqa_interface_attribute_rec.interface_header_attribute10,
  	p_interface_header_attribute11  => pqa_interface_attribute_rec.interface_header_attribute11,
  	p_interface_header_attribute12  => pqa_interface_attribute_rec.interface_header_attribute12,
  	p_interface_header_attribute13	=> pqa_interface_attribute_rec.interface_header_attribute13,
  	p_interface_header_attribute14  => pqa_interface_attribute_rec.interface_header_attribute14,
  	p_interface_header_attribute15  => pqa_interface_attribute_rec.interface_header_attribute15,
  	p_default_ussgl_trx_code	=> NULL,
	p_line_percent			=> NULL,
	p_freight_percent 		=> NULL,
  	p_line_amount     		=> l_line_amount,
  	p_freight_amount  		=> l_freight_amount,
  	p_compute_tax  			=> 'N',    -- Bug 3152685.
	p_comments  			=> l_comments,
  	p_customer_trx_id 		=> l_cm_customer_trx_id,
  	p_trx_number      		=> l_trx_number,
  	p_computed_tax_percent  	=> l_computed_tax_percent,
  	p_computed_tax_amount  		=> l_computed_tax_amount,
        p_errors                        => p_error_tab,
  	p_status			=> p_status,
        p_purchase_order                => l_trx_header_rec.purchase_order,
        p_purchase_order_revision       => l_trx_header_rec.purchase_order_revision,
        p_purchase_order_date           => l_trx_header_rec.purchase_order_date,
        p_legal_entity_id               => l_trx_header_rec.legal_entity_id,
	/*4556000-4606558*/
  	p_global_attribute_category    => pqa_global_attribute_rec.global_attribute_category,
  	p_global_attribute1            => pqa_global_attribute_rec.global_attribute1,
  	p_global_attribute2            => pqa_global_attribute_rec.global_attribute2,
  	p_global_attribute3            => pqa_global_attribute_rec.global_attribute3,
  	p_global_attribute4            => pqa_global_attribute_rec.global_attribute4,
  	p_global_attribute5            => pqa_global_attribute_rec.global_attribute5,
  	p_global_attribute6            => pqa_global_attribute_rec.global_attribute6,
  	p_global_attribute7            => pqa_global_attribute_rec.global_attribute7,
  	p_global_attribute8            => pqa_global_attribute_rec.global_attribute8,
  	p_global_attribute9            => pqa_global_attribute_rec.global_attribute9,
  	p_global_attribute10            => pqa_global_attribute_rec.global_attribute10,
  	p_global_attribute11            => pqa_global_attribute_rec.global_attribute11,
  	p_global_attribute12            => pqa_global_attribute_rec.global_attribute12,
  	p_global_attribute13            => pqa_global_attribute_rec.global_attribute13,
  	p_global_attribute14            => pqa_global_attribute_rec.global_attribute14,
  	p_global_attribute15            => pqa_global_attribute_rec.global_attribute15,
  	p_global_attribute16            => pqa_global_attribute_rec.global_attribute16,
  	p_global_attribute17            => pqa_global_attribute_rec.global_attribute17,
  	p_global_attribute18            => pqa_global_attribute_rec.global_attribute18,
  	p_global_attribute19            => pqa_global_attribute_rec.global_attribute19,
  	p_global_attribute20            => pqa_global_attribute_rec.global_attribute20,
  	p_global_attribute21            => pqa_global_attribute_rec.global_attribute21,
  	p_global_attribute22            => pqa_global_attribute_rec.global_attribute22,
  	p_global_attribute23            => pqa_global_attribute_rec.global_attribute23,
  	p_global_attribute24            => pqa_global_attribute_rec.global_attribute24,
  	p_global_attribute25            => pqa_global_attribute_rec.global_attribute25,
  	p_global_attribute26            => pqa_global_attribute_rec.global_attribute26,
  	p_global_attribute27            => pqa_global_attribute_rec.global_attribute27,
  	p_global_attribute28            => pqa_global_attribute_rec.global_attribute28,
  	p_global_attribute29            => pqa_global_attribute_rec.global_attribute29,
  	p_global_attribute30            => pqa_global_attribute_rec.global_attribute30,
	p_start_date_commitment		=> l_trx_header_rec.start_date_commitment
	);

  ELSIF l_line_credits_flag IN ('Y','L') THEN

    /* 7658882 - communicating user intent for taxation or not
       to accompany CM lines */
    IF l_line_credits_flag = 'Y' and l_trx_header_rec.start_date_commitment IS NULL
    THEN
       l_compute_tax_flag := 'Y';
    ELSE
       l_compute_tax_flag := NULL;
    END IF;

    OPEN line_cur;
    LOOP
      EXIT WHEN line_cur%NOTFOUND;
      i := i+1;
      /*4606558*/
      FETCH line_cur INTO l_credit_line_table(i).previous_customer_trx_line_id,
			  l_credit_line_table(i).extended_amount,
			  l_credit_line_table(i).quantity_credited,
			  l_credit_line_table(i).unit_selling_price,
	      l_credit_line_table(i).INTERFACE_LINE_CONTEXT, l_credit_line_table(i).INTERFACE_LINE_ATTRIBUTE1,
	      l_credit_line_table(i).INTERFACE_LINE_ATTRIBUTE2,
	      l_credit_line_table(i).INTERFACE_LINE_ATTRIBUTE3,
	      l_credit_line_table(i).INTERFACE_LINE_ATTRIBUTE4,
	      l_credit_line_table(i).INTERFACE_LINE_ATTRIBUTE5,
	      l_credit_line_table(i).INTERFACE_LINE_ATTRIBUTE6,
	      l_credit_line_table(i).INTERFACE_LINE_ATTRIBUTE7,
	      l_credit_line_table(i).INTERFACE_LINE_ATTRIBUTE8,
	      l_credit_line_table(i).INTERFACE_LINE_ATTRIBUTE9,
	      l_credit_line_table(i).INTERFACE_LINE_ATTRIBUTE10,
	      l_credit_line_table(i).INTERFACE_LINE_ATTRIBUTE11,
	      l_credit_line_table(i).INTERFACE_LINE_ATTRIBUTE12,
	      l_credit_line_table(i).INTERFACE_LINE_ATTRIBUTE13,
	      l_credit_line_table(i).INTERFACE_LINE_ATTRIBUTE14,
	      l_credit_line_table(i).INTERFACE_LINE_ATTRIBUTE15,
	      l_credit_line_table(i).ATTRIBUTE_CATEGORY        ,
	      l_credit_line_table(i).ATTRIBUTE1                ,
	      l_credit_line_table(i).ATTRIBUTE2                ,
	      l_credit_line_table(i).ATTRIBUTE3                ,
	      l_credit_line_table(i).ATTRIBUTE4                ,
	      l_credit_line_table(i).ATTRIBUTE5                ,
	      l_credit_line_table(i).ATTRIBUTE6                ,
	      l_credit_line_table(i).ATTRIBUTE7                ,
	      l_credit_line_table(i).ATTRIBUTE8                ,
	      l_credit_line_table(i).ATTRIBUTE9                ,
	      l_credit_line_table(i).ATTRIBUTE10               ,
	      l_credit_line_table(i).ATTRIBUTE11               ,
	      l_credit_line_table(i).ATTRIBUTE12               ,
	      l_credit_line_table(i).ATTRIBUTE13               ,
	      l_credit_line_table(i).ATTRIBUTE14               ,
	      l_credit_line_table(i).ATTRIBUTE15               ,
	      l_credit_line_table(i).GLOBAL_ATTRIBUTE_CATEGORY ,
	      l_credit_line_table(i).GLOBAL_ATTRIBUTE1         ,
	      l_credit_line_table(i).GLOBAL_ATTRIBUTE2         ,
	      l_credit_line_table(i).GLOBAL_ATTRIBUTE3         ,
	      l_credit_line_table(i).GLOBAL_ATTRIBUTE4         ,
	      l_credit_line_table(i).GLOBAL_ATTRIBUTE5         ,
	      l_credit_line_table(i).GLOBAL_ATTRIBUTE6         ,
	      l_credit_line_table(i).GLOBAL_ATTRIBUTE7         ,
	      l_credit_line_table(i).GLOBAL_ATTRIBUTE8         ,
	      l_credit_line_table(i).GLOBAL_ATTRIBUTE9         ,
	      l_credit_line_table(i).GLOBAL_ATTRIBUTE10        ,
	      l_credit_line_table(i).GLOBAL_ATTRIBUTE11        ,
	      l_credit_line_table(i).GLOBAL_ATTRIBUTE12        ,
	      l_credit_line_table(i).GLOBAL_ATTRIBUTE13        ,
	      l_credit_line_table(i).GLOBAL_ATTRIBUTE14        ,
	      l_credit_line_table(i).GLOBAL_ATTRIBUTE15        ,
	      l_credit_line_table(i).GLOBAL_ATTRIBUTE16        ,
	      l_credit_line_table(i).GLOBAL_ATTRIBUTE17        ,
	      l_credit_line_table(i).GLOBAL_ATTRIBUTE18        ,
	      l_credit_line_table(i).GLOBAL_ATTRIBUTE19        ,
	      l_credit_line_table(i).GLOBAL_ATTRIBUTE20        ;
    END LOOP;
    CLOSE line_cur;

   /*
   TDEY  02/23/00 : Bug 1199202 : replaced calls to ar_transaction_pub.
                    credit_transaction
                    with arw_cm_cover.create_line_cm

   VCRISOST 09/18/02 : Bug 2507329/2580574 : instead of NULL, pass actual
                       values to p_reason_code and p_internal_notes
   VCRISOST 10/08/02 : Bug 2609465 : l_comments should populate p_comments
                       rather than p_internal_notes

   Bug 2637404 : pass attribute* / interface_header_attribute* from transaction
   being credited to the credit memo
   */

  arw_cm_cover.create_line_cm(
	p_prev_customer_trx_id 		=> l_customer_trx_id ,
	p_batch_id 			=> NULL,
	p_trx_date 			=> NULL,
	p_gl_date			=> NULL,
	p_complete_flag			=> 'Y',
	p_batch_source_id		=> l_batch_source_id,
	p_cust_trx_type_id		=> NULL,
	p_currency_code			=> NULL,
	p_exchange_date			=> NULL,
	p_exchange_rate_type		=> NULL,
	p_exchange_rate			=> NULL,
	p_invoicing_rule_id		=> NULL,
	p_method_for_rules		=> p_credit_method_rules,
	p_split_term_method		=> p_credit_method_installments,
	p_initial_customer_trx_id	=> l_trx_header_rec.initial_customer_trx_id,
	p_primary_salesrep_id		=> NULL,
	p_bill_to_customer_id		=> NULL,
	p_bill_to_address_id		=> NULL,
	p_bill_to_site_use_id		=> NULL,
	p_bill_to_contact_id		=> NULL,
	p_ship_to_customer_id		=> NULL,
	p_ship_to_address_id		=> NULL,
	p_ship_to_site_use_id		=> NULL,
	p_ship_to_contact_id		=> NULL,
	p_receipt_method_id		=> NULL,
	p_paying_customer_id		=> NULL,
	p_paying_site_use_id		=> NULL,
	p_customer_bank_account_id	=> NULL,
	p_printing_option		=> NULL,
	p_printing_last_printed		=> NULL,
	p_printing_pending		=> NULL,
	p_doc_sequence_value  		=> NULL,
  	p_doc_sequence_id      		=> NULL,
  	p_reason_code               	=> l_reason_code,
  	p_customer_reference        	=> NULL,
  	p_customer_reference_date   	=> NULL,
  	p_internal_notes		=> NULL,
	p_set_of_books_id		=> NULL,
	p_created_from			=> 'AR_CREDIT_MEMO_API',
	p_old_trx_number		=> NULL,
        /*4606558*/
        p_attribute_category            => pqa_attribute_rec.attribute_category,
        p_attribute1                    => pqa_attribute_rec.attribute1,
        p_attribute2                    => pqa_attribute_rec.attribute2,
        p_attribute3                    => pqa_attribute_rec.attribute3,
        p_attribute4                    => pqa_attribute_rec.attribute4,
        p_attribute5                    => pqa_attribute_rec.attribute5,
        p_attribute6                    => pqa_attribute_rec.attribute6,
        p_attribute7                    => pqa_attribute_rec.attribute7,
        p_attribute8                    => pqa_attribute_rec.attribute8,
        p_attribute9                    => pqa_attribute_rec.attribute9,
        p_attribute10                   => pqa_attribute_rec.attribute10,
        p_attribute11                   => pqa_attribute_rec.attribute11,
        p_attribute12                   => pqa_attribute_rec.attribute12,
        p_attribute13                   => pqa_attribute_rec.attribute13,
        p_attribute14                   => pqa_attribute_rec.attribute14,
        p_attribute15                   => pqa_attribute_rec.attribute15,
        p_interface_header_context      => pqa_interface_attribute_rec.interface_header_context,
        p_interface_header_attribute1   => pqa_interface_attribute_rec.interface_header_attribute1,
        p_interface_header_attribute2   => pqa_interface_attribute_rec.interface_header_attribute2,
        p_interface_header_attribute3   => pqa_interface_attribute_rec.interface_header_attribute3,
        p_interface_header_attribute4   => pqa_interface_attribute_rec.interface_header_attribute4,
        p_interface_header_attribute5   => pqa_interface_attribute_rec.interface_header_attribute5,
        p_interface_header_attribute6   => pqa_interface_attribute_rec.interface_header_attribute6,
        p_interface_header_attribute7   => pqa_interface_attribute_rec.interface_header_attribute7,
        p_interface_header_attribute8   => pqa_interface_attribute_rec.interface_header_attribute8,
        p_interface_header_attribute9   => pqa_interface_attribute_rec.interface_header_attribute9,
        p_interface_header_attribute10  => pqa_interface_attribute_rec.interface_header_attribute10,
        p_interface_header_attribute11  => pqa_interface_attribute_rec.interface_header_attribute11,
        p_interface_header_attribute12  => pqa_interface_attribute_rec.interface_header_attribute12,
        p_interface_header_attribute13  => pqa_interface_attribute_rec.interface_header_attribute13,
        p_interface_header_attribute14  => pqa_interface_attribute_rec.interface_header_attribute14,
        p_interface_header_attribute15  => pqa_interface_attribute_rec.interface_header_attribute15,
  	p_default_ussgl_trx_code	=> NULL,
	p_line_percent			=> NULL,
	p_freight_percent 		=> NULL,
  	p_line_amount     		=> NULL,
  	p_freight_amount  		=> NULL,
  	p_compute_tax  			=> l_compute_tax_flag,  -- 7658882
	p_comments  			=> l_comments,
  	p_customer_trx_id 		=> l_cm_customer_trx_id,
  	p_trx_number      		=> l_trx_number,
  	p_computed_tax_percent  	=> l_computed_tax_percent,
  	p_computed_tax_amount  		=> l_computed_tax_amount,
        p_errors                        => p_error_tab,
  	p_status			=> p_status,
	p_credit_line_table		=> l_credit_line_table,
        p_purchase_order                => l_trx_header_rec.purchase_order,
        p_purchase_order_revision       => l_trx_header_rec.purchase_order_revision,
        p_purchase_order_date           => l_trx_header_rec.purchase_order_date,
        p_legal_entity_id               => l_trx_header_rec.legal_entity_id,
	/*4556000-4606558*/
  	p_global_attribute_category    => pqa_global_attribute_rec.global_attribute_category,
  	p_global_attribute1            => pqa_global_attribute_rec.global_attribute1,
  	p_global_attribute2            => pqa_global_attribute_rec.global_attribute2,
  	p_global_attribute3            => pqa_global_attribute_rec.global_attribute3,
  	p_global_attribute4            => pqa_global_attribute_rec.global_attribute4,
  	p_global_attribute5            => pqa_global_attribute_rec.global_attribute5,
  	p_global_attribute6            => pqa_global_attribute_rec.global_attribute6,
  	p_global_attribute7            => pqa_global_attribute_rec.global_attribute7,
  	p_global_attribute8            => pqa_global_attribute_rec.global_attribute8,
  	p_global_attribute9            => pqa_global_attribute_rec.global_attribute9,
  	p_global_attribute10            => pqa_global_attribute_rec.global_attribute10,
  	p_global_attribute11            => pqa_global_attribute_rec.global_attribute11,
  	p_global_attribute12            => pqa_global_attribute_rec.global_attribute12,
  	p_global_attribute13            => pqa_global_attribute_rec.global_attribute13,
  	p_global_attribute14            => pqa_global_attribute_rec.global_attribute14,
  	p_global_attribute15            => pqa_global_attribute_rec.global_attribute15,
  	p_global_attribute16            => pqa_global_attribute_rec.global_attribute16,
  	p_global_attribute17            => pqa_global_attribute_rec.global_attribute17,
  	p_global_attribute18            => pqa_global_attribute_rec.global_attribute18,
  	p_global_attribute19            => pqa_global_attribute_rec.global_attribute19,
  	p_global_attribute20            => pqa_global_attribute_rec.global_attribute20,
  	p_global_attribute21            => pqa_global_attribute_rec.global_attribute21,
  	p_global_attribute22            => pqa_global_attribute_rec.global_attribute22,
  	p_global_attribute23            => pqa_global_attribute_rec.global_attribute23,
  	p_global_attribute24            => pqa_global_attribute_rec.global_attribute24,
  	p_global_attribute25            => pqa_global_attribute_rec.global_attribute25,
  	p_global_attribute26            => pqa_global_attribute_rec.global_attribute26,
  	p_global_attribute27            => pqa_global_attribute_rec.global_attribute27,
  	p_global_attribute28            => pqa_global_attribute_rec.global_attribute28,
  	p_global_attribute29            => pqa_global_attribute_rec.global_attribute29,
  	p_global_attribute30            => pqa_global_attribute_rec.global_attribute30);

   END IF;

IF l_cm_customer_trx_id IS NOT NULL THEN
	UPDATE ra_cm_requests
	SET    cm_customer_trx_id = l_cm_customer_trx_id
	WHERE  request_id = p_request_id;
END IF;


IF PG_DEBUG in ('Y', 'C') THEN
   arp_util.debug(  'arw_cmreq_cover.get_cm_defaults(-)');
END IF;

EXCEPTION
	WHEN OTHERS THEN
      /*Bug3041195*/
      p_status := 'E';


END ar_autocreate_cm;

-- Bug 3751162/3471955 : define logic for abort process event
/*4220382 : GSCC warning */
FUNCTION cancel_cm_request (p_subscription_guid in raw,
                            p_event in out NOCOPY WF_EVENT_T) return varchar2 is

-- note ITMETYPE is misspelled on purpose as that is how it is saved in
-- wfengb.pls AbortProcess definition
l_itemtype         VARCHAR2(8) := p_event.GetValueForParameter('ITMETYPE');
l_itemkey          VARCHAR2(240) := p_event.GetValueForParameter('ITEMKEY');

begin
  /* bug 8830917*/
  if l_itemtype = 'ARCMREQ' OR l_itemtype = 'ARAMECM' then

     begin
        update ra_cm_requests_all
           set status = 'CANCELLED'
         where request_id = l_itemkey;
     exception
     when no_data_found then
        null;
     end;

  end if;

  return 'SUCCESS';

exception
when others then

     WF_CORE.CONTEXT('ARW_CMREQ_COVER', 'CANCEL_CM_REQUEST',
                      p_event.getEventName(), p_subscription_guid);
     WF_EVENT.setErrorInfo(p_event, 'ERROR');

     RETURN 'ERROR';

end;

END ARW_CMREQ_COVER;

/
