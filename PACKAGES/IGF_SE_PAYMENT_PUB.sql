--------------------------------------------------------
--  DDL for Package IGF_SE_PAYMENT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_SE_PAYMENT_PUB" AUTHID CURRENT_USER AS
/* $Header: IGFSE02S.pls 120.1 2006/01/19 01:42:31 ugummall noship $ */
/*#
 * A public API that creates payment information for a given authorization id
 * @rep:scope public
 * @rep:product IGF
 * @rep:displayname Create payment
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY IGF_FWS
 */
 /*=======================================================================+
 |  Copyright (c) 1994, 1996 Oracle Corp. Redwood Shores, California, USA|
 |                            All rights reserved.                       |
 +=======================================================================+
 |                                                                       |
 | DESCRIPTION                                                           |
 |      PL/SQL spec for package: igf_se_payment_pub                      |
 |                                                                       |
 | NOTES                                                                 |
 |                                                                       |
 |                                                                       |
 |                                                                       |
 | HISTORY                                                               |
 | Who       When         What                                           |
 *=======================================================================*/


-- Payment Record declaration
TYPE payment_rec_type IS RECORD (
  transaction_id NUMBER,
  payroll_id NUMBER,
  payroll_date DATE,
  authorization_id NUMBER,
  person_id NUMBER,
  paid_amount NUMBER,
  organization_unit_name VARCHAR2(360),
  source VARCHAR2(30)
);


--
-- API Name            : create_payment
-- Type                : Public
-- Pre-reqs            : None
-- Function            : Creates a New Payment information for the given
--                       authorization id and award year combination.
--                       this api updates an existing payment information
--                       provided if a payroll id value that is already existing
--                       in the system is sent.
-- Parameters          :
--   IN                :
--                       p_init_msg_list IN VARCHAR2 default to FND_API.G_FALSE
--                       p_payment_rec payment record type
--                               i.    payroll_date IN DATE. date of payment. Required
--                               ii.   payroll_id IN NUMBER. Unique payroll identifier
--                                     from the payroll interface. Required
--                               iii.  authorization_id IN NUMBER the authorization
--                                     against which the payment is made. Required
--                               iv.   person_id IN NUMBER internal person identifier. Required.
--                               v.    payment_amount IN NUMBER the actual amount that is paid.
--                                     Required.
--                               vi.   organization_unit_cd IN VARCHAR2. The Organization
--                                     or the Employer Organization. Optional
--                              vii.  source IN VARCHAR2. Oracle seeded values are
--                                     ORACLE_HRMS, MANUAL and UPLOAD
--                                     if this API is being called from a User Interface then
--                                     the source is MANUAL. If the payment table is being
--                                     populated via Oracle HRMS then the value is ORACLE_HRMS.
--                                     If the payment table is populated via upload from the
--                                     payment interface table then the value is UPLOAD.
--   OUT               :
--                       x_transaction_id OUT NUMBER. a unique identifier in the Oracle Financial
--                         Aid Entity, created for each payment record.
--
--                       x_return_status Return status after the call. The status can
--                        be FND_API.G_RET_STS_SUCCESS (success),
--                        FND_API.G_RET_STS_ERROR (error),
--                        FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
--                       x_msg_count Number of messages in message stack.
--                       x_msg_data  Message text if x_msg_count is 1.
--
-- History             :
--                       Current Version 1.0
--                       Previous Version None
--                       Initial Version 1.0
--
--
/*#
 * A public API that creates payment information for a given authorization id
 * @param  p_init_msg_list Initialized Message List
 * @param  p_payment_rec Payment record Type
 * @param  x_transaction_id Transaction ID
 * @param  x_return_status Return Status
 * @param  x_msg_count Message Count
 * @param  x_msg_data Message Data
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create payment
 */
PROCEDURE create_payment(
 p_init_msg_list IN VARCHAR2 := FND_API.G_FALSE,
 p_payment_rec IN payment_rec_type,
 x_transaction_id OUT NOCOPY NUMBER,
 x_return_status OUT NOCOPY VARCHAR2,
 x_msg_count OUT NOCOPY NUMBER,
 x_msg_data OUT NOCOPY VARCHAR2
);

END igf_se_payment_pub;

 

/
