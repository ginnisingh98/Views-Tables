--------------------------------------------------------
--  DDL for Package Body AR_IREC_PAYMENTS_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_IREC_PAYMENTS_W" as
  /* $Header: ARIPMTWB.pls 120.0.12000000.1 2007/03/13 06:43:54 abathini noship $ */
  procedure rosetta_table_copy_in_p34(t out nocopy ar_irec_payments.inv_list_table_type, a0 JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := a0(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p34;
  procedure rosetta_table_copy_out_p34(t ar_irec_payments.inv_list_table_type, a0 out nocopy JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p34;

  procedure allow_payment(p_payment_schedule_id  NUMBER
    , p_customer_id  NUMBER
    , p_customer_site_id  NUMBER
    , ddrosetta_retval_bool OUT NOCOPY NUMBER
  )

  as
    ddindx binary_integer; indx binary_integer;
    ddrosetta_retval boolean;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    -- here's the delegated call to the old PL/SQL routine
    ddrosetta_retval := ar_irec_payments.allow_payment(p_payment_schedule_id,
      p_customer_id,
      p_customer_site_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    if ddrosetta_retval is null
      then ddrosetta_retval_bool := null;
    elsif ddrosetta_retval
      then ddrosetta_retval_bool := 1;
    else ddrosetta_retval_bool := 0;
    end if;


  end;

  procedure update_invoice_payment_status(p_payment_schedule_id_list JTF_NUMBER_TABLE
    , p_inv_pay_status  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_payment_schedule_id_list ar_irec_payments.inv_list_table_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ar_irec_payments_w.rosetta_table_copy_in_p34(ddp_payment_schedule_id_list, p_payment_schedule_id_list);





    -- here's the delegated call to the old PL/SQL routine
    ar_irec_payments.update_invoice_payment_status(ddp_payment_schedule_id_list,
      p_inv_pay_status,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




  end;

end ar_irec_payments_w;

/
