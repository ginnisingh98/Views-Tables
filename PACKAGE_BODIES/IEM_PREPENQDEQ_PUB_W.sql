--------------------------------------------------------
--  DDL for Package Body IEM_PREPENQDEQ_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_PREPENQDEQ_PUB_W" as
  /* $Header: IEMVPEQB.pls 115.2 2000/03/04 11:11:21 pkm ship      $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  function rosetta_g_miss_num_map(n number) return number as
    a number := fnd_api.g_miss_num;
    b number := 0-1962.0724;
  begin
    if n=a then return b; end if;
    if n=b then return a; end if;
    return n;
  end;

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure proc_enqueue(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_msg_id  NUMBER
    , p_msg_size  NUMBER
    , p_sender_name  VARCHAR2
    , p_user_name  VARCHAR2
    , p_domain_name  VARCHAR2
    , p_priority  VARCHAR2
    , p_msg_status  VARCHAR2
    , p_subject VARCHAR2
    , p_sent_date  date
    , p_customer_id  NUMBER
    , p_product_id  NUMBER
    , p_classification  VARCHAR2
    , p_score_percent  NUMBER
    , p_info_id  NUMBER
    , p_key1  VARCHAR2
    , p_val1  VARCHAR2
    , p_key2  VARCHAR2
    , p_val2  VARCHAR2
    , p_key3  VARCHAR2
    , p_val3  VARCHAR2
    , p_key4  VARCHAR2
    , p_val4  VARCHAR2
    , p_key5  VARCHAR2
    , p_val5  VARCHAR2
    , p_key6  VARCHAR2
    , p_val6  VARCHAR2
    , p_key7  VARCHAR2
    , p_val7  VARCHAR2
    , p_key8  VARCHAR2
    , p_val8  VARCHAR2
    , p_key9  VARCHAR2
    , p_val9  VARCHAR2
    , p_key10  VARCHAR2
    , p_val10  VARCHAR2
    , x_msg_count out  NUMBER
    , x_return_status out  VARCHAR2
    , x_msg_data out  VARCHAR2
  )
  as
    ddp_sent_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any










    ddp_sent_date := rosetta_g_miss_date_in_map(p_sent_date);





























    -- here's the delegated call to the old PL/SQL routine
    iem_prepenqdeq_pub.proc_enqueue(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_msg_id,
      p_msg_size,
      p_sender_name,
      p_user_name,
      p_domain_name,
      p_priority,
      p_msg_status,
      p_subject,
      ddp_sent_date,
      p_customer_id,
      p_product_id,
      p_classification,
      p_score_percent,
      p_info_id,
      p_key1,
      p_val1,
      p_key2,
      p_val2,
      p_key3,
      p_val3,
      p_key4,
      p_val4,
      p_key5,
      p_val5,
      p_key6,
      p_val6,
      p_key7,
      p_val7,
      p_key8,
      p_val8,
      p_key9,
      p_val9,
      p_key10,
      p_val10,
      x_msg_count,
      x_return_status,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any






































  end;

end iem_prepenqdeq_pub_w;

/
