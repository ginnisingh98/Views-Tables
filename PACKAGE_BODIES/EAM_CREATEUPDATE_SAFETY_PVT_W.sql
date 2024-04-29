--------------------------------------------------------
--  DDL for Package Body EAM_CREATEUPDATE_SAFETY_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_CREATEUPDATE_SAFETY_PVT_W" as
  /* $Header: EAMVWPCB.pls 120.0.12010000.2 2010/03/23 00:36:56 mashah noship $ */
    procedure create_update_permit(p_commit  VARCHAR2
    , p1_a0  NUMBER
    , p1_a1  NUMBER
    , p1_a2  NUMBER
    , p1_a3  NUMBER
    , p1_a4  NUMBER
    , p1_a5  VARCHAR2
    , p1_a6  NUMBER
    , p1_a7  VARCHAR2
    , p1_a8  NUMBER
    , p1_a9  NUMBER
    , p1_a10  DATE
    , p1_a11  DATE
    , p1_a12  VARCHAR2
    , p1_a13  DATE
    , p1_a14  NUMBER
    , p1_a15  VARCHAR2
    , p1_a16  VARCHAR2
    , p1_a17  VARCHAR2
    , p1_a18  VARCHAR2
    , p1_a19  VARCHAR2
    , p1_a20  VARCHAR2
    , p1_a21  VARCHAR2
    , p1_a22  VARCHAR2
    , p1_a23  VARCHAR2
    , p1_a24  VARCHAR2
    , p1_a25  VARCHAR2
    , p1_a26  VARCHAR2
    , p1_a27  VARCHAR2
    , p1_a28  VARCHAR2
    , p1_a29  VARCHAR2
    , p1_a30  VARCHAR2
    , p1_a31  VARCHAR2
    , p1_a32  VARCHAR2
    , p1_a33  VARCHAR2
    , p1_a34  VARCHAR2
    , p1_a35  VARCHAR2
    , p1_a36  VARCHAR2
    , p1_a37  VARCHAR2
    , p1_a38  VARCHAR2
    , p1_a39  VARCHAR2
    , p1_a40  VARCHAR2
    , p1_a41  VARCHAR2
    , p1_a42  VARCHAR2
    , p1_a43  VARCHAR2
    , p1_a44  VARCHAR2
    , p1_a45  VARCHAR2
    , p1_a46  NUMBER
    , p1_a47  NUMBER
    , p1_a48  DATE
    , p1_a49  NUMBER
    , p1_a50  NUMBER
    , p2_a0 JTF_NUMBER_TABLE
    , p2_a1 JTF_NUMBER_TABLE
    , p2_a2 JTF_NUMBER_TABLE
    , p2_a3 JTF_NUMBER_TABLE
    , p2_a4 JTF_NUMBER_TABLE
    , p2_a5 JTF_NUMBER_TABLE
    , p2_a6 JTF_NUMBER_TABLE
    , p2_a7 JTF_NUMBER_TABLE
    , p2_a8 JTF_VARCHAR2_TABLE_100
    , p2_a9 JTF_VARCHAR2_TABLE_300
    , p2_a10 JTF_VARCHAR2_TABLE_300
    , p2_a11 JTF_VARCHAR2_TABLE_300
    , p2_a12 JTF_VARCHAR2_TABLE_300
    , p2_a13 JTF_VARCHAR2_TABLE_300
    , p2_a14 JTF_VARCHAR2_TABLE_300
    , p2_a15 JTF_VARCHAR2_TABLE_300
    , p2_a16 JTF_VARCHAR2_TABLE_300
    , p2_a17 JTF_VARCHAR2_TABLE_300
    , p2_a18 JTF_VARCHAR2_TABLE_300
    , p2_a19 JTF_VARCHAR2_TABLE_300
    , p2_a20 JTF_VARCHAR2_TABLE_300
    , p2_a21 JTF_VARCHAR2_TABLE_300
    , p2_a22 JTF_VARCHAR2_TABLE_300
    , p2_a23 JTF_VARCHAR2_TABLE_300
    , p2_a24 JTF_VARCHAR2_TABLE_300
    , p2_a25 JTF_VARCHAR2_TABLE_300
    , p2_a26 JTF_VARCHAR2_TABLE_300
    , p2_a27 JTF_VARCHAR2_TABLE_300
    , p2_a28 JTF_VARCHAR2_TABLE_300
    , p2_a29 JTF_VARCHAR2_TABLE_300
    , p2_a30 JTF_VARCHAR2_TABLE_300
    , p2_a31 JTF_VARCHAR2_TABLE_300
    , p2_a32 JTF_VARCHAR2_TABLE_300
    , p2_a33 JTF_VARCHAR2_TABLE_300
    , p2_a34 JTF_VARCHAR2_TABLE_300
    , p2_a35 JTF_VARCHAR2_TABLE_300
    , p2_a36 JTF_VARCHAR2_TABLE_300
    , p2_a37 JTF_VARCHAR2_TABLE_300
    , p2_a38 JTF_VARCHAR2_TABLE_300
    , p2_a39 JTF_NUMBER_TABLE
    , p2_a40 JTF_DATE_TABLE
    , x_permit_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
  )

  as
    ddp_work_permit_header_rec eam_process_permit_pub.eam_wp_header_rec_type;
    ddp_permit_wo_association_tbl eam_process_permit_pub.eam_wp_association_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_work_permit_header_rec.header_id := p1_a0;
    ddp_work_permit_header_rec.batch_id := p1_a1;
    ddp_work_permit_header_rec.row_id := p1_a2;
    ddp_work_permit_header_rec.transaction_type := p1_a3;
    ddp_work_permit_header_rec.permit_id := p1_a4;
    ddp_work_permit_header_rec.permit_name := p1_a5;
    ddp_work_permit_header_rec.permit_type := p1_a6;
    ddp_work_permit_header_rec.description := p1_a7;
    ddp_work_permit_header_rec.organization_id := p1_a8;
    ddp_work_permit_header_rec.status_type := p1_a9;
    ddp_work_permit_header_rec.valid_from := p1_a10;
    ddp_work_permit_header_rec.valid_to := p1_a11;
    ddp_work_permit_header_rec.pending_flag := p1_a12;
    ddp_work_permit_header_rec.completion_date := p1_a13;
    ddp_work_permit_header_rec.user_defined_status_id := p1_a14;
    ddp_work_permit_header_rec.attribute_category := p1_a15;
    ddp_work_permit_header_rec.attribute1 := p1_a16;
    ddp_work_permit_header_rec.attribute2 := p1_a17;
    ddp_work_permit_header_rec.attribute3 := p1_a18;
    ddp_work_permit_header_rec.attribute4 := p1_a19;
    ddp_work_permit_header_rec.attribute5 := p1_a20;
    ddp_work_permit_header_rec.attribute6 := p1_a21;
    ddp_work_permit_header_rec.attribute7 := p1_a22;
    ddp_work_permit_header_rec.attribute8 := p1_a23;
    ddp_work_permit_header_rec.attribute9 := p1_a24;
    ddp_work_permit_header_rec.attribute10 := p1_a25;
    ddp_work_permit_header_rec.attribute11 := p1_a26;
    ddp_work_permit_header_rec.attribute12 := p1_a27;
    ddp_work_permit_header_rec.attribute13 := p1_a28;
    ddp_work_permit_header_rec.attribute14 := p1_a29;
    ddp_work_permit_header_rec.attribute15 := p1_a30;
    ddp_work_permit_header_rec.attribute16 := p1_a31;
    ddp_work_permit_header_rec.attribute17 := p1_a32;
    ddp_work_permit_header_rec.attribute18 := p1_a33;
    ddp_work_permit_header_rec.attribute19 := p1_a34;
    ddp_work_permit_header_rec.attribute20 := p1_a35;
    ddp_work_permit_header_rec.attribute21 := p1_a36;
    ddp_work_permit_header_rec.attribute22 := p1_a37;
    ddp_work_permit_header_rec.attribute23 := p1_a38;
    ddp_work_permit_header_rec.attribute24 := p1_a39;
    ddp_work_permit_header_rec.attribute25 := p1_a40;
    ddp_work_permit_header_rec.attribute26 := p1_a41;
    ddp_work_permit_header_rec.attribute27 := p1_a42;
    ddp_work_permit_header_rec.attribute28 := p1_a43;
    ddp_work_permit_header_rec.attribute29 := p1_a44;
    ddp_work_permit_header_rec.attribute30 := p1_a45;
    ddp_work_permit_header_rec.approved_by := p1_a46;
    ddp_work_permit_header_rec.created_by := p1_a47;
    ddp_work_permit_header_rec.creation_date := p1_a48;
    ddp_work_permit_header_rec.user_id := p1_a49;
    ddp_work_permit_header_rec.responsibility_id := p1_a50;

    eam_process_permit_pub_w.rosetta_table_copy_in_p3(ddp_permit_wo_association_tbl, p2_a0
      , p2_a1
      , p2_a2
      , p2_a3
      , p2_a4
      , p2_a5
      , p2_a6
      , p2_a7
      , p2_a8
      , p2_a9
      , p2_a10
      , p2_a11
      , p2_a12
      , p2_a13
      , p2_a14
      , p2_a15
      , p2_a16
      , p2_a17
      , p2_a18
      , p2_a19
      , p2_a20
      , p2_a21
      , p2_a22
      , p2_a23
      , p2_a24
      , p2_a25
      , p2_a26
      , p2_a27
      , p2_a28
      , p2_a29
      , p2_a30
      , p2_a31
      , p2_a32
      , p2_a33
      , p2_a34
      , p2_a35
      , p2_a36
      , p2_a37
      , p2_a38
      , p2_a39
      , p2_a40
      );




    -- here's the delegated call to the old PL/SQL routine
    eam_createupdate_safety_pvt.create_update_permit(p_commit,
      ddp_work_permit_header_rec,
      ddp_permit_wo_association_tbl,
      x_permit_id,
      x_return_status,
      x_msg_count);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end eam_createupdate_safety_pvt_w;


/
