--------------------------------------------------------
--  DDL for Package AR_IREC_PAYMENTS_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_IREC_PAYMENTS_W" AUTHID CURRENT_USER as
  /* $Header: ARIPMTWS.pls 120.0.12000000.1 2007/03/13 06:44:26 abathini noship $ */
  procedure rosetta_table_copy_in_p34(t out nocopy ar_irec_payments.inv_list_table_type, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p34(t ar_irec_payments.inv_list_table_type, a0 out nocopy JTF_NUMBER_TABLE);

  procedure allow_payment(p_payment_schedule_id  NUMBER
    , p_customer_id  NUMBER
    , p_customer_site_id  NUMBER
    , ddrosetta_retval_bool OUT NOCOPY NUMBER
  );
  procedure update_invoice_payment_status(p_payment_schedule_id_list JTF_NUMBER_TABLE
    , p_inv_pay_status  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
end ar_irec_payments_w;

 

/
