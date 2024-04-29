--------------------------------------------------------
--  DDL for Package Body AHL_OSP_RCV_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_OSP_RCV_PVT_W" as
  /* $Header: AHLWORCB.pls 120.0 2008/02/05 16:17:10 mpothuku noship $ */
  procedure receive_against_rma(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_module_type  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p8_a0  NUMBER
    , p8_a1  NUMBER
    , p8_a2  VARCHAR2
    , p8_a3  NUMBER
    , p8_a4  NUMBER
    , p8_a5  VARCHAR2
    , p8_a6  DATE
    , p8_a7  NUMBER
    , p8_a8  VARCHAR2
    , p8_a9  VARCHAR2
    , p8_a10  VARCHAR2
    , p8_a11  VARCHAR2
    , p8_a12  NUMBER
    , p8_a13  VARCHAR2
    , p8_a14  VARCHAR2
    , x_request_id out nocopy  NUMBER
    , x_return_line_id out nocopy  NUMBER
  )

  as
    ddp_rma_receipt_rec ahl_osp_rcv_pvt.rma_receipt_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    ddp_rma_receipt_rec.return_line_id := p8_a0;
    ddp_rma_receipt_rec.receiving_org_id := p8_a1;
    ddp_rma_receipt_rec.receiving_subinventory := p8_a2;
    ddp_rma_receipt_rec.receiving_locator_id := p8_a3;
    ddp_rma_receipt_rec.receipt_quantity := p8_a4;
    ddp_rma_receipt_rec.receipt_uom_code := p8_a5;
    ddp_rma_receipt_rec.receipt_date := p8_a6;
    ddp_rma_receipt_rec.new_item_id := p8_a7;
    ddp_rma_receipt_rec.new_serial_number := p8_a8;
    ddp_rma_receipt_rec.new_serial_tag_code := p8_a9;
    ddp_rma_receipt_rec.new_lot_number := p8_a10;
    ddp_rma_receipt_rec.new_item_rev_number := p8_a11;
    ddp_rma_receipt_rec.exchange_item_id := p8_a12;
    ddp_rma_receipt_rec.exchange_serial_number := p8_a13;
    ddp_rma_receipt_rec.exchange_lot_number := p8_a14;



    -- here's the delegated call to the old PL/SQL routine
    ahl_osp_rcv_pvt.receive_against_rma(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_module_type,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rma_receipt_rec,
      x_request_id,
      x_return_line_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










  end;

end ahl_osp_rcv_pvt_w;

/
