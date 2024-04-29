--------------------------------------------------------
--  DDL for Package Body ASO_SERVICE_CONTRACTS_INT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_SERVICE_CONTRACTS_INT_W" as
  /* $Header: asovqwsb.pls 120.6 2005/10/27 23:10:15 gsachdev ship $ */
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

  procedure rosetta_table_copy_in_p2(t OUT NOCOPY aso_service_contracts_int.order_service_tbl_type, a0 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).service_item_id := rosetta_g_miss_num_map(a0(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t aso_service_contracts_int.order_service_tbl_type, a0 OUT NOCOPY JTF_NUMBER_TABLE
    ) as
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).service_item_id);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure rosetta_table_copy_in_p4(t OUT NOCOPY aso_service_contracts_int.war_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_2000
    , a2 JTF_VARCHAR2_TABLE_300
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_DATE_TABLE
    , a7 JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).service_item_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).service_name := a1(indx);
          t(ddindx).service_description := a2(indx);
          t(ddindx).duration_quantity := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).duration_period := a4(indx);
          t(ddindx).coverage_schedule_id := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).warranty_start_date := rosetta_g_miss_date_in_map(a6(indx));
          t(ddindx).warranty_end_date := rosetta_g_miss_date_in_map(a7(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p4;
  procedure rosetta_table_copy_out_p4(t aso_service_contracts_int.war_tbl_type, a0 OUT NOCOPY JTF_NUMBER_TABLE
    , a1 OUT NOCOPY JTF_VARCHAR2_TABLE_2000
    , a2 OUT NOCOPY JTF_VARCHAR2_TABLE_300
    , a3 OUT NOCOPY JTF_NUMBER_TABLE
    , a4 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a5 OUT NOCOPY JTF_NUMBER_TABLE
    , a6 OUT NOCOPY JTF_DATE_TABLE
    , a7 OUT NOCOPY JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_2000();
    a2 := JTF_VARCHAR2_TABLE_300();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_DATE_TABLE();
    a7 := JTF_DATE_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_2000();
      a2 := JTF_VARCHAR2_TABLE_300();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_DATE_TABLE();
      a7 := JTF_DATE_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        a5.extend(t.count);
        a6.extend(t.count);
        a7.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).service_item_id);
          a1(indx) := t(ddindx).service_name;
          a2(indx) := t(ddindx).service_description;
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).duration_quantity);
          a4(indx) := t(ddindx).duration_period;
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).coverage_schedule_id);
          a6(indx) := t(ddindx).warranty_start_date;
          a7(indx) := t(ddindx).warranty_end_date;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p4;

  procedure available_services(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , x_return_status OUT NOCOPY  VARCHAR2
    , p6_a0 OUT NOCOPY JTF_NUMBER_TABLE
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  DATE := fnd_api.g_miss_date
  )
  as
    ddp_avail_service_rec aso_service_contracts_int.avail_service_rec_type;
    ddx_orderable_service_tbl aso_service_contracts_int.order_service_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    ASO_Quote_Util_Pvt.Enable_Debug_Pvt;
    ASO_QUOTE_UTIL_PVT.Debug('aso_service_contracts_int_w.available_services  BEGIN....');
    -- copy data to the local IN or IN-OUT args, if any

    ddp_avail_service_rec.product_item_id := rosetta_g_miss_num_map(p5_a0);
    ddp_avail_service_rec.customer_id := rosetta_g_miss_num_map(p5_a1);
    ddp_avail_service_rec.product_revision := p5_a2;
    ddp_avail_service_rec.request_date := rosetta_g_miss_date_in_map(p5_a3);

    -- here's the delegated call to the old PL/SQL routine
    ASO_QUOTE_UTIL_PVT.Debug('Calling aso_service_contracts_int.available_services');
    aso_service_contracts_int.available_services(p_api_version_number,
      p_init_msg_list,
      x_msg_count,
      x_msg_data,
      x_return_status,
      ddp_avail_service_rec,
      ddx_orderable_service_tbl);
    ASO_QUOTE_UTIL_PVT.Debug('Ending  aso_service_contracts_int.available_services');

    -- copy data back from the local OUT NOCOPY /* file.sql.39 change */ or IN-OUT args, if any

    aso_service_contracts_int_w.rosetta_table_copy_out_p2(ddx_orderable_service_tbl, p6_a0
      );
    ASO_QUOTE_UTIL_PVT.Debug('aso_service_contracts_int_w.available_services  END....');
    ASO_Quote_Util_Pvt.Disable_Debug_Pvt;
  end;

  procedure get_warranty(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , p_org_id  NUMBER
    , p_organization_id  NUMBER
    , p_product_item_id  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , p8_a0 OUT NOCOPY JTF_NUMBER_TABLE
    , p8_a1 OUT NOCOPY JTF_VARCHAR2_TABLE_2000
    , p8_a2 OUT NOCOPY JTF_VARCHAR2_TABLE_300
    , p8_a3 OUT NOCOPY JTF_NUMBER_TABLE
    , p8_a4 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , p8_a5 OUT NOCOPY JTF_NUMBER_TABLE
    , p8_a6 OUT NOCOPY JTF_DATE_TABLE
    , p8_a7 OUT NOCOPY JTF_DATE_TABLE
  )
  as
    ddx_warranty_tbl aso_service_contracts_int.war_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    ASO_Quote_Util_Pvt.Enable_Debug_Pvt;
    ASO_QUOTE_UTIL_PVT.Debug('aso_service_contracts_int_w.get_warranty  BEGIN....');
    -- here's the delegated call to the old PL/SQL routine

    ASO_QUOTE_UTIL_PVT.Debug('Calling aso_service_contracts_int.get_warranty');
    aso_service_contracts_int.get_warranty(p_api_version_number,
      p_init_msg_list,
      x_msg_count,
      x_msg_data,
      p_org_id,
      p_organization_id,
      p_product_item_id,
      x_return_status,
      ddx_warranty_tbl);
    ASO_QUOTE_UTIL_PVT.Debug('Ending aso_service_contracts_int.get_warranty');

    -- copy data back from the local OUT NOCOPY /* file.sql.39 change */ or IN-OUT args, if any

    aso_service_contracts_int_w.rosetta_table_copy_out_p4(ddx_warranty_tbl, p8_a0
      , p8_a1
      , p8_a2
      , p8_a3
      , p8_a4
      , p8_a5
      , p8_a6
      , p8_a7
      );
    ASO_QUOTE_UTIL_PVT.Debug('aso_service_contracts_int_w.get_warranty  END..');
    ASO_Quote_Util_Pvt.Disable_Debug_Pvt;
  end;


PROCEDURE GET_SERVICES (
     x_item_number_tbl    OUT NOCOPY JTF_VARCHAR2_TABLE_2000,
     x_item_desc_tbl      OUT NOCOPY JTF_VARCHAR2_TABLE_2000,
     x_start_date_tbl     OUT NOCOPY JTF_DATE_TABLE,
     x_duration_tbl       OUT NOCOPY JTF_NUMBER_TABLE,
     x_period_code_tbl    OUT NOCOPY JTF_VARCHAR2_TABLE_100,
     x_warranty_flag_tbl  OUT NOCOPY JTF_VARCHAR2_TABLE_100,
     p_source             IN VARCHAR2,
     p_source_id          IN NUMBER,
     p_api_version_number IN NUMBER,
     p_init_msg_list      IN VARCHAR2,
     x_return_status      OUT NOCOPY VARCHAR2,
     x_msg_count          OUT NOCOPY NUMBER,
     x_msg_data           OUT NOCOPY VARCHAR2) AS

    -- for the  install base
     CURSOR  c_getInvOrgId_ib IS
      SELECT   inventory_item_id, inv_master_organization_id
      FROM     csi_item_instances
      WHERE    instance_id=p_source_id;

    -- for the  Quote
     CURSOR  c_getInvOrgId_qe IS
      SELECT   inventory_item_id, organization_id
      FROM     aso_quote_lines_all
      WHERE    quote_line_id=p_source_id;

   -- for the  Order
   --Query to get inventory item id:
    CURSOR c_getInventoryId IS
     SELECT inventory_item_id
     FROM   oe_order_lines_all
     WHERE  line_id =p_source_id;

  --Query to get inventory organization id:
    CURSOR c_getOrgId IS
     SELECT master_organization_id
     FROM   oe_system_parameters;


 -- Cursor to  retrieve the  existing services for the  org id
 -- and  service ref line id  for the quote

   CURSOR  c_getExistService_qe(p_orgId NUMBER)  IS
     SELECT  msiv.concatenated_segments, msiv.description,
             aql.start_date_active, aqld.service_ref_line_id,
             aqld.service_duration, aqld.service_period
     FROM    aso_quote_lines_all aql,
             aso_quote_line_details aqld, mtl_system_items_vl msiv
     WHERE   aqld.quote_line_id = aql.quote_line_id
     AND     aql.inventory_item_id = msiv.inventory_item_id
     AND     aql.organization_id = msiv.organization_id
     AND     msiv.organization_id=p_orgId
     AND     aqld.service_ref_line_id =p_source_Id;

 -- Cursor  to  get existing services for order
   CURSOR c_getExistService_or (p_orgId NUMBER) IS
    SELECT  msiv.concatenated_segments, msiv.description,
            ol.service_start_date, ol.service_duration, ol.service_period
    FROM    oe_order_lines_all ol, mtl_system_items_vl msiv
    WHERE   ol.service_reference_type_code = 'ORDER'
    AND     ol.inventory_item_id = msiv.inventory_item_id
    AND     msiv.organization_id = p_orgId
    AND     ol.service_reference_line_id=p_source_Id ;

    l_contracts_tbl  oks_entitlements_pub.output_tbl_ib;
    l_inp_rec  oks_entitlements_pub.input_rec_ib;
    l_item_id NUMBER;
    l_inv_org_id  NUMBER;
    l_warranty_tbl aso_service_contracts_int.war_tbl_type;
    l_return_status VARCHAR2(5);
    l_item_number  JTF_VARCHAR2_TABLE_2000;
    l_count NUMBER :=0;
    l_index NUMBER :=0;
    l_api_version  NUMBER := 1.0;
    l_api_name VARCHAR2(50) := 'GET_SERVICES';
    G_PKG_NAME VARCHAR2(50):= 'ASO_SERVICE_CONTRACTS_INT_W';
    l_current_org_id NUMBER ;

 BEGIN

    -- Enable  debug message
     Aso_Quote_Util_Pvt.Enable_Debug_Pvt;

     ASO_QUOTE_UTIL_PVT.Debug('aso_service_contracts_int_w.getServices  BEGIN....');
    -- Standard Start of API savepoint
     SAVEPOINT GET_SERVICES_PUB;

     aso_debug_pub.g_debug_flag := Aso_Quote_Util_Pvt.is_debug_enabled;
      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version,
                           	           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list ) THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      ASO_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                    'Private API: ' || l_api_name || 'start');

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      -- ******************************************************************
      -- Validate Environment
      -- ******************************************************************
      IF FND_GLOBAL.User_Id IS NULL THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)THEN
           FND_MESSAGE.Set_Name(' + appShortName +',
                                   'UT_CANNOT_GET_PROFILE_VALUE');
           FND_MESSAGE.Set_Token('PROFILE', 'USER_ID', FALSE);
           FND_MSG_PUB.ADD;
        END IF;
        RAISE FND_API.G_EXC_ERROR;
      END IF;


     x_item_number_tbl := JTF_VARCHAR2_TABLE_2000();
     x_item_desc_tbl   := JTF_VARCHAR2_TABLE_2000();
     x_start_date_tbl  := JTF_DATE_TABLE();
     x_duration_tbl    := JTF_NUMBER_TABLE();
     x_period_code_tbl := JTF_VARCHAR2_TABLE_100();
     x_warranty_flag_tbl := JTF_VARCHAR2_TABLE_100();

  IF (p_source ='INSTALL_BASE') THEN

     IF aso_debug_pub.g_debug_flag = 'Y' THEN
       aso_debug_pub.add('Aso_Service_Contracts_int_w:Get_Services p_source = INSTALL_BASE ', 1, 'N');
     END IF;

    l_inp_rec.validate_flag :='Y'; -- show all contracts
    l_inp_rec.product_id :=p_source_Id;
    l_inp_rec.calc_resptime_flag :='N';

    ASO_QUOTE_UTIL_PVT.Debug('Calling oks_entitlements_pub.get_contracts  InstallBase');
    aso_utility_pvt.print_login_info();

    oks_entitlements_pub.get_contracts(
   		p_api_version =>l_api_version,
	   	p_init_msg_list => FND_API.G_TRUE,
   		p_inp_rec => l_inp_rec,
  	 	x_ent_contracts => l_contracts_tbl,
		x_return_status => x_return_status,
		x_msg_count => x_msg_count,
		x_msg_data => x_msg_data);
    ASO_QUOTE_UTIL_PVT.Debug('Ending oks_entitlements_pub.get_contracts  InstallBase');

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
      aso_debug_pub.add('ASO_Service_contracts_int_w: After Call to OKS entitlements get contracts: x_return_status '|| x_return_status, 1, 'N');
    END IF;

      -- Check return status from the above procedure call
      IF x_return_status = FND_API.G_RET_STS_ERROR then
          raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
       IF l_contracts_tbl IS NOT NULL THEN
        IF l_contracts_tbl.count >0 THEN
         x_item_number_tbl.extend(l_contracts_tbl.count);
         x_item_desc_tbl.extend(l_contracts_tbl.count);
         x_start_date_tbl.extend(l_contracts_tbl.count);
         x_duration_tbl.extend(l_contracts_tbl.count);
         x_period_code_tbl.extend(l_contracts_tbl.count);
         x_warranty_flag_tbl.extend(l_contracts_tbl.count);
         FOR i in  l_contracts_tbl.FIRST..l_contracts_tbl.LAST LOOP
          x_item_number_tbl(i) := l_contracts_tbl(i).service_name;
          x_item_desc_tbl(i) := l_contracts_tbl(i).service_description;
          x_start_date_tbl(i) := l_contracts_tbl(i).service_start_date;
          x_warranty_flag_tbl(i) := l_contracts_tbl(i).warranty_flag;
          ASO_QUOTE_UTIL_PVT.Debug('Calling okc_time_util_pub.get_duration  InstallBase');
          okc_time_util_pub.get_duration(
            p_start_date => l_contracts_tbl(i).service_start_date,
            p_end_date => l_contracts_tbl(i).service_end_date,
            x_duration => x_duration_tbl(i),
            x_timeunit => x_period_code_tbl(i),
            x_return_status => l_return_status);
          ASO_QUOTE_UTIL_PVT.Debug('Calling okc_time_util_pub.get_duration  InstallBase');
          IF l_return_status = FND_API.G_RET_STS_ERROR then
            RAISE FND_API.G_EXC_ERROR;
          ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
         END LOOP;
        END IF;
       END IF;
      END IF;
  ELSIF (p_source='QUOTE') THEN

     IF aso_debug_pub.g_debug_flag = 'Y' THEN
       aso_debug_pub.add('Aso_Service_Contracts_int_w:Get_Services p_source:= QUOTE', 1, 'N');
     END IF;

     FOR  c_InvOrg_or IN c_getInvOrgId_qe LOOP
      l_item_id := c_invOrg_or.inventory_item_id;
      l_inv_org_id :=c_invOrg_or.organization_id;
     END LOOP;

     IF aso_debug_pub.g_debug_flag = 'Y' THEN
       aso_debug_pub.add('Aso_Service_Contracts_int_w:Get_Services l_item_id=  '|| l_item_id ||'l_inv_org_id=' || l_inv_org_id , 1, 'N');
     END IF;

     l_index :=0;
     FOR c_quote IN  c_getExistService_qe(l_inv_org_id) LOOP
       l_index := l_index + 1;
       x_item_number_tbl.extend(1);
       x_item_desc_tbl.extend(1);
       x_start_date_tbl.extend(1);
       x_duration_tbl.extend(1);
       x_period_code_tbl.extend(1);
       x_warranty_flag_tbl.extend(1);

       x_item_number_tbl(l_index) :=c_quote.concatenated_segments;
       x_item_desc_tbl(l_index) := c_quote.description;
       x_start_date_tbl(l_index) := c_quote.start_date_active;
       x_duration_tbl(l_index) := c_quote.service_duration;
       x_period_code_tbl(l_index) := c_quote.service_period;
       x_warranty_flag_tbl(l_index) := 'N';
     END LOOP;

  ELSIF (p_source='ORDER') THEN
    IF aso_debug_pub.g_debug_flag = 'Y' THEN
      aso_debug_pub.add('Aso_Service_Contracts_int_w:Get_Services p_source = ORDER ', 1, 'N');
    END IF;

    FOR c_getItemId  IN c_getInventoryId LOOP
     l_item_id :=c_getItemId.inventory_item_id;
    END LOOP;

    FOR c_getMasterOrg IN c_getOrgId LOOP
      l_inv_org_id :=c_getMasterOrg.master_organization_id;
    END LOOP;

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
      aso_debug_pub.add('Aso_Service_Contracts_int_w:Get_Services l_item_id=  '|| l_item_id ||'l_inv_org_id=' || l_inv_org_id , 1, 'N');
    END IF;

     l_index :=0;
     FOR c_order  IN  c_getExistService_or(l_inv_org_id) LOOP
       l_index := l_index + 1;
       x_item_number_tbl.extend(1);
       x_item_desc_tbl.extend(1);
       x_start_date_tbl.extend(1);
       x_duration_tbl.extend(1);
       x_period_code_tbl.extend(1);
       x_warranty_flag_tbl.extend(1);
       x_item_number_tbl(l_index) :=c_order.concatenated_segments;
       x_item_desc_tbl(l_index) := c_order.description;
       x_start_date_tbl(l_index) := c_order.service_start_date;
       x_duration_tbl(l_index) := c_order.service_duration;
       x_period_code_tbl(l_index) := c_order.service_period;
       x_warranty_flag_tbl(l_index) := 'N';
     END LOOP;
  END IF;

  IF (P_SOURCE <> 'INSTALL_BASE') THEN
    ASO_QUOTE_UTIL_PVT.Debug('Calling aso_service_contracts_int.get_warranty <> InstallBase');
    l_current_org_id := MO_GLOBAL.GET_CURRENT_ORG_ID ;
    ASO_QUOTE_UTIL_PVT.Debug('Current Org ID :' || l_current_org_id);

    Aso_Service_Contracts_Int.Get_Warranty(
             p_api_version_number => l_api_version,
             p_init_msg_list => FND_API.G_FALSE,
             x_return_status => x_return_status,
             x_msg_count => x_msg_count,
             x_msg_data => x_msg_data,
             --p_org_id => Fnd_Profile.value('ORG_ID'),
	     --Modified to get the value from context
	     p_org_id => l_current_org_id,
             p_organization_id	=> l_inv_org_id,
             p_product_item_id => l_item_id,
             x_warranty_tbl => l_warranty_tbl);
    ASO_QUOTE_UTIL_PVT.Debug('Ending  aso_service_contracts_int.get_warranty <> InstallBase');

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
      aso_debug_pub.add('ASO_Service_contracts_int_w: After Call to get_warranty: x_return_status '|| x_return_status, 1, 'N');
    END IF;

      -- Check return status from the above procedure call
      IF x_return_status = FND_API.G_RET_STS_ERROR then
          raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
       IF l_warranty_tbl IS NOT NULL THEN
        IF l_warranty_tbl.count >0 THEN
         x_item_number_tbl.extend(l_warranty_tbl.count);
         x_item_desc_tbl.extend(l_warranty_tbl.count);
         x_start_date_tbl.extend(l_warranty_tbl.count);
         x_duration_tbl.extend(l_warranty_tbl.count);
         x_period_code_tbl.extend(l_warranty_tbl.count);
         x_warranty_flag_tbl.extend(l_warranty_tbl.count);
         FOR i in  l_warranty_tbl.FIRST..l_warranty_tbl.LAST LOOP
          l_index := l_index + 1;
          x_item_number_tbl(l_index) := l_warranty_tbl(i).service_name;
          x_item_desc_tbl(l_index) := l_warranty_tbl(i).service_description;
          x_start_date_tbl(l_index) := l_warranty_tbl(i).warranty_start_date;
          x_duration_tbl(l_index) := l_warranty_tbl(i).duration_quantity;
          x_period_code_tbl(l_index) := l_warranty_tbl(i).duration_period;
          x_warranty_flag_tbl(l_index) := 'Y';
         END LOOP;
        END IF;
       END IF;
      END IF;
   END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

    --disable the  debug message
    ASO_QUOTE_UTIL_PVT.Debug('aso_service_contracts_int_w.getServices  END....');
    ASO_Quote_Util_Pvt.disable_debug_pvt;
 EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
       ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
               P_API_NAME => L_API_NAME
              ,P_PKG_NAME => G_PKG_NAME
              ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
              ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
              ,X_MSG_COUNT => X_MSG_COUNT
              ,X_MSG_DATA => X_MSG_DATA
              ,X_RETURN_STATUS => X_RETURN_STATUS);
      ASO_Quote_Util_Pvt.disable_debug_pvt;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
               P_API_NAME => L_API_NAME
              ,P_PKG_NAME => G_PKG_NAME
              ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
              ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
              ,X_MSG_COUNT => X_MSG_COUNT
              ,X_MSG_DATA => X_MSG_DATA
              ,X_RETURN_STATUS => X_RETURN_STATUS);
       ASO_Quote_Util_Pvt.disable_debug_pvt;
     WHEN OTHERS THEN
         ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
               P_API_NAME => L_API_NAME
              ,P_PKG_NAME => G_PKG_NAME
              ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
              ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
              ,X_MSG_COUNT => X_MSG_COUNT
              ,X_MSG_DATA => X_MSG_DATA
              ,X_RETURN_STATUS => X_RETURN_STATUS);
         ASO_Quote_Util_Pvt.disable_debug_pvt;
 END GET_SERVICES;

  procedure is_service_available (
     p_api_version_number  IN NUMBER
   , p_init_msg_list       IN VARCHAR2
   , x_return_status       OUT NOCOPY VARCHAR2
   , x_msg_count           OUT NOCOPY  NUMBER
   , x_msg_data            OUT NOCOPY  VARCHAR2
   , p_product_item_id     IN Number
   , p_service_item_id     IN  Number
   , p_customer_id         IN Number
   , p_product_revision    IN Varchar2
   , p_request_date        IN Date
   , X_Available_YN        OUT NOCOPY /* file.sql.39 change */ varchar2) IS

 l_check_service_rec ASO_service_contracts_INT.CHECK_SERVICE_REC_TYPE;
 l_api_name varchar2(50) := 'is_service_available';
    l_api_version  NUMBER := 1.0;
    G_PKG_NAME VARCHAR2(50):= 'ASO_SERVICE_CONTRACTS_INT_W';

 BEGIN


    -- Enable  debug message
     Aso_Quote_Util_Pvt.Enable_Debug_Pvt;

     ASO_QUOTE_UTIL_PVT.Debug('aso_service_contracts_int_w.is_service_available  BEGIN....');

     aso_debug_pub.g_debug_flag := Aso_Quote_Util_Pvt.is_debug_enabled;
      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                         p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list ) THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --
   l_check_service_rec.product_item_id := p_product_item_id;
   l_check_service_rec.service_item_id := p_service_item_id;
   l_check_service_rec.customer_id := p_customer_id;
   l_check_service_rec.product_revision :=  p_product_revision;
   l_check_service_rec.request_date := p_request_date;

    ASO_service_contracts_INT.Is_Service_Available
   	 (
	P_Api_Version_Number,
	P_init_msg_list,
	X_msg_Count,
	X_msg_Data,
	X_Return_Status,
	l_check_service_rec,
	X_Available_YN);

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

    --disable the  debug message
    ASO_QUOTE_UTIL_PVT.Debug('aso_service_contracts_int_w.is_service_available  END....');
    ASO_Quote_Util_Pvt.disable_debug_pvt;


 EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
       ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
               P_API_NAME => L_API_NAME
              ,P_PKG_NAME => G_PKG_NAME
              ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
              ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
              ,X_MSG_COUNT => X_MSG_COUNT
              ,X_MSG_DATA => X_MSG_DATA
              ,X_RETURN_STATUS => X_RETURN_STATUS);
      ASO_Quote_Util_Pvt.disable_debug_pvt;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
               P_API_NAME => L_API_NAME
              ,P_PKG_NAME => G_PKG_NAME
              ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
              ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
              ,X_MSG_COUNT => X_MSG_COUNT
              ,X_MSG_DATA => X_MSG_DATA
              ,X_RETURN_STATUS => X_RETURN_STATUS);
       ASO_Quote_Util_Pvt.disable_debug_pvt;
     WHEN OTHERS THEN
         ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
               P_API_NAME => L_API_NAME
              ,P_PKG_NAME => G_PKG_NAME
              ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
              ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
              ,X_MSG_COUNT => X_MSG_COUNT
              ,X_MSG_DATA => X_MSG_DATA
              ,X_RETURN_STATUS => X_RETURN_STATUS);
         ASO_Quote_Util_Pvt.disable_debug_pvt;

  END  is_service_available;

  procedure available_services(
     x_Inventory_organization_id           OUT NOCOPY  JTF_NUMBER_TABLE
   , x_Service_item_id                     OUT NOCOPY  JTF_NUMBER_TABLE
   , x_Concatenated_segments               OUT NOCOPY  JTF_VARCHAR2_TABLE_1000
   , x_Description                         OUT NOCOPY  JTF_VARCHAR2_TABLE_1000
   , x_Primary_uom_code                    OUT NOCOPY  JTF_VARCHAR2_TABLE_300
   , x_Serviceable_product_flag            OUT NOCOPY  JTF_VARCHAR2_TABLE_100
   , x_Service_item_flag                   OUT NOCOPY  JTF_VARCHAR2_TABLE_100
   , x_Bom_item_type                       OUT NOCOPY  JTF_NUMBER_TABLE
   , x_Item_type                           OUT NOCOPY  JTF_VARCHAR2_TABLE_1000
   , x_Service_duration                    OUT NOCOPY  JTF_NUMBER_TABLE
   , x_Service_duration_period_code        OUT NOCOPY  JTF_VARCHAR2_TABLE_1000
   , x_Shippable_item_flag                 OUT NOCOPY  JTF_VARCHAR2_TABLE_100
   , x_Returnable_flag                     OUT NOCOPY  JTF_VARCHAR2_TABLE_100
   , p_api_version_number                  IN NUMBER
   , p_init_msg_list                       IN VARCHAR2 := FND_API.G_MISS_CHAR
   , p_commit                              IN VARCHAR2:= FND_API.g_false
   , p_search_input                        IN VARCHAR2 := FND_API.G_MISS_CHAR
   , p_product_item_id                     IN Number := FND_API.G_MISS_NUM
   , p_customer_id                         IN Number := FND_API.G_MISS_NUM
   , p_product_revision                    IN Varchar2 := FND_API.G_MISS_CHAR
   , p_request_date                        IN Date := FND_API.G_MISS_DATE
   , x_return_status                       OUT NOCOPY VARCHAR2
   , x_msg_count                           OUT NOCOPY  NUMBER
   , x_msg_data                            OUT NOCOPY  VARCHAR2)

 is
 l_api_name varchar2(50) := 'available_services';
 l_api_version  NUMBER := 1.0;
 G_PKG_NAME VARCHAR2(50):= 'ASO_SERVICE_CONTRACTS_INT_W';
 l_avail_service_rec                   OKS_OMINT_PUB.Avail_Service_Rec_Type;
 l_orderable_service_tbl               OKS_OMINT_PUB.new_order_service_tbl_type;
 l_count NUMBER :=0;
 l_index NUMBER :=0;
 begin


    -- Enable  debug message
     Aso_Quote_Util_Pvt.Enable_Debug_Pvt;


      IF aso_debug_pub.g_debug_flag = 'Y' THEN
       aso_debug_pub.ADD ( 'Overloaded aso_service_contracts_int_w.is_service_available  BEGIN.... ' , 1 , 'Y' );
      END IF;


     aso_debug_pub.g_debug_flag := Aso_Quote_Util_Pvt.is_debug_enabled;
      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                         p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list ) THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      SAVEPOINT AVAILABLE_SERVICES_PUB;


      --
      -- API body


       ASO_QUOTE_UTIL_PVT.Debug('Constructing the input record');

       l_avail_service_rec.product_item_id := p_product_item_id;
       l_avail_service_rec.customer_id := p_customer_id;
       l_avail_service_rec.product_revision := p_product_revision;
       l_avail_service_rec.request_date := p_request_date;

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
       aso_debug_pub.ADD ( 'p_product_item_id'||p_product_item_id , 1 , 'Y' );
       aso_debug_pub.ADD ( 'p_customer_id ' ||p_customer_id , 1 , 'Y' );
       aso_debug_pub.ADD ( 'p_product_revision ' ||p_product_revision , 1 , 'Y' );
       aso_debug_pub.ADD ( 'p_request_date ' ||p_request_date, 1 , 'Y' );
       aso_debug_pub.ADD ( 'P_search_input ' ||P_search_input , 1 , 'Y' );
       aso_debug_pub.ADD ( 'Before calling the OKC API' , 1 , 'Y' );
       aso_utility_pvt.print_login_info();
      END IF;



       OKS_OMINT_PUB.Available_Services(
         P_Api_Version  => P_Api_Version_number,
         P_init_msg_list => P_init_msg_list,
         P_search_input  => P_search_input,
         X_msg_Count  => X_msg_Count,
         X_msg_Data     => X_msg_Data,
         X_Return_Status  => X_Return_Status,
         p_avail_service_rec => l_avail_service_rec,
         x_orderable_service_tbl => l_orderable_service_tbl
         );

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
       aso_debug_pub.ADD ( 'After calling the OKC API' , 1 , 'Y' );
       aso_debug_pub.ADD ( 'Return status from OKC API : '|| X_Return_Status , 1 , 'Y' );
       aso_utility_pvt.print_login_info();
      END IF;


      -- Check return status from the above procedure call
      IF x_return_status = FND_API.G_RET_STS_ERROR then
          raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

    -- initialize the record structures
    x_Inventory_organization_id := JTF_NUMBER_TABLE();
    x_Service_item_id := JTF_NUMBER_TABLE();
    x_Concatenated_segments := JTF_VARCHAR2_TABLE_1000();
    x_Description := JTF_VARCHAR2_TABLE_1000();
    x_Primary_uom_code := JTF_VARCHAR2_TABLE_300();
    x_Serviceable_product_flag := JTF_VARCHAR2_TABLE_100();
    x_Service_item_flag := JTF_VARCHAR2_TABLE_100();
    x_Bom_item_type :=  JTF_NUMBER_TABLE();
    x_Item_type := JTF_VARCHAR2_TABLE_1000();
    x_Service_duration := JTF_NUMBER_TABLE();
    x_Service_duration_period_code :=  JTF_VARCHAR2_TABLE_1000();
    x_Shippable_item_flag := JTF_VARCHAR2_TABLE_100();
    x_Returnable_flag :=  JTF_VARCHAR2_TABLE_100();

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
       aso_debug_pub.ADD ( 'Number of Records Returned from OKC API : '|| to_char(l_orderable_service_tbl.count) , 1 , 'Y' );
      END IF;


      IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
       IF l_orderable_service_tbl IS NOT NULL THEN
        IF l_orderable_service_tbl.count >0 THEN

           ASO_QUOTE_UTIL_PVT.Debug('Extending the jtf tables ');

              x_Inventory_organization_id.extend(l_orderable_service_tbl.count);
              x_Service_item_id.extend(l_orderable_service_tbl.count);
              x_Concatenated_segments.extend(l_orderable_service_tbl.count);
              x_Description.extend(l_orderable_service_tbl.count);
              x_Primary_uom_code.extend(l_orderable_service_tbl.count);
              x_Serviceable_product_flag.extend(l_orderable_service_tbl.count);
              x_Service_item_flag.extend(l_orderable_service_tbl.count);
              x_Bom_item_type.extend(l_orderable_service_tbl.count);
              x_Item_type.extend(l_orderable_service_tbl.count);
              x_Service_duration.extend(l_orderable_service_tbl.count);
              x_Service_duration_period_code.extend(l_orderable_service_tbl.count);
              x_Shippable_item_flag.extend(l_orderable_service_tbl.count);
              x_Returnable_flag.extend(l_orderable_service_tbl.count);

         FOR i in  l_orderable_service_tbl.FIRST..l_orderable_service_tbl.LAST LOOP
          l_index := l_index + 1;

           ASO_QUOTE_UTIL_PVT.Debug('Assigning the values ');

          x_Inventory_organization_id(l_index) := l_orderable_service_tbl(i).Inventory_organization_id;
          x_Service_item_id(l_index) := l_orderable_service_tbl(i).Service_item_id;
          x_Concatenated_segments(l_index) := l_orderable_service_tbl(i).Concatenated_segments;
          x_Description(l_index) := l_orderable_service_tbl(i).Description;
          x_Primary_uom_code(l_index) := l_orderable_service_tbl(i).Primary_uom_code;
          x_Serviceable_product_flag(l_index) := l_orderable_service_tbl(i).Serviceable_product_flag;
          x_Service_item_flag(l_index) := l_orderable_service_tbl(i).Service_item_flag;
          x_Bom_item_type(l_index) := l_orderable_service_tbl(i).Bom_item_type;
          x_Item_type(l_index) := l_orderable_service_tbl(i).Item_type;
          x_Service_duration(l_index) := l_orderable_service_tbl(i).Service_duration;
          x_Service_duration_period_code(l_index) := l_orderable_service_tbl(i).Service_duration_period_code;
          x_Shippable_item_flag(l_index) := l_orderable_service_tbl(i).Shippable_item_flag;
          x_Returnable_flag(l_index) := l_orderable_service_tbl(i).Returnable_flag;

         END LOOP;
        END IF;
       END IF;
      END IF;

               ASO_QUOTE_UTIL_PVT.Debug('After Assigning the values ');
   -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

    --disable the  debug message
      IF aso_debug_pub.g_debug_flag = 'Y' THEN
       aso_debug_pub.ADD ( 'Overloaded aso_service_contracts_int_w.is_service_available  END.... ' , 1 , 'Y' );
      END IF;

    ASO_Quote_Util_Pvt.disable_debug_pvt;


 EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
       ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
               P_API_NAME => L_API_NAME
              ,P_PKG_NAME => G_PKG_NAME
              ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
              ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
              ,X_MSG_COUNT => X_MSG_COUNT
              ,X_MSG_DATA => X_MSG_DATA
              ,X_RETURN_STATUS => X_RETURN_STATUS);
      ASO_Quote_Util_Pvt.disable_debug_pvt;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
               P_API_NAME => L_API_NAME
              ,P_PKG_NAME => G_PKG_NAME
              ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
              ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
              ,X_MSG_COUNT => X_MSG_COUNT
              ,X_MSG_DATA => X_MSG_DATA
              ,X_RETURN_STATUS => X_RETURN_STATUS);
       ASO_Quote_Util_Pvt.disable_debug_pvt;
     WHEN OTHERS THEN
         ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
               P_API_NAME => L_API_NAME
              ,P_PKG_NAME => G_PKG_NAME
              ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
              ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
              ,X_MSG_COUNT => X_MSG_COUNT
              ,X_MSG_DATA => X_MSG_DATA
              ,X_RETURN_STATUS => X_RETURN_STATUS);
         ASO_Quote_Util_Pvt.disable_debug_pvt;
 end available_services;


end aso_service_contracts_int_w;

/
