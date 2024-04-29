--------------------------------------------------------
--  DDL for Package Body OKL_SECURITIZATION_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SECURITIZATION_PVT_W" AS
  /* $Header: OKLESZSB.pls 115.3 2003/10/21 00:21:07 mvasudev noship $ */
  rosetta_g_mistake_date DATE := TO_DATE('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date DATE := TO_DATE('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  FUNCTION rosetta_g_miss_date_in_map(d DATE) RETURN DATE AS
  BEGIN
    IF d = rosetta_g_mistake_date THEN RETURN fnd_api.g_miss_date; END IF;
    RETURN d;
  END;

  FUNCTION rosetta_g_miss_num_map(n NUMBER) RETURN NUMBER AS
    a NUMBER := fnd_api.g_miss_num;
    b NUMBER := 0-1962.0724;
  BEGIN
    IF n=a THEN RETURN b; END IF;
    IF n=b THEN RETURN a; END IF;
    RETURN n;
  END;

  PROCEDURE rosetta_table_copy_in_p29(t OUT nocopy okl_securitization_pvt.inv_agmt_chr_id_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_500
    ) AS
    ddindx BINARY_INTEGER; indx BINARY_INTEGER;
  BEGIN
  IF a0 IS NOT NULL AND a0.COUNT > 0 THEN
      IF a0.COUNT > 0 THEN
        indx := a0.first;
        ddindx := 1;
        WHILE TRUE LOOP
          t(ddindx).khr_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).process_code := a1(indx);
          ddindx := ddindx+1;
          IF a0.last =indx
            THEN EXIT;
          END IF;
          indx := a0.NEXT(indx);
        END LOOP;
      END IF;
   END IF;
  END rosetta_table_copy_in_p29;
  PROCEDURE rosetta_table_copy_out_p29(t okl_securitization_pvt.inv_agmt_chr_id_tbl_type, a0 OUT nocopy JTF_NUMBER_TABLE
    , a1 OUT nocopy JTF_VARCHAR2_TABLE_500
    ) AS
    ddindx BINARY_INTEGER; indx BINARY_INTEGER;
  BEGIN
  IF t IS NULL OR t.COUNT = 0 THEN
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_500();
  ELSE
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_500();
      IF t.COUNT > 0 THEN
        a0.extend(t.COUNT);
        a1.extend(t.COUNT);
        ddindx := t.first;
        indx := 1;
        WHILE TRUE LOOP
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).khr_id);
          a1(indx) := t(ddindx).process_code;
          indx := indx+1;
          IF t.last =ddindx
            THEN EXIT;
          END IF;
          ddindx := t.NEXT(ddindx);
        END LOOP;
      END IF;
   END IF;
  END rosetta_table_copy_out_p29;

  PROCEDURE check_khr_securitized(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status OUT nocopy  VARCHAR2
    , x_msg_count OUT nocopy  NUMBER
    , x_msg_data OUT nocopy  VARCHAR2
    , p_khr_id  NUMBER
    , p_effective_date  DATE
    , p_effective_date_operator  VARCHAR2
    , p_stream_type_subclass  VARCHAR2
    , x_value OUT nocopy  VARCHAR2
    , p10_a0 OUT nocopy JTF_NUMBER_TABLE
    , p10_a1 OUT nocopy JTF_VARCHAR2_TABLE_500
  )

  AS
    ddp_effective_date DATE;
    ddx_inv_agmt_chr_id_tbl okl_securitization_pvt.inv_agmt_chr_id_tbl_type;
    ddindx BINARY_INTEGER; indx BINARY_INTEGER;
  BEGIN

    -- copy data to the local IN or IN-OUT args, if any






    ddp_effective_date := rosetta_g_miss_date_in_map(p_effective_date);





    -- here's the delegated call to the old PL/SQL routine
    okl_securitization_pvt.check_khr_securitized(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_khr_id,
      ddp_effective_date,
      p_effective_date_operator,
      p_stream_type_subclass,
      x_value,
      ddx_inv_agmt_chr_id_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










    okl_securitization_pvt_w.rosetta_table_copy_out_p29(ddx_inv_agmt_chr_id_tbl, p10_a0
      , p10_a1
      );
  END;

  PROCEDURE check_kle_securitized(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status OUT nocopy  VARCHAR2
    , x_msg_count OUT nocopy  NUMBER
    , x_msg_data OUT nocopy  VARCHAR2
    , p_kle_id  NUMBER
    , p_effective_date  DATE
    , p_effective_date_operator  VARCHAR2
    , p_stream_type_subclass  VARCHAR2
    , x_value OUT nocopy  VARCHAR2
    , p10_a0 OUT nocopy JTF_NUMBER_TABLE
    , p10_a1 OUT nocopy JTF_VARCHAR2_TABLE_500
  )

  AS
    ddp_effective_date DATE;
    ddx_inv_agmt_chr_id_tbl okl_securitization_pvt.inv_agmt_chr_id_tbl_type;
    ddindx BINARY_INTEGER; indx BINARY_INTEGER;
  BEGIN

    -- copy data to the local IN or IN-OUT args, if any






    ddp_effective_date := rosetta_g_miss_date_in_map(p_effective_date);





    -- here's the delegated call to the old PL/SQL routine
    okl_securitization_pvt.check_kle_securitized(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_kle_id,
      ddp_effective_date,
      p_effective_date_operator,
      p_stream_type_subclass,
      x_value,
      ddx_inv_agmt_chr_id_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










    okl_securitization_pvt_w.rosetta_table_copy_out_p29(ddx_inv_agmt_chr_id_tbl, p10_a0
      , p10_a1
      );
  END;

  PROCEDURE check_sty_securitized(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status OUT nocopy  VARCHAR2
    , x_msg_count OUT nocopy  NUMBER
    , x_msg_data OUT nocopy  VARCHAR2
    , p_khr_id  NUMBER
    , p_effective_date  DATE
    , p_effective_date_operator  VARCHAR2
    , p_sty_id  NUMBER
    , x_value OUT nocopy  VARCHAR2
    , x_inv_agmt_chr_id OUT nocopy  NUMBER
  )

  AS
    ddp_effective_date DATE;
    ddindx BINARY_INTEGER; indx BINARY_INTEGER;
  BEGIN

    -- copy data to the local IN or IN-OUT args, if any






    ddp_effective_date := rosetta_g_miss_date_in_map(p_effective_date);





    -- here's the delegated call to the old PL/SQL routine
    okl_securitization_pvt.check_sty_securitized(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_khr_id,
      ddp_effective_date,
      p_effective_date_operator,
      p_sty_id,
      x_value,
      x_inv_agmt_chr_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










  END;

  PROCEDURE check_stm_securitized(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status OUT nocopy  VARCHAR2
    , x_msg_count OUT nocopy  NUMBER
    , x_msg_data OUT nocopy  VARCHAR2
    , p_stm_id  NUMBER
    , p_effective_date  DATE
    , x_value OUT nocopy  VARCHAR2
  )

  AS
    ddp_effective_date DATE;
    ddindx BINARY_INTEGER; indx BINARY_INTEGER;
  BEGIN

    -- copy data to the local IN or IN-OUT args, if any






    ddp_effective_date := rosetta_g_miss_date_in_map(p_effective_date);


    -- here's the delegated call to the old PL/SQL routine
    okl_securitization_pvt.check_stm_securitized(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_stm_id,
      ddp_effective_date,
      x_value);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  END;

  PROCEDURE check_sel_securitized(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status OUT nocopy  VARCHAR2
    , x_msg_count OUT nocopy  NUMBER
    , x_msg_data OUT nocopy  VARCHAR2
    , p_sel_id  NUMBER
    , p_effective_date  DATE
    , x_value OUT nocopy  VARCHAR2
  )

  AS
    ddp_effective_date DATE;
    ddindx BINARY_INTEGER; indx BINARY_INTEGER;
  BEGIN

    -- copy data to the local IN or IN-OUT args, if any






    ddp_effective_date := rosetta_g_miss_date_in_map(p_effective_date);


    -- here's the delegated call to the old PL/SQL routine
    okl_securitization_pvt.check_sel_securitized(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_sel_id,
      ddp_effective_date,
      x_value);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  END;

  PROCEDURE buyback_asset(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status OUT nocopy  VARCHAR2
    , x_msg_count OUT nocopy  NUMBER
    , x_msg_data OUT nocopy  VARCHAR2
    , p_kle_id  NUMBER
    , p_effective_date  DATE
  )

  AS
    ddp_effective_date DATE;
    ddindx BINARY_INTEGER; indx BINARY_INTEGER;
  BEGIN

    -- copy data to the local IN or IN-OUT args, if any






    ddp_effective_date := rosetta_g_miss_date_in_map(p_effective_date);

    -- here's the delegated call to the old PL/SQL routine
    okl_securitization_pvt.buyback_asset(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_kle_id,
      ddp_effective_date);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  END;

  PROCEDURE buyback_contract(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status OUT nocopy  VARCHAR2
    , x_msg_count OUT nocopy  NUMBER
    , x_msg_data OUT nocopy  VARCHAR2
    , p_khr_id  NUMBER
    , p_effective_date  DATE
  )

  AS
    ddp_effective_date DATE;
    ddindx BINARY_INTEGER; indx BINARY_INTEGER;
  BEGIN

    -- copy data to the local IN or IN-OUT args, if any






    ddp_effective_date := rosetta_g_miss_date_in_map(p_effective_date);

    -- here's the delegated call to the old PL/SQL routine
    okl_securitization_pvt.buyback_contract(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_khr_id,
      ddp_effective_date);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  END;

  PROCEDURE process_khr_investor_rules(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status OUT nocopy  VARCHAR2
    , x_msg_count OUT nocopy  NUMBER
    , x_msg_data OUT nocopy  VARCHAR2
    , p_khr_id  NUMBER
    , p_effective_date  DATE
    , p_rgd_code  VARCHAR2
    , p_rdf_code  VARCHAR2
    , x_process_code OUT nocopy  VARCHAR2
    , p10_a0 OUT nocopy JTF_NUMBER_TABLE
    , p10_a1 OUT nocopy JTF_VARCHAR2_TABLE_500
  )

  AS
    ddp_effective_date DATE;
    ddx_inv_agmt_chr_id_tbl okl_securitization_pvt.inv_agmt_chr_id_tbl_type;
    ddindx BINARY_INTEGER; indx BINARY_INTEGER;
  BEGIN

    -- copy data to the local IN or IN-OUT args, if any






    ddp_effective_date := rosetta_g_miss_date_in_map(p_effective_date);





    -- here's the delegated call to the old PL/SQL routine
    okl_securitization_pvt.process_khr_investor_rules(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_khr_id,
      ddp_effective_date,
      p_rgd_code,
      p_rdf_code,
      x_process_code,
      ddx_inv_agmt_chr_id_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










    okl_securitization_pvt_w.rosetta_table_copy_out_p29(ddx_inv_agmt_chr_id_tbl, p10_a0
      , p10_a1
      );
  END;

  PROCEDURE process_kle_investor_rules(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status OUT nocopy  VARCHAR2
    , x_msg_count OUT nocopy  NUMBER
    , x_msg_data OUT nocopy  VARCHAR2
    , p_kle_id  NUMBER
    , p_effective_date  DATE
    , p_rgd_code  VARCHAR2
    , p_rdf_code  VARCHAR2
    , x_process_code OUT nocopy  VARCHAR2
    , p10_a0 OUT nocopy JTF_NUMBER_TABLE
    , p10_a1 OUT nocopy JTF_VARCHAR2_TABLE_500
  )

  AS
    ddp_effective_date DATE;
    ddx_inv_agmt_chr_id_tbl okl_securitization_pvt.inv_agmt_chr_id_tbl_type;
    ddindx BINARY_INTEGER; indx BINARY_INTEGER;
  BEGIN

    -- copy data to the local IN or IN-OUT args, if any






    ddp_effective_date := rosetta_g_miss_date_in_map(p_effective_date);





    -- here's the delegated call to the old PL/SQL routine
    okl_securitization_pvt.process_kle_investor_rules(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_kle_id,
      ddp_effective_date,
      p_rgd_code,
      p_rdf_code,
      x_process_code,
      ddx_inv_agmt_chr_id_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










    okl_securitization_pvt_w.rosetta_table_copy_out_p29(ddx_inv_agmt_chr_id_tbl, p10_a0
      , p10_a1
      );
  END;

  PROCEDURE buyback_pool_contents(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_khr_id  NUMBER
    , p_pol_id  NUMBER
    , p_stream_type_subclass  VARCHAR2
    , p_effective_date  DATE
    , x_return_status OUT nocopy  VARCHAR2
    , x_msg_count OUT nocopy  NUMBER
    , x_msg_data OUT nocopy  VARCHAR2
  )

  AS
    ddp_effective_date DATE;
    ddindx BINARY_INTEGER; indx BINARY_INTEGER;
  BEGIN

    -- copy data to the local IN or IN-OUT args, if any





    ddp_effective_date := rosetta_g_miss_date_in_map(p_effective_date);




    -- here's the delegated call to the old PL/SQL routine
    okl_securitization_pvt.buyback_pool_contents(p_api_version,
      p_init_msg_list,
      p_khr_id,
      p_pol_id,
      p_stream_type_subclass,
      ddp_effective_date,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  END;

  PROCEDURE modify_pool_contents(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_transaction_reason  VARCHAR2
    , p_khr_id  NUMBER
    , p_kle_id  NUMBER
    , p_stream_type_subclass  VARCHAR2
    , p_transaction_date  DATE
    , p_effective_date  DATE
    , x_return_status OUT nocopy  VARCHAR2
    , x_msg_count OUT nocopy  NUMBER
    , x_msg_data OUT nocopy  VARCHAR2
  )

  AS
    ddp_transaction_date DATE;
    ddp_effective_date DATE;
    ddindx BINARY_INTEGER; indx BINARY_INTEGER;
  BEGIN

    -- copy data to the local IN or IN-OUT args, if any






    ddp_transaction_date := rosetta_g_miss_date_in_map(p_transaction_date);

    ddp_effective_date := rosetta_g_miss_date_in_map(p_effective_date);




    -- here's the delegated call to the old PL/SQL routine
    okl_securitization_pvt.modify_pool_contents(p_api_version,
      p_init_msg_list,
      p_transaction_reason,
      p_khr_id,
      p_kle_id,
      p_stream_type_subclass,
      ddp_transaction_date,
      ddp_effective_date,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










  END;

  PROCEDURE modify_pool_contents(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_transaction_reason  VARCHAR2
    , p_khr_id  NUMBER
    , p_kle_id  NUMBER
    , p5_a0 JTF_NUMBER_TABLE
    , p_transaction_date  DATE
    , p_effective_date  DATE
    , x_return_status OUT nocopy  VARCHAR2
    , x_msg_count OUT nocopy  NUMBER
    , x_msg_data OUT nocopy  VARCHAR2
  )

  AS
    ddp_split_kle_ids okl_securitization_pvt.cle_tbl_type;
    ddp_transaction_date DATE;
    ddp_effective_date DATE;
    ddindx BINARY_INTEGER; indx BINARY_INTEGER;
  BEGIN

    -- copy data to the local IN or IN-OUT args, if any





    okl_split_asset_pvt_w.rosetta_table_copy_in_p10(ddp_split_kle_ids, p5_a0
      );

    ddp_transaction_date := rosetta_g_miss_date_in_map(p_transaction_date);

    ddp_effective_date := rosetta_g_miss_date_in_map(p_effective_date);




    -- here's the delegated call to the old PL/SQL routine
    okl_securitization_pvt.modify_pool_contents(p_api_version,
      p_init_msg_list,
      p_transaction_reason,
      p_khr_id,
      p_kle_id,
      ddp_split_kle_ids,
      ddp_transaction_date,
      ddp_effective_date,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










  END;

END okl_securitization_pvt_w;

/
