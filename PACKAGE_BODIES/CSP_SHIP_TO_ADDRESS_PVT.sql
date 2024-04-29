--------------------------------------------------------
--  DDL for Package Body CSP_SHIP_TO_ADDRESS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_SHIP_TO_ADDRESS_PVT" AS
/*$Header: cspvstab.pls 120.7.12010000.23 2013/10/24 05:59:09 htank ship $*/
------------------------------------------------------------------------------------------------------------------------
--
-- Procedure Name   : Main procedure name is ship_to_address_handler.  All calling programs should call it directly.
--                    It can handle the following situations:
--                    1. Create an inventory location.
--                    2. Modify an inventory location.
--                    3. Create site location, party, party site, party site use, customer account, customer profile,
--                       customer account site, customer account site use, location association, ... for a ship to
--                       address.
--                       The ship to address (inventory location) will be set to be linked to a customer.  Order Entry
--                       will pick up the right ship to address and customer at a later time.
-- Version          : 1.0
--
-- Modification History
-- Person      Date         Comments
-- ---------   -----------  ------------------------------------------
-- iouyang     01-May-2001  New
--
------------------------------------------------------------------------------------------------------------------------

G_PKG_NAME  CONSTANT    VARCHAR2(30) := 'CSP_SHIP_TO_ADDRESS_PUB';
G_FILE_NAME CONSTANT    VARCHAR2(30) := 'cspvstab.pls';


--------------------------------------------------------------------------------
--
-- Procedure Name   : do_create_rs_cust_relation
-- Purpose          : Create a relationship between a resource and a customer
--                    in table csp_rs_cust_relations.
--
PROCEDURE do_rs_cust_relations
   (p_resource_type         IN VARCHAR2
   ,p_resource_id           IN NUMBER
   ,p_customer_id           IN NUMBER) IS

   l_rs_cust_relation_id   csp_rs_cust_relations.rs_cust_relation_id%TYPE := NULL;
   l_resource_type         csp_rs_cust_relations.resource_type%TYPE;
   l_resource_id           csp_rs_cust_relations.resource_id%TYPE;
   l_customer_id           csp_rs_cust_relations.customer_id%TYPE;
   l_CREATED_BY            number;
   l_CREATION_DATE         date;
   l_ATTRIBUTE_CATEGORY    varchar2(30);
   l_ATTRIBUTE1            varchar2(150);
   l_ATTRIBUTE2            varchar2(150);
   l_ATTRIBUTE3            varchar2(150);
   l_ATTRIBUTE4            varchar2(150);
   l_ATTRIBUTE5            varchar2(150);
   l_ATTRIBUTE6            varchar2(150);
   l_ATTRIBUTE7            varchar2(150);
   l_ATTRIBUTE8            varchar2(150);
   l_ATTRIBUTE9            varchar2(150);
   l_ATTRIBUTE10           varchar2(150);
   l_ATTRIBUTE11           varchar2(150);
   l_ATTRIBUTE12           varchar2(150);
   l_ATTRIBUTE13           varchar2(150);
   l_ATTRIBUTE14           varchar2(150);
   l_ATTRIBUTE15           varchar2(150);

   CURSOR l_rs_relation_csr IS
      select rs_cust_relation_id,
		customer_id,
created_by,
creation_date,
attribute_category,
attribute1,
attribute2,
attribute3,
attribute4,
attribute5,
attribute6,
attribute7,
attribute8,
attribute9,
attribute10,
attribute11,
attribute12,
attribute13,
attribute14,
attribute15
       from csp_rs_cust_relations
where resource_type = p_resource_type and resource_id = p_resource_id;

BEGIN
   csp_ship_to_address_pvt.g_rs_cust_relation_id := null;
   OPEN l_rs_relation_csr;
   FETCH l_rs_relation_csr INTO l_rs_cust_relation_id,
l_customer_id,
l_created_by,
l_creation_date,
l_attribute_category,
l_attribute1,
l_attribute2,
l_attribute3,
l_attribute4,
l_attribute5,
l_attribute6,
l_attribute7,
l_attribute8,
l_attribute9,
l_attribute10,
l_attribute11,
l_attribute12,
l_attribute13,
l_attribute14,
l_attribute15;
   IF l_rs_relation_csr%FOUND THEN
      CLOSE l_rs_relation_csr;
      IF l_customer_id IS NULL THEN
         csp_rs_cust_relations_pkg.update_row(
         p_RS_CUST_RELATION_ID      => l_rs_cust_relation_id,
         p_RESOURCE_TYPE            => p_resource_type,
         p_RESOURCE_ID              => p_resource_id,
         p_CUSTOMER_ID              => p_customer_id,
         p_CREATED_BY               => l_created_by,
         p_CREATION_DATE            => l_creation_date,
         p_LAST_UPDATED_BY          => nvl(fnd_global.user_id, 1),
         p_LAST_UPDATE_DATE         => sysdate,
         p_LAST_UPDATE_LOGIN        => nvl(fnd_global.user_id, 1),
         p_ATTRIBUTE_CATEGORY       => l_attribute_category,
         p_ATTRIBUTE1               => l_attribute1,
         p_ATTRIBUTE2               => l_attribute2,
         p_ATTRIBUTE3               => l_attribute3,
         p_ATTRIBUTE4               => l_attribute4,
         p_ATTRIBUTE5               => l_attribute5,
         p_ATTRIBUTE6               => l_attribute6,
         p_ATTRIBUTE7               => l_attribute7,
         p_ATTRIBUTE8               => l_attribute8,
         p_ATTRIBUTE9               => l_attribute9,
         p_ATTRIBUTE10              => l_attribute10,
         p_ATTRIBUTE11              => l_attribute11,
         p_ATTRIBUTE12              => l_attribute12,
         p_ATTRIBUTE13              => l_attribute13,
         p_ATTRIBUTE14              => l_attribute14,
         p_ATTRIBUTE15              => l_attribute15);
      END IF;
   ELSE
      CLOSE l_rs_relation_csr;
      csp_rs_cust_relations_pkg.insert_row(
         px_RS_CUST_RELATION_ID     => l_rs_cust_relation_id,
         p_RESOURCE_TYPE            => p_resource_type,
         p_RESOURCE_ID              => p_resource_id,
         p_CUSTOMER_ID              => p_customer_id,
         p_CREATED_BY               => nvl(fnd_global.user_id, 1),
         p_CREATION_DATE            => sysdate,
         p_LAST_UPDATED_BY          => nvl(fnd_global.user_id, 1),
         p_LAST_UPDATE_DATE         => sysdate,
         p_LAST_UPDATE_LOGIN        => nvl(fnd_global.user_id, 1),
         p_ATTRIBUTE_CATEGORY       => NULL,
         p_ATTRIBUTE1               => NULL,
         p_ATTRIBUTE2               => NULL,
         p_ATTRIBUTE3               => NULL,
         p_ATTRIBUTE4               => NULL,
         p_ATTRIBUTE5               => NULL,
         p_ATTRIBUTE6               => NULL,
         p_ATTRIBUTE7               => NULL,
         p_ATTRIBUTE8               => NULL,
         p_ATTRIBUTE9               => NULL,
         p_ATTRIBUTE10              => NULL,
         p_ATTRIBUTE11              => NULL,
         p_ATTRIBUTE12              => NULL,
         p_ATTRIBUTE13              => NULL,
         p_ATTRIBUTE14              => NULL,
         p_ATTRIBUTE15              => NULL);

   END IF;
         csp_ship_to_address_pvt.g_rs_cust_relation_id := l_rs_cust_relation_id;

END do_rs_cust_relations;



--------------------------------------------------------------------------------
--
-- Procedure Name   : do_create_ship_to_location
-- Purpose          : It takes location code, description, and address fields
--                    to create a new inventory location.
--                    Return location_id.
--
PROCEDURE do_create_ship_to_location
   (p_location_id            OUT NOCOPY NUMBER
   ,p_style                  IN VARCHAR2
   ,p_address_line_1         IN VARCHAR2
   ,p_address_line_2         IN VARCHAR2
   ,p_address_line_3         IN VARCHAR2
   ,p_country                IN VARCHAR2
   ,p_postal_code            IN VARCHAR2
   ,p_region_1               IN VARCHAR2
   ,p_region_2               IN VARCHAR2
   ,p_region_3               IN VARCHAR2
   ,p_town_or_city           IN VARCHAR2
   ,p_tax_name               IN VARCHAR2
   ,p_telephone_number_1     IN VARCHAR2
   ,p_telephone_number_2     IN VARCHAR2
   ,p_telephone_number_3     IN VARCHAR2
   ,p_loc_information13      IN VARCHAR2
   ,p_loc_information14      IN VARCHAR2
   ,p_loc_information15      IN VARCHAR2
   ,p_loc_information16      IN VARCHAR2
   ,p_loc_information17      IN VARCHAR2
   ,p_loc_information18      IN VARCHAR2
   ,p_loc_information19      IN VARCHAR2
   ,p_loc_information20      IN VARCHAR2
   ,p_attribute_category     IN VARCHAR2
   ,p_attribute1             IN VARCHAR2
   ,p_attribute2             IN VARCHAR2
   ,p_attribute3             IN VARCHAR2
   ,p_attribute4             IN VARCHAR2
   ,p_attribute5             IN VARCHAR2
   ,p_attribute6             IN VARCHAR2
   ,p_attribute7             IN VARCHAR2
   ,p_attribute8             IN VARCHAR2
   ,p_attribute9             IN VARCHAR2
   ,p_attribute10             IN VARCHAR2
   ,p_attribute11             IN VARCHAR2
   ,p_attribute12             IN VARCHAR2
   ,p_attribute13            IN VARCHAR2
   ,p_attribute14             IN VARCHAR2
   ,p_attribute15             IN VARCHAR2
   ,p_attribute16             IN VARCHAR2
   ,p_attribute17             IN VARCHAR2
   ,p_attribute18             IN VARCHAR2
   ,p_attribute19             IN VARCHAR2
   ,p_attribute20             IN VARCHAR2
   ,p_object_version_number  OUT NOCOPY NUMBER
   ,x_return_status          OUT NOCOPY VARCHAR2
   ,x_msg_count              OUT NOCOPY NUMBER
   ,x_msg_data               OUT NOCOPY VARCHAR2 ) IS

   l_api_version_number    CONSTANT NUMBER := 1.0;
   l_api_name              CONSTANT VARCHAR2(30) := 'do_create_ship_to_location';
   EXCP_USER_DEFINED       EXCEPTION;

   l_validate                   BOOLEAN := false;
   l_effective_date             DATE := sysdate;
   l_location_id                hr_locations_all.location_id%TYPE;
   l_language                   hr_locations_all_tl.language%TYPE;
   l_location_code              hr_locations_all.location_code%TYPE := NULL;
   l_description                hr_locations_all.description%TYPE := NULL;
   l_bill_to_site_flag          hr_locations_all.bill_to_site_flag%TYPE := 'Y';
   l_ship_to_site_flag          hr_locations_all.ship_to_site_flag%TYPE := 'Y';
   l_tp_header_id               hr_locations_all.tp_header_id%TYPE := NULL;
   l_ece_tp_location_code       hr_locations_all.ece_tp_location_code%TYPE := NULL;
   l_designated_receiver_id     hr_locations_all.designated_receiver_id%TYPE := NULL;
   l_in_organization_flag       hr_locations_all.in_organization_flag%TYPE := 'N';
   l_inactive_date              hr_locations_all.inactive_date%TYPE := NULL;
   l_operating_unit_id          NUMBER := NULL;
   l_inventory_organization_id  hr_locations_all.inventory_organization_id%TYPE := NULL;
   l_office_site_flag           hr_locations_all.office_site_flag%TYPE := 'N';
   l_receiving_site_flag        hr_locations_all.receiving_site_flag%TYPE := 'Y';
   l_ship_to_location_id        hr_locations_all.ship_to_location_id%TYPE := NULL;

   l_in_hr_loc_hook_rec   hr_location_record.location_rectype;
   l_out_hr_loc_hook_rec   hr_location_record.location_rectype;

BEGIN

    if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'Begin...');
    end if;

   SAVEPOINT do_create_ship_to_location_PUB;

   -- Initialize
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   select userenv('LANG') into l_language from dual;

    if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_language = ' || l_language);
    end if;

   -- Assign location code
   select csp_location_id_s1.NEXTVAL into l_location_code from dual;
   l_location_code := 'CSP' || l_location_code;

    if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_location_code = ' || l_location_code);
    end if;

   -- Default location description to address 1.
   --l_description := p_address_line_1;

   l_in_hr_loc_hook_rec.location_code := l_location_code;
   l_in_hr_loc_hook_rec.description := l_description;
   l_in_hr_loc_hook_rec.tp_header_id := l_tp_header_id;
   l_in_hr_loc_hook_rec.ece_tp_location_code := l_ece_tp_location_code;
   l_in_hr_loc_hook_rec.address_line_1 := p_address_line_1;
   l_in_hr_loc_hook_rec.address_line_2 := p_address_line_2;
   l_in_hr_loc_hook_rec.address_line_3 := p_address_line_3;
   l_in_hr_loc_hook_rec.bill_to_site_flag := l_bill_to_site_flag;
   l_in_hr_loc_hook_rec.country := p_country;
   l_in_hr_loc_hook_rec.designated_receiver_id := l_designated_receiver_id;
   l_in_hr_loc_hook_rec.in_organization_flag := l_in_organization_flag;
   l_in_hr_loc_hook_rec.inactive_date := l_inactive_date;
   l_in_hr_loc_hook_rec.inventory_organization_id := l_inventory_organization_id;
   l_in_hr_loc_hook_rec.office_site_flag := l_office_site_flag;
   l_in_hr_loc_hook_rec.postal_code := p_postal_code;
   l_in_hr_loc_hook_rec.receiving_site_flag := l_receiving_site_flag;
   l_in_hr_loc_hook_rec.region_1 := p_region_1;
   l_in_hr_loc_hook_rec.region_2 := p_region_2;
   l_in_hr_loc_hook_rec.region_3 := p_region_3;
   l_in_hr_loc_hook_rec.ship_to_location_id := l_ship_to_location_id;
   l_in_hr_loc_hook_rec.ship_to_site_flag := l_ship_to_site_flag;
   l_in_hr_loc_hook_rec.style := p_style;
   l_in_hr_loc_hook_rec.tax_name := p_tax_name;
   l_in_hr_loc_hook_rec.telephone_number_1 := p_telephone_number_1;
   l_in_hr_loc_hook_rec.telephone_number_2 := p_telephone_number_2;
   l_in_hr_loc_hook_rec.telephone_number_3 := p_telephone_number_3;
   l_in_hr_loc_hook_rec.town_or_city := p_town_or_city;
   l_in_hr_loc_hook_rec.loc_information13 := p_loc_information13;
   l_in_hr_loc_hook_rec.loc_information14 := p_loc_information14;
   l_in_hr_loc_hook_rec.loc_information15 := p_loc_information15;
   l_in_hr_loc_hook_rec.loc_information16 := p_loc_information16;
   l_in_hr_loc_hook_rec.loc_information17 := p_loc_information17;
   l_in_hr_loc_hook_rec.loc_information18 := p_loc_information18;
   l_in_hr_loc_hook_rec.loc_information19 := p_loc_information19;
   l_in_hr_loc_hook_rec.loc_information20 := p_loc_information20;
   l_in_hr_loc_hook_rec.attribute1 := p_attribute1;
   l_in_hr_loc_hook_rec.attribute2 := p_attribute2;
   l_in_hr_loc_hook_rec.attribute3 := p_attribute3;
   l_in_hr_loc_hook_rec.attribute4 := p_attribute4;
   l_in_hr_loc_hook_rec.attribute5 := p_attribute5;
   l_in_hr_loc_hook_rec.attribute6 := p_attribute6;
   l_in_hr_loc_hook_rec.attribute7 := p_attribute7;
   l_in_hr_loc_hook_rec.attribute8 := p_attribute8;
   l_in_hr_loc_hook_rec.attribute9 := p_attribute9;
   l_in_hr_loc_hook_rec.attribute10 := p_attribute10;
   l_in_hr_loc_hook_rec.attribute11 := p_attribute11;
   l_in_hr_loc_hook_rec.attribute12 := p_attribute12;
   l_in_hr_loc_hook_rec.attribute13 := p_attribute13;
   l_in_hr_loc_hook_rec.attribute14 := p_attribute14;
   l_in_hr_loc_hook_rec.attribute15 := p_attribute15;
   l_in_hr_loc_hook_rec.attribute16 := p_attribute16;
   l_in_hr_loc_hook_rec.attribute17 := p_attribute17;
   l_in_hr_loc_hook_rec.attribute18 := p_attribute18;
   l_in_hr_loc_hook_rec.attribute19 := p_attribute19;
   l_in_hr_loc_hook_rec.attribute20 := p_attribute20;
   l_in_hr_loc_hook_rec.attribute_category := p_attribute_category;

    if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'Before calling CSP_HR_LOC_CUST.user_hook...');
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_in_hr_loc_hook_rec.location_code = ' || l_in_hr_loc_hook_rec.location_code);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_in_hr_loc_hook_rec.description = ' || l_in_hr_loc_hook_rec.description);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_in_hr_loc_hook_rec.tp_header_id = ' || l_in_hr_loc_hook_rec.tp_header_id);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_in_hr_loc_hook_rec.ece_tp_location_code = ' || l_in_hr_loc_hook_rec.ece_tp_location_code);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_in_hr_loc_hook_rec.address_line_1 = ' || l_in_hr_loc_hook_rec.address_line_1);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_in_hr_loc_hook_rec.address_line_2 = ' || l_in_hr_loc_hook_rec.address_line_2);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_in_hr_loc_hook_rec.address_line_3 = ' || l_in_hr_loc_hook_rec.address_line_3);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_in_hr_loc_hook_rec.bill_to_site_flag = ' || l_in_hr_loc_hook_rec.bill_to_site_flag);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_in_hr_loc_hook_rec.country = ' || l_in_hr_loc_hook_rec.country);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_in_hr_loc_hook_rec.designated_receiver_id = ' || l_in_hr_loc_hook_rec.designated_receiver_id);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_in_hr_loc_hook_rec.in_organization_flag = ' || l_in_hr_loc_hook_rec.in_organization_flag);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_in_hr_loc_hook_rec.inactive_date = ' || l_in_hr_loc_hook_rec.inactive_date);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_in_hr_loc_hook_rec.inventory_organization_id = ' || l_in_hr_loc_hook_rec.inventory_organization_id);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_in_hr_loc_hook_rec.office_site_flag = ' || l_in_hr_loc_hook_rec.office_site_flag);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_in_hr_loc_hook_rec.postal_code = ' || l_in_hr_loc_hook_rec.postal_code);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_in_hr_loc_hook_rec.receiving_site_flag = ' || l_in_hr_loc_hook_rec.receiving_site_flag);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_in_hr_loc_hook_rec.region_1 = ' || l_in_hr_loc_hook_rec.region_1);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_in_hr_loc_hook_rec.region_2 = ' || l_in_hr_loc_hook_rec.region_2);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_in_hr_loc_hook_rec.region_3 = ' || l_in_hr_loc_hook_rec.region_3);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_in_hr_loc_hook_rec.ship_to_location_id = ' || l_in_hr_loc_hook_rec.ship_to_location_id);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_in_hr_loc_hook_rec.ship_to_site_flag = ' || l_in_hr_loc_hook_rec.ship_to_site_flag);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_in_hr_loc_hook_rec.style = ' || l_in_hr_loc_hook_rec.style);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_in_hr_loc_hook_rec.tax_name = ' || l_in_hr_loc_hook_rec.tax_name);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_in_hr_loc_hook_rec.telephone_number_1 = ' || l_in_hr_loc_hook_rec.telephone_number_1);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_in_hr_loc_hook_rec.telephone_number_2 = ' || l_in_hr_loc_hook_rec.telephone_number_2);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_in_hr_loc_hook_rec.telephone_number_3 = ' || l_in_hr_loc_hook_rec.telephone_number_3);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_in_hr_loc_hook_rec.town_or_city = ' || l_in_hr_loc_hook_rec.town_or_city);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_in_hr_loc_hook_rec.loc_information13 = ' || l_in_hr_loc_hook_rec.loc_information13);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_in_hr_loc_hook_rec.loc_information14 = ' || l_in_hr_loc_hook_rec.loc_information14);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_in_hr_loc_hook_rec.loc_information15 = ' || l_in_hr_loc_hook_rec.loc_information15);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_in_hr_loc_hook_rec.loc_information16 = ' || l_in_hr_loc_hook_rec.loc_information16);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_in_hr_loc_hook_rec.loc_information17 = ' || l_in_hr_loc_hook_rec.loc_information17);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_in_hr_loc_hook_rec.loc_information18 = ' || l_in_hr_loc_hook_rec.loc_information18);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_in_hr_loc_hook_rec.loc_information19 = ' || l_in_hr_loc_hook_rec.loc_information19);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_in_hr_loc_hook_rec.loc_information20 = ' || l_in_hr_loc_hook_rec.loc_information20);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_in_hr_loc_hook_rec.attribute1 = ' || l_in_hr_loc_hook_rec.attribute1);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_in_hr_loc_hook_rec.attribute2 = ' || l_in_hr_loc_hook_rec.attribute2);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_in_hr_loc_hook_rec.attribute3 = ' || l_in_hr_loc_hook_rec.attribute3);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_in_hr_loc_hook_rec.attribute4 = ' || l_in_hr_loc_hook_rec.attribute4);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_in_hr_loc_hook_rec.attribute5 = ' || l_in_hr_loc_hook_rec.attribute5);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_in_hr_loc_hook_rec.attribute6 = ' || l_in_hr_loc_hook_rec.attribute6);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_in_hr_loc_hook_rec.attribute7 = ' || l_in_hr_loc_hook_rec.attribute7);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_in_hr_loc_hook_rec.attribute8 = ' || l_in_hr_loc_hook_rec.attribute8);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_in_hr_loc_hook_rec.attribute9 = ' || l_in_hr_loc_hook_rec.attribute9);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_in_hr_loc_hook_rec.attribute10 = ' || l_in_hr_loc_hook_rec.attribute10);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_in_hr_loc_hook_rec.attribute11 = ' || l_in_hr_loc_hook_rec.attribute11);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_in_hr_loc_hook_rec.attribute12 = ' || l_in_hr_loc_hook_rec.attribute12);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_in_hr_loc_hook_rec.attribute13 = ' || l_in_hr_loc_hook_rec.attribute13);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_in_hr_loc_hook_rec.attribute14 = ' || l_in_hr_loc_hook_rec.attribute14);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_in_hr_loc_hook_rec.attribute15 = ' || l_in_hr_loc_hook_rec.attribute15);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_in_hr_loc_hook_rec.attribute16 = ' || l_in_hr_loc_hook_rec.attribute16);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_in_hr_loc_hook_rec.attribute17 = ' || l_in_hr_loc_hook_rec.attribute17);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_in_hr_loc_hook_rec.attribute18 = ' || l_in_hr_loc_hook_rec.attribute18);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_in_hr_loc_hook_rec.attribute19 = ' || l_in_hr_loc_hook_rec.attribute19);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_in_hr_loc_hook_rec.attribute20 = ' || l_in_hr_loc_hook_rec.attribute20);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_in_hr_loc_hook_rec.attribute_category = ' || l_in_hr_loc_hook_rec.attribute_category);
    end if;

    l_out_hr_loc_hook_rec := CSP_HR_LOC_CUST.user_hook(l_in_hr_loc_hook_rec);

    if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'After calling CSP_HR_LOC_CUST.user_hook...');
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_out_hr_loc_hook_rec.location_code = ' || l_out_hr_loc_hook_rec.location_code);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_out_hr_loc_hook_rec.description = ' || l_out_hr_loc_hook_rec.description);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_out_hr_loc_hook_rec.tp_header_id = ' || l_out_hr_loc_hook_rec.tp_header_id);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_out_hr_loc_hook_rec.ece_tp_location_code = ' || l_out_hr_loc_hook_rec.ece_tp_location_code);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_out_hr_loc_hook_rec.address_line_1 = ' || l_out_hr_loc_hook_rec.address_line_1);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_out_hr_loc_hook_rec.address_line_2 = ' || l_out_hr_loc_hook_rec.address_line_2);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_out_hr_loc_hook_rec.address_line_3 = ' || l_out_hr_loc_hook_rec.address_line_3);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_out_hr_loc_hook_rec.bill_to_site_flag = ' || l_out_hr_loc_hook_rec.bill_to_site_flag);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_out_hr_loc_hook_rec.country = ' || l_out_hr_loc_hook_rec.country);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_out_hr_loc_hook_rec.designated_receiver_id = ' || l_out_hr_loc_hook_rec.designated_receiver_id);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_out_hr_loc_hook_rec.in_organization_flag = ' || l_out_hr_loc_hook_rec.in_organization_flag);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_out_hr_loc_hook_rec.inactive_date = ' || l_out_hr_loc_hook_rec.inactive_date);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_out_hr_loc_hook_rec.inventory_organization_id = ' || l_out_hr_loc_hook_rec.inventory_organization_id);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_out_hr_loc_hook_rec.office_site_flag = ' || l_out_hr_loc_hook_rec.office_site_flag);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_out_hr_loc_hook_rec.postal_code = ' || l_out_hr_loc_hook_rec.postal_code);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_out_hr_loc_hook_rec.receiving_site_flag = ' || l_out_hr_loc_hook_rec.receiving_site_flag);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_out_hr_loc_hook_rec.region_1 = ' || l_out_hr_loc_hook_rec.region_1);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_out_hr_loc_hook_rec.region_2 = ' || l_out_hr_loc_hook_rec.region_2);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_out_hr_loc_hook_rec.region_3 = ' || l_out_hr_loc_hook_rec.region_3);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_out_hr_loc_hook_rec.ship_to_location_id = ' || l_out_hr_loc_hook_rec.ship_to_location_id);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_out_hr_loc_hook_rec.ship_to_site_flag = ' || l_out_hr_loc_hook_rec.ship_to_site_flag);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_out_hr_loc_hook_rec.style = ' || l_out_hr_loc_hook_rec.style);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_out_hr_loc_hook_rec.tax_name = ' || l_out_hr_loc_hook_rec.tax_name);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_out_hr_loc_hook_rec.telephone_number_1 = ' || l_out_hr_loc_hook_rec.telephone_number_1);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_out_hr_loc_hook_rec.telephone_number_2 = ' || l_out_hr_loc_hook_rec.telephone_number_2);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_out_hr_loc_hook_rec.telephone_number_3 = ' || l_out_hr_loc_hook_rec.telephone_number_3);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_out_hr_loc_hook_rec.town_or_city = ' || l_out_hr_loc_hook_rec.town_or_city);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_out_hr_loc_hook_rec.loc_information13 = ' || l_out_hr_loc_hook_rec.loc_information13);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_out_hr_loc_hook_rec.loc_information14 = ' || l_out_hr_loc_hook_rec.loc_information14);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_out_hr_loc_hook_rec.loc_information15 = ' || l_out_hr_loc_hook_rec.loc_information15);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_out_hr_loc_hook_rec.loc_information16 = ' || l_out_hr_loc_hook_rec.loc_information16);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_out_hr_loc_hook_rec.loc_information17 = ' || l_out_hr_loc_hook_rec.loc_information17);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_out_hr_loc_hook_rec.loc_information18 = ' || l_out_hr_loc_hook_rec.loc_information18);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_out_hr_loc_hook_rec.loc_information19 = ' || l_out_hr_loc_hook_rec.loc_information19);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_out_hr_loc_hook_rec.loc_information20 = ' || l_out_hr_loc_hook_rec.loc_information20);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_out_hr_loc_hook_rec.attribute1 = ' || l_out_hr_loc_hook_rec.attribute1);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_out_hr_loc_hook_rec.attribute2 = ' || l_out_hr_loc_hook_rec.attribute2);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_out_hr_loc_hook_rec.attribute3 = ' || l_out_hr_loc_hook_rec.attribute3);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_out_hr_loc_hook_rec.attribute4 = ' || l_out_hr_loc_hook_rec.attribute4);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_out_hr_loc_hook_rec.attribute5 = ' || l_out_hr_loc_hook_rec.attribute5);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_out_hr_loc_hook_rec.attribute6 = ' || l_out_hr_loc_hook_rec.attribute6);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_out_hr_loc_hook_rec.attribute7 = ' || l_out_hr_loc_hook_rec.attribute7);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_out_hr_loc_hook_rec.attribute8 = ' || l_out_hr_loc_hook_rec.attribute8);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_out_hr_loc_hook_rec.attribute9 = ' || l_out_hr_loc_hook_rec.attribute9);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_out_hr_loc_hook_rec.attribute10 = ' || l_out_hr_loc_hook_rec.attribute10);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_out_hr_loc_hook_rec.attribute11 = ' || l_out_hr_loc_hook_rec.attribute11);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_out_hr_loc_hook_rec.attribute12 = ' || l_out_hr_loc_hook_rec.attribute12);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_out_hr_loc_hook_rec.attribute13 = ' || l_out_hr_loc_hook_rec.attribute13);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_out_hr_loc_hook_rec.attribute14 = ' || l_out_hr_loc_hook_rec.attribute14);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_out_hr_loc_hook_rec.attribute15 = ' || l_out_hr_loc_hook_rec.attribute15);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_out_hr_loc_hook_rec.attribute16 = ' || l_out_hr_loc_hook_rec.attribute16);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_out_hr_loc_hook_rec.attribute17 = ' || l_out_hr_loc_hook_rec.attribute17);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_out_hr_loc_hook_rec.attribute18 = ' || l_out_hr_loc_hook_rec.attribute18);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_out_hr_loc_hook_rec.attribute19 = ' || l_out_hr_loc_hook_rec.attribute19);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_out_hr_loc_hook_rec.attribute20 = ' || l_out_hr_loc_hook_rec.attribute20);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'l_out_hr_loc_hook_rec.attribute_category = ' || l_out_hr_loc_hook_rec.attribute_category);
    end if;

    if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'Before calling hr_location_api.create_location...');
    end if;

   hr_location_api.create_location(
      p_effective_date              => l_effective_date,
      p_location_code               => l_location_code,
      p_description                 => l_description,
      p_tp_header_id                => l_tp_header_id,
      p_ece_tp_location_code        => l_ece_tp_location_code,
      p_address_line_1              => p_address_line_1,
      p_address_line_2              => p_address_line_2,
      p_address_line_3              => p_address_line_3,
      p_bill_to_site_flag           => l_bill_to_site_flag,
      p_country                     => p_country,
      p_designated_receiver_id      => l_designated_receiver_id,
      p_in_organization_flag        => l_in_organization_flag,
      p_inactive_date               => l_inactive_date,
      p_operating_unit_id           => l_operating_unit_id,
      p_inventory_organization_id   => l_inventory_organization_id,
      p_office_site_flag            => l_office_site_flag,
      p_postal_code                 => p_postal_code,
      p_receiving_site_flag         => l_receiving_site_flag,
      p_region_1                    => p_region_1,
      p_region_2                    => p_region_2,
      p_region_3                    => p_region_3,
      p_ship_to_location_id         => l_ship_to_location_id,
      p_ship_to_site_flag           => l_ship_to_site_flag,
      p_style                       => p_style,
      p_tax_name                    => p_tax_name,
      p_telephone_number_1          => p_telephone_number_1,
      p_telephone_number_2          => p_telephone_number_2,
      p_telephone_number_3          => p_telephone_number_3,
      p_town_or_city                => p_town_or_city,
      p_loc_information13           => p_loc_information13,
      p_loc_information14           => p_loc_information14,
      p_loc_information15           => p_loc_information15,
      p_loc_information16           => p_loc_information16,
      p_loc_information17           => p_loc_information17,
      p_loc_information18           => p_loc_information18,
      p_loc_information19           => p_loc_information19,
      p_loc_information20           => p_loc_information20,
      p_location_id                 => p_location_id,
      p_object_version_number       => p_object_version_number,
      p_attribute1                  => l_out_hr_loc_hook_rec.attribute1,
      p_attribute2                  => l_out_hr_loc_hook_rec.attribute2,
      p_attribute3                  => l_out_hr_loc_hook_rec.attribute3,
      p_attribute4                  => l_out_hr_loc_hook_rec.attribute4,
      p_attribute5                  => l_out_hr_loc_hook_rec.attribute5,
      p_attribute6                  => l_out_hr_loc_hook_rec.attribute6,
      p_attribute7                  => l_out_hr_loc_hook_rec.attribute7,
      p_attribute8                  => l_out_hr_loc_hook_rec.attribute8,
      p_attribute9                  => l_out_hr_loc_hook_rec.attribute9,
      p_attribute10                  => l_out_hr_loc_hook_rec.attribute10,
      p_attribute11                  => l_out_hr_loc_hook_rec.attribute11,
      p_attribute12                  => l_out_hr_loc_hook_rec.attribute12,
      p_attribute13                  => l_out_hr_loc_hook_rec.attribute13,
      p_attribute14                  => l_out_hr_loc_hook_rec.attribute14,
      p_attribute15                  => l_out_hr_loc_hook_rec.attribute15,
      p_attribute16                  => l_out_hr_loc_hook_rec.attribute16,
      p_attribute17                  => l_out_hr_loc_hook_rec.attribute17,
      p_attribute18                  => l_out_hr_loc_hook_rec.attribute18,
      p_attribute19                  => l_out_hr_loc_hook_rec.attribute19,
      p_attribute20                  => l_out_hr_loc_hook_rec.attribute20,
      p_attribute_category          => l_out_hr_loc_hook_rec.attribute_category
   );

    if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'After calling hr_location_api.create_location...');
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'x_msg_count=' || x_msg_count || ', x_msg_data=' || x_msg_data);
    end if;

   fnd_msg_pub.count_and_get
      ( p_count => x_msg_count
      , p_data  => x_msg_data);

    if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                  'x_msg_count=' || x_msg_count || ', x_msg_data=' || x_msg_data);
    end if;

   -- Exception Block
   EXCEPTION
      WHEN EXCP_USER_DEFINED THEN

          if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
             FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                        'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                        'In EXCP_USER_DEFINED block');
          end if;

         Rollback to do_create_ship_to_location_PUB;
         x_return_status := FND_API.G_RET_STS_ERROR;
         JTF_PLSQL_API.HANDLE_EXCEPTIONS(
            P_API_NAME => L_API_NAME
           ,P_PKG_NAME => G_PKG_NAME
           ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
           ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PUB
           ,X_MSG_COUNT    => x_MSG_COUNT
           ,X_MSG_DATA     => x_MSG_DATA
           ,X_RETURN_STATUS => x_RETURN_STATUS);
      WHEN FND_API.G_EXC_ERROR THEN

          if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
             FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                        'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                        'In FND_API.G_EXC_ERROR block');
          end if;

         JTF_PLSQL_API.HANDLE_EXCEPTIONS(
            P_API_NAME => L_API_NAME
           ,P_PKG_NAME => G_PKG_NAME
           ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
           ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PUB
           ,X_MSG_COUNT    => x_MSG_COUNT
           ,X_MSG_DATA     => x_MSG_DATA
           ,X_RETURN_STATUS => x_RETURN_STATUS);
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

          if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
             FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                        'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                        'In FND_API.G_EXC_UNEXPECTED_ERROR block');
          end if;

         JTF_PLSQL_API.HANDLE_EXCEPTIONS(
            P_API_NAME => L_API_NAME
           ,P_PKG_NAME => G_PKG_NAME
           ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
           ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PUB
           ,X_MSG_COUNT    => x_MSG_COUNT
           ,X_MSG_DATA     => x_MSG_DATA
           ,X_RETURN_STATUS => x_RETURN_STATUS);
      WHEN OTHERS THEN

          if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
             FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                        'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                        'In OTHERS block');
             FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                        'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.do_create_ship_to_location',
                        'sqlerrm = ' || sqlerrm);
          end if;

         Rollback to do_create_ship_to_location_PUB;
         FND_MESSAGE.SET_NAME('CSP', 'CSP_UNEXPECTED_EXEC_ERRORS');
         FND_MESSAGE.SET_TOKEN('ROUTINE', l_api_name, false);
         FND_MESSAGE.SET_TOKEN('SQLERRM', sqlerrm, false);
         FND_MSG_PUB.ADD;
         fnd_msg_pub.count_and_get
           ( p_count => x_msg_count
           , p_data  => x_msg_data);
         x_return_status := FND_API.G_RET_STS_ERROR;

END do_create_ship_to_location;


--------------------------------------------------------------------------------
--
-- Procedure Name   : do_update_ship_to_location
-- Purpose          : It updates the address fields based on the location id
--                    passed in.
--
PROCEDURE do_update_ship_to_location
   (p_location_id            IN NUMBER
   ,p_style                  IN VARCHAR2
   ,p_address_line_1         IN VARCHAR2
   ,p_address_line_2         IN VARCHAR2
   ,p_address_line_3         IN VARCHAR2
   ,p_country                IN VARCHAR2
   ,p_postal_code            IN VARCHAR2
   ,p_region_1               IN VARCHAR2
   ,p_region_2               IN VARCHAR2
   ,p_region_3               IN VARCHAR2
   ,p_town_or_city           IN VARCHAR2
   ,p_tax_name               IN VARCHAR2
   ,p_telephone_number_1     IN VARCHAR2
   ,p_telephone_number_2     IN VARCHAR2
   ,p_telephone_number_3     IN VARCHAR2
   ,p_loc_information13      IN VARCHAR2
   ,p_loc_information14      IN VARCHAR2
   ,p_loc_information15      IN VARCHAR2
   ,p_loc_information16      IN VARCHAR2
   ,p_loc_information17      IN VARCHAR2
   ,p_loc_information18      IN VARCHAR2
   ,p_loc_information19      IN VARCHAR2
   ,p_loc_information20      IN VARCHAR2
   ,p_attribute_category     IN VARCHAR2
   ,p_attribute1             IN VARCHAR2
   ,p_attribute2             IN VARCHAR2
   ,p_attribute3             IN VARCHAR2
   ,p_attribute4             IN VARCHAR2
   ,p_attribute5             IN VARCHAR2
   ,p_attribute6             IN VARCHAR2
   ,p_attribute7             IN VARCHAR2
   ,p_attribute8             IN VARCHAR2
   ,p_attribute9             IN VARCHAR2
   ,p_attribute10             IN VARCHAR2
   ,p_attribute11             IN VARCHAR2
   ,p_attribute12             IN VARCHAR2
   ,p_attribute13            IN VARCHAR2
   ,p_attribute14             IN VARCHAR2
   ,p_attribute15             IN VARCHAR2
   ,p_attribute16             IN VARCHAR2
   ,p_attribute17             IN VARCHAR2
   ,p_attribute18             IN VARCHAR2
   ,p_attribute19             IN VARCHAR2
   ,p_attribute20             IN VARCHAR2
   ,p_object_version_number  IN OUT NOCOPY NUMBER
   ,x_return_status          OUT NOCOPY VARCHAR2
   ,x_msg_count              OUT NOCOPY NUMBER
   ,x_msg_data               OUT NOCOPY VARCHAR2 ) IS

   l_api_version_number         CONSTANT NUMBER := 1.0;
   l_api_name                   CONSTANT VARCHAR2(30) := 'do_update_ship_to_location';
   l_language                   VARCHAR2(4);
   EXCP_USER_DEFINED            EXCEPTION;

   l_object_version_number      hr_locations_all.object_version_number%TYPE := NULL;

BEGIN
     SAVEPOINT do_update_ship_to_location_PUB;

   -- initialize
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   select userenv('LANG') into l_language from dual;

/*   OPEN l_inv_location_csr;
   FETCH l_inv_location_csr INTO
l_location_code,
l_tp_header_id,
l_ece_tp_location_code,
l_bill_to_site_flag,
l_designated_receiver_id,
l_in_organization_flag,
l_inactive_date,
l_inventory_organization_id,
l_office_site_flag,
l_receiving_site_flag,
l_ship_to_location_id,
l_ship_to_site_flag,
l_attribute_category,
l_attribute1,
l_attribute2,
l_attribute3,
l_attribute4,
l_attribute5,
l_attribute6,
l_attribute7,
l_attribute8,
l_attribute9,
l_attribute10,
l_attribute11,
l_attribute12,
l_attribute13,
l_attribute14,
l_attribute15,
l_attribute16,
l_attribute17,
l_attribute18,
l_attribute19,
l_attribute20,
l_global_attribute_category,
l_global_attribute1,
l_global_attribute2,
l_global_attribute3,
l_global_attribute4,
l_global_attribute5,
l_global_attribute6,
l_global_attribute7,
l_global_attribute8,
l_global_attribute9,
l_global_attribute10,
l_global_attribute11,
l_global_attribute12,
l_global_attribute13,
l_global_attribute14,
l_global_attribute15,
l_global_attribute16,
l_global_attribute17,
l_global_attribute18,
l_global_attribute19,
l_global_attribute20,
l_object_version_number;
   IF l_inv_location_csr%NOTFOUND THEN
      CLOSE l_inv_location_csr;
      FND_MESSAGE.SET_NAME ('CSP', 'CSP_INV_LOC_NOT_FOUND');
      FND_MESSAGE.SET_TOKEN('TSK_ASSGN_ID', p_location_id, TRUE);
      FND_MSG_PUB.ADD;
      RAISE EXCP_USER_DEFINED;
   END IF;
   CLOSE l_inv_location_csr;

   -- Default location description to address 1.
   l_description := p_address_line_1;
*/
   l_object_version_number := p_object_version_number;

   hr_location_api.update_location
     (p_validate                    => false,
      p_effective_date              => sysdate,
--      p_language_code               => l_language,
      p_location_id                 => p_location_id,
--      p_location_code               => l_location_code,
      p_description                 => p_address_line_1,
--      p_tp_header_id                => l_tp_header_id,
--      p_ece_tp_location_code        => l_ece_tp_location_code,
      p_address_line_1              => p_address_line_1,
      p_address_line_2              => p_address_line_2,
      p_address_line_3              => p_address_line_3,
--      p_bill_to_site_flag           => l_bill_to_site_flag,
      p_country                     => p_country,
--      p_designated_receiver_id      => l_designated_receiver_id,
--      p_in_organization_flag        => l_in_organization_flag,
--      p_inactive_date               => l_inactive_date,
--      p_operating_unit_id           => l_operating_unit_id,
--      p_inventory_organization_id   => l_inventory_organization_id,
--      p_office_site_flag            => l_office_site_flag,
      p_postal_code                 => p_postal_code,
--      p_receiving_site_flag         => l_receiving_site_flag,
      p_region_1                    => p_region_1,
      p_region_2                    => p_region_2,
      p_region_3                    => p_region_3,
--      p_ship_to_location_id         => l_ship_to_location_id,
--      p_ship_to_site_flag           => l_ship_to_site_flag,
      p_style                       => p_style,
      p_tax_name                    => p_tax_name,
      p_telephone_number_1          => p_telephone_number_1,
      p_telephone_number_2          => p_telephone_number_2,
      p_telephone_number_3          => p_telephone_number_3,
      p_town_or_city                => p_town_or_city,
      p_loc_information13           => p_loc_information13,
      p_loc_information14           => p_loc_information14,
      p_loc_information15           => p_loc_information15,
      p_loc_information16           => p_loc_information16,
      p_loc_information17           => p_loc_information17,
      p_loc_information18           => p_loc_information18,
      p_loc_information19           => p_loc_information19,
      p_loc_information20           => p_loc_information20,
      p_object_version_number       => l_object_version_number,
      p_attribute1                  => p_attribute1,
      p_attribute2                  => p_attribute2,
      p_attribute3                  => p_attribute3,
      p_attribute4                  => p_attribute4,
      p_attribute5                  => p_attribute5,
      p_attribute6                  => p_attribute6,
      p_attribute7                  => p_attribute7,
      p_attribute8                  => p_attribute8,
      p_attribute9                  => p_attribute9,
      p_attribute10                  => p_attribute10,
      p_attribute11                  => p_attribute11,
      p_attribute12                  => p_attribute12,
      p_attribute13                  => p_attribute13,
      p_attribute14                  => p_attribute14,
      p_attribute15                  => p_attribute15,
      p_attribute16                  => p_attribute16,
      p_attribute17                  => p_attribute17,
      p_attribute18                  => p_attribute18,
      p_attribute19                  => p_attribute19,
      p_attribute20                  => p_attribute20,
      p_attribute_category          => p_attribute_category
   );

   p_object_version_number := l_object_version_number;
   fnd_msg_pub.count_and_get
      ( p_count => x_msg_count
      , p_data  => x_msg_data);

   -- Exception Block
   EXCEPTION
      WHEN EXCP_USER_DEFINED THEN
         Rollback to do_update_ship_to_location_PUB;
         x_return_status := FND_API.G_RET_STS_ERROR;
         JTF_PLSQL_API.HANDLE_EXCEPTIONS(
            P_API_NAME => L_API_NAME
           ,P_PKG_NAME => G_PKG_NAME
           ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
           ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PUB
           ,X_MSG_COUNT    => x_MSG_COUNT
           ,X_MSG_DATA     => x_MSG_DATA
           ,X_RETURN_STATUS => x_RETURN_STATUS);
      WHEN FND_API.G_EXC_ERROR THEN
         JTF_PLSQL_API.HANDLE_EXCEPTIONS(
            P_API_NAME => L_API_NAME
           ,P_PKG_NAME => G_PKG_NAME
           ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
           ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PUB
           ,X_MSG_COUNT    => x_MSG_COUNT
           ,X_MSG_DATA     => x_MSG_DATA
           ,X_RETURN_STATUS => x_RETURN_STATUS);
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         JTF_PLSQL_API.HANDLE_EXCEPTIONS(
            P_API_NAME => L_API_NAME
           ,P_PKG_NAME => G_PKG_NAME
           ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
           ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PUB
           ,X_MSG_COUNT    => x_MSG_COUNT
           ,X_MSG_DATA     => x_MSG_DATA
           ,X_RETURN_STATUS => x_RETURN_STATUS);
      WHEN OTHERS THEN
         Rollback to do_update_ship_to_location_PUB;
         FND_MESSAGE.SET_NAME('CSP', 'CSP_UNEXPECTED_EXEC_ERRORS');
         FND_MESSAGE.SET_TOKEN('ROUTINE', l_api_name, false);
         FND_MESSAGE.SET_TOKEN('SQLERRM', sqlerrm, false);
         FND_MSG_PUB.ADD;
         fnd_msg_pub.count_and_get
           ( p_count => x_msg_count
           , p_data  => x_msg_data);
         x_return_status := FND_API.G_RET_STS_ERROR;

END do_update_ship_to_location;



------------------------------------------------------------------------------------------
-- Procedure Name   : do_create_site_use
-- Purpose          : It will create a ship to site use that link to
--                    an inventory location.
--
PROCEDURE do_create_site_use
   (p_customer_id            IN NUMBER
   ,p_party_id               IN NUMBER
   ,p_address_id             IN NUMBER
   ,p_location_id            IN NUMBER
   ,p_inv_location_id        IN NUMBER
   ,p_primary_flag           IN VARCHAR2
   ,p_status                 IN VARCHAR2
   ,p_bill_to_create		  IN VARCHAR2 := 'Y'
   ,x_return_status          OUT NOCOPY VARCHAR2
   ,x_msg_count              OUT NOCOPY NUMBER
   ,x_msg_data               OUT NOCOPY VARCHAR2 ) IS

   l_api_version_number      CONSTANT NUMBER := 1.0;
   l_api_name                CONSTANT VARCHAR2(30) := 'do_create_site_use';
   l_language                VARCHAR2(4);
   EXCP_USER_DEFINED         EXCEPTION;

   s_location_id             hr_locations.location_id%TYPE := p_location_id;
   s_site_use_id             hz_cust_site_uses_all.site_use_id%TYPE := NULL;
   b_site_use_id             hz_cust_site_uses_all.site_use_id%TYPE := NULL;
   s_primary_flag            hz_cust_site_uses_all.primary_flag%TYPE := NULL;
   s_status                  hz_cust_site_uses_all.status%TYPE := NULL;

   CURSOR l_primary_party_site_use_csr IS
      select primary_per_type
from hz_party_site_uses
where site_use_type = 'SHIP_TO'
and primary_per_type = 'Y'
and (party_site_id in
(select party_site_id
from hz_party_sites where party_id = p_party_id and status = 'A'));

cursor cr_get_primary_bill_to_id (v_address_id number) is
select site_use_id
from HZ_CUST_SITE_USES
where cust_acct_site_id in (
  select hsc1.cust_acct_site_id
  from hz_cust_acct_sites hsc1, hz_cust_acct_sites hsc2
  where hsc1.cust_account_id = hsc2.cust_account_id
  and hsc2.cust_acct_site_id = v_address_id
  and hsc1.cust_acct_site_id <> v_address_id
)
and primary_flag = 'Y'
and status = 'A';

BEGIN
   SAVEPOINT do_create_site_use_PUB;

   IF p_primary_flag IS NULL THEN
      -- Check if there is an existing primary ship to party site use
      -- Set the primary_per_type to 'Y' only if there is no existing one
      OPEN l_primary_party_site_use_csr;
      FETCH l_primary_party_site_use_csr INTO s_primary_flag;
      IF l_primary_party_site_use_csr%NOTFOUND THEN
         CLOSE l_primary_party_site_use_csr;
         s_primary_flag := 'Y';
      ELSE
         CLOSE l_primary_party_site_use_csr;
         s_primary_flag := 'N';
      END IF;
   ELSE
      s_primary_flag := p_primary_flag;
   END IF;

   IF p_status IS NULL THEN
      s_status := 'A';
   ELSE
      s_status := p_status;
   END IF;

   s_location_id := null;

   -- Create Bill To site use first for billing purpose.
   b_site_use_id := null;
   if nvl(p_bill_to_create, 'Y') <> 'Y' then
		open cr_get_primary_bill_to_id(p_address_id);
		fetch cr_get_primary_bill_to_id into b_site_use_id;
		close cr_get_primary_bill_to_id;
   end if;

   if b_site_use_id is null then
   arh_csu_pkg.Insert_Row(
         X_Site_Use_Id                  => b_site_use_id,
         X_Last_Update_Date             => sysdate,
         X_Last_Updated_By              => nvl(fnd_global.user_id,1),
         X_Creation_Date                => sysdate,
         X_Created_By                   => nvl(fnd_global.user_id,1),
         X_Site_Use_Code                => 'BILL_TO',
         x_customer_id	                => p_customer_id,
         X_Address_Id                   => p_address_id,
         X_Primary_Flag                 => 'N',
         X_Status                       => 'A',
         X_Location                     => s_location_id,
         X_Last_Update_Login            => nvl(fnd_global.user_id,1),
         X_Contact_Id                   => null,
         X_Bill_To_Site_Use_Id          => null,
         X_Sic_Code                     => null,
         X_Payment_Term_Id              => null,
         X_Gsa_Indicator                => 'N',
         X_Ship_Partial                 => 'N',
         X_Ship_Via                     => null,
         X_Fob_Point                    => null,
         X_Order_Type_Id                => null,
         X_Price_List_Id                => null,
         X_Freight_Term                 => null,
         X_Warehouse_Id                 => null,
         X_Territory_Id                 => null,
         X_Tax_Code                     => null,
         X_Tax_Reference                => null,
         X_Demand_Class_Code            => null,
         x_inventory_location_id        => null,
         x_inventory_organization_id    => null,
         X_Attribute_Category           => null,
         X_Attribute1                   => null,
         X_Attribute2                   => null,
         X_Attribute3                   => null,
         X_Attribute4                   => null,
         X_Attribute5                   => null,
         X_Attribute6                   => null,
         X_Attribute7                   => null,
         X_Attribute8                   => null,
         X_Attribute9                   => null,
         X_Attribute10                  => null,
         X_Attribute11                  => null,
         X_Attribute12                  => null,
         X_Attribute13                  => null,
         X_Attribute14                  => null,
         X_Attribute15                  => null,
         X_Attribute16                  => null,
         X_Attribute17                  => null,
         X_Attribute18                  => null,
         X_Attribute19                  => null,
         X_Attribute20                  => null,
         X_Attribute21                  => null,
         X_Attribute22                  => null,
         X_Attribute23                  => null,
         X_Attribute24                  => null,
         X_Attribute25                  => null,
         X_Tax_Classification           => null,
         X_Tax_Header_Level_Flag        => null,
         X_Tax_Rounding_Rule            => null,
         X_Global_Attribute_Category    => null,
         X_Global_Attribute1            => null,
         X_Global_Attribute2            => null,
         X_Global_Attribute3            => null,
         X_Global_Attribute4            => null,
         X_Global_Attribute5            => null,
         X_Global_Attribute6            => null,
         X_Global_Attribute7            => null,
         X_Global_Attribute8            => null,
         X_Global_Attribute9            => null,
         X_Global_Attribute10           => null,
         X_Global_Attribute11           => null,
         X_Global_Attribute12           => null,
         X_Global_Attribute13           => null,
         X_Global_Attribute14           => null,
         X_Global_Attribute15           => null,
         X_Global_Attribute16           => null,
         X_Global_Attribute17           => null,
         X_Global_Attribute18           => null,
         X_Global_Attribute19           => null,
         X_Global_Attribute20           => null,
         X_Primary_Salesrep_Id          => null,
         X_Finchrg_Receivables_Trx_Id   => null,
         X_GL_ID_Rec                    => null,
         X_GL_ID_Rev                    => null,
         X_GL_ID_Tax                    => null,
         X_GL_ID_Freight                => null,
         X_GL_ID_Clearing               => null,
         X_GL_ID_Unbilled               => null,
         X_GL_ID_Unearned               => null,
         X_GL_ID_Unpaid_rec             => null,
         X_GL_ID_remittance             => null,
         X_GL_ID_factor                 => null,
         X_DATES_NEGATIVE_TOLERANCE     => null,
         X_DATES_POSITIVE_TOLERANCE     => null,
         X_DATE_TYPE_PREFERENCE         => null,
         X_OVER_SHIPMENT_TOLERANCE      => null,
         X_UNDER_SHIPMENT_TOLERANCE     => null,
         X_ITEM_CROSS_REF_PREF          => null,
         X_OVER_RETURN_TOLERANCE        => null,
         X_UNDER_RETURN_TOLERANCE       => null,
         X_SHIP_SETS_INCLUDE_LINES_FLAG => 'N',
         X_ARRIVALSETS_INCL_LINES_FLAG  => 'N',
         X_SCHED_DATE_PUSH_FLAG         => 'N',
         X_INVOICE_QUANTITY_RULE        => null,
         x_msg_count                    => x_msg_count,
         x_msg_data                     => x_msg_data,
         x_return_status                => x_return_status);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         Rollback to do_create_site_use_PUB;
         /*FND_MESSAGE.SET_NAME ('CSP', 'CSP_SITE_USE_API_ERROR');
         FND_MESSAGE.SET_TOKEN ('TEXT', x_msg_data);
         FND_MSG_PUB.ADD;*/
         RAISE EXCP_USER_DEFINED;
      END IF;
     END IF;
      s_location_id := null;

   -- Create Ship To site use to link to the inventory location and link the bill to location to the bill to site.
   arh_csu_pkg.Insert_Row(
         X_Site_Use_Id                  => s_site_use_id,
         X_Last_Update_Date             => sysdate,
         X_Last_Updated_By              => nvl(fnd_global.user_id,1),
         X_Creation_Date                => sysdate,
         X_Created_By                   => nvl(fnd_global.user_id,1),
         X_Site_Use_Code                => 'SHIP_TO',
         x_customer_id	                => p_customer_id,
         X_Address_Id                   => p_address_id,
         X_Primary_Flag                 => s_primary_flag,
         X_Status                       => s_status,
         X_Location                     => s_location_id,
         X_Last_Update_Login            => nvl(fnd_global.user_id,1),
         X_Contact_Id                   => null,
--         X_Bill_To_Site_Use_Id          => null,
         X_Bill_To_Site_Use_Id          => b_site_use_id,
         X_Sic_Code                     => null,
         X_Payment_Term_Id              => null,
         X_Gsa_Indicator                => 'N',
         X_Ship_Partial                 => 'N',
         X_Ship_Via                     => null,
         X_Fob_Point                    => null,
         X_Order_Type_Id                => null,
         X_Price_List_Id                => null,
         X_Freight_Term                 => null,
         X_Warehouse_Id                 => null,
         X_Territory_Id                 => null,
         X_Tax_Code                     => null,
         X_Tax_Reference                => null,
         X_Demand_Class_Code            => null,
         x_inventory_location_id        => p_inv_location_id,
         x_inventory_organization_id    => null,
         X_Attribute_Category           => null,
         X_Attribute1                   => null,
         X_Attribute2                   => null,
         X_Attribute3                   => null,
         X_Attribute4                   => null,
         X_Attribute5                   => null,
         X_Attribute6                   => null,
         X_Attribute7                   => null,
         X_Attribute8                   => null,
         X_Attribute9                   => null,
         X_Attribute10                  => null,
         X_Attribute11                  => null,
         X_Attribute12                  => null,
         X_Attribute13                  => null,
         X_Attribute14                  => null,
         X_Attribute15                  => null,
         X_Attribute16                  => null,
         X_Attribute17                  => null,
         X_Attribute18                  => null,
         X_Attribute19                  => null,
         X_Attribute20                  => null,
         X_Attribute21                  => null,
         X_Attribute22                  => null,
         X_Attribute23                  => null,
         X_Attribute24                  => null,
         X_Attribute25                  => null,
         X_Tax_Classification           => null,
         X_Tax_Header_Level_Flag        => null,
         X_Tax_Rounding_Rule            => null,
         X_Global_Attribute_Category    => null,
         X_Global_Attribute1            => null,
         X_Global_Attribute2            => null,
         X_Global_Attribute3            => null,
         X_Global_Attribute4            => null,
         X_Global_Attribute5            => null,
         X_Global_Attribute6            => null,
         X_Global_Attribute7            => null,
         X_Global_Attribute8            => null,
         X_Global_Attribute9            => null,
         X_Global_Attribute10           => null,
         X_Global_Attribute11           => null,
         X_Global_Attribute12           => null,
         X_Global_Attribute13           => null,
         X_Global_Attribute14           => null,
         X_Global_Attribute15           => null,
         X_Global_Attribute16           => null,
         X_Global_Attribute17           => null,
         X_Global_Attribute18           => null,
         X_Global_Attribute19           => null,
         X_Global_Attribute20           => null,
         X_Primary_Salesrep_Id          => null,
         X_Finchrg_Receivables_Trx_Id   => null,
         X_GL_ID_Rec                    => null,
         X_GL_ID_Rev                    => null,
         X_GL_ID_Tax                    => null,
         X_GL_ID_Freight                => null,
         X_GL_ID_Clearing               => null,
         X_GL_ID_Unbilled               => null,
         X_GL_ID_Unearned               => null,
         X_GL_ID_Unpaid_rec             => null,
         X_GL_ID_remittance             => null,
         X_GL_ID_factor                 => null,
         X_DATES_NEGATIVE_TOLERANCE     => null,
         X_DATES_POSITIVE_TOLERANCE     => null,
         X_DATE_TYPE_PREFERENCE         => null,
         X_OVER_SHIPMENT_TOLERANCE      => null,
         X_UNDER_SHIPMENT_TOLERANCE     => null,
         X_ITEM_CROSS_REF_PREF          => null,
         X_OVER_RETURN_TOLERANCE        => null,
         X_UNDER_RETURN_TOLERANCE       => null,
         X_SHIP_SETS_INCLUDE_LINES_FLAG => 'N',
         X_ARRIVALSETS_INCL_LINES_FLAG  => 'N',
         X_SCHED_DATE_PUSH_FLAG         => 'N',
         X_INVOICE_QUANTITY_RULE        => null,
         x_msg_count                    => x_msg_count,
         x_msg_data                     => x_msg_data,
         x_return_status                => x_return_status);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         Rollback to do_create_site_use_PUB;
        /*FND_MESSAGE.SET_NAME ('CSP', 'CSP_SITE_USE_API_ERROR');
         FND_MESSAGE.SET_TOKEN ('TEXT', x_msg_data);
         FND_MSG_PUB.ADD;*/
         RAISE EXCP_USER_DEFINED;
      END IF;

   -- Exception Block
   EXCEPTION
      WHEN EXCP_USER_DEFINED THEN
         Rollback to do_create_site_use_PUB;
         x_return_status := FND_API.G_RET_STS_ERROR;
         JTF_PLSQL_API.HANDLE_EXCEPTIONS(
            P_API_NAME => L_API_NAME
           ,P_PKG_NAME => G_PKG_NAME
           ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
           ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PUB
           ,X_MSG_COUNT    => x_MSG_COUNT
           ,X_MSG_DATA     => x_MSG_DATA
           ,X_RETURN_STATUS => x_RETURN_STATUS);
      WHEN FND_API.G_EXC_ERROR THEN
         JTF_PLSQL_API.HANDLE_EXCEPTIONS(
            P_API_NAME => L_API_NAME
           ,P_PKG_NAME => G_PKG_NAME
           ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
           ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PUB
           ,X_MSG_COUNT    => x_MSG_COUNT
           ,X_MSG_DATA     => x_MSG_DATA
           ,X_RETURN_STATUS => x_RETURN_STATUS);
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         JTF_PLSQL_API.HANDLE_EXCEPTIONS(
            P_API_NAME => L_API_NAME
           ,P_PKG_NAME => G_PKG_NAME
           ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
           ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PUB
           ,X_MSG_COUNT    => x_MSG_COUNT
           ,X_MSG_DATA     => x_MSG_DATA
           ,X_RETURN_STATUS => x_RETURN_STATUS);
      WHEN OTHERS THEN
         Rollback to do_create_site_use_PUB;
         FND_MESSAGE.SET_NAME('CSP', 'CSP_UNEXPECTED_EXEC_ERRORS');
         FND_MESSAGE.SET_TOKEN('ROUTINE', l_api_name, false);
         FND_MESSAGE.SET_TOKEN('SQLERRM', sqlerrm, false);
         FND_MSG_PUB.ADD;
         fnd_msg_pub.count_and_get
           ( p_count => x_msg_count
           , p_data  => x_msg_data);
         x_return_status := FND_API.G_RET_STS_ERROR;

END do_create_site_use;



------------------------------------------------------------------------------------------
-- Procedure Name   : do_update_site_use
-- Purpose          : It will update a ship to site use that link to
--                    an inventory location.
--
------------------------------------------------------------------------------------------
-- Procedure Name   : do_update_site_use
-- Purpose          : It will update a ship to site use that link to
--                    an inventory location.
--
PROCEDURE do_update_site_use
   (p_site_use_id            IN NUMBER
   ,p_primary_flag           IN VARCHAR2
   ,p_status                 IN VARCHAR2
   ,p_customer_id            IN NUMBER
   ,p_inv_location_id        IN NUMBER
   ,x_return_status          OUT NOCOPY VARCHAR2
   ,x_msg_count              OUT NOCOPY NUMBER
   ,x_msg_data               OUT NOCOPY VARCHAR2 ) IS

   l_api_version_number      CONSTANT NUMBER := 1.0;
   l_api_name                CONSTANT VARCHAR2(30) := 'do_update_site_use';
   l_language                VARCHAR2(4);
   EXCP_USER_DEFINED         EXCEPTION;

   l_site_use_id                    hz_cust_site_uses_all.site_use_id%TYPE;
   s_cust_acct_site_id              hz_cust_site_uses_all.cust_acct_site_id%TYPE;
   s_creation_date                  hz_cust_site_uses_all.creation_date%TYPE;
   s_created_by                     hz_cust_site_uses_all.created_by%TYPE;
   s_site_use_code                  hz_cust_site_uses_all.site_use_code%TYPE;
   s_primary_flag                   hz_cust_site_uses_all.primary_flag%TYPE;
   s_status                         hz_cust_site_uses_all.status%TYPE;
   s_location                       hz_cust_site_uses_all.location%TYPE;
   s_last_update_login              hz_cust_site_uses_all.last_update_login%TYPE;
   s_contact_id                     hz_cust_site_uses_all.contact_id%TYPE;
   s_bill_to_site_use_id            hz_cust_site_uses_all.bill_to_site_use_id%TYPE;
   s_orig_system_reference          hz_cust_site_uses_all.orig_system_reference%TYPE;
   s_sic_code                       hz_cust_site_uses_all.sic_code%TYPE;
   s_payment_term_id                hz_cust_site_uses_all.payment_term_id%TYPE;
   s_gsa_indicator                  hz_cust_site_uses_all.gsa_indicator%TYPE;
   s_ship_partial                   hz_cust_site_uses_all.ship_partial%TYPE;
   s_ship_via                       hz_cust_site_uses_all.ship_via%TYPE;
   s_fob_point                      hz_cust_site_uses_all.fob_point%TYPE;
   s_order_type_id                  hz_cust_site_uses_all.order_type_id%TYPE;
   s_price_list_id                  hz_cust_site_uses_all.price_list_id%TYPE;
   s_freight_term                   hz_cust_site_uses_all.freight_term%TYPE;
   s_warehouse_id                   hz_cust_site_uses_all.warehouse_id%TYPE;
   s_territory_id                   hz_cust_site_uses_all.territory_id%TYPE;
   s_attribute_category             hz_cust_site_uses_all.attribute_category%TYPE;
   s_attribute1                     hz_cust_site_uses_all.attribute1%TYPE;
   s_attribute2                     hz_cust_site_uses_all.attribute2%TYPE;
   s_attribute3                     hz_cust_site_uses_all.attribute3%TYPE;
   s_attribute4                     hz_cust_site_uses_all.attribute4%TYPE;
   s_attribute5                     hz_cust_site_uses_all.attribute5%TYPE;
   s_attribute6                     hz_cust_site_uses_all.attribute6%TYPE;
   s_attribute7                     hz_cust_site_uses_all.attribute7%TYPE;
   s_attribute8                     hz_cust_site_uses_all.attribute8%TYPE;
   s_attribute9                     hz_cust_site_uses_all.attribute9%TYPE;
   s_attribute10                    hz_cust_site_uses_all.attribute10%TYPE;
   s_request_id                     hz_cust_site_uses_all.request_id%TYPE;
   s_program_application_id         hz_cust_site_uses_all.program_application_id%TYPE;
   s_program_id                     hz_cust_site_uses_all.program_id%TYPE;
   s_program_update_date            hz_cust_site_uses_all.program_update_date%TYPE;
   s_tax_reference                  hz_cust_site_uses_all.tax_reference%TYPE;
   s_sort_priority                  hz_cust_site_uses_all.sort_priority%TYPE;
   s_tax_code                       hz_cust_site_uses_all.tax_code%TYPE;
   s_attribute11                    hz_cust_site_uses_all.attribute11%TYPE;
   s_attribute12                    hz_cust_site_uses_all.attribute12%TYPE;
   s_attribute13                    hz_cust_site_uses_all.attribute13%TYPE;
   s_attribute14                    hz_cust_site_uses_all.attribute14%TYPE;
   s_attribute15                    hz_cust_site_uses_all.attribute15%TYPE;
   s_attribute16                    hz_cust_site_uses_all.attribute16%TYPE;
   s_attribute17                    hz_cust_site_uses_all.attribute17%TYPE;
   s_attribute18                    hz_cust_site_uses_all.attribute18%TYPE;
   s_attribute19                    hz_cust_site_uses_all.attribute19%TYPE;
   s_attribute20                    hz_cust_site_uses_all.attribute20%TYPE;
   s_attribute21                    hz_cust_site_uses_all.attribute21%TYPE;
   s_attribute22                    hz_cust_site_uses_all.attribute22%TYPE;
   s_attribute23                    hz_cust_site_uses_all.attribute23%TYPE;
   s_attribute24                    hz_cust_site_uses_all.attribute24%TYPE;
   s_attribute25                    hz_cust_site_uses_all.attribute25%TYPE;
   s_last_accrue_charge_date        DATE;
   s_snd_last_accrue_charge_date    DATE;
   s_last_unaccrue_charge_date      DATE;
   s_snd_last_unaccrue_chrg_date    DATE;
   s_demand_class_code              hz_cust_site_uses_all.demand_class_code%TYPE;
   s_org_id                         hz_cust_site_uses_all.org_id%TYPE;
   s_tax_header_level_flag          hz_cust_site_uses_all.tax_header_level_flag%TYPE;
   s_tax_rounding_rule              hz_cust_site_uses_all.tax_rounding_rule%TYPE;
   s_wh_update_date                 hz_cust_site_uses_all.wh_update_date%TYPE;
   s_global_attribute1              hz_cust_site_uses_all.global_attribute1%TYPE;
   s_global_attribute2              hz_cust_site_uses_all.global_attribute2%TYPE;
   s_global_attribute3              hz_cust_site_uses_all.global_attribute3%TYPE;
   s_global_attribute4              hz_cust_site_uses_all.global_attribute4%TYPE;
   s_global_attribute5              hz_cust_site_uses_all.global_attribute5%TYPE;
   s_global_attribute6              hz_cust_site_uses_all.global_attribute6%TYPE;
   s_global_attribute7              hz_cust_site_uses_all.global_attribute7%TYPE;
   s_global_attribute8              hz_cust_site_uses_all.global_attribute8%TYPE;
   s_global_attribute9              hz_cust_site_uses_all.global_attribute9%TYPE;
   s_global_attribute10             hz_cust_site_uses_all.global_attribute10%TYPE;
   s_global_attribute11             hz_cust_site_uses_all.global_attribute11%TYPE;
   s_global_attribute12             hz_cust_site_uses_all.global_attribute12%TYPE;
   s_global_attribute13             hz_cust_site_uses_all.global_attribute13%TYPE;
   s_global_attribute14             hz_cust_site_uses_all.global_attribute14%TYPE;
   s_global_attribute15             hz_cust_site_uses_all.global_attribute15%TYPE;
   s_global_attribute16             hz_cust_site_uses_all.global_attribute16%TYPE;
   s_global_attribute17             hz_cust_site_uses_all.global_attribute17%TYPE;
   s_global_attribute18             hz_cust_site_uses_all.global_attribute18%TYPE;
   s_global_attribute19             hz_cust_site_uses_all.global_attribute19%TYPE;
   s_global_attribute20             hz_cust_site_uses_all.global_attribute20%TYPE;
   s_global_attribute_category      hz_cust_site_uses_all.global_attribute_category%TYPE;
   s_primary_salesrep_id            hz_cust_site_uses_all.primary_salesrep_id%TYPE;
   s_finchrg_receivables_trx_id     hz_cust_site_uses_all.finchrg_receivables_trx_id%TYPE;
   s_dates_negative_tolerance       hz_cust_site_uses_all.dates_negative_tolerance%TYPE;
   s_dates_positive_tolerance       hz_cust_site_uses_all.dates_positive_tolerance%TYPE;
   s_date_type_preference           hz_cust_site_uses_all.date_type_preference%TYPE;
   s_over_shipment_tolerance        hz_cust_site_uses_all.over_shipment_tolerance%TYPE;
   s_under_shipment_tolerance       hz_cust_site_uses_all.under_shipment_tolerance%TYPE;
   s_item_cross_ref_pref            hz_cust_site_uses_all.item_cross_ref_pref%TYPE;
   s_over_return_tolerance          hz_cust_site_uses_all.over_return_tolerance%TYPE;
   s_under_return_tolerance         hz_cust_site_uses_all.under_return_tolerance%TYPE;
   s_ship_sets_include_lines_flag   hz_cust_site_uses_all.ship_sets_include_lines_flag%TYPE;
   s_arv_include_lines_flag         hz_cust_site_uses_all.arrivalsets_include_lines_flag%TYPE;
   s_sched_date_push_flag           hz_cust_site_uses_all.sched_date_push_flag%TYPE;
   s_invoice_quantity_rule          hz_cust_site_uses_all.invoice_quantity_rule%TYPE;
   s_pricing_event                  hz_cust_site_uses_all.pricing_event%TYPE;
   s_gl_id_rec                      hz_cust_site_uses_all.gl_id_rec%TYPE;
   s_gl_id_rev                      hz_cust_site_uses_all.gl_id_rev%TYPE;
   s_gl_id_tax                      hz_cust_site_uses_all.gl_id_tax%TYPE;
   s_gl_id_freight                  hz_cust_site_uses_all.gl_id_freight%TYPE;
   s_gl_id_clearing                 hz_cust_site_uses_all.gl_id_clearing%TYPE;
   s_gl_id_unbilled                 hz_cust_site_uses_all.gl_id_unbilled%TYPE;
   s_gl_id_unearned                 hz_cust_site_uses_all.gl_id_unearned%TYPE;
   s_gl_id_unpaid_rec               hz_cust_site_uses_all.gl_id_unpaid_rec%TYPE;
   s_gl_id_remittance               hz_cust_site_uses_all.gl_id_remittance%TYPE;
   s_gl_id_factor                   hz_cust_site_uses_all.gl_id_factor%TYPE;
   s_tax_classification             hz_cust_site_uses_all.tax_classification%TYPE;
   s_last_update_date               DATE;
   s_last_updated_by                NUMBER;

   CURSOR l_cust_site_use_csr IS
      select cust_acct_site_id,
last_update_date,
last_updated_by,
creation_date,
created_by,
site_use_code,
primary_flag,
status,
location,
last_update_login,
contact_id,
bill_to_site_use_id,
orig_system_reference,
sic_code,
payment_term_id,
gsa_indicator,
        ship_partial,
ship_via,
fob_point,
order_type_id,
price_list_id,
freight_term,
warehouse_id,
territory_id,
attribute_category,
attribute1,
attribute2,
attribute3,
attribute4,
attribute5,
attribute6,
attribute7,
        attribute8,
attribute9,
attribute10,
request_id,
program_application_id,
program_id,
program_update_date,
tax_reference,
sort_priority,
tax_code,
attribute11,
attribute12,
attribute13,
attribute14,
attribute15,
        attribute16,
attribute17,
attribute18,
attribute19,
attribute20,
attribute21,
attribute22,
attribute23,
attribute24,
attribute25,
last_accrue_charge_date,
second_last_accrue_charge_date,
last_unaccrue_charge_date,
        second_last_unaccrue_chrg_date,
demand_class_code,
org_id,
tax_header_level_flag,
tax_rounding_rule,
wh_update_date,
global_attribute1,
global_attribute2,
global_attribute3,
global_attribute4,
global_attribute5,
        global_attribute6,
global_attribute7,
global_attribute8,
global_attribute9,
global_attribute10,
global_attribute11,
global_attribute12,
global_attribute13,
global_attribute14,
global_attribute15,
global_attribute16,
        global_attribute17,
global_attribute18,
global_attribute19,
global_attribute20,
global_attribute_category,
primary_salesrep_id,
finchrg_receivables_trx_id,
dates_negative_tolerance,
dates_positive_tolerance,
date_type_preference,
        over_shipment_tolerance,
under_shipment_tolerance,
item_cross_ref_pref,
over_return_tolerance,
under_return_tolerance,
ship_sets_include_lines_flag,
arrivalsets_include_lines_flag,
sched_date_push_flag,
invoice_quantity_rule,
        pricing_event,
gl_id_rec,
gl_id_rev,
gl_id_tax,
gl_id_freight,
gl_id_clearing,
gl_id_unbilled,
gl_id_unearned,
gl_id_unpaid_rec,
gl_id_remittance,
gl_id_factor,
tax_classification
      from hz_cust_site_uses
where site_use_id = p_site_use_id and site_use_code = 'SHIP_TO';

CURSOR get_bill_to_site_use_id IS
      select bill_to_site_use_id
      from hz_cust_site_uses
where site_use_id = p_site_use_id and site_use_code = 'SHIP_TO';

l_Bill_to_site_use_id NUMBER;

   CURSOR l_cust_Bill_to_site_use_csr IS
      select cust_acct_site_id,
last_update_date,
last_updated_by,
creation_date,
created_by,
site_use_code,
primary_flag,
status,
location,
last_update_login,
contact_id,
bill_to_site_use_id,
orig_system_reference,
sic_code,
payment_term_id,
gsa_indicator,
        ship_partial,
ship_via,
fob_point,
order_type_id,
price_list_id,
freight_term,
warehouse_id,
territory_id,
attribute_category,
attribute1,
attribute2,
attribute3,
attribute4,
attribute5,
attribute6,
attribute7,
        attribute8,
attribute9,
attribute10,
request_id,
program_application_id,
program_id,
program_update_date,
tax_reference,
sort_priority,
tax_code,
attribute11,
attribute12,
attribute13,
attribute14,
attribute15,
        attribute16,
attribute17,
attribute18,
attribute19,
attribute20,
attribute21,
attribute22,
attribute23,
attribute24,
attribute25,
last_accrue_charge_date,
second_last_accrue_charge_date,
last_unaccrue_charge_date,
        second_last_unaccrue_chrg_date,
demand_class_code,
org_id,
tax_header_level_flag,
tax_rounding_rule,
wh_update_date,
global_attribute1,
global_attribute2,
global_attribute3,
global_attribute4,
global_attribute5,
        global_attribute6,
global_attribute7,
global_attribute8,
global_attribute9,
global_attribute10,
global_attribute11,
global_attribute12,
global_attribute13,
global_attribute14,
global_attribute15,
global_attribute16,
        global_attribute17,
global_attribute18,
global_attribute19,
global_attribute20,
global_attribute_category,
primary_salesrep_id,
finchrg_receivables_trx_id,
dates_negative_tolerance,
dates_positive_tolerance,
date_type_preference,
        over_shipment_tolerance,
under_shipment_tolerance,
item_cross_ref_pref,
over_return_tolerance,
under_return_tolerance,
ship_sets_include_lines_flag,
arrivalsets_include_lines_flag,
sched_date_push_flag,
invoice_quantity_rule,
        pricing_event,
gl_id_rec,
gl_id_rev,
gl_id_tax,
gl_id_freight,
gl_id_clearing,
gl_id_unbilled,
gl_id_unearned,
gl_id_unpaid_rec,
gl_id_remittance,
gl_id_factor,
tax_classification
      from hz_cust_site_uses
where site_use_id = l_bill_to_site_use_id and site_use_code = 'BILL_TO';


BEGIN
   SAVEPOINT do_update_site_use_PUB;

   open get_bill_to_site_use_id;
   fetch get_bill_to_site_use_id INTO l_bill_to_site_use_id;
   CLose get_bill_to_site_use_id;
   if l_bill_to_site_use_id  IS NOT NULL and p_status = 'A' THEN
        open l_cust_Bill_to_site_use_csr;
   fetch l_cust_Bill_to_site_use_csr into
s_cust_acct_site_id,
s_last_update_date,
s_last_updated_by,
s_creation_date,
s_created_by,
s_site_use_code,
s_primary_flag,
s_status,
s_location,
s_last_update_login,
s_contact_id,
s_bill_to_site_use_id,
s_orig_system_reference,
s_sic_code,
s_payment_term_id,
s_gsa_indicator,
        s_ship_partial,
s_ship_via,
s_fob_point,
s_order_type_id,
s_price_list_id,
s_freight_term,
s_warehouse_id,
s_territory_id,
s_attribute_category,
s_attribute1,
s_attribute2,
s_attribute3,
s_attribute4,
s_attribute5,
s_attribute6,
s_attribute7,
        s_attribute8,
s_attribute9,
s_attribute10,
s_request_id,
s_program_application_id,
s_program_id,
s_program_update_date,
s_tax_reference,
s_sort_priority,
s_tax_code,
s_attribute11,
s_attribute12,
s_attribute13,
s_attribute14,
s_attribute15,
        s_attribute16,
s_attribute17,
s_attribute18,
s_attribute19,
s_attribute20,
s_attribute21,
s_attribute22,
s_attribute23,
s_attribute24,
s_attribute25,
s_last_accrue_charge_date,
s_snd_last_accrue_charge_date,
s_last_unaccrue_charge_date,
        s_snd_last_unaccrue_chrg_date,
s_demand_class_code,
s_org_id,
s_tax_header_level_flag,
s_tax_rounding_rule,
s_wh_update_date,
s_global_attribute1,
s_global_attribute2,
s_global_attribute3,
s_global_attribute4,
s_global_attribute5,
        s_global_attribute6,
s_global_attribute7,
s_global_attribute8,
s_global_attribute9,
s_global_attribute10,
s_global_attribute11,
s_global_attribute12,
s_global_attribute13,
s_global_attribute14,
s_global_attribute15,
s_global_attribute16,
        s_global_attribute17,
s_global_attribute18,
s_global_attribute19,
s_global_attribute20,
s_global_attribute_category,
s_primary_salesrep_id,
s_finchrg_receivables_trx_id,
s_dates_negative_tolerance,
s_dates_positive_tolerance,
s_date_type_preference,
        s_over_shipment_tolerance,
s_under_shipment_tolerance,
s_item_cross_ref_pref,
s_over_return_tolerance,
s_under_return_tolerance,
s_ship_sets_include_lines_flag,
s_arv_include_lines_flag,
s_sched_date_push_flag,
s_invoice_quantity_rule,
        s_pricing_event,
s_gl_id_rec,
s_gl_id_rev,
s_gl_id_tax,
s_gl_id_freight,
s_gl_id_clearing,
s_gl_id_unbilled,
s_gl_id_unearned,
s_gl_id_unpaid_rec,
s_gl_id_remittance,
s_gl_id_factor,
s_tax_classification;
     IF l_cust_Bill_to_site_use_csr%FOUND THEN
        close l_cust_Bill_to_site_use_csr;

        -- Update site use for ship_to
        arh_csu_pkg.Update_Row(
           X_Site_Use_Id            => l_Bill_to_site_use_id,
           X_Last_Update_Date       => s_last_update_date,
           X_Last_Updated_By        => nvl(fnd_global.user_id, 1),
           X_Site_Use_Code          => s_site_use_code,
		   X_customer_id			=> p_customer_id,
           X_Address_Id             => s_cust_acct_site_id,
           X_Primary_Flag           => p_primary_flag,
           X_Status                 => p_status,
           X_Location               => s_location,
           X_Last_Update_Login      => s_last_update_login,
           X_Contact_Id             => s_Contact_Id,
           X_Bill_To_Site_Use_Id    => s_Bill_To_Site_Use_Id,
           X_Sic_Code               => s_Sic_Code,
           X_Payment_Term_Id        => s_Payment_Term_Id,
           X_Gsa_Indicator          => s_Gsa_Indicator,
           X_Ship_Partial           => s_Ship_Partial,
           X_Ship_Via               => s_Ship_Via,
           X_Fob_Point              => s_Fob_Point,
           X_Order_Type_Id          => s_Order_Type_Id,
           X_Price_List_Id          => s_Price_List_Id,
           X_Freight_Term           => s_Freight_Term,
           X_Warehouse_Id           => s_Warehouse_Id,
           X_Territory_Id           => s_Territory_Id,
           X_Tax_Code               => s_Tax_Code,
           X_Tax_Reference          => s_Tax_Reference,
           X_Demand_Class_Code      => s_Demand_Class_Code,
		   x_inventory_location_id	=> p_inv_location_id,
		   x_inventory_organization_id	=> null,
           X_Attribute_Category     => s_attribute_category,
           X_Attribute1             => s_attribute1,
           X_Attribute2             => s_attribute2,
           X_Attribute3             => s_attribute3,
           X_Attribute4             => s_attribute4,
           X_Attribute5             => s_attribute5,
           X_Attribute6             => s_attribute6,
           X_Attribute7             => s_attribute7,
           X_Attribute8             => s_attribute8,
           X_Attribute9             => s_attribute9,
           X_Attribute10            => s_attribute10,
           X_Attribute11            => s_attribute11,
           X_Attribute12            => s_attribute12,
           X_Attribute13            => s_attribute13,
           X_Attribute14            => s_attribute14,
           X_Attribute15            => s_attribute15,
           X_Attribute16            => s_attribute16,
           X_Attribute17            => s_attribute17,
           X_Attribute18            => s_attribute18,
           X_Attribute19            => s_attribute19,
           X_Attribute20            => s_attribute20,
           X_Attribute21            => s_attribute21,
           X_Attribute22            => s_attribute22,
           X_Attribute23            => s_attribute23,
           X_Attribute24            => s_attribute24,
           X_Attribute25            => s_attribute25,
           X_Tax_Classification     => s_Tax_Classification,
           X_Tax_Header_Level_Flag  => s_Tax_Header_Level_Flag,
           X_Tax_Rounding_Rule      => s_Tax_Rounding_Rule,
           X_Global_Attribute_Category  => s_global_attribute_category,
           X_Global_Attribute1      => s_global_attribute1,
           X_Global_Attribute2      => s_global_attribute2,
           X_Global_Attribute3      => s_global_attribute3,
           X_Global_Attribute4      => s_global_attribute4,
           X_Global_Attribute5      => s_global_attribute5,
           X_Global_Attribute6      => s_global_attribute6,
           X_Global_Attribute7      => s_global_attribute7,
           X_Global_Attribute8      => s_global_attribute8,
           X_Global_Attribute9      => s_global_attribute9,
           X_Global_Attribute10     => s_global_attribute10,
           X_Global_Attribute11     => s_global_attribute11,
           X_Global_Attribute12     => s_global_attribute12,
           X_Global_Attribute13     => s_global_attribute13,
           X_Global_Attribute14     => s_global_attribute14,
           X_Global_Attribute15     => s_global_attribute15,
           X_Global_Attribute16     => s_global_attribute16,
           X_Global_Attribute17     => s_global_attribute17,
           X_Global_Attribute18     => s_global_attribute18,
           X_Global_Attribute19     => s_global_attribute19,
           X_Global_Attribute20     => s_global_attribute20,
           X_Primary_Salesrep_Id    => s_primary_salesrep_id,
           X_Finchrg_Receivables_Trx_Id  => s_Finchrg_Receivables_Trx_Id,
  		   X_GL_ID_Rec			    => s_GL_ID_Rec,
		   X_GL_ID_Rev			    => s_GL_ID_Rev,
		   X_GL_ID_Tax			    => s_GL_ID_Tax,
		   X_GL_ID_Freight			=> s_GL_ID_Freight,
		   X_GL_ID_Clearing			=> s_GL_ID_Clearing,
		   X_GL_ID_Unbilled			=> s_GL_ID_Unbilled,
		   X_GL_ID_Unearned 		=> s_GL_ID_Unearned,
           X_GL_ID_Unpaid_rec       => s_GL_ID_Unpaid_rec,
           X_GL_ID_Remittance       => s_GL_ID_Remittance,
           X_GL_ID_Factor           => s_GL_ID_Factor,
           X_DATES_NEGATIVE_TOLERANCE  => s_DATES_NEGATIVE_TOLERANCE,
           X_DATES_POSITIVE_TOLERANCE  => s_DATES_POSITIVE_TOLERANCE,
           X_DATE_TYPE_PREFERENCE      => s_DATE_TYPE_PREFERENCE,
           X_OVER_SHIPMENT_TOLERANCE   => s_OVER_SHIPMENT_TOLERANCE,
           X_UNDER_SHIPMENT_TOLERANCE  => s_UNDER_SHIPMENT_TOLERANCE,
           X_ITEM_CROSS_REF_PREF       => s_ITEM_CROSS_REF_PREF,
           X_OVER_RETURN_TOLERANCE     => s_OVER_RETURN_TOLERANCE,
           X_UNDER_RETURN_TOLERANCE    => s_UNDER_RETURN_TOLERANCE,
           X_SHIP_SETS_INCLUDE_LINES_FLAG   => s_SHIP_SETS_INCLUDE_LINES_FLAG,
           X_ARRIVALSETS_INCL_LINES_FLAG    => s_arv_include_lines_flag,
           X_SCHED_DATE_PUSH_FLAG           => s_SCHED_DATE_PUSH_FLAG,
           X_INVOICE_QUANTITY_RULE          => s_INVOICE_QUANTITY_RULE,
           x_msg_count               => x_msg_count,
           x_msg_data                => x_msg_data,
           x_return_status           => x_return_status);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         Rollback to do_update_site_use_PUB;
        /* FND_MESSAGE.SET_NAME ('CSP', 'CSP_SITE_USE_API_ERROR');
         FND_MESSAGE.SET_TOKEN ('TEXT', x_msg_data);
         FND_MSG_PUB.ADD;*/
         RAISE EXCP_USER_DEFINED;
      END IF;
    ELSE
      close l_cust_Bill_to_site_use_csr;
    END IF;
    END IF;


   l_site_use_id := p_site_use_id;

   open l_cust_site_use_csr;
   fetch l_cust_site_use_csr into
s_cust_acct_site_id,
s_last_update_date,
s_last_updated_by,
s_creation_date,
s_created_by,
s_site_use_code,
s_primary_flag,
s_status,
s_location,
s_last_update_login,
s_contact_id,
s_bill_to_site_use_id,
s_orig_system_reference,
s_sic_code,
s_payment_term_id,
s_gsa_indicator,
        s_ship_partial,
s_ship_via,
s_fob_point,
s_order_type_id,
s_price_list_id,
s_freight_term,
s_warehouse_id,
s_territory_id,
s_attribute_category,
s_attribute1,
s_attribute2,
s_attribute3,
s_attribute4,
s_attribute5,
s_attribute6,
s_attribute7,
        s_attribute8,
s_attribute9,
s_attribute10,
s_request_id,
s_program_application_id,
s_program_id,
s_program_update_date,
s_tax_reference,
s_sort_priority,
s_tax_code,
s_attribute11,
s_attribute12,
s_attribute13,
s_attribute14,
s_attribute15,
        s_attribute16,
s_attribute17,
s_attribute18,
s_attribute19,
s_attribute20,
s_attribute21,
s_attribute22,
s_attribute23,
s_attribute24,
s_attribute25,
s_last_accrue_charge_date,
s_snd_last_accrue_charge_date,
s_last_unaccrue_charge_date,
        s_snd_last_unaccrue_chrg_date,
s_demand_class_code,
s_org_id,
s_tax_header_level_flag,
s_tax_rounding_rule,
s_wh_update_date,
s_global_attribute1,
s_global_attribute2,
s_global_attribute3,
s_global_attribute4,
s_global_attribute5,
        s_global_attribute6,
s_global_attribute7,
s_global_attribute8,
s_global_attribute9,
s_global_attribute10,
s_global_attribute11,
s_global_attribute12,
s_global_attribute13,
s_global_attribute14,
s_global_attribute15,
s_global_attribute16,
        s_global_attribute17,
s_global_attribute18,
s_global_attribute19,
s_global_attribute20,
s_global_attribute_category,
s_primary_salesrep_id,
s_finchrg_receivables_trx_id,
s_dates_negative_tolerance,
s_dates_positive_tolerance,
s_date_type_preference,
        s_over_shipment_tolerance,
s_under_shipment_tolerance,
s_item_cross_ref_pref,
s_over_return_tolerance,
s_under_return_tolerance,
s_ship_sets_include_lines_flag,
s_arv_include_lines_flag,
s_sched_date_push_flag,
s_invoice_quantity_rule,
        s_pricing_event,
s_gl_id_rec,
s_gl_id_rev,
s_gl_id_tax,
s_gl_id_freight,
s_gl_id_clearing,
s_gl_id_unbilled,
s_gl_id_unearned,
s_gl_id_unpaid_rec,
s_gl_id_remittance,
s_gl_id_factor,
s_tax_classification;
     IF l_cust_site_use_csr%FOUND THEN
        close l_cust_site_use_csr;
        -- Update site use
        arh_csu_pkg.Update_Row(
           X_Site_Use_Id            => l_site_use_id,
           X_Last_Update_Date       => s_last_update_date,
           X_Last_Updated_By        => nvl(fnd_global.user_id, 1),
           X_Site_Use_Code          => s_site_use_code,
		   X_customer_id			=> p_customer_id,
           X_Address_Id             => s_cust_acct_site_id,
           X_Primary_Flag           => p_primary_flag,
           X_Status                 => p_status,
           X_Location               => s_location,
           X_Last_Update_Login      => s_last_update_login,
           X_Contact_Id             => s_Contact_Id,
           X_Bill_To_Site_Use_Id    => s_Bill_To_Site_Use_Id,
           X_Sic_Code               => s_Sic_Code,
           X_Payment_Term_Id        => s_Payment_Term_Id,
           X_Gsa_Indicator          => s_Gsa_Indicator,
           X_Ship_Partial           => s_Ship_Partial,
           X_Ship_Via               => s_Ship_Via,
           X_Fob_Point              => s_Fob_Point,
           X_Order_Type_Id          => s_Order_Type_Id,
           X_Price_List_Id          => s_Price_List_Id,
           X_Freight_Term           => s_Freight_Term,
           X_Warehouse_Id           => s_Warehouse_Id,
           X_Territory_Id           => s_Territory_Id,
           X_Tax_Code               => s_Tax_Code,
           X_Tax_Reference          => s_Tax_Reference,
           X_Demand_Class_Code      => s_Demand_Class_Code,
		   x_inventory_location_id	=> p_inv_location_id,
		   x_inventory_organization_id	=> null,
           X_Attribute_Category     => s_attribute_category,
           X_Attribute1             => s_attribute1,
           X_Attribute2             => s_attribute2,
           X_Attribute3             => s_attribute3,
           X_Attribute4             => s_attribute4,
           X_Attribute5             => s_attribute5,
           X_Attribute6             => s_attribute6,
           X_Attribute7             => s_attribute7,
           X_Attribute8             => s_attribute8,
           X_Attribute9             => s_attribute9,
           X_Attribute10            => s_attribute10,
           X_Attribute11            => s_attribute11,
           X_Attribute12            => s_attribute12,
           X_Attribute13            => s_attribute13,
           X_Attribute14            => s_attribute14,
           X_Attribute15            => s_attribute15,
           X_Attribute16            => s_attribute16,
           X_Attribute17            => s_attribute17,
           X_Attribute18            => s_attribute18,
           X_Attribute19            => s_attribute19,
           X_Attribute20            => s_attribute20,
           X_Attribute21            => s_attribute21,
           X_Attribute22            => s_attribute22,
           X_Attribute23            => s_attribute23,
           X_Attribute24            => s_attribute24,
           X_Attribute25            => s_attribute25,
           X_Tax_Classification     => s_Tax_Classification,
           X_Tax_Header_Level_Flag  => s_Tax_Header_Level_Flag,
           X_Tax_Rounding_Rule      => s_Tax_Rounding_Rule,
           X_Global_Attribute_Category  => s_global_attribute_category,
           X_Global_Attribute1      => s_global_attribute1,
           X_Global_Attribute2      => s_global_attribute2,
           X_Global_Attribute3      => s_global_attribute3,
           X_Global_Attribute4      => s_global_attribute4,
           X_Global_Attribute5      => s_global_attribute5,
           X_Global_Attribute6      => s_global_attribute6,
           X_Global_Attribute7      => s_global_attribute7,
           X_Global_Attribute8      => s_global_attribute8,
           X_Global_Attribute9      => s_global_attribute9,
           X_Global_Attribute10     => s_global_attribute10,
           X_Global_Attribute11     => s_global_attribute11,
           X_Global_Attribute12     => s_global_attribute12,
           X_Global_Attribute13     => s_global_attribute13,
           X_Global_Attribute14     => s_global_attribute14,
           X_Global_Attribute15     => s_global_attribute15,
           X_Global_Attribute16     => s_global_attribute16,
           X_Global_Attribute17     => s_global_attribute17,
           X_Global_Attribute18     => s_global_attribute18,
           X_Global_Attribute19     => s_global_attribute19,
           X_Global_Attribute20     => s_global_attribute20,
           X_Primary_Salesrep_Id    => s_primary_salesrep_id,
           X_Finchrg_Receivables_Trx_Id  => s_Finchrg_Receivables_Trx_Id,
  		   X_GL_ID_Rec			    => s_GL_ID_Rec,
		   X_GL_ID_Rev			    => s_GL_ID_Rev,
		   X_GL_ID_Tax			    => s_GL_ID_Tax,
		   X_GL_ID_Freight			=> s_GL_ID_Freight,
		   X_GL_ID_Clearing			=> s_GL_ID_Clearing,
		   X_GL_ID_Unbilled			=> s_GL_ID_Unbilled,
		   X_GL_ID_Unearned 		=> s_GL_ID_Unearned,
           X_GL_ID_Unpaid_rec       => s_GL_ID_Unpaid_rec,
           X_GL_ID_Remittance       => s_GL_ID_Remittance,
           X_GL_ID_Factor           => s_GL_ID_Factor,
           X_DATES_NEGATIVE_TOLERANCE  => s_DATES_NEGATIVE_TOLERANCE,
           X_DATES_POSITIVE_TOLERANCE  => s_DATES_POSITIVE_TOLERANCE,
           X_DATE_TYPE_PREFERENCE      => s_DATE_TYPE_PREFERENCE,
           X_OVER_SHIPMENT_TOLERANCE   => s_OVER_SHIPMENT_TOLERANCE,
           X_UNDER_SHIPMENT_TOLERANCE  => s_UNDER_SHIPMENT_TOLERANCE,
           X_ITEM_CROSS_REF_PREF       => s_ITEM_CROSS_REF_PREF,
           X_OVER_RETURN_TOLERANCE     => s_OVER_RETURN_TOLERANCE,
           X_UNDER_RETURN_TOLERANCE    => s_UNDER_RETURN_TOLERANCE,
           X_SHIP_SETS_INCLUDE_LINES_FLAG   => s_SHIP_SETS_INCLUDE_LINES_FLAG,
           X_ARRIVALSETS_INCL_LINES_FLAG    => s_arv_include_lines_flag,
           X_SCHED_DATE_PUSH_FLAG           => s_SCHED_DATE_PUSH_FLAG,
           X_INVOICE_QUANTITY_RULE          => s_INVOICE_QUANTITY_RULE,
           x_msg_count               => x_msg_count,
           x_msg_data                => x_msg_data,
           x_return_status           => x_return_status);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         Rollback to do_update_site_use_PUB;
        /* FND_MESSAGE.SET_NAME ('CSP', 'CSP_SITE_USE_API_ERROR');
         FND_MESSAGE.SET_TOKEN ('TEXT', x_msg_data);
         FND_MSG_PUB.ADD;*/
         RAISE EXCP_USER_DEFINED;
      END IF;
   ELSE
      close l_cust_site_use_csr;
   END IF;
   if l_bill_to_site_use_id  IS NOT NULL and p_status = 'I' THEN
        open l_cust_Bill_to_site_use_csr;
   fetch l_cust_Bill_to_site_use_csr into
s_cust_acct_site_id,
s_last_update_date,
s_last_updated_by,
s_creation_date,
s_created_by,
s_site_use_code,
s_primary_flag,
s_status,
s_location,
s_last_update_login,
s_contact_id,
s_bill_to_site_use_id,
s_orig_system_reference,
s_sic_code,
s_payment_term_id,
s_gsa_indicator,
        s_ship_partial,
s_ship_via,
s_fob_point,
s_order_type_id,
s_price_list_id,
s_freight_term,
s_warehouse_id,
s_territory_id,
s_attribute_category,
s_attribute1,
s_attribute2,
s_attribute3,
s_attribute4,
s_attribute5,
s_attribute6,
s_attribute7,
        s_attribute8,
s_attribute9,
s_attribute10,
s_request_id,
s_program_application_id,
s_program_id,
s_program_update_date,
s_tax_reference,
s_sort_priority,
s_tax_code,
s_attribute11,
s_attribute12,
s_attribute13,
s_attribute14,
s_attribute15,
        s_attribute16,
s_attribute17,
s_attribute18,
s_attribute19,
s_attribute20,
s_attribute21,
s_attribute22,
s_attribute23,
s_attribute24,
s_attribute25,
s_last_accrue_charge_date,
s_snd_last_accrue_charge_date,
s_last_unaccrue_charge_date,
        s_snd_last_unaccrue_chrg_date,
s_demand_class_code,
s_org_id,
s_tax_header_level_flag,
s_tax_rounding_rule,
s_wh_update_date,
s_global_attribute1,
s_global_attribute2,
s_global_attribute3,
s_global_attribute4,
s_global_attribute5,
        s_global_attribute6,
s_global_attribute7,
s_global_attribute8,
s_global_attribute9,
s_global_attribute10,
s_global_attribute11,
s_global_attribute12,
s_global_attribute13,
s_global_attribute14,
s_global_attribute15,
s_global_attribute16,
        s_global_attribute17,
s_global_attribute18,
s_global_attribute19,
s_global_attribute20,
s_global_attribute_category,
s_primary_salesrep_id,
s_finchrg_receivables_trx_id,
s_dates_negative_tolerance,
s_dates_positive_tolerance,
s_date_type_preference,
        s_over_shipment_tolerance,
s_under_shipment_tolerance,
s_item_cross_ref_pref,
s_over_return_tolerance,
s_under_return_tolerance,
s_ship_sets_include_lines_flag,
s_arv_include_lines_flag,
s_sched_date_push_flag,
s_invoice_quantity_rule,
        s_pricing_event,
s_gl_id_rec,
s_gl_id_rev,
s_gl_id_tax,
s_gl_id_freight,
s_gl_id_clearing,
s_gl_id_unbilled,
s_gl_id_unearned,
s_gl_id_unpaid_rec,
s_gl_id_remittance,
s_gl_id_factor,
s_tax_classification;
     IF l_cust_Bill_to_site_use_csr%FOUND THEN
        close l_cust_Bill_to_site_use_csr;

        -- Update site use for ship_to
        arh_csu_pkg.Update_Row(
           X_Site_Use_Id            => l_Bill_to_site_use_id,
           X_Last_Update_Date       => s_last_update_date,
           X_Last_Updated_By        => nvl(fnd_global.user_id, 1),
           X_Site_Use_Code          => s_site_use_code,
		   X_customer_id			=> p_customer_id,
           X_Address_Id             => s_cust_acct_site_id,
           X_Primary_Flag           => p_primary_flag,
           X_Status                 => p_status,
           X_Location               => s_location,
           X_Last_Update_Login      => s_last_update_login,
           X_Contact_Id             => s_Contact_Id,
           X_Bill_To_Site_Use_Id    => s_Bill_To_Site_Use_Id,
           X_Sic_Code               => s_Sic_Code,
           X_Payment_Term_Id        => s_Payment_Term_Id,
           X_Gsa_Indicator          => s_Gsa_Indicator,
           X_Ship_Partial           => s_Ship_Partial,
           X_Ship_Via               => s_Ship_Via,
           X_Fob_Point              => s_Fob_Point,
           X_Order_Type_Id          => s_Order_Type_Id,
           X_Price_List_Id          => s_Price_List_Id,
           X_Freight_Term           => s_Freight_Term,
           X_Warehouse_Id           => s_Warehouse_Id,
           X_Territory_Id           => s_Territory_Id,
           X_Tax_Code               => s_Tax_Code,
           X_Tax_Reference          => s_Tax_Reference,
           X_Demand_Class_Code      => s_Demand_Class_Code,
		   x_inventory_location_id	=> p_inv_location_id,
		   x_inventory_organization_id	=> null,
           X_Attribute_Category     => s_attribute_category,
           X_Attribute1             => s_attribute1,
           X_Attribute2             => s_attribute2,
           X_Attribute3             => s_attribute3,
           X_Attribute4             => s_attribute4,
           X_Attribute5             => s_attribute5,
           X_Attribute6             => s_attribute6,
           X_Attribute7             => s_attribute7,
           X_Attribute8             => s_attribute8,
           X_Attribute9             => s_attribute9,
           X_Attribute10            => s_attribute10,
           X_Attribute11            => s_attribute11,
           X_Attribute12            => s_attribute12,
           X_Attribute13            => s_attribute13,
           X_Attribute14            => s_attribute14,
           X_Attribute15            => s_attribute15,
           X_Attribute16            => s_attribute16,
           X_Attribute17            => s_attribute17,
           X_Attribute18            => s_attribute18,
           X_Attribute19            => s_attribute19,
           X_Attribute20            => s_attribute20,
           X_Attribute21            => s_attribute21,
           X_Attribute22            => s_attribute22,
           X_Attribute23            => s_attribute23,
           X_Attribute24            => s_attribute24,
           X_Attribute25            => s_attribute25,
           X_Tax_Classification     => s_Tax_Classification,
           X_Tax_Header_Level_Flag  => s_Tax_Header_Level_Flag,
           X_Tax_Rounding_Rule      => s_Tax_Rounding_Rule,
           X_Global_Attribute_Category  => s_global_attribute_category,
           X_Global_Attribute1      => s_global_attribute1,
           X_Global_Attribute2      => s_global_attribute2,
           X_Global_Attribute3      => s_global_attribute3,
           X_Global_Attribute4      => s_global_attribute4,
           X_Global_Attribute5      => s_global_attribute5,
           X_Global_Attribute6      => s_global_attribute6,
           X_Global_Attribute7      => s_global_attribute7,
           X_Global_Attribute8      => s_global_attribute8,
           X_Global_Attribute9      => s_global_attribute9,
           X_Global_Attribute10     => s_global_attribute10,
           X_Global_Attribute11     => s_global_attribute11,
           X_Global_Attribute12     => s_global_attribute12,
           X_Global_Attribute13     => s_global_attribute13,
           X_Global_Attribute14     => s_global_attribute14,
           X_Global_Attribute15     => s_global_attribute15,
           X_Global_Attribute16     => s_global_attribute16,
           X_Global_Attribute17     => s_global_attribute17,
           X_Global_Attribute18     => s_global_attribute18,
           X_Global_Attribute19     => s_global_attribute19,
           X_Global_Attribute20     => s_global_attribute20,
           X_Primary_Salesrep_Id    => s_primary_salesrep_id,
           X_Finchrg_Receivables_Trx_Id  => s_Finchrg_Receivables_Trx_Id,
  		   X_GL_ID_Rec			    => s_GL_ID_Rec,
		   X_GL_ID_Rev			    => s_GL_ID_Rev,
		   X_GL_ID_Tax			    => s_GL_ID_Tax,
		   X_GL_ID_Freight			=> s_GL_ID_Freight,
		   X_GL_ID_Clearing			=> s_GL_ID_Clearing,
		   X_GL_ID_Unbilled			=> s_GL_ID_Unbilled,
		   X_GL_ID_Unearned 		=> s_GL_ID_Unearned,
           X_GL_ID_Unpaid_rec       => s_GL_ID_Unpaid_rec,
           X_GL_ID_Remittance       => s_GL_ID_Remittance,
           X_GL_ID_Factor           => s_GL_ID_Factor,
           X_DATES_NEGATIVE_TOLERANCE  => s_DATES_NEGATIVE_TOLERANCE,
           X_DATES_POSITIVE_TOLERANCE  => s_DATES_POSITIVE_TOLERANCE,
           X_DATE_TYPE_PREFERENCE      => s_DATE_TYPE_PREFERENCE,
           X_OVER_SHIPMENT_TOLERANCE   => s_OVER_SHIPMENT_TOLERANCE,
           X_UNDER_SHIPMENT_TOLERANCE  => s_UNDER_SHIPMENT_TOLERANCE,
           X_ITEM_CROSS_REF_PREF       => s_ITEM_CROSS_REF_PREF,
           X_OVER_RETURN_TOLERANCE     => s_OVER_RETURN_TOLERANCE,
           X_UNDER_RETURN_TOLERANCE    => s_UNDER_RETURN_TOLERANCE,
           X_SHIP_SETS_INCLUDE_LINES_FLAG   => s_SHIP_SETS_INCLUDE_LINES_FLAG,
           X_ARRIVALSETS_INCL_LINES_FLAG    => s_arv_include_lines_flag,
           X_SCHED_DATE_PUSH_FLAG           => s_SCHED_DATE_PUSH_FLAG,
           X_INVOICE_QUANTITY_RULE          => s_INVOICE_QUANTITY_RULE,
           x_msg_count               => x_msg_count,
           x_msg_data                => x_msg_data,
           x_return_status           => x_return_status);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         Rollback to do_update_site_use_PUB;
        /* FND_MESSAGE.SET_NAME ('CSP', 'CSP_SITE_USE_API_ERROR');
         FND_MESSAGE.SET_TOKEN ('TEXT', x_msg_data);
         FND_MSG_PUB.ADD;*/
         RAISE EXCP_USER_DEFINED;
      END IF;
    ELSE
      close l_cust_Bill_to_site_use_csr;
    END IF;
    END IF;


   -- Exception Block
   EXCEPTION
      WHEN EXCP_USER_DEFINED THEN
         Rollback to do_update_site_use_PUB;
         x_return_status := FND_API.G_RET_STS_ERROR;
        JTF_PLSQL_API.HANDLE_EXCEPTIONS(
            P_API_NAME => L_API_NAME
           ,P_PKG_NAME => G_PKG_NAME
           ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
           ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PUB
           ,X_MSG_COUNT    => x_MSG_COUNT
           ,X_MSG_DATA     => x_MSG_DATA
           ,X_RETURN_STATUS => x_RETURN_STATUS);
      WHEN FND_API.G_EXC_ERROR THEN
         JTF_PLSQL_API.HANDLE_EXCEPTIONS(
            P_API_NAME => L_API_NAME
           ,P_PKG_NAME => G_PKG_NAME
           ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
           ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PUB
           ,X_MSG_COUNT    => x_MSG_COUNT
           ,X_MSG_DATA     => x_MSG_DATA
           ,X_RETURN_STATUS => x_RETURN_STATUS);
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         JTF_PLSQL_API.HANDLE_EXCEPTIONS(
            P_API_NAME => L_API_NAME
           ,P_PKG_NAME => G_PKG_NAME
           ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
           ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PUB
           ,X_MSG_COUNT    => x_MSG_COUNT
           ,X_MSG_DATA     => x_MSG_DATA
           ,X_RETURN_STATUS => x_RETURN_STATUS);
      WHEN OTHERS THEN
         Rollback to do_update_site_use_PUB;
         FND_MESSAGE.SET_NAME('CSP', 'CSP_UNEXPECTED_EXEC_ERRORS');
         FND_MESSAGE.SET_TOKEN('ROUTINE', l_api_name, FALSE);
         FND_MESSAGE.SET_TOKEN('SQLERRM', sqlerrm, FALSE);
         FND_MSG_PUB.ADD;
         fnd_msg_pub.count_and_get
           ( p_count => x_msg_count
           , p_data  => x_msg_data);
         x_return_status := FND_API.G_RET_STS_ERROR;

END do_update_site_use;
------------------------------------------------------------------------------------------
-- Procedure Name   : ship_to_address_handler
-- Purpose          : If address fields is not blank:
--                      If location_id is blank, create a new inventory location.
--                      else update the existing inventory location with the addresses feed in.
--                    If task_assignment_id is not blank, or resource_type and resource_id is not blank,
--                    (only use task_assignment_id to retrieve resource_type and resource_id if the
--                     resource_type and resource_id pass in are blank).
--                    create party, customer, account, site location, party site, party site use,
--                    account site, account site use, location association, ...
--                    Return error if address fields and task_assignment_id are both blank.

--                    The address information passed in must be validated before passing in.
--                    It will not create an inventory location if the address is not valid.
--                    Required fields are varied depends on the country.  The country field
--                    is used to check if there is a address passed in.
--
PROCEDURE ship_to_address_handler
  (p_task_assignment_id      IN NUMBER
  ,p_resource_type           IN VARCHAR2
  ,p_resource_id             IN NUMBER
  ,p_customer_id             OUT NOCOPY NUMBER
  ,p_location_id             IN OUT NOCOPY NUMBER
  ,p_style                   IN VARCHAR2
  ,p_address_line_1          IN VARCHAR2
  ,p_address_line_2          IN VARCHAR2
  ,p_address_line_3          IN VARCHAR2
  ,p_country                 IN VARCHAR2
  ,p_postal_code             IN VARCHAR2
  ,p_region_1                IN VARCHAR2
  ,p_region_2                IN VARCHAR2
  ,p_region_3                IN VARCHAR2
  ,p_town_or_city            IN VARCHAR2
  ,p_tax_name                IN VARCHAR2
  ,p_telephone_number_1      IN VARCHAR2
  ,p_telephone_number_2      IN VARCHAR2
  ,p_telephone_number_3      IN VARCHAR2
  ,p_loc_information13       IN VARCHAR2
  ,p_loc_information14       IN VARCHAR2
  ,p_loc_information15       IN VARCHAR2
  ,p_loc_information16       IN VARCHAR2
  ,p_loc_information17       IN VARCHAR2
  ,p_loc_information18       IN VARCHAR2
  ,p_loc_information19       IN VARCHAR2
  ,p_loc_information20       IN VARCHAR2
  ,p_timezone                IN VARCHAR2
  ,p_primary_flag            IN VARCHAR2
  ,p_status                  IN VARCHAR2
  ,p_object_version_number   IN OUT NOCOPY NUMBER
  ,p_api_version_number      IN NUMBER
  ,p_init_msg_list           IN VARCHAR2
  ,p_commit                  IN VARCHAR2
  ,p_attribute_category     IN VARCHAR2
   ,p_attribute1             IN VARCHAR2
   ,p_attribute2             IN VARCHAR2
   ,p_attribute3             IN VARCHAR2
   ,p_attribute4             IN VARCHAR2
   ,p_attribute5             IN VARCHAR2
   ,p_attribute6             IN VARCHAR2
   ,p_attribute7             IN VARCHAR2
   ,p_attribute8             IN VARCHAR2
   ,p_attribute9             IN VARCHAR2
   ,p_attribute10             IN VARCHAR2
   ,p_attribute11             IN VARCHAR2
   ,p_attribute12             IN VARCHAR2
   ,p_attribute13            IN VARCHAR2
   ,p_attribute14             IN VARCHAR2
   ,p_attribute15             IN VARCHAR2
   ,p_attribute16             IN VARCHAR2
   ,p_attribute17             IN VARCHAR2
   ,p_attribute18             IN VARCHAR2
   ,p_attribute19             IN VARCHAR2
   ,p_attribute20             IN VARCHAR2
    ,p_bill_to_create		  IN VARCHAR2 := 'Y'
    ,p_province                IN VARCHAR2 DEFAULT NULL
	,p_address_lines_phonetic  IN VARCHAR2 DEFAULT NULL
         ,p_address_line_4          IN VARCHAR2 DEFAULT NULL
         ,P_HZ_LOCATION_ID          IN NUMBER DEFAULT NULL
  ,x_return_status           OUT NOCOPY VARCHAR2
  ,x_msg_count               OUT NOCOPY NUMBER
  ,x_msg_data                OUT NOCOPY VARCHAR2) IS

   l_api_version_number         CONSTANT NUMBER := 1.0;
   l_api_name                   CONSTANT VARCHAR2(30) := 'ship_to_address_handler';
   EXCP_USER_DEFINED            EXCEPTION;

   l_customer_profile_class_id      AR_CUSTOMER_PROFILE_CLASSES_V.customer_profile_class_id%TYPE := 0;  -- internal customer
   l_customer_id                    hz_cust_accounts.cust_account_id%TYPE := NULL;
   t_customer_id                    hz_cust_accounts.cust_account_id%TYPE := NULL;
   l_location_id                    hr_locations_all.location_id%TYPE := NULL;
   l_inv_location_id                hr_locations_all.location_id%TYPE := NULL;
   l_resource_id                    jtf_task_assignments.resource_id%TYPE := NULL;
   l_resource_type                  jtf_task_assignments.resource_type_code%TYPE := NULL;
   l_resource_name                  jtf_rs_resource_extns_vl.resource_name%TYPE := NULL;
   l_party_id                       hz_parties.party_id%TYPE := NULL;
   l_first_name                     hz_parties.person_first_name%TYPE := NULL;
   l_middle_name                    hz_parties.person_middle_name%TYPE := NULL;
   l_last_name                      hz_parties.person_last_name%TYPE := NULL;
   l_account_number                 hz_cust_accounts.account_number%TYPE := NULL;
   l_customer_number                hz_cust_accounts.account_number%TYPE := NULL;
   l_Attribute_Category             hz_cust_accounts.attribute_category%TYPE := NULL;
   l_Attribute1                     hz_cust_accounts.attribute1%TYPE := NULL;
   l_Attribute2                     hz_cust_accounts.attribute2%TYPE := NULL;
   l_Attribute3                     hz_cust_accounts.attribute3%TYPE := NULL;
   l_Attribute4                     hz_cust_accounts.attribute4%TYPE := NULL;
   l_Attribute5                     hz_cust_accounts.attribute5%TYPE := NULL;
   l_Attribute6                     hz_cust_accounts.attribute6%TYPE := NULL;
   l_Attribute7                     hz_cust_accounts.attribute7%TYPE := NULL;
   l_Attribute8                     hz_cust_accounts.attribute8%TYPE := NULL;
   l_Attribute9                     hz_cust_accounts.attribute9%TYPE := NULL;
   l_Attribute10                    hz_cust_accounts.attribute10%TYPE := NULL;
   l_Attribute11                    hz_cust_accounts.attribute11%TYPE := NULL;
   l_Attribute12                    hz_cust_accounts.attribute12%TYPE := NULL;
   l_Attribute13                    hz_cust_accounts.attribute13%TYPE := NULL;
   l_Attribute14                    hz_cust_accounts.attribute14%TYPE := NULL;
   l_Attribute15                    hz_cust_accounts.attribute15%TYPE := NULL;
   l_Attribute16                    hz_cust_accounts.attribute16%TYPE := NULL;
   l_Attribute17                    hz_cust_accounts.attribute17%TYPE := NULL;
   l_Attribute18                    hz_cust_accounts.attribute18%TYPE := NULL;
   l_Attribute19                    hz_cust_accounts.attribute19%TYPE := NULL;
   l_Attribute20                    hz_cust_accounts.attribute20%TYPE := NULL;
   l_global_attribute_category      hz_cust_accounts.global_attribute_category%TYPE := NULL;
   l_global_attribute1              hz_cust_accounts.attribute1%TYPE := NULL;
   l_global_attribute2              hz_cust_accounts.attribute2%TYPE := NULL;
   l_global_attribute3              hz_cust_accounts.attribute3%TYPE := NULL;
   l_global_attribute4              hz_cust_accounts.attribute4%TYPE := NULL;
   l_global_attribute5              hz_cust_accounts.attribute5%TYPE := NULL;
   l_global_attribute6              hz_cust_accounts.attribute6%TYPE := NULL;
   l_global_attribute7              hz_cust_accounts.attribute7%TYPE := NULL;
   l_global_attribute8              hz_cust_accounts.attribute8%TYPE := NULL;
   l_global_attribute9              hz_cust_accounts.attribute9%TYPE := NULL;
   l_global_attribute10             hz_cust_accounts.attribute10%TYPE := NULL;
   l_global_attribute11             hz_cust_accounts.attribute11%TYPE := NULL;
   l_global_attribute12             hz_cust_accounts.attribute12%TYPE := NULL;
   l_global_attribute13             hz_cust_accounts.attribute13%TYPE := NULL;
   l_global_attribute14             hz_cust_accounts.attribute14%TYPE := NULL;
   l_global_attribute15             hz_cust_accounts.attribute15%TYPE := NULL;
   l_global_attribute16             hz_cust_accounts.attribute16%TYPE := NULL;
   l_global_attribute17             hz_cust_accounts.attribute17%TYPE := NULL;
   l_global_attribute18             hz_cust_accounts.attribute18%TYPE := NULL;
   l_global_attribute19             hz_cust_accounts.attribute19%TYPE := NULL;
   l_global_attribute20             hz_cust_accounts.attribute20%TYPE := NULL;
   l_jgzz_attribute_category        hz_cust_accounts.global_attribute_category%TYPE := NULL;
   l_jgzz_attribute1                hz_cust_accounts.attribute1%TYPE := NULL;
   l_jgzz_attribute2                hz_cust_accounts.attribute2%TYPE := NULL;
   l_jgzz_attribute3                hz_cust_accounts.attribute3%TYPE := NULL;
   l_jgzz_attribute4                hz_cust_accounts.attribute4%TYPE := NULL;
   l_jgzz_attribute5                hz_cust_accounts.attribute5%TYPE := NULL;
   l_jgzz_attribute6                hz_cust_accounts.attribute6%TYPE := NULL;
   l_jgzz_attribute7                hz_cust_accounts.attribute7%TYPE := NULL;
   l_jgzz_attribute8                hz_cust_accounts.attribute8%TYPE := NULL;
   l_jgzz_attribute9                hz_cust_accounts.attribute9%TYPE := NULL;
   l_jgzz_attribute10               hz_cust_accounts.attribute10%TYPE := NULL;
   l_jgzz_attribute11               hz_cust_accounts.attribute11%TYPE := NULL;
   l_jgzz_attribute12               hz_cust_accounts.attribute12%TYPE := NULL;
   l_jgzz_attribute13               hz_cust_accounts.attribute13%TYPE := NULL;
   l_jgzz_attribute14               hz_cust_accounts.attribute14%TYPE := NULL;
   l_jgzz_attribute15               hz_cust_accounts.attribute15%TYPE := NULL;
   l_orig_system_reference          hz_cust_accounts.orig_system_reference%TYPE := NULL;
   l_status                         hz_cust_accounts.status%TYPE := 'A';  -- Active
   l_customer_type                  hz_cust_accounts.customer_type%TYPE := 'I';  -- Internal
   l_customer_class_code            hz_cust_accounts.customer_class_code%TYPE := NULL;
   l_primary_salesrep_id            hz_cust_accounts.primary_salesrep_id%TYPE := NULL;
   l_sales_channel_code             hz_cust_accounts.sales_channel_code%TYPE := NULL;
   l_order_type_id                  hz_cust_accounts.order_type_id%TYPE := NULL;
   l_price_list_id                  hz_cust_accounts.price_list_id%TYPE := NULL;
   l_category_code                  hz_cust_accounts.subcategory_code%TYPE := NULL;
   l_reference_use_flag             VARCHAR2(1) := 'N';
   l_tax_code                       hz_cust_accounts.tax_code%TYPE := NULL;
   l_third_party_flag               VARCHAR2(1) := 'N';
   l_competitor_flag                VARCHAR2(1) := 'N';
   l_fob_point                      hz_cust_accounts.fob_point%TYPE := NULL;
   l_tax_header_level_flag          hz_cust_accounts.tax_header_level_flag%TYPE := NULL;
   l_tax_rounding_rule              hz_cust_accounts.tax_rounding_rule%TYPE := NULL;
   l_account_name                   hz_cust_accounts.account_name%TYPE := NULL;
   l_freight_term                   hz_cust_accounts.freight_term%TYPE := NULL;
   l_ship_partial                   hz_cust_accounts.ship_partial%TYPE := NULL;
   l_ship_via                       hz_cust_accounts.ship_via%TYPE := NULL;
   l_warehouse_id                   hz_cust_accounts.warehouse_id%TYPE := NULL;
   l_payment_term_id                hz_cust_accounts.payment_term_id%TYPE := NULL;
   l_DATES_NEGATIVE_TOLERANCE       hz_cust_accounts.DATES_NEGATIVE_TOLERANCE%TYPE := NULL;
   l_DATES_POSITIVE_TOLERANCE       hz_cust_accounts.DATES_POSITIVE_TOLERANCE%TYPE := NULL;
   l_DATE_TYPE_PREFERENCE           hz_cust_accounts.DATE_TYPE_PREFERENCE%TYPE := NULL;
   l_OVER_SHIPMENT_TOLERANCE        hz_cust_accounts.OVER_SHIPMENT_TOLERANCE%TYPE := NULL;
   l_UNDER_SHIPMENT_TOLERANCE       hz_cust_accounts.UNDER_SHIPMENT_TOLERANCE%TYPE := NULL;
   l_ITEM_CROSS_REF_PREF            hz_cust_accounts.ITEM_CROSS_REF_PREF%TYPE := NULL;
   l_OVER_RETURN_TOLERANCE          hz_cust_accounts.OVER_RETURN_TOLERANCE%TYPE := NULL;
   l_UNDER_RETURN_TOLERANCE         hz_cust_accounts.UNDER_RETURN_TOLERANCE%TYPE := NULL;
   l_SHIP_SETS_INCLUDE_LINES_FLAG   hz_cust_accounts.SHIP_SETS_INCLUDE_LINES_FLAG%TYPE := 'N';
   l_ARRIVALSETS_INCL_LINES_FLAG    hz_cust_accounts.ARRIVALSETS_INCLUDE_LINES_FLAG%TYPE := 'N';
   l_SCHED_DATE_PUSH_FLAG           hz_cust_accounts.SCHED_DATE_PUSH_FLAG%TYPE := 'N';
   l_INVOICE_QUANTITY_RULE          hz_cust_accounts.INVOICE_QUANTITY_RULE%TYPE := NULL;
   l_party_number                   hz_parties.party_number%TYPE := NULL;
   l_customer_key                   hz_parties.customer_key%TYPE := NULL;
   l_person_profile_id              hz_person_profiles.person_profile_id%TYPE := NULL;
   l_pre_name_adjunct               hz_parties.person_pre_name_adjunct%TYPE := NULL;
   l_name_suffix                    hz_parties.person_name_suffix%TYPE := NULL;
   l_tax_reference                  hz_person_profiles.tax_reference%TYPE := NULL;
   l_taxpayer_id                    hz_parties.jgzz_fiscal_code%TYPE := NULL;
   l_party_name_phonetic            hz_parties.organization_name_phonetic%TYPE := NULL;
   l_customer_profile_id            hz_customer_profiles.cust_account_profile_id%TYPE := NULL;
   l_collector_id                   hz_customer_profiles.collector_id%TYPE := NULL;
   l_collector_name                 VARCHAR2(80) := NULL;
   l_credit_analyst_id              hz_customer_profiles.credit_analyst_id%TYPE := NULL;
   l_credit_checking                hz_customer_profiles.credit_checking%TYPE := 'Y';
   l_next_credit_review_date        hz_customer_profiles.next_credit_review_date%TYPE := NULL;
   l_tolerance                      hz_customer_profiles.tolerance%TYPE := 0;
   l_discount_terms                 hz_customer_profiles.discount_terms%TYPE := 'Y';
   l_dunning_letters                hz_customer_profiles.dunning_letters%TYPE := 'Y';
   l_interest_charges               hz_customer_profiles.interest_charges%TYPE := 'Y';
   l_send_statements                hz_customer_profiles.send_statements%TYPE := 'Y';
   l_statement_cycle_name           VARCHAR2(80) := NULL;
   l_standard_terms_name            VARCHAR2(80) := NULL;
   l_credit_balance_statements      hz_customer_profiles.credit_balance_statements%TYPE := 'Y';
   l_credit_hold                    hz_customer_profiles.credit_hold%TYPE := 'N';
   l_profile_class_id               hz_customer_profiles.profile_class_id%TYPE := 0;
   l_site_use_id                    hz_customer_profiles.site_use_id%TYPE := NULL;
   l_credit_rating                  hz_customer_profiles.credit_rating%TYPE := NULL;
   l_risk_code                      hz_customer_profiles.risk_code%TYPE := NULL;
   l_standard_terms                 hz_customer_profiles.standard_terms%TYPE := NULL;
   l_override_terms                 hz_customer_profiles.override_terms%TYPE := 'Y';
   l_dunning_letter_set_id          hz_customer_profiles.dunning_letter_set_id%TYPE := NULL;
   l_dunning_letter_set_name        VARCHAR2(80) := NULL;
   l_interest_period_days           hz_customer_profiles.interest_period_days%TYPE := NULL;
   l_payment_grace_days             hz_customer_profiles.payment_grace_days%TYPE := 0;
   l_discount_grace_days            hz_customer_profiles.discount_grace_days%TYPE := 0;
   l_statement_cycle_id             hz_customer_profiles.statement_cycle_id%TYPE := NULL;
   l_account_status                 hz_customer_profiles.account_status%TYPE := NULL;
   l_percent_collectable            hz_customer_profiles.percent_collectable%TYPE := NULL;
   l_autocash_hierarchy_id          hz_customer_profiles.autocash_hierarchy_id%TYPE := NULL;
   l_auto_rec_incl_disputed_flag    hz_customer_profiles.auto_rec_incl_disputed_flag%TYPE := 'Y';
   l_autocash_hierarchy_name        VARCHAR2(80) := NULL;
   l_autocash_hierarchy_name_adr    VARCHAR2(80) := NULL;
   l_tax_printing_option            hz_customer_profiles.tax_printing_option%TYPE := NULL;
   l_charge_on_fin_charge_flag      hz_customer_profiles.charge_on_finance_charge_flag%TYPE := 'N';
   l_grouping_rule_id               hz_customer_profiles.grouping_rule_id%TYPE := NULL;
   l_grouping_rule_name             VARCHAR2(80) := NULL;
   l_clearing_days                  hz_customer_profiles.clearing_days%TYPE := NULL;
   l_cons_inv_flag                  hz_customer_profiles.cons_inv_flag%TYPE := 'N';
   l_cons_inv_type                  hz_customer_profiles.cons_inv_type%TYPE := NULL;
   l_autocash_hier_id_for_adr       hz_customer_profiles.autocash_hierarchy_id_for_adr%TYPE := NULL;
   l_lockbox_matching_option        hz_customer_profiles.lockbox_matching_option%TYPE := NULL;
   l_lockbox_matching_name          VARCHAR2(80) := NULL;

   s_Address_Id                     hz_locations.location_id%TYPE := NULL;
   s_Status                         hz_party_sites.Status%TYPE := 'A';
   s_Orig_System_Reference          hz_locations.Orig_System_Reference%TYPE := NULL;
   s_Country                        hz_locations.Country%TYPE := NULL;
   s_Address1                       hz_locations.Address1%TYPE := NULL;
   s_Address2                       hz_locations.Address2%TYPE := NULL;
   s_Address3                       hz_locations.Address3%TYPE := NULL;
   s_Address4                       hz_locations.Address4%TYPE := NULL;
   s_City                           hz_locations.City%TYPE := NULL;
   s_Postal_Code                    hz_locations.Postal_Code%TYPE := NULL;
   s_State                          hz_locations.State%TYPE := NULL;
   s_Province                       hz_locations.Province%TYPE := NULL;
   s_County                         hz_locations.County%TYPE := NULL;
   s_Last_Update_Login              hz_locations.Last_Update_Login%TYPE := nvl(fnd_global.user_id,1);
   s_Address_Key                    hz_locations.Address_Key%TYPE := NULL;
   s_Language                       hz_locations.Language%TYPE := NULL;
   s_Attribute_Category             hz_locations.Attribute_Category%TYPE := NULL;
   s_Attribute1                     hz_locations.Attribute1%TYPE := NULL;
   s_Attribute2                     hz_locations.Attribute2%TYPE := NULL;
   s_Attribute3                     hz_locations.Attribute3%TYPE := NULL;
   s_Attribute4                     hz_locations.Attribute4%TYPE := NULL;
   s_Attribute5                     hz_locations.Attribute5%TYPE := NULL;
   s_Attribute6                     hz_locations.Attribute6%TYPE := NULL;
   s_Attribute7                     hz_locations.Attribute7%TYPE := NULL;
   s_Attribute8                     hz_locations.Attribute8%TYPE := NULL;
   s_Attribute9                     hz_locations.Attribute9%TYPE := NULL;
   s_Attribute10                    hz_locations.Attribute10%TYPE := NULL;
   s_Attribute11                    hz_locations.Attribute11%TYPE := NULL;
   s_Attribute12                    hz_locations.Attribute12%TYPE := NULL;
   s_Attribute13                    hz_locations.Attribute13%TYPE := NULL;
   s_Attribute14                    hz_locations.Attribute14%TYPE := NULL;
   s_Attribute15                    hz_locations.Attribute15%TYPE := NULL;
   s_Attribute16                    hz_locations.Attribute16%TYPE := NULL;
   s_Attribute17                    hz_locations.Attribute17%TYPE := NULL;
   s_Attribute18                    hz_locations.Attribute18%TYPE := NULL;
   s_Attribute19                    hz_locations.Attribute19%TYPE := NULL;
   s_Attribute20                    hz_locations.Attribute20%TYPE := NULL;
   s_Global_Attribute_Category      hz_locations.Global_Attribute_Category%TYPE := NULL;
   s_Global_Attribute1              hz_locations.Global_Attribute1%TYPE := NULL;
   s_Global_Attribute2              hz_locations.Global_Attribute2%TYPE := NULL;
   s_Global_Attribute3              hz_locations.Global_Attribute3%TYPE := NULL;
   s_Global_Attribute4              hz_locations.Global_Attribute4%TYPE := NULL;
   s_Global_Attribute5              hz_locations.Global_Attribute5%TYPE := NULL;
   s_Global_Attribute6              hz_locations.Global_Attribute6%TYPE := NULL;
   s_Global_Attribute7              hz_locations.Global_Attribute7%TYPE := NULL;
   s_Global_Attribute8              hz_locations.Global_Attribute8%TYPE := NULL;
   s_Global_Attribute9              hz_locations.Global_Attribute9%TYPE := NULL;
   s_Global_Attribute10             hz_locations.Global_Attribute10%TYPE := NULL;
   s_Global_Attribute11             hz_locations.Global_Attribute11%TYPE := NULL;
   s_Global_Attribute12             hz_locations.Global_Attribute12%TYPE := NULL;
   s_Global_Attribute13             hz_locations.Global_Attribute13%TYPE := NULL;
   s_Global_Attribute14             hz_locations.Global_Attribute14%TYPE := NULL;
   s_Global_Attribute15             hz_locations.Global_Attribute15%TYPE := NULL;
   s_Global_Attribute16             hz_locations.Global_Attribute16%TYPE := NULL;
   s_Global_Attribute17             hz_locations.Global_Attribute17%TYPE := NULL;
   s_Global_Attribute18             hz_locations.Global_Attribute18%TYPE := NULL;
   s_Global_Attribute19             hz_locations.Global_Attribute19%TYPE := NULL;
   s_Global_Attribute20             hz_locations.Global_Attribute20%TYPE := NULL;

   s_Address_warning                BOOLEAN;
   s_Address_Lines_Phonetic         hz_locations.Address_Lines_Phonetic%TYPE := NULL;
   s_Party_site_id                  hz_party_sites.Party_site_id%TYPE := NULL;
   s_Party_id                       hz_party_sites.Party_id%TYPE := NULL;
   s_Location_id                    hz_party_sites.Location_id%TYPE := NULL;
   s_Party_Site_Number              hz_party_sites.Party_Site_Number%TYPE := NULL;
   s_Identifying_address_flag       hz_party_sites.Identifying_address_flag%TYPE := 'N';
   s_Cust_acct_site_id              hz_cust_acct_sites_all.Cust_acct_site_id%TYPE := NULL;
   s_Cust_account_id                hz_cust_acct_sites_all.Cust_account_id%TYPE := NULL;
   s_su_Bill_To_Flag                hz_cust_acct_sites_all.Bill_To_Flag%TYPE := 'Y';
   s_su_Ship_To_Flag                hz_cust_acct_sites_all.Ship_To_Flag%TYPE := 'Y';
   s_su_Market_Flag                 hz_cust_acct_sites_all.Market_Flag%TYPE := 'Y';
   s_su_stmt_flag                   VARCHAR2(1) := 'N';
   s_su_dun_flag                    VARCHAR2(1) := 'N';
   s_su_legal_flag                  VARCHAR2(1) := 'N';
   s_Customer_Category              hz_cust_acct_sites_all.Customer_Category_code%TYPE := NULL;
   s_Key_Account_Flag               hz_cust_acct_sites_all.Key_Account_Flag%TYPE := 'N';
   s_Territory_id                   hz_cust_acct_sites_all.Territory_id%TYPE := NULL;
   s_ece_tp_location_code           hz_cust_acct_sites_all.ece_tp_location_code%TYPE := NULL;
   s_address_mode                   fnd_territories.address_style%TYPE := 'STANDARD';
   s_territory                      hz_cust_acct_sites_all.territory%TYPE := NULL;
   s_translated_customer_name       hz_cust_acct_sites_all.translated_customer_name%TYPE := NULL;
   s_sales_tax_geo_code             hz_locations.sales_tax_geocode%TYPE := NULL;
   s_sale_tax_inside_city_limits    hz_locations.sales_tax_inside_city_limits%TYPE := '1';
   s_ADDRESSEE                      VARCHAR2(50) := NULL;
   s_shared_party_site              VARCHAR2(1) := 'N';
   s_update_account_site            VARCHAR2(1) := 'N';
   s_create_location_party_site     VARCHAR2(1) := 'N';
   t_site_use_id                    hz_cust_site_uses_all.site_use_id%TYPE;
   t_cust_acct_site_id              hz_cust_site_uses_all.cust_acct_site_id%TYPE;
   t_primary_flag                   hz_cust_site_uses_all.primary_flag%TYPE;
   t_status                         hz_cust_site_uses_all.status%TYPE;
   t_address_id                     po_location_associations_all.address_id%TYPE;
   t_site_loc_id                    hr_locations.location_id%TYPE;
   t_orig_system_reference          hz_locations.orig_system_reference%TYPE;
   t_last_update_date               DATE;
   t_party_site_last_update_date    DATE;
   t_loc_last_update_date           DATE;
   t_party_id                       hz_cust_accounts.party_id%TYPE;
   t_party_site_id                  hz_party_sites.party_site_id%TYPE;
   t_party_site_number              hz_party_sites.party_site_number%TYPE;
   t_Bill_To_Flag                   hz_cust_acct_sites_all.Bill_To_Flag%TYPE;
   t_Ship_To_Flag                   hz_cust_acct_sites_all.Ship_To_Flag%TYPE;
   t_Market_Flag                    hz_cust_acct_sites_all.Market_Flag%TYPE;
   t_Customer_Category              hz_cust_acct_sites_all.Customer_Category_code%TYPE;
   t_Key_Account_Flag               hz_cust_acct_sites_all.Key_Account_Flag%TYPE;
   t_territory_id                   hz_cust_acct_sites_all.territory_id%TYPE;
   t_territory                      hz_cust_acct_sites_all.territory%TYPE;
   t_ece_tp_location_code           hz_cust_acct_sites_all.ece_tp_location_code%TYPE;
   t_translated_customer_name       hz_cust_acct_sites_all.translated_customer_name%TYPE;
--   l_sql_str                        varchar2(1000);
--   l_where_clause                   varchar2(500);
   t_inv_location_id                csp_requirement_headers.ship_to_location_id%TYPE;
   l_timezone_id                    csp_requirement_headers.timezone_id%TYPE;
   l_rs_cust_relation_id			number;
   l_process_type                   varchar2(30);
   l_column_NAME                    varchar2(30);
   l_org_id number;
   psite_rec                        hz_party_site_v2pub.party_site_rec_type;  --rrajain

      CURSOR c_party_id IS
    select papf.party_id
   from   jtf_rs_resource_extns jrre,
          per_all_people_f papf
   where  papf.person_id = jrre.source_id
   and    jrre.resource_id = l_resource_id
   and    decode(l_resource_type,'RS_EMPLOYEE','EMPLOYEE',null) = jrre.category
   and    trunc(sysdate) between trunc(papf.effective_start_date) and
                                 trunc(papf.effective_end_date)
   and    jrre.category = 'EMPLOYEE'
   UNION ALL
    select hp.party_id
   from   jtf_rs_resource_extns jrre,
          hz_parties hp
   where  hp.party_id = jrre.source_id
   and    jrre.resource_id = l_resource_id
   and jrre.category = 'PARTY';


   CURSOR l_resource_id_csr IS
      select resource_type_code, resource_id from jtf_task_assignments where task_assignment_id = p_task_assignment_id and assignee_role = 'ASSIGNEE';

   CURSOR l_customer_id_csr IS
   select rs_cust_relation_id,
		customer_id
   from   csp_rs_cust_relations
   where  resource_type = l_resource_type
   and    resource_id = l_resource_id;

   CURSOR l_party_id_csr IS
      select party_id from hz_cust_accounts where cust_account_id = l_customer_id;

   CURSOR l_requirement_hdr_csr IS
--      select ship_to_location_id from csp_requirement_headers where task_assignment_id = p_task_assignment_id;
      select ship_to_location_id,
timezone_id
from csp_requirement_headers
where task_assignment_id = p_task_assignment_id;

   CURSOR l_resource_name_csr IS
      select resource_name,
source_first_name,
source_middle_name,
source_last_name
from jtf_rs_resource_extns_vl
where category = substr(l_resource_type, 4) and resource_id = l_resource_id;

--   CURSOR l_sql_str_csr IS
--      select 'select '||select_id||' select_id, '||select_name||' select_name '|| 'from '||from_table sql_str, where_clause
--      from jtf_objects_vl where object_code = l_resource_type;

   CURSOR l_party_number_csr IS
      select hz_parties_s.nextval from dual;

   CURSOR l_customer_number_csr IS
      select hz_cust_accounts_s.nextval from dual;

   CURSOR l_party_site_number_csr IS
      select hz_party_sites_s.nextval from dual;

   CURSOR l_po_loc_association_csr IS
      select p.customer_id,
p.address_id,
p.site_use_id,
ps.location_id,
p.address_id,
ps.identifying_address_flag,
ps.status,
z.orig_system_reference,
ps.party_id,
c.party_site_id,
ps.party_site_number,
c.bill_to_flag,
c.market_flag,
c.ship_to_flag,
c.customer_category_code,
c.key_account_flag,
c.territory_id,
c.territory,
c.ece_tp_location_code,
c.translated_customer_name,
c.last_update_date,
ps.last_update_date,
z.last_update_date
        from po_location_associations p, hz_locations z, hz_cust_acct_sites c, hz_party_sites ps
        where p.address_id = c.cust_acct_site_id and c.party_site_id = ps.party_site_id and ps.location_id = z.location_id and p.location_id = l_inv_location_id;

   CURSOR l_inv_loc_csr IS
      select address_line_1, address_line_2, address_line_3, decode(style, 'IN', loc_information15, 'IN_GLB', loc_information15, town_or_city),
         country, postal_code, region_1,
         decode(style, 'IN', loc_information16, 'IN_GLB', loc_information16, region_2), region_3, attribute_category,
        attribute1, attribute2, attribute3, attribute4, attribute5, attribute6, attribute7, attribute8, attribute9, attribute10, attribute11,
        attribute12, attribute13, attribute14, attribute15, attribute16, attribute17, attribute18, attribute19, attribute20, global_attribute_category,
        global_attribute1, global_attribute2, global_attribute3, global_attribute4, global_attribute5, global_attribute6, global_attribute7,
        global_attribute8, global_attribute9, global_attribute10, global_attribute11, global_attribute12, global_attribute13, global_attribute14,
        global_attribute15, global_attribute16, global_attribute17, global_attribute18, global_attribute19, global_attribute20 from hr_locations where location_id = l_inv_location_id;

   CURSOR l_identify_address_flag_csr IS
      select identifying_address_flag from hz_party_sites where party_id = l_party_id and identifying_address_flag = 'Y' and status = 'A';

    Cursor province_enabled IS
    select APPLICATION_COLUMN_NAME
    from FND_DESCR_FLEX_COL_USAGE_VL
    where DESCRIPTIVE_FLEXFIELD_NAME like 'Address Location'
    and upper(END_USER_COLUMN_NAME) like 'PROVINCE'
    and  DESCRIPTIVE_FLEX_CONTEXT_CODE = p_style;

   CURSOR l_cust_acct_site(p_cust_acct_site_id number) IS
      select attribute_category,
             attribute1,attribute2,attribute3,attribute4,attribute5,
             attribute6,attribute7,attribute8,attribute9,attribute10,
             attribute11,attribute12,attribute13,attribute14,attribute15,
             attribute16,attribute17,attribute18,attribute19,attribute20
      from hz_cust_acct_sites_all where cust_acct_site_id = p_cust_acct_site_id;


	cursor c_check_hz_party_rule is
	SELECT 1
	FROM hz_party_usage_rules
	WHERE party_usage_rule_type  = 'CANNOT_COEXIST'
	AND party_usage_code         = 'SUPPLIER'
	AND RELATED_PARTY_USAGE_CODE = 'CUSTOMER'
	AND EXISTS
	  (SELECT 1
	  FROM hz_party_usg_assignments
	  WHERE party_id       = l_party_id
	  AND party_usage_code = 'SUPPLIER'
	  )
	AND NVL(EFFECTIVE_START_DATE, sysdate-1) < sysdate
	AND NVL(effective_end_date, sysdate  +1) > sysdate;

	l_module_name varchar2(100);

BEGIN
   SAVEPOINT ship_to_address_handler_PUB;

   l_module_name := 'csp.plsql.csp_ship_to_address_pvt.ship_to_address_handler1';

	if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
		FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
			l_module_name,
			'Begin... p_resource_type=' || p_resource_type
			|| ', p_resource_id=' || p_resource_id
			|| ', p_location_id=' || p_location_id
			|| ', p_timezone=' || p_timezone
			|| ', p_primary_flag=' || p_primary_flag
			|| ', p_status=' || p_status
			|| ', p_object_version_number=' || p_object_version_number);
	end if;

   -- initialize message list
   FND_MSG_PUB.initialize;

   IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                        p_api_version_number,
                                        l_api_name,
                                        G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;
   select userenv('LANG') into s_language from dual;
   csp_ship_to_address_pvt.g_rs_cust_relation_id := null;
   csp_ship_to_address_pvt.call_internal_hook('CSP_SHIP_TO_ADDRESS_PVT','SHIP_TO_ADDRESS_HANDLER','B',x_return_status);

   -- If task assignment id and addresses are both null, return error.
   IF (p_task_assignment_id IS NULL) and (p_country IS NULL) THEN
      FND_MESSAGE.SET_NAME ('CSP', 'CSP_TSK_ASSGN_ID_OR_ADDR_REQD');
      FND_MSG_PUB.ADD;
      RAISE EXCP_USER_DEFINED;
   END IF;


   -- If address fields are not null:
   --   If location_id is null, create a new inventory location.
   --   If location_id is not null, update the existing inventory location.
   IF p_country IS NOT NULL THEN
   BEGIN
      IF p_location_id IS NULL THEN
         do_create_ship_to_location(
         p_location_id            => p_location_id,
         p_style                  => p_style,
         p_address_line_1         => p_address_line_1,
         p_address_line_2         => p_address_line_2,
         p_address_line_3         => p_address_line_3,
         p_country                => p_country,
         p_postal_code            => p_postal_code,
         p_region_1               => p_region_1,
         p_region_2               => p_region_2,
         p_region_3               => p_region_3,
         p_town_or_city           => p_town_or_city,
         p_tax_name               => p_tax_name,
         p_telephone_number_1     => p_telephone_number_1,
         p_telephone_number_2     => p_telephone_number_2,
         p_telephone_number_3     => p_telephone_number_3,
         p_loc_information13      => p_loc_information13,
         p_loc_information14      => p_loc_information14,
         p_loc_information15      => p_loc_information15,
         p_loc_information16      => p_loc_information16,
         p_loc_information17      => p_loc_information17,
         p_loc_information18      => p_loc_information18,
         p_loc_information19      => p_loc_information19,
         p_loc_information20      => p_loc_information20,
         p_object_version_number  => p_object_version_number,
         p_attribute1                  => p_attribute1,
      p_attribute2                  => p_attribute2,
      p_attribute3                  => p_attribute3,
      p_attribute4                  => p_attribute4,
      p_attribute5                  => p_attribute5,
      p_attribute6                  => p_attribute6,
      p_attribute7                  => p_attribute7,
      p_attribute8                  => p_attribute8,
      p_attribute9                  => p_attribute9,
      p_attribute10                  => p_attribute10,
      p_attribute11                  => p_attribute11,
      p_attribute12                  => p_attribute12,
      p_attribute13                  => p_attribute13,
      p_attribute14                  => p_attribute14,
      p_attribute15                  => p_attribute15,
      p_attribute16                  => p_attribute16,
      p_attribute17                  => p_attribute17,
      p_attribute18                  => p_attribute18,
      p_attribute19                  => p_attribute19,
      p_attribute20                  => p_attribute20,
      p_attribute_category          => p_attribute_category,
         x_return_status          => x_return_status,
         x_msg_count              => x_msg_count,
         x_msg_data               => x_msg_data);
         l_process_type := 'INSERT';
      ELSE
         do_update_ship_to_location(
         p_location_id            => p_location_id,
         p_style                  => p_style,
         p_address_line_1         => p_address_line_1,
         p_address_line_2         => p_address_line_2,
         p_address_line_3         => p_address_line_3,
         p_country                => p_country,
         p_postal_code            => p_postal_code,
         p_region_1               => p_region_1,
         p_region_2               => p_region_2,
         p_region_3               => p_region_3,
         p_town_or_city           => p_town_or_city,
         p_tax_name               => p_tax_name,
         p_telephone_number_1     => p_telephone_number_1,
         p_telephone_number_2     => p_telephone_number_2,
         p_telephone_number_3     => p_telephone_number_3,
         p_loc_information13      => p_loc_information13,
         p_loc_information14      => p_loc_information14,
         p_loc_information15      => p_loc_information15,
         p_loc_information16      => p_loc_information16,
         p_loc_information17      => p_loc_information17,
         p_loc_information18      => p_loc_information18,
         p_loc_information19      => p_loc_information19,
         p_loc_information20      => p_loc_information20,
         p_object_version_number  => p_object_version_number,
         p_attribute1                  => p_attribute1,
      p_attribute2                  => p_attribute2,
      p_attribute3                  => p_attribute3,
      p_attribute4                  => p_attribute4,
      p_attribute5                  => p_attribute5,
      p_attribute6                  => p_attribute6,
      p_attribute7                  => p_attribute7,
      p_attribute8                  => p_attribute8,
      p_attribute9                  => p_attribute9,
      p_attribute10                  => p_attribute10,
      p_attribute11                  => p_attribute11,
      p_attribute12                  => p_attribute12,
      p_attribute13                  => p_attribute13,
      p_attribute14                  => p_attribute14,
      p_attribute15                  => p_attribute15,
      p_attribute16                  => p_attribute16,
      p_attribute17                  => p_attribute17,
      p_attribute18                  => p_attribute18,
      p_attribute19                  => p_attribute19,
      p_attribute20                  => p_attribute20,
      p_attribute_category          => p_attribute_category,
         x_return_status          => x_return_status,
         x_msg_count              => x_msg_count,
         x_msg_data               => x_msg_data);
         l_process_type := 'UPDATE';
      END IF;
      l_inv_location_id := p_location_id;
      IF x_return_status in ('E','U') THEN
         Rollback to ship_to_address_handler_PUB;
         /*FND_MESSAGE.SET_NAME ('CSP', 'CSP_STA_API_ERROR');
         FND_MESSAGE.SET_TOKEN ('TEXT', x_msg_data);
         FND_MSG_PUB.ADD;*/
         RAISE EXCP_USER_DEFINED;
      END IF;

   END;
   END IF;

   -- If p_task_assignment_id is not null or (resource_type and resource_id are not null), it will
   -- create account if the engineer doesn't exist in the customer table yet, then create sites.
   IF (p_task_assignment_id IS NOT NULL) or
      (p_resource_type IS NOT NULL and p_resource_id IS NOT NULL) THEN
   BEGIN
      IF p_resource_type IS NOT NULL and p_resource_id IS NOT NULL THEN
         l_resource_type := p_resource_type;
         l_resource_id := p_resource_id;
      ELSE
         -- Use task_assignment_id to retrieve resource_type, and resource_id
         OPEN l_resource_id_csr;
         FETCH l_resource_id_csr INTO l_resource_type, l_resource_id;
         IF l_resource_id_csr%NOTFOUND THEN
            CLOSE l_resource_id_csr;
            FND_MESSAGE.SET_NAME ('CSP', 'CSP_RESOURCE_ID_MISSING');
            FND_MESSAGE.SET_TOKEN('TSK_ASSGN_ID', p_task_assignment_id, false);
            FND_MSG_PUB.ADD;
            RAISE EXCP_USER_DEFINED;
         END IF;
         CLOSE l_resource_id_csr;
      END IF;

      IF p_task_assignment_id IS NOT NULL THEN
--      IF l_inv_location_id IS NULL THEN
         -- Use task_assignment_id to retrieve inventory_location_id from csp_requirement_headers
         OPEN l_requirement_hdr_csr;
--         FETCH l_requirement_hdr_csr INTO l_inv_location_id;
         FETCH l_requirement_hdr_csr INTO t_inv_location_id, l_timezone_id;
         IF l_requirement_hdr_csr%NOTFOUND THEN
            CLOSE l_requirement_hdr_csr;
--            FND_MESSAGE.SET_NAME ('CSP', 'CSP_INV_LOC_MISSING');
--            FND_MESSAGE.SET_TOKEN('TSK_ASSGN_ID', p_task_assignment_id, TRUE);
--            FND_MSG_PUB.ADD;
--            RAISE EXCP_USER_DEFINED;
            t_inv_location_id := null;
            l_timezone_id := null;
         ELSE
            CLOSE l_requirement_hdr_csr;
         END IF;
      END IF;

      IF l_inv_location_id IS NULL THEN
         l_inv_location_id := t_inv_location_id;
      END IF;

      IF p_timezone IS NOT NULL THEN
         l_timezone_id := p_timezone;
      END IF;

      IF l_inv_location_id IS NULL THEN
         FND_MESSAGE.SET_NAME ('CSP', 'CSP_INV_LOC_MISSING');
         FND_MESSAGE.SET_TOKEN('TSK_ASSGN_ID', p_task_assignment_id, false);
         FND_MSG_PUB.ADD;
         RAISE EXCP_USER_DEFINED;
      END IF;

-- Get party_id if it exists for this resource
      open  c_party_id;
      fetch c_party_id into l_party_id;
      close c_party_id;

	if l_resource_type = 'RS_EMPLOYEE' then
		open c_check_hz_party_rule;
		if c_check_hz_party_rule%notfound then
			close c_check_hz_party_rule;
		else
			l_party_id := null;
		end if;
		close c_check_hz_party_rule;
	end if;

      -- Retrieve customer_id from CSP_RS_CUST_RELATIONS
      -- If found, no need to create new customer account for this resource
      OPEN l_customer_id_csr;
      FETCH l_customer_id_csr INTO l_rs_cust_relation_id,l_customer_id;
	 csp_ship_to_address_pvt.g_rs_cust_relation_id := l_rs_cust_relation_id;
      IF l_customer_id_csr%FOUND and l_customer_id IS NOT NULL THEN
         CLOSE l_customer_id_csr;

         -- Use the customer_id to retrieve party_id from hz_cust_accounts
         OPEN l_party_id_csr;
         FETCH l_party_id_csr INTO l_party_id;
         IF l_party_id_csr%NOTFOUND THEN
            CLOSE l_party_id_csr;
            FND_MESSAGE.SET_NAME ('CSP', 'CSP_PARTY_ID_MISSING');
            FND_MESSAGE.SET_TOKEN('RESOURCE_ID', l_resource_id, false);
            FND_MESSAGE.SET_TOKEN('CUST_ID', l_customer_id, false);
            FND_MSG_PUB.ADD;
            RAISE EXCP_USER_DEFINED;
         END IF;
         CLOSE l_party_id_csr;

      ELSE
         CLOSE l_customer_id_csr;
         l_customer_id := null;

         -- prepare to create account
         -- retrieve resource name information to create new account
         OPEN l_resource_name_csr;
         FETCH l_resource_name_csr INTO l_resource_name, l_first_name, l_middle_name, l_last_name;
         IF l_resource_name_csr%FOUND AND (l_first_name IS NULL and l_last_name IS NULL) THEN
            l_first_name := l_resource_name;
            l_last_name := l_resource_name;
         END IF;
         IF l_resource_name_csr%NOTFOUND THEN
--            CLOSE l_resource_name_csr;
--            FND_MESSAGE.SET_NAME ('CSP', 'CSP_RESOURCE_NAME_MISSING');
--            FND_MESSAGE.SET_TOKEN('TSK_ASSGN_ID', p_task_assignment_id, TRUE);
--            FND_MESSAGE.SET_TOKEN('RESOURCE_CODE', l_resource_type, TRUE);
--            FND_MESSAGE.SET_TOKEN('RESOURCE_ID', l_resource_id, TRUE);
--            FND_MSG_PUB.ADD;
--            RAISE EXCP_USER_DEFINED;
            l_resource_name := csp_pick_utils.get_object_name(l_resource_type, l_resource_id);
            l_first_name := l_resource_name;
            l_last_name := l_resource_name;
         END IF;
         CLOSE l_resource_name_csr;

         -- Create profile
--         hzp_cprof_pkg.create_profile_from_class
         csp_customer_account_pvt.create_profile_from_class
            (x_customer_profile_class_id            => l_customer_profile_class_id,
             x_customer_profile_id                  => l_customer_profile_id,
             x_customer_id                          => l_customer_id,
             x_site_use_id                          => l_site_use_id,
             x_collector_id                         => l_collector_id,
             x_collector_name                       => l_collector_name,
             x_credit_checking                      => l_credit_checking,
             x_tolerance                            => l_tolerance,
             x_interest_charges                     => l_interest_charges,
             x_charge_on_fin_charge_flag            => l_charge_on_fin_charge_flag,
             x_interest_period_days                 => l_interest_period_days,
             x_discount_terms                       => l_discount_terms,
             x_discount_grace_days                  => l_discount_grace_days,
             x_statements                           => l_send_statements,
             x_statement_cycle_id                   => l_statement_cycle_id,
             x_statement_cycle_name                 => l_statement_cycle_name,
             x_credit_balance_statements            => l_credit_balance_statements,
             x_standard_terms                       => l_standard_terms,
             x_standard_terms_name                  => l_standard_terms_name,
             x_override_terms                       => l_override_terms,
             x_payment_grace_days                   => l_payment_grace_days,
             x_dunning_letters                      => l_dunning_letters,
             x_dunning_letter_set_id                => l_dunning_letter_set_id,
             x_dunning_letter_set_name              => l_dunning_letter_set_name,
             x_autocash_hierarchy_id                => l_autocash_hierarchy_id,
             x_autocash_hierarchy_name              => l_autocash_hierarchy_name,
             x_auto_rec_incl_disputed_flag          => l_auto_rec_incl_disputed_flag,
             x_tax_printing_option                  => l_tax_printing_option,
             x_grouping_rule_id                     => l_grouping_rule_id,
             x_grouping_rule_name                   => l_grouping_rule_name,
             x_cons_inv_flag                        => l_cons_inv_flag,
             x_cons_inv_type                        => l_cons_inv_type,
             x_attribute_category                   => l_attribute_category,
             x_attribute1                           => l_attribute1,
             x_attribute2                           => l_attribute2,
             x_attribute3                           => l_attribute3,
             x_attribute4                           => l_attribute4,
             x_attribute5                           => l_attribute5,
             x_attribute6                           => l_attribute6,
             x_attribute7                           => l_attribute7,
             x_attribute8                           => l_attribute8,
             x_attribute9                           => l_attribute9,
             x_attribute10                          => l_attribute10,
             x_attribute11                          => l_attribute11,
             x_attribute12                          => l_attribute12,
             x_attribute13                          => l_attribute13,
             x_attribute14                          => l_attribute14,
             x_attribute15                          => l_attribute15,
             x_jgzz_attribute_category              => l_jgzz_attribute_category,
             x_jgzz_attribute1                      => l_jgzz_attribute1,
             x_jgzz_attribute2                      => l_jgzz_attribute2,
             x_jgzz_attribute3                      => l_jgzz_attribute3,
             x_jgzz_attribute4                      => l_jgzz_attribute4,
             x_jgzz_attribute5                      => l_jgzz_attribute5,
             x_jgzz_attribute6                      => l_jgzz_attribute6,
             x_jgzz_attribute7                      => l_jgzz_attribute7,
             x_jgzz_attribute8                      => l_jgzz_attribute8,
             x_jgzz_attribute9                      => l_jgzz_attribute9,
             x_jgzz_attribute10                     => l_jgzz_attribute10,
             x_jgzz_attribute11                     => l_jgzz_attribute11,
             x_jgzz_attribute12                     => l_jgzz_attribute12,
             x_jgzz_attribute13                     => l_jgzz_attribute13,
             x_jgzz_attribute14                     => l_jgzz_attribute14,
             x_jgzz_attribute15                     => l_jgzz_attribute15,
             x_global_attribute_category            => l_global_attribute_category,
             x_global_attribute1                    => l_global_attribute1,
             x_global_attribute2                    => l_global_attribute2,
             x_global_attribute3                    => l_global_attribute3,
             x_global_attribute4                    => l_global_attribute4,
             x_global_attribute5                    => l_global_attribute5,
             x_global_attribute6                    => l_global_attribute6,
             x_global_attribute7                    => l_global_attribute7,
             x_global_attribute8                    => l_global_attribute8,
             x_global_attribute9                    => l_global_attribute9,
             x_global_attribute10                   => l_global_attribute10,
             x_global_attribute11                   => l_global_attribute11,
             x_global_attribute12                   => l_global_attribute12,
             x_global_attribute13                   => l_global_attribute13,
             x_global_attribute14                   => l_global_attribute14,
             x_global_attribute15                   => l_global_attribute15,
             x_global_attribute16                   => l_global_attribute16,
             x_global_attribute17                   => l_global_attribute17,
             x_global_attribute18                   => l_global_attribute18,
             x_global_attribute19                   => l_global_attribute19,
             x_global_attribute20                   => l_global_attribute20,
             x_lockbox_matching_option              => l_lockbox_matching_option,
             x_lockbox_matching_name                => l_lockbox_matching_name,
             x_autocash_hierarchy_id_adr            => l_autocash_hierarchy_id,
             x_autocash_hierarchy_name_adr          => l_autocash_hierarchy_name_adr,
             x_return_status                        => x_return_status,
             x_msg_count                            => x_msg_count,
             x_msg_data                             => x_msg_data);

         IF x_return_status in ('E','U') THEN
            Rollback to ship_to_address_handler_PUB;
           /* FND_MESSAGE.SET_NAME ('CSP', 'CSP_PROF_API_ERROR');
            FND_MESSAGE.SET_TOKEN ('TEXT', x_msg_data);
            FND_MSG_PUB.ADD;*/
            RAISE EXCP_USER_DEFINED;
         END IF;

         -- if auto generate customer number is no, pass the customer number to the API
         IF nvl(arp_standard.sysparm.generate_customer_number,'Y') <> 'N' THEN
            l_customer_number := NULL;
         ELSE
            OPEN  l_customer_number_csr;
            FETCH l_customer_number_csr into l_customer_number;
            CLOSE l_customer_number_csr;
         END IF;

         -- if the party number generation profile is yes or null, pass the party number to the api
         IF  fnd_profile.value('HZ_GENERATE_PARTY_NUMBER') <> 'N' THEN
            l_party_number := NULL;
         ELSE
            OPEN  l_party_number_csr;
            FETCH l_party_number_csr into l_party_number;
            CLOSE l_party_number_csr;
         END IF;

--         hz_acct_create_pkg.insert_person_row
         csp_customer_account_pvt.insert_person_row
           (c_cust_account_id                   => l_customer_id,
            c_party_id                          => l_party_id,
            c_account_number                    => l_customer_number,
            c_Attribute_Category                => null,
            c_Attribute1                        => null,
            c_Attribute2                        => null,
            c_Attribute3                        => null,
            c_Attribute4                        => null,
            c_Attribute5                        => null,
            c_Attribute6                        => null,
            c_Attribute7                        => null,
            c_Attribute8                        => null,
            c_Attribute9                        => null,
            c_Attribute10                       => null,
            c_Attribute11                       => null,
            c_Attribute12                       => null,
            c_Attribute13                       => null,
            c_Attribute14                       => null,
            c_Attribute15                       => null,
            c_Attribute16                       => null,
            c_Attribute17                       => null,
            c_Attribute18                       => null,
            c_Attribute19                       => null,
            c_Attribute20                       => null,
            c_global_attribute_category         => l_global_attribute_category,
            c_global_attribute1                 => l_global_attribute1,
            c_global_attribute2                 => l_global_attribute2,
            c_global_attribute3                 => l_global_attribute3,
            c_global_attribute4                 => l_global_attribute4,
            c_global_attribute5                 => l_global_attribute5,
            c_global_attribute6                 => l_global_attribute6,
            c_global_attribute7                 => l_global_attribute7,
            c_global_attribute8                 => l_global_attribute8,
            c_global_attribute9                 => l_global_attribute9,
            c_global_attribute10                => l_global_attribute10,
            c_global_attribute11                => l_global_attribute11,
            c_global_attribute12                => l_global_attribute12,
            c_global_attribute13                => l_global_attribute13,
            c_global_attribute14                => l_global_attribute14,
            c_global_attribute15                => l_global_attribute15,
            c_global_attribute16                => l_global_attribute16,
            c_global_attribute17                => l_global_attribute17,
            c_global_attribute18                => l_global_attribute18,
            c_global_attribute19                => l_global_attribute19,
            c_global_attribute20                => l_global_attribute20,
            c_orig_system_reference             => l_orig_system_reference,
            c_status                            => l_status,
            c_customer_type                     => l_customer_type,
            c_customer_class_code               => l_customer_class_code,
            c_primary_salesrep_id               => l_primary_salesrep_id,
            c_sales_channel_code                => l_sales_channel_code,
            c_order_type_id                     => l_order_type_id,
            c_price_list_id                     => l_price_list_id,
            c_category_code                     => l_category_code,
            c_reference_use_flag                => l_reference_use_flag,
            c_tax_code                          => l_tax_code,
            c_third_party_flag                  => l_third_party_flag,
            c_competitor_flag                   => l_competitor_flag,
            c_fob_point                         => l_fob_point,
            c_tax_header_level_flag             => l_tax_header_level_flag,
            c_tax_rounding_rule                 => l_tax_rounding_rule,
            c_account_name                      => l_account_name,
            c_freight_term                      => l_freight_term,
            c_ship_partial                      => l_ship_partial,
            c_ship_via                          => l_ship_via,
            c_warehouse_id                      => l_warehouse_id,
            c_payment_term_id                   => l_payment_term_id,
            c_DATES_NEGATIVE_TOLERANCE          => l_DATES_NEGATIVE_TOLERANCE,
            c_DATES_POSITIVE_TOLERANCE          => l_DATES_POSITIVE_TOLERANCE,
            c_DATE_TYPE_PREFERENCE              => l_DATE_TYPE_PREFERENCE,
            c_OVER_SHIPMENT_TOLERANCE           => l_OVER_SHIPMENT_TOLERANCE,
            c_UNDER_SHIPMENT_TOLERANCE          => l_UNDER_SHIPMENT_TOLERANCE,
            c_ITEM_CROSS_REF_PREF               => l_ITEM_CROSS_REF_PREF,
            c_OVER_RETURN_TOLERANCE             => l_OVER_RETURN_TOLERANCE,
            c_UNDER_RETURN_TOLERANCE            => l_UNDER_RETURN_TOLERANCE,
            c_SHIP_SETS_INCLUDE_LINES_FLAG      => l_SHIP_SETS_INCLUDE_LINES_FLAG,
            c_ARRIVALSETS_INCL_LINES_FLAG       => l_ARRIVALSETS_INCL_LINES_FLAG,
            c_SCHED_DATE_PUSH_FLAG              => l_SCHED_DATE_PUSH_FLAG,
            c_INVOICE_QUANTITY_RULE             => l_INVOICE_QUANTITY_RULE,
            t_party_id                          => l_party_id,
            t_party_number                      => l_party_number,
            t_customer_key                      => l_customer_key,
            t_Attribute_Category                => l_Attribute_Category,
            t_Attribute1                        => l_Attribute1,
            t_Attribute2                        => l_Attribute2,
            t_Attribute3                        => l_Attribute3,
            t_Attribute4                        => l_Attribute4,
            t_Attribute5                        => l_Attribute5,
            t_Attribute6                        => l_Attribute6,
            t_Attribute7                        => l_Attribute7,
            t_Attribute8                        => l_Attribute8,
            t_Attribute9                        => l_Attribute9,
            t_Attribute10                       => l_Attribute10,
            t_Attribute11                       => l_Attribute11,
            t_Attribute12                       => l_Attribute12,
            t_Attribute13                       => l_Attribute13,
            t_Attribute14                       => l_Attribute14,
            t_Attribute15                       => l_Attribute15,
            t_Attribute16                       => l_Attribute16,
            t_Attribute17                       => l_Attribute17,
            t_Attribute18                       => l_Attribute18,
            t_Attribute19                       => l_Attribute19,
            t_Attribute20                       => l_Attribute20,
            t_global_attribute_category         => l_global_attribute_category,
            t_global_attribute1                 => l_global_attribute1,
            t_global_attribute2                 => l_global_attribute2,
            t_global_attribute3                 => l_global_attribute3,
            t_global_attribute4                 => l_global_attribute4,
            t_global_attribute5                 => l_global_attribute5,
            t_global_attribute6                 => l_global_attribute6,
            t_global_attribute7                 => l_global_attribute7,
            t_global_attribute8                 => l_global_attribute8,
            t_global_attribute9                 => l_global_attribute9,
            t_global_attribute10                => l_global_attribute10,
            t_global_attribute11                => l_global_attribute11,
            t_global_attribute12                => l_global_attribute12,
            t_global_attribute13                => l_global_attribute13,
            t_global_attribute14                => l_global_attribute14,
            t_global_attribute15                => l_global_attribute15,
            t_global_attribute16                => l_global_attribute16,
            t_global_attribute17                => l_global_attribute17,
            t_global_attribute18                => l_global_attribute18,
            t_global_attribute19                => l_global_attribute19,
            t_global_attribute20                => l_global_attribute20,
            o_pre_name_adjunct                  => l_pre_name_adjunct,
            o_first_name                        => l_first_name,
            o_middle_name                       => l_middle_name,
            o_last_name                         => l_last_name,
            o_name_suffix                       => l_name_suffix,
            o_tax_reference                     => l_tax_reference,
            o_taxpayer_id                       => l_taxpayer_id,
            o_party_name_phonetic               => l_party_name_phonetic,
            p_cust_account_profile_id           => l_customer_profile_id,
            p_cust_account_id                   => l_customer_id,
            p_status                            => l_status,
            p_collector_id                      => l_collector_id,
            p_credit_analyst_id                 => l_credit_analyst_id,
            p_credit_checking                   => l_credit_checking,
            p_next_credit_review_date           => l_next_credit_review_date,
            p_tolerance                         => l_tolerance,
            p_discount_terms                    => l_discount_terms,
            p_dunning_letters                   => l_dunning_letters,
            p_interest_charges                  => l_interest_charges,
            p_send_statements                   => l_send_statements,
            p_credit_balance_statements         => l_credit_balance_statements,
            p_credit_hold                       => l_credit_hold,
            p_profile_class_id                  => l_customer_profile_class_id,
            p_site_use_id                       => l_site_use_id,
            p_credit_rating                     => l_credit_rating,
            p_risk_code                         => l_risk_code,
            p_standard_terms                    => l_standard_terms,
            p_override_terms                    => l_override_terms,
            p_dunning_letter_set_id             => l_dunning_letter_set_id,
            p_interest_period_days              => l_interest_period_days,
            p_payment_grace_days                => l_payment_grace_days,
            p_discount_grace_days               => l_discount_grace_days,
            p_statement_cycle_id                => l_statement_cycle_id,
            p_account_status                    => l_account_status,
            p_percent_collectable               => l_percent_collectable,
            p_autocash_hierarchy_id             => l_autocash_hierarchy_id,
            p_Attribute_Category                => l_Attribute_Category,
            p_Attribute1                        => l_Attribute1,
            p_Attribute2                        => l_Attribute2,
            p_Attribute3                        => l_Attribute3,
            p_Attribute4                        => l_Attribute4,
            p_Attribute5                        => l_Attribute5,
            p_Attribute6                        => l_Attribute6,
            p_Attribute7                        => l_Attribute7,
            p_Attribute8                        => l_Attribute8,
            p_Attribute9                        => l_Attribute9,
            p_Attribute10                       => l_Attribute10,
            p_Attribute11                       => l_Attribute11,
            p_Attribute12                       => l_Attribute12,
            p_Attribute13                       => l_Attribute13,
            p_Attribute14                       => l_Attribute14,
            p_Attribute15                       => l_Attribute15,
            p_auto_rec_incl_disputed_flag       => l_auto_rec_incl_disputed_flag,
            p_tax_printing_option               => l_tax_printing_option,
            p_charge_on_fin_charge_flag         => l_charge_on_fin_charge_flag,
            p_grouping_rule_id                  => l_grouping_rule_id,
            p_clearing_days                     => l_clearing_days,
            p_jgzz_attribute_category           => l_jgzz_attribute_category,
            p_jgzz_attribute1                   => l_jgzz_attribute1,
            p_jgzz_attribute2                   => l_jgzz_attribute2,
            p_jgzz_attribute3                   => l_jgzz_attribute3,
            p_jgzz_attribute4                   => l_jgzz_attribute4,
            p_jgzz_attribute5                   => l_jgzz_attribute5,
            p_jgzz_attribute6                   => l_jgzz_attribute6,
            p_jgzz_attribute7                   => l_jgzz_attribute7,
            p_jgzz_attribute8                   => l_jgzz_attribute8,
            p_jgzz_attribute9                   => l_jgzz_attribute9,
            p_jgzz_attribute10                  => l_jgzz_attribute10,
            p_jgzz_attribute11                  => l_jgzz_attribute11,
            p_jgzz_attribute12                  => l_jgzz_attribute12,
            p_jgzz_attribute13                  => l_jgzz_attribute13,
            p_jgzz_attribute14                  => l_jgzz_attribute14,
            p_jgzz_attribute15                  => l_jgzz_attribute15,
            p_global_attribute_category         => l_global_attribute_category,
            p_global_attribute1                 => l_global_attribute1,
            p_global_attribute2                 => l_global_attribute2,
            p_global_attribute3                 => l_global_attribute3,
            p_global_attribute4                 => l_global_attribute4,
            p_global_attribute5                 => l_global_attribute5,
            p_global_attribute6                 => l_global_attribute6,
            p_global_attribute7                 => l_global_attribute7,
            p_global_attribute8                 => l_global_attribute8,
            p_global_attribute9                 => l_global_attribute9,
            p_global_attribute10                => l_global_attribute10,
            p_global_attribute11                => l_global_attribute11,
            p_global_attribute12                => l_global_attribute12,
            p_global_attribute13                => l_global_attribute13,
            p_global_attribute14                => l_global_attribute14,
            p_global_attribute15                => l_global_attribute15,
            p_global_attribute16                => l_global_attribute16,
            p_global_attribute17                => l_global_attribute17,
            p_global_attribute18                => l_global_attribute18,
            p_global_attribute19                => l_global_attribute19,
            p_global_attribute20                => l_global_attribute20,
            p_cons_inv_flag                     => l_cons_inv_flag,
            p_cons_inv_type                     => l_cons_inv_type,
            p_autocash_hier_id_for_adr          => l_autocash_hier_id_for_adr,
            p_lockbox_matching_option           => l_lockbox_matching_option,
            o_person_profile_id                 => l_person_profile_id,
            x_msg_count                         => x_msg_count,
            x_msg_data                          => x_msg_data,
            x_return_status                     => x_return_status);

         IF x_return_status in ('E','U') THEN
            Rollback to ship_to_address_handler_PUB;
            /*FND_MESSAGE.SET_NAME ('CSP', 'CSP_CUST_API_ERROR');
            FND_MESSAGE.SET_TOKEN ('TEXT', x_msg_data);
            FND_MSG_PUB.ADD;*/
            RAISE EXCP_USER_DEFINED;
         ELSE
            -- Create/update resource customer relationship in csp_rs_cust_relations.
            do_rs_cust_relations(l_resource_type, l_resource_id, l_customer_id);
         END IF;
      END IF;

      -- Select inventory location information
      OPEN l_inv_loc_csr;
      FETCH l_inv_loc_csr INTO s_address1, s_address2, s_address3, s_city, s_country, s_postal_code, s_county, s_state, s_province, s_attribute_category,
        s_attribute1, s_attribute2, s_attribute3, s_attribute4, s_attribute5, s_attribute6, s_attribute7, s_attribute8, s_attribute9, s_attribute10, s_attribute11,
        s_attribute12, s_attribute13, s_attribute14, s_attribute15, s_attribute16, s_attribute17, s_attribute18, s_attribute19, s_attribute20, s_global_attribute_category,
        s_global_attribute1, s_global_attribute2, s_global_attribute3, s_global_attribute4, s_global_attribute5, s_global_attribute6, s_global_attribute7,
        s_global_attribute8, s_global_attribute9, s_global_attribute10, s_global_attribute11, s_global_attribute12, s_global_attribute13, s_global_attribute14,
        s_global_attribute15, s_global_attribute16, s_global_attribute17, s_global_attribute18, s_global_attribute19, s_global_attribute20;
      IF l_inv_loc_csr%NOTFOUND THEN
         CLOSE l_inv_loc_csr;
         FND_MESSAGE.SET_NAME ('CSP', 'CSP_INV_LOC_NOT_FOUND');
         FND_MESSAGE.SET_TOKEN ('LOC_ID', 'l_inv_location_id',false);
         FND_MSG_PUB.ADD;
         RAISE EXCP_USER_DEFINED;
      END IF;
      CLOSE l_inv_loc_csr;
      s_province := p_province;
      s_address_lines_phonetic := p_address_lines_phonetic;
      s_address4 := p_address_line_4;
      /* As part of bug fix  following code is included for canadian address ,
      Provice is stored in region_1 not in Region_3 of hr_locations_v*/
      l_column_NAME := null;
      OPEN province_enabled;
      FETCH province_enabled INTO l_column_NAME;
      CLOSE province_enabled;
      IF l_column_NAME IS NOT NULL AND UPPER(l_column_NAME) = 'REGION_1' THEN
            s_province := s_county;
            s_county := null;
      ELSIF l_column_NAME IS NOT NULL AND UPPER(l_column_NAME) = 'REGION_2' THEN
            s_province := s_state;
            s_state := null;
      END IF;
      -- Check if the inventory location has been assoicated to another customer site.
      -- If it is associated to the same customer, fine.  No need to create new site and site use.  Just update it.
      -- If it is associated to a different customer, stop with error message.
      OPEN l_po_loc_association_csr;
      FETCH l_po_loc_association_csr INTO
t_customer_id,
t_cust_acct_site_id,
t_site_use_id,
t_site_loc_id,
t_cust_acct_site_id,
t_primary_flag,
t_status,
t_orig_system_reference,
t_party_id,
t_party_site_id,
t_party_site_number,
t_bill_to_flag,
t_market_flag,
t_ship_to_flag,
t_customer_category,
t_key_account_flag,
t_territory_id,
t_territory,
t_ece_tp_location_code,
t_translated_customer_name,
t_last_update_date,
t_party_site_last_update_date,
t_loc_last_update_date;
      IF l_po_loc_association_csr%FOUND THEN
         CLOSE l_po_loc_association_csr;
         IF t_customer_id <> l_customer_id THEN
            FND_MESSAGE.SET_NAME ('CSP', 'CSP_INV_LOC_HAS_ASSIGNED');
            FND_MESSAGE.SET_TOKEN ('LOC_ID', 'l_inv_location_id',false);
            FND_MESSAGE.SET_TOKEN ('CUSTOMER_ID', 't_customer_id',false);
            FND_MSG_PUB.ADD;
            RAISE EXCP_USER_DEFINED;
         ELSE
            IF p_status IS NOT NULL THEN
               t_status := p_status;
            END IF;

            IF p_primary_flag IS NOT NULL THEN
               t_primary_flag := p_primary_flag;
            END IF;

	     IF l_timezone_id IS NOT NULL THEN
               update hz_locations set time_zone = l_timezone_id where location_id = t_site_loc_id;
            END IF;

         open  l_cust_acct_site(t_cust_acct_site_id);
         fetch l_cust_acct_site into l_attribute_category,
                                     l_attribute1,l_attribute2,l_attribute3,
                                     l_attribute4,l_attribute5,l_attribute6,
                                     l_attribute7,l_attribute8,l_attribute9,
                                     l_attribute10,l_attribute11,l_attribute12,
                                     l_attribute13,l_attribute14,l_attribute15,
                                     l_attribute16,l_attribute17,l_attribute18,
                                     l_attribute19,l_attribute20;
         close l_cust_acct_site;

            -- If p_primary_flag is not null or p_status is not null, calling from the
            -- Resource Ship To Address and Subinventory Assignments form, update it.
         IF p_status = 'I' THEN
            IF p_primary_flag IS NOT NULL or p_status IS NOT NULL THEN
               do_update_site_use
                 (p_site_use_id            => t_site_use_id
                 ,p_primary_flag           => p_primary_flag
                 ,p_status                 => p_status
                 ,p_customer_id            => l_customer_id
                 ,p_inv_location_id        => l_inv_location_id
                 ,x_return_status          => x_return_status
                 ,x_msg_count              => x_msg_count
                 ,x_msg_data               => x_msg_data);
            END IF;

            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               Rollback to ship_to_address_handler_PUB;
               /*FND_MESSAGE.SET_NAME ('CSP', 'CSP_SITE_USE_API_ERROR');
               FND_MESSAGE.SET_TOKEN ('TEXT', x_msg_data);
               FND_MSG_PUB.ADD;*/
               RAISE EXCP_USER_DEFINED;
            END IF;


			select last_update_date into t_last_update_date from hz_cust_acct_sites where CUST_ACCT_SITE_ID = t_cust_acct_site_id;


            -- Update the site location and related tables.
            arh_addr_pkg.update_row (
              X_Address_Id                          => t_cust_acct_site_id,
              X_Last_Update_Date                    => t_last_update_date,
              X_party_site_Last_Update_Date         => t_party_site_last_update_date,
              X_loc_Last_Update_Date                => t_loc_last_update_date,
              X_Last_Updated_By                     => nvl(fnd_global.user_id, 1),
              X_Status                              => t_status,
              X_Orig_System_Reference               => t_orig_system_reference,
              X_Country                             => s_country,
              X_Address1                            => s_address1,
              X_Address2                            => s_address2,
              X_Address3                            => s_address3,
              X_Address4                            => s_address4,
              X_City                                => s_city,
              X_Postal_Code                         => s_postal_code,
              X_State                               => s_state,
              X_Province                            => s_province,
              X_County                              => s_county,
              X_Last_Update_Login                   => nvl(fnd_global.user_id,1),
              X_Address_Key                         => s_address_key,
              X_Language                            => null,--s_language,
              X_Attribute_Category                  => l_attribute_category,
              X_Attribute1                          => l_attribute1,
              X_Attribute2                          => l_attribute2,
              X_Attribute3                          => l_attribute3,
              X_Attribute4                          => l_attribute4,
              X_Attribute5                          => l_attribute5,
              X_Attribute6                          => l_attribute6,
              X_Attribute7                          => l_attribute7,
              X_Attribute8                          => l_attribute8,
              X_Attribute9                          => l_attribute9,
              X_Attribute10                         => l_attribute10,
              X_Attribute11                         => l_attribute11,
              X_Attribute12                         => l_attribute12,
              X_Attribute13                         => l_attribute13,
              X_Attribute14                         => l_attribute14,
              X_Attribute15                         => l_attribute15,
              X_Attribute16                         => l_attribute16,
              X_Attribute17                         => l_attribute17,
              X_Attribute18                         => l_attribute18,
              X_Attribute19                         => l_attribute19,
              X_Attribute20                         => l_attribute20,
              X_Address_warning                     => s_address_warning,
              X_Address_Lines_Phonetic              => s_address_lines_phonetic,
              X_Global_Attribute_Category           => s_global_attribute_category,
              X_Global_Attribute1                   => s_global_attribute1,
              X_Global_Attribute2                   => s_global_attribute2,
              X_Global_Attribute3                   => s_global_attribute3,
              X_Global_Attribute4                   => s_global_attribute4,
              X_Global_Attribute5                   => s_global_attribute5,
              X_Global_Attribute6                   => s_global_attribute6,
              X_Global_Attribute7                   => s_global_attribute7,
              X_Global_Attribute8                   => s_global_attribute8,
              X_Global_Attribute9                   => s_global_attribute9,
              X_Global_Attribute10                  => s_global_attribute10,
              X_Global_Attribute11                  => s_global_attribute11,
              X_Global_Attribute12                  => s_global_attribute12,
              X_Global_Attribute13                  => s_global_attribute13,
              X_Global_Attribute14                  => s_global_attribute14,
              X_Global_Attribute15                  => s_global_attribute15,
              X_Global_Attribute16                  => s_global_attribute16,
              X_Global_Attribute17                  => s_global_attribute17,
              X_Global_Attribute18                  => s_global_attribute18,
              X_Global_Attribute19                  => s_global_attribute19,
              X_Global_Attribute20                  => s_global_attribute20,
              X_Party_site_id                       => t_party_site_id,
              X_Party_id                            => t_party_id,
              X_Location_id                         => t_site_loc_id,
              X_Party_Site_Number                   => t_party_site_number,
              X_Identifying_address_flag            => t_primary_flag,
              X_Cust_acct_site_id                   => t_cust_acct_site_id,
              X_Cust_account_id                     => l_customer_id,
              X_su_Bill_To_Flag                     => t_bill_to_flag,
              X_su_Ship_To_Flag                     => t_ship_to_flag,
              X_su_Market_Flag                      => t_market_flag,
              X_su_stmt_flag                        => s_su_stmt_flag,
              X_su_dun_flag                         => s_su_dun_flag,
              X_su_legal_flag                       => s_su_legal_flag,
              X_Customer_Category                   => t_customer_category,
              X_Key_Account_Flag                    => t_key_account_flag,
              X_Territory_id                        => t_territory_id,
              X_ece_tp_location_code                => t_ece_tp_location_code,
              x_address_mode                        => s_address_mode,
              X_Territory                           => t_territory,
              X_Translated_Customer_Name            => t_translated_customer_name,
              X_Sales_Tax_Geocode                   => s_sales_tax_geo_code,
              X_Sales_Tax_Inside_City_Limits        => s_sale_tax_inside_city_limits,
              x_ADDRESSEE                           => s_addressee,
              x_msg_count                           => x_msg_count,
              x_msg_data                            => x_msg_data,
              x_return_status                       => x_return_status);

            IF x_return_status in ('E','U') THEN
               Rollback to ship_to_address_handler_PUB;
               /*FND_MESSAGE.SET_NAME ('CSP', 'CSP_ADDR_API_ERROR');
               FND_MESSAGE.SET_TOKEN ('TEXT', x_msg_data);
               FND_MSG_PUB.ADD;*/
               RAISE EXCP_USER_DEFINED;
            END IF;
         ELSE
              arh_addr_pkg.update_row (
              X_Address_Id                          => t_cust_acct_site_id,
              X_Last_Update_Date                    => t_last_update_date,
              X_party_site_Last_Update_Date         => t_party_site_last_update_date,
              X_loc_Last_Update_Date                => t_loc_last_update_date,
              X_Last_Updated_By                     => nvl(fnd_global.user_id, 1),
              X_Status                              => t_status,
              X_Orig_System_Reference               => t_orig_system_reference,
              X_Country                             => s_country,
              X_Address1                            => s_address1,
              X_Address2                            => s_address2,
              X_Address3                            => s_address3,
              X_Address4                            => s_address4,
              X_City                                => s_city,
              X_Postal_Code                         => s_postal_code,
              X_State                               => s_state,
              X_Province                            => s_province,
              X_County                              => s_county,
              X_Last_Update_Login                   => nvl(fnd_global.user_id,1),
              X_Address_Key                         => s_address_key,
              X_Language                            => null,--s_language,
              X_Attribute_Category                  => l_attribute_category,
              X_Attribute1                          => l_attribute1,
              X_Attribute2                          => l_attribute2,
              X_Attribute3                          => l_attribute3,
              X_Attribute4                          => l_attribute4,
              X_Attribute5                          => l_attribute5,
              X_Attribute6                          => l_attribute6,
              X_Attribute7                          => l_attribute7,
              X_Attribute8                          => l_attribute8,
              X_Attribute9                          => l_attribute9,
              X_Attribute10                         => l_attribute10,
              X_Attribute11                         => l_attribute11,
              X_Attribute12                         => l_attribute12,
              X_Attribute13                         => l_attribute13,
              X_Attribute14                         => l_attribute14,
              X_Attribute15                         => l_attribute15,
              X_Attribute16                         => l_attribute16,
              X_Attribute17                         => l_attribute17,
              X_Attribute18                         => l_attribute18,
              X_Attribute19                         => l_attribute19,
              X_Attribute20                         => l_attribute20,
              X_Address_warning                     => s_address_warning,
              X_Address_Lines_Phonetic              => s_address_lines_phonetic,
              X_Global_Attribute_Category           => s_global_attribute_category,
              X_Global_Attribute1                   => s_global_attribute1,
              X_Global_Attribute2                   => s_global_attribute2,
              X_Global_Attribute3                   => s_global_attribute3,
              X_Global_Attribute4                   => s_global_attribute4,
              X_Global_Attribute5                   => s_global_attribute5,
              X_Global_Attribute6                   => s_global_attribute6,
              X_Global_Attribute7                   => s_global_attribute7,
              X_Global_Attribute8                   => s_global_attribute8,
              X_Global_Attribute9                   => s_global_attribute9,
              X_Global_Attribute10                  => s_global_attribute10,
              X_Global_Attribute11                  => s_global_attribute11,
              X_Global_Attribute12                  => s_global_attribute12,
              X_Global_Attribute13                  => s_global_attribute13,
              X_Global_Attribute14                  => s_global_attribute14,
              X_Global_Attribute15                  => s_global_attribute15,
              X_Global_Attribute16                  => s_global_attribute16,
              X_Global_Attribute17                  => s_global_attribute17,
              X_Global_Attribute18                  => s_global_attribute18,
              X_Global_Attribute19                  => s_global_attribute19,
              X_Global_Attribute20                  => s_global_attribute20,
              X_Party_site_id                       => t_party_site_id,
              X_Party_id                            => t_party_id,
              X_Location_id                         => t_site_loc_id,
              X_Party_Site_Number                   => t_party_site_number,
              X_Identifying_address_flag            => t_primary_flag,
              X_Cust_acct_site_id                   => t_cust_acct_site_id,
              X_Cust_account_id                     => l_customer_id,
              X_su_Bill_To_Flag                     => t_bill_to_flag,
              X_su_Ship_To_Flag                     => t_ship_to_flag,
              X_su_Market_Flag                      => t_market_flag,
              X_su_stmt_flag                        => s_su_stmt_flag,
              X_su_dun_flag                         => s_su_dun_flag,
              X_su_legal_flag                       => s_su_legal_flag,
              X_Customer_Category                   => t_customer_category,
              X_Key_Account_Flag                    => t_key_account_flag,
              X_Territory_id                        => t_territory_id,
              X_ece_tp_location_code                => t_ece_tp_location_code,
              x_address_mode                        => s_address_mode,
              X_Territory                           => t_territory,
              X_Translated_Customer_Name            => t_translated_customer_name,
              X_Sales_Tax_Geocode                   => s_sales_tax_geo_code,
              X_Sales_Tax_Inside_City_Limits        => s_sale_tax_inside_city_limits,
              x_ADDRESSEE                           => s_addressee,
              x_msg_count                           => x_msg_count,
              x_msg_data                            => x_msg_data,
              x_return_status                       => x_return_status);

            IF x_return_status in ('E','U') THEN
               Rollback to ship_to_address_handler_PUB;
               /*FND_MESSAGE.SET_NAME ('CSP', 'CSP_ADDR_API_ERROR');
               FND_MESSAGE.SET_TOKEN ('TEXT', x_msg_data);
               FND_MSG_PUB.ADD;*/
               RAISE EXCP_USER_DEFINED;
            END IF;
            IF p_primary_flag IS NOT NULL or p_status IS NOT NULL THEN
               do_update_site_use
                 (p_site_use_id            => t_site_use_id
                 ,p_primary_flag           => p_primary_flag
                 ,p_status                 => p_status
                 ,p_customer_id            => l_customer_id
                 ,p_inv_location_id        => l_inv_location_id
                 ,x_return_status          => x_return_status
                 ,x_msg_count              => x_msg_count
                 ,x_msg_data               => x_msg_data);
            END IF;

            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               Rollback to ship_to_address_handler_PUB;
               /*FND_MESSAGE.SET_NAME ('CSP', 'CSP_SITE_USE_API_ERROR');
               FND_MESSAGE.SET_TOKEN ('TEXT', x_msg_data);
               FND_MSG_PUB.ADD;*/
               RAISE EXCP_USER_DEFINED;
            END IF;

         END IF;
         END IF;
      ELSE
         CLOSE l_po_loc_association_csr;

         -- If the party site number generation profile is yes or null, pass the party site number to the api
         IF fnd_profile.value('HZ_GENERATE_PARTY_SITE_NUMBER') <> 'N' THEN
            s_party_site_number := NULL;
         ELSE
            OPEN  l_party_site_number_csr;
            FETCH l_party_site_number_csr into s_party_site_number;
            CLOSE l_party_site_number_csr;
         END IF;

         IF p_primary_flag is not null THEN
            s_identifying_address_flag := p_primary_flag;
         ELSE
            -- Check if there is an existing party site with identifying address flag set to 'Y'
            -- Set the identifying address flag to 'Y' only if there is no existing one
            OPEN l_identify_address_flag_csr;
            FETCH l_identify_address_flag_csr INTO s_identifying_address_flag;
            IF l_identify_address_flag_csr%NOTFOUND THEN
               CLOSE l_identify_address_flag_csr;
               s_identifying_address_flag := 'Y';
            ELSE
               CLOSE l_identify_address_flag_csr;
               s_identifying_address_flag := 'N';
            END IF;
         END IF;

         IF p_status is not null THEN
            s_status := p_status;
         END IF;



          SELECT TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1,1), ' ', NULL,
	        SUBSTRB(USERENV('CLIENT_INFO'),1,10)))
          INTO l_org_id
          FROM DUAL;

          mo_global.set_policy_context('S', l_org_id);

          IF P_HZ_LOCATION_ID IS NOT NULL THEN

          PSITE_REC.PARTY_ID              := L_PARTY_ID;
          PSITE_REC.LOCATION_ID           := P_HZ_LOCATION_ID;
          PSITE_REC.CREATED_BY_MODULE     := 'TCA_FORM_WRAPPER';

          PSITE_REC.IDENTIFYING_ADDRESS_FLAG := S_IDENTIFYING_ADDRESS_FLAG;
          psite_rec.status := s_status;

            HZ_PARTY_SITE_V2PUB.CREATE_PARTY_SITE (
               P_PARTY_SITE_REC                   => PSITE_REC,
               x_party_site_id                    => s_party_site_id,
               X_PARTY_SITE_NUMBER                => s_party_site_number,
               X_RETURN_STATUS                    => X_RETURN_STATUS,
               X_MSG_COUNT                        => X_MSG_COUNT,
               x_msg_data                         => x_msg_data );

                IF(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, X_RETURN_STATUS, 'Calling HZ_PARTY_SITE_V2PUB.CREATE_PARTY_SITE'); END IF;

             s_location_id  := P_HZ_LOCATION_ID;
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RETURN;
      END IF;
         END IF;

         -- create sites
          arh_addr_pkg.insert_row(
            X_Address_Id                     => s_cust_acct_site_id,
            X_Last_Update_Date               => sysdate,
            X_Last_Updated_By                => nvl(fnd_global.user_id,1),
            X_Creation_Date                  => sysdate,
            X_Created_By                     => nvl(fnd_global.user_id,1),
            X_Status                         => s_status,
            X_Orig_System_Reference          => s_orig_system_reference,
            X_Country                        => s_country,
            X_Address1                       => s_address1,
            X_Address2                       => s_address2,
            X_Address3                       => s_address3,
            X_Address4                       => s_address4,
            X_City                           => s_city,
            X_Postal_Code                    => s_postal_code,
            X_State                          => s_state,
            X_Province                       => s_province,
            X_County                         => s_county,
            X_Last_Update_Login              => nvl(fnd_global.user_id,1),
            X_Address_Key                    => s_address_key,
            X_Language                       => null,--s_language,
            X_Attribute_Category             => null,
            X_Attribute1                     => null,
            X_Attribute2                     => null,
            X_Attribute3                     => null,
            X_Attribute4                     => null,
            X_Attribute5                     => null,
            X_Attribute6                     => null,
            X_Attribute7                     => null,
            X_Attribute8                     => null,
            X_Attribute9                     => null,
            X_Attribute10                    => null,
            X_Attribute11                    => null,
            X_Attribute12                    => null,
            X_Attribute13                    => null,
            X_Attribute14                    => null,
            X_Attribute15                    => null,
            X_Attribute16                    => null,
            X_Attribute17                    => null,
            X_Attribute18                    => null,
            X_Attribute19                    => null,
            X_Attribute20                    => null,
            X_Address_warning                => s_address_warning,
            X_Address_Lines_Phonetic         => s_Address_Lines_Phonetic,
            X_Global_Attribute_Category      => s_global_attribute_category,
            X_Global_Attribute1              => s_global_attribute1,
            X_Global_Attribute2              => s_global_attribute2,
            X_Global_Attribute3              => s_global_attribute3,
            X_Global_Attribute4              => s_global_attribute4,
            X_Global_Attribute5              => s_global_attribute5,
            X_Global_Attribute6              => s_global_attribute6,
            X_Global_Attribute7              => s_global_attribute7,
            X_Global_Attribute8              => s_global_attribute8,
            X_Global_Attribute9              => s_global_attribute9,
            X_Global_Attribute10             => s_global_attribute10,
            X_Global_Attribute11             => s_global_attribute11,
            X_Global_Attribute12             => s_global_attribute12,
            X_Global_Attribute13             => s_global_attribute13,
            X_Global_Attribute14             => s_global_attribute14,
            X_Global_Attribute15             => s_global_attribute15,
            X_Global_Attribute16             => s_global_attribute16,
            X_Global_Attribute17             => s_global_attribute17,
            X_Global_Attribute18             => s_global_attribute18,
            X_Global_Attribute19             => s_global_attribute19,
            X_Global_Attribute20             => s_global_attribute20,
            X_Party_site_id                  => s_party_site_id,
            X_Party_id                       => l_party_id,
            X_Location_id                    => s_location_id,
            X_Party_Site_Number              => s_party_site_number,
            X_Identifying_address_flag       => s_identifying_address_flag,
            X_Cust_acct_site_id              => s_address_id,
            X_Cust_account_id                => l_customer_id,
            X_su_Bill_To_Flag                => s_su_bill_to_flag,
            X_su_Ship_To_Flag                => s_su_ship_to_flag,
            X_su_Market_Flag                 => s_su_market_flag,
            X_su_stmt_flag                   => s_su_stmt_flag,
            X_su_dun_flag                    => s_su_dun_flag,
            X_su_legal_flag                  => s_su_legal_flag,
            X_Customer_Category              => s_customer_category,
            X_Key_Account_Flag               => s_key_account_flag,
            X_Territory_id                   => s_territory_id,
            X_ece_tp_location_code           => s_ece_tp_location_code,
            x_address_mode                   => s_address_mode,
            x_territory                      => s_territory,
            x_translated_customer_name       => s_translated_customer_name,
            x_sales_tax_geo_code             => s_sales_tax_geo_code,
            x_sale_tax_inside_city_limits    => s_sale_tax_inside_city_limits,
            x_ADDRESSEE                      => s_addressee,
            x_shared_party_site              => s_shared_party_site,
            x_update_account_site            => s_update_account_site,
            x_create_location_party_site     => s_create_location_party_site,
            x_msg_count                      => x_msg_count,
            x_msg_data                       => x_msg_data,
            x_return_status                  => x_return_status);

         IF x_return_status in ('E','U') THEN
            Rollback to ship_to_address_handler_PUB;
            /*FND_MESSAGE.SET_NAME ('CSP', 'CSP_ADDR_API_ERROR');
            FND_MESSAGE.SET_TOKEN ('TEXT', x_msg_data);
            FND_MSG_PUB.ADD;*/
            RAISE EXCP_USER_DEFINED;
         END IF;

         IF l_timezone_id IS NOT NULL THEN
            update hz_locations set time_zone = l_timezone_id where location_id = s_location_id;
         END IF;

          -- Create site use to link to the inventory location
          do_create_site_use(
             p_customer_id              => l_customer_id,
             p_party_id                 => l_party_id,
             p_address_id               => s_address_id,
             p_location_id              => s_location_id,
             p_inv_location_id          => l_inv_location_id,
             p_primary_flag             => s_identifying_address_flag,
             p_status                   => s_status,
	     p_bill_to_create			=> p_bill_to_create,
             x_return_status            => x_return_status,
             x_msg_count                => x_msg_count,
             x_msg_data                 => x_msg_data);

         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            Rollback to ship_to_address_handler_PUB;
            /*FND_MESSAGE.SET_NAME ('CSP', 'CSP_SITE_USE_API_ERROR');
            FND_MESSAGE.SET_TOKEN ('TEXT', x_msg_data);
            FND_MSG_PUB.ADD;*/
            RAISE EXCP_USER_DEFINED;
         END IF;
      END IF;
   END;
   END IF;

   -- Return location_id and customer_id.
   p_location_id := l_inv_location_id;
   p_customer_id := l_customer_id;

--   -- Create or update resource/customer relationship record in csp_rs_cust_relations
--   do_rs_cust_relations(l_resource_type, l_resource_id, l_resource_name, l_customer_id);
  csp_ship_to_address_pvt.g_inv_loc_id := l_inv_location_id;
  IF l_process_type = 'INSERT' THEN
   csp_ship_to_address_pvt.call_internal_hook('CSP_SHIP_TO_ADDRESS_PVT','SHIP_TO_ADDRESS_HANDLER','A',x_return_status);
  ELSIF l_process_type = 'UPDATE' THEN
   csp_ship_to_address_pvt.call_internal_hook('CSP_SHIP_TO_ADDRESS_PVT','UPDATE_LOCATION','A',x_return_status);
  END IF;
   -- If no error occurs, commit.
   IF p_commit = FND_API.G_TRUE THEN
      COMMIT;
   END IF;

   fnd_msg_pub.count_and_get
      ( p_count => x_msg_count
      , p_data  => x_msg_data);

   -- Exception Block --
  EXCEPTION
      WHEN EXCP_USER_DEFINED THEN
         Rollback to ship_to_address_handler_PUB;
         x_return_status := FND_API.G_RET_STS_ERROR;
        JTF_PLSQL_API.HANDLE_EXCEPTIONS(
            P_API_NAME => L_API_NAME
           ,P_PKG_NAME => G_PKG_NAME
           ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
           ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PUB
           ,X_MSG_COUNT    => X_MSG_COUNT
           ,X_MSG_DATA     => X_MSG_DATA
           ,X_RETURN_STATUS => X_RETURN_STATUS);
      WHEN FND_API.G_EXC_ERROR THEN
         JTF_PLSQL_API.HANDLE_EXCEPTIONS(
            P_API_NAME => L_API_NAME
           ,P_PKG_NAME => G_PKG_NAME
           ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
           ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PUB
           ,X_MSG_COUNT    => X_MSG_COUNT
           ,X_MSG_DATA     => X_MSG_DATA
           ,X_RETURN_STATUS => X_RETURN_STATUS);
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         JTF_PLSQL_API.HANDLE_EXCEPTIONS(
            P_API_NAME => L_API_NAME
            ,P_PKG_NAME => G_PKG_NAME
            ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
            ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PUB
            ,X_MSG_COUNT    => X_MSG_COUNT
            ,X_MSG_DATA     => X_MSG_DATA
            ,X_RETURN_STATUS => X_RETURN_STATUS);
      WHEN OTHERS THEN
         Rollback to ship_to_address_handler_PUB;
         FND_MESSAGE.SET_NAME('CSP', 'CSP_UNEXPECTED_EXEC_ERRORS');
         FND_MESSAGE.SET_TOKEN('ROUTINE', l_api_name, false);
         FND_MESSAGE.SET_TOKEN('SQLERRM', sqlerrm, false);
         FND_MSG_PUB.ADD;
         fnd_msg_pub.count_and_get
           ( p_count => x_msg_count
           , p_data  => x_msg_data);
         x_return_status := FND_API.G_RET_STS_ERROR;

END ship_to_address_handler;


------------------------------------------------------------------------------------------
-- Procedure Name   : site_to_invloc_linkage
-- Purpose          : This procedure will create a new inventory location and link the
--                    site use id passed in to the new inventory location.
-- Note             : Before calling this proceudre, make sure the site_use is not linked to
--                    any inventory location yet.
--
/* commented for bug

  PROCEDURE site_to_invloc_linkage
  (p_customer_id             IN NUMBER
  ,p_address_id              IN NUMBER
  ,p_site_use_id             IN NUMBER
  ,p_location_id             OUT NOCOPY NUMBER
  ,p_style                   IN VARCHAR2
  ,p_address_line_1          IN VARCHAR2
  ,p_address_line_2          IN VARCHAR2
  ,p_address_line_3          IN VARCHAR2
  ,p_country                 IN VARCHAR2
  ,p_postal_code             IN VARCHAR2
  ,p_region_1                IN VARCHAR2
  ,p_region_2                IN VARCHAR2
  ,p_region_3                IN VARCHAR2
  ,p_town_or_city            IN VARCHAR2
  ,p_tax_name                IN VARCHAR2
  ,p_telephone_number_1      IN VARCHAR2
  ,p_telephone_number_2      IN VARCHAR2
  ,p_telephone_number_3      IN VARCHAR2
  ,p_loc_information13       IN VARCHAR2
  ,p_loc_information14       IN VARCHAR2
  ,p_loc_information15       IN VARCHAR2
  ,p_loc_information16       IN VARCHAR2
  ,p_loc_information17       IN VARCHAR2
  ,p_loc_information18       IN VARCHAR2
  ,p_loc_information19       IN VARCHAR2
  ,p_loc_information20       IN VARCHAR2
  ,p_api_version_number      IN NUMBER
  ,p_init_msg_list           IN VARCHAR2
  ,p_attribute_category     IN VARCHAR2
   ,p_attribute1             IN VARCHAR2
   ,p_attribute2             IN VARCHAR2
   ,p_attribute3             IN VARCHAR2
   ,p_attribute4             IN VARCHAR2
   ,p_attribute5             IN VARCHAR2
   ,p_attribute6             IN VARCHAR2
   ,p_attribute7             IN VARCHAR2
   ,p_attribute8             IN VARCHAR2
   ,p_attribute9             IN VARCHAR2
   ,p_attribute10             IN VARCHAR2
   ,p_attribute11             IN VARCHAR2
   ,p_attribute12             IN VARCHAR2
   ,p_attribute13            IN VARCHAR2
   ,p_attribute14             IN VARCHAR2
   ,p_attribute15             IN VARCHAR2
   ,p_attribute16             IN VARCHAR2
   ,p_attribute17             IN VARCHAR2
   ,p_attribute18             IN VARCHAR2
   ,p_attribute19             IN VARCHAR2
   ,p_attribute20             IN VARCHAR2
  ,x_return_status           OUT NOCOPY VARCHAR2
  ,x_msg_count               OUT NOCOPY NUMBER
  ,x_msg_data                OUT NOCOPY VARCHAR2) IS

   l_api_version_number      CONSTANT NUMBER := 1.0;
   l_api_name                CONSTANT VARCHAR2(30) := 'site_to_invloc_linkage';
   EXCP_USER_DEFINED         EXCEPTION;
   l_inv_loc_id              hr_locations.location_id%type;
   l_object_version_number   hr_locations.object_version_number%type;

BEGIN
   SAVEPOINT site_to_invloc_linkage_PUB;

   -- initialize message list
   FND_MSG_PUB.initialize;

   IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                        p_api_version_number,
                                        l_api_name,
                                        G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- If site use id is null, return error.
   IF p_site_use_id IS NULL THEN
      FND_MESSAGE.SET_NAME ('CSP', 'CSP_SITE_USE_ID_REQD');
      FND_MSG_PUB.ADD;
      RAISE EXCP_USER_DEFINED;
   END IF;

   -- If address fields are not null, create a new inventory location.  Otherwise, return error.
   IF p_country IS NOT NULL THEN
      do_create_ship_to_location(
      p_location_id            => p_location_id,
      p_style                  => p_style,
      p_address_line_1         => p_address_line_1,
      p_address_line_2         => p_address_line_2,
      p_address_line_3         => p_address_line_3,
      p_country                => p_country,
      p_postal_code            => p_postal_code,
      p_region_1               => p_region_1,
      p_region_2               => p_region_2,
      p_region_3               => p_region_3,
      p_town_or_city           => p_town_or_city,
      p_tax_name               => p_tax_name,
      p_telephone_number_1     => p_telephone_number_1,
      p_telephone_number_2     => p_telephone_number_2,
      p_telephone_number_3     => p_telephone_number_3,
      p_loc_information13      => p_loc_information13,
      p_loc_information14      => p_loc_information14,
      p_loc_information15      => p_loc_information15,
      p_loc_information16      => p_loc_information16,
      p_loc_information17      => p_loc_information17,
      p_loc_information18      => p_loc_information18,
      p_loc_information19      => p_loc_information19,
      p_loc_information20      => p_loc_information20,
      p_object_version_number  => l_object_version_number,
       p_attribute1                  => p_attribute1,
      p_attribute2                  => p_attribute2,
      p_attribute3                  => p_attribute3,
      p_attribute4                  => p_attribute4,
      p_attribute5                  => p_attribute5,
      p_attribute6                  => p_attribute6,
      p_attribute7                  => p_attribute7,
      p_attribute8                  => p_attribute8,
      p_attribute9                  => p_attribute9,
      p_attribute10                  => p_attribute10,
      p_attribute11                  => p_attribute11,
      p_attribute12                  => p_attribute12,
      p_attribute13                  => p_attribute13,
      p_attribute14                  => p_attribute14,
      p_attribute15                  => p_attribute15,
      p_attribute16                  => p_attribute16,
      p_attribute17                  => p_attribute17,
      p_attribute18                  => p_attribute18,
      p_attribute19                  => p_attribute19,
      p_attribute20                  => p_attribute20,
      p_attribute_category          => p_attribute_category,
      x_return_status          => x_return_status,
      x_msg_count              => x_msg_count,
      x_msg_data               => x_msg_data);

      l_inv_loc_id := p_location_id;
      IF x_return_status in ('E','U') THEN
         Rollback to site_to_invloc_linkage_PUB;
         /*FND_MESSAGE.SET_NAME ('CSP', 'CSP_STA_API_ERROR');
         FND_MESSAGE.SET_TOKEN ('TEXT', x_msg_data);
         FND_MSG_PUB.ADD;*/
  /*       RAISE EXCP_USER_DEFINED;
      ELSE

         -- Create the linkage between the site use and the inventory location.
         arp_clas_pkg.insert_po_loc_associations(
            p_inventory_location_id       => l_inv_loc_id,
            p_inventory_organization_id   => null,
            p_customer_id                 => p_customer_id,
            p_address_id                  => p_address_id,
            p_site_use_id                 => p_site_use_id);

      END IF;
   ELSE
      Rollback to site_to_invloc_linkage_PUB;
      FND_MESSAGE.SET_NAME ('CSP', 'CSP_ADDRESS_REQD');
      FND_MESSAGE.SET_TOKEN ('TEXT', x_msg_data,false);
      FND_MSG_PUB.ADD;
      RAISE EXCP_USER_DEFINED;
   END IF;

   EXCEPTION
      WHEN EXCP_USER_DEFINED THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         fnd_msg_pub.count_and_get
         ( p_count   => x_msg_count
         , p_data    => x_msg_data);
      WHEN FND_API.G_EXC_ERROR THEN
         JTF_PLSQL_API.HANDLE_EXCEPTIONS(
            P_API_NAME => L_API_NAME
           ,P_PKG_NAME => G_PKG_NAME
           ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
           ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PUB
           ,X_MSG_COUNT    => x_MSG_COUNT
           ,X_MSG_DATA     => x_MSG_DATA
           ,X_RETURN_STATUS => x_RETURN_STATUS);
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         JTF_PLSQL_API.HANDLE_EXCEPTIONS(
            P_API_NAME => L_API_NAME
           ,P_PKG_NAME => G_PKG_NAME
           ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
           ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PUB
           ,X_MSG_COUNT    => x_MSG_COUNT
           ,X_MSG_DATA     => x_MSG_DATA
           ,X_RETURN_STATUS => x_RETURN_STATUS);
      WHEN OTHERS THEN
         Rollback to site_to_invloc_linkage_PUB;
         FND_MESSAGE.SET_NAME('CSP', 'CSP_UNEXPECTED_EXEC_ERRORS');
         FND_MESSAGE.SET_TOKEN('ROUTINE', l_api_name, false);
         FND_MESSAGE.SET_TOKEN('SQLERRM', sqlerrm, false);
         FND_MSG_PUB.ADD;
         fnd_msg_pub.count_and_get
           ( p_count => x_msg_count
           , p_data  => x_msg_data);
         x_return_status := FND_API.G_RET_STS_ERROR;

END site_to_invloc_linkage; */
PROCEDURE site_to_invloc_linkage
  (p_customer_id             IN NUMBER
  ,p_address_id              IN NUMBER
  ,p_site_use_id             IN NUMBER
  ,p_location_id             OUT NOCOPY NUMBER
  ,p_style                   IN VARCHAR2
  ,p_address_line_1          IN VARCHAR2
  ,p_address_line_2          IN VARCHAR2
  ,p_address_line_3          IN VARCHAR2
  ,p_country                 IN VARCHAR2
  ,p_postal_code             IN VARCHAR2
  ,p_region_1                IN VARCHAR2
  ,p_region_2                IN VARCHAR2
  ,p_region_3                IN VARCHAR2
  ,p_town_or_city            IN VARCHAR2
  ,p_tax_name                IN VARCHAR2
  ,p_telephone_number_1      IN VARCHAR2
  ,p_telephone_number_2      IN VARCHAR2
  ,p_telephone_number_3      IN VARCHAR2
  ,p_loc_information13       IN VARCHAR2
  ,p_loc_information14       IN VARCHAR2
  ,p_loc_information15       IN VARCHAR2
  ,p_loc_information16       IN VARCHAR2
  ,p_loc_information17       IN VARCHAR2
  ,p_loc_information18       IN VARCHAR2
  ,p_loc_information19       IN VARCHAR2
  ,p_loc_information20       IN VARCHAR2
  ,p_api_version_number      IN NUMBER
  ,p_init_msg_list           IN VARCHAR2
  ,p_attribute_category     IN VARCHAR2
   ,p_attribute1             IN VARCHAR2
   ,p_attribute2             IN VARCHAR2
   ,p_attribute3             IN VARCHAR2
   ,p_attribute4             IN VARCHAR2
   ,p_attribute5             IN VARCHAR2
   ,p_attribute6             IN VARCHAR2
   ,p_attribute7             IN VARCHAR2
   ,p_attribute8             IN VARCHAR2
   ,p_attribute9             IN VARCHAR2
   ,p_attribute10             IN VARCHAR2
   ,p_attribute11             IN VARCHAR2
   ,p_attribute12             IN VARCHAR2
   ,p_attribute13            IN VARCHAR2
   ,p_attribute14             IN VARCHAR2
   ,p_attribute15             IN VARCHAR2
   ,p_attribute16             IN VARCHAR2
   ,p_attribute17             IN VARCHAR2
   ,p_attribute18             IN VARCHAR2
   ,p_attribute19             IN VARCHAR2
   ,p_attribute20             IN VARCHAR2
  ,x_return_status           OUT NOCOPY VARCHAR2
  ,x_msg_count               OUT NOCOPY NUMBER
  ,x_msg_data                OUT NOCOPY VARCHAR2) IS

   l_api_version_number      CONSTANT NUMBER := 1.0;
   l_api_name                CONSTANT VARCHAR2(30) := 'site_to_invloc_linkage';
   EXCP_USER_DEFINED         EXCEPTION;
   l_inv_loc_id              hr_locations.location_id%type;
   l_object_version_number   hr_locations.object_version_number%type;
 l_town_or_city varchar2(30);
   l_region_1 varchar2(120);
   cursor get_csp_location is
   select STYLE,ADDRESS_LINE_1,ADDRESS_LINE_2,ADDRESS_LINE_3,TOWN_OR_CITY,COUNTRY
        ,POSTAL_CODE,REGION_1,REGION_2,REGION_3,TELEPHONE_NUMBER_1,TELEPHONE_NUMBER_2,TELEPHONE_NUMBER_3,LOC_INFORMATION13
        ,LOC_INFORMATION14,LOC_INFORMATION15,LOC_INFORMATION16,LOC_INFORMATION17,LOC_INFORMATION18,LOC_INFORMATION19
        ,LOC_INFORMATION20,ATTRIBUTE_CATEGORY,ATTRIBUTE1,ATTRIBUTE2,ATTRIBUTE3,ATTRIBUTE4,ATTRIBUTE5
        ,ATTRIBUTE6,ATTRIBUTE7,ATTRIBUTE8,ATTRIBUTE9,ATTRIBUTE10,ATTRIBUTE11,ATTRIBUTE12,ATTRIBUTE13,ATTRIBUTE14,ATTRIBUTE15
        ,ATTRIBUTE16,ATTRIBUTE17,ATTRIBUTE18,ATTRIBUTE19,ATTRIBUTE20,TAX_NAME
    from hr_locations
    where location_code like 'CSP%'
    and country = p_country ;

    cursor get_country_location is
   select STYLE,ADDRESS_LINE_1,ADDRESS_LINE_2,ADDRESS_LINE_3,TOWN_OR_CITY,COUNTRY
        ,POSTAL_CODE,REGION_1,REGION_2,REGION_3,TELEPHONE_NUMBER_1,TELEPHONE_NUMBER_2,TELEPHONE_NUMBER_3,LOC_INFORMATION13
        ,LOC_INFORMATION14,LOC_INFORMATION15,LOC_INFORMATION16,LOC_INFORMATION17,LOC_INFORMATION18,LOC_INFORMATION19
        ,LOC_INFORMATION20,ATTRIBUTE_CATEGORY,ATTRIBUTE1,ATTRIBUTE2,ATTRIBUTE3,ATTRIBUTE4,ATTRIBUTE5
        ,ATTRIBUTE6,ATTRIBUTE7,ATTRIBUTE8,ATTRIBUTE9,ATTRIBUTE10,ATTRIBUTE11,ATTRIBUTE12,ATTRIBUTE13,ATTRIBUTE14,ATTRIBUTE15
        ,ATTRIBUTE16,ATTRIBUTE17,ATTRIBUTE18,ATTRIBUTE19,ATTRIBUTE20,TAX_NAME
    from hr_locations
    where country = p_country ;

    csp_location_rec get_csp_location%ROWTYPE;
     l_org_id   number;
     l_ou_id    number;
     l_cust_acct_id number;     -- bug # 12545721
BEGIN

   if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.site_to_invloc_linkage',
                     'Begin');
   end if;

   SAVEPOINT site_to_invloc_linkage_PUB;

   -- initialize message list
   FND_MSG_PUB.initialize;

   IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                        p_api_version_number,
                                        l_api_name,
                                        G_PKG_NAME) THEN

   if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.site_to_invloc_linkage',
                     'In FND_API.Compatible_API_Call');
   end if;

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- If site use id is null, return error.
   IF p_site_use_id IS NULL THEN
      FND_MESSAGE.SET_NAME ('CSP', 'CSP_SITE_USE_ID_REQD');
      FND_MSG_PUB.ADD;
       if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.site_to_invloc_linkage',
                     'In CSP_SITE_USE_ID_REQD error');
       end if;
      RAISE EXCP_USER_DEFINED;
   END IF;
 IF fnd_profile.value('CSP_INTRANSIT_LOCATION_USED') = 'Y' THEN
         if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.site_to_invloc_linkage',
                     'In CSP_INTRANSIT_LOCATION_USED condition');
       end if;
   -- If address fields are not null, create a new inventory location.  Otherwise, return error.
   IF p_country IS NOT NULL THEN
       if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.site_to_invloc_linkage',
                     'In CSP_INTRANSIT_LOCATION_USED : p_country condition');
       end if;
        if  p_country = 'US' THEN
           l_town_or_city := initcap(p_town_or_city);
           l_region_1 :=initcap(p_region_1);
        else
            l_town_or_city := p_town_or_city;
           l_region_1 :=p_region_1;
        end if;
       if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.site_to_invloc_linkage',
                     'l_town_or_city = ' || l_town_or_city
                     || ', l_region_1' || l_region_1);
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.site_to_invloc_linkage',
                     'Before calling do_create_ship_to_location');
       end if;
      do_create_ship_to_location(
      p_location_id            => p_location_id,
      p_style                  => p_style,
      p_address_line_1         => p_address_line_1,
      p_address_line_2         => p_address_line_2,
      p_address_line_3         => p_address_line_3,
      p_country                => p_country,
      p_postal_code            => p_postal_code,
      p_region_1               => l_region_1,
      p_region_2               => p_region_2,
      p_region_3               => p_region_3,
      p_town_or_city           => l_town_or_city,
      p_tax_name               => p_tax_name,
      p_telephone_number_1     => p_telephone_number_1,
      p_telephone_number_2     => p_telephone_number_2,
      p_telephone_number_3     => p_telephone_number_3,
      p_loc_information13      => p_loc_information13,
      p_loc_information14      => p_loc_information14,
      p_loc_information15      => p_loc_information15,
      p_loc_information16      => p_loc_information16,
      p_loc_information17      => p_loc_information17,
      p_loc_information18      => p_loc_information18,
      p_loc_information19      => p_loc_information19,
      p_loc_information20      => p_loc_information20,
      p_object_version_number  => l_object_version_number,
       p_attribute1                  => p_attribute1,
      p_attribute2                  => p_attribute2,
      p_attribute3                  => p_attribute3,
      p_attribute4                  => p_attribute4,
      p_attribute5                  => p_attribute5,
      p_attribute6                  => p_attribute6,
      p_attribute7                  => p_attribute7,
      p_attribute8                  => p_attribute8,
      p_attribute9                  => p_attribute9,
      p_attribute10                  => p_attribute10,
      p_attribute11                  => p_attribute11,
      p_attribute12                  => p_attribute12,
      p_attribute13                  => p_attribute13,
      p_attribute14                  => p_attribute14,
      p_attribute15                  => p_attribute15,
      p_attribute16                  => p_attribute16,
      p_attribute17                  => p_attribute17,
      p_attribute18                  => p_attribute18,
      p_attribute19                  => p_attribute19,
      p_attribute20                  => p_attribute20,
      p_attribute_category          => p_attribute_category,
      x_return_status          => x_return_status,
      x_msg_count              => x_msg_count,
      x_msg_data               => x_msg_data);

       if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.site_to_invloc_linkage',
                     'After do_create_ship_to_location... x_return_status = ' || x_return_status);
       end if;

      l_inv_loc_id := p_location_id;
      IF x_return_status in ('E','U') THEN
         Rollback to site_to_invloc_linkage_PUB;
         /*FND_MESSAGE.SET_NAME ('CSP', 'CSP_STA_API_ERROR');
         FND_MESSAGE.SET_TOKEN ('TEXT', x_msg_data);
         FND_MSG_PUB.ADD;*/
         RAISE EXCP_USER_DEFINED;
      ELSE

       if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.site_to_invloc_linkage',
                     'p_address_id = ' || p_address_id);
       end if;

           SELECT  org_id
           INTO    l_org_id
           FROM    HZ_CUST_ACCT_SITES_ALL
           WHERE   cust_acct_site_id = p_address_id;

       if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.site_to_invloc_linkage',
                     'l_org_id = ' || l_org_id);
       end if;

           /*
           select operating_unit
           into l_ou_id
           from org_organization_Definitions
           where organization_id = l_org_id;
           */
           l_ou_id := l_org_id;

       if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.site_to_invloc_linkage',
                     'l_ou_id = ' || l_ou_id);
       end if;

          SELECT TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1,1), ' ', NULL, SUBSTRB(USERENV('CLIENT_INFO'),1,10)))
          INTO   l_org_id
          FROM   dual;

       if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.site_to_invloc_linkage',
                     'l_org_id = ' || l_org_id);
       end if;

          mo_global.set_policy_context('S', l_ou_id);

       if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.site_to_invloc_linkage',
                     'Before calling arp_clas_pkg.insert_po_loc_associations');
       end if;

       select cust_account_id into l_cust_acct_id
        from hz_cust_acct_sites_all
        where cust_acct_site_id = p_address_id;

       if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.site_to_invloc_linkage',
                     'l_cust_acct_id = ' || l_cust_acct_id);
       end if;

         -- Create the linkage between the site use and the inventory location.
         arp_clas_pkg.insert_po_loc_associations(
            p_inventory_location_id       => l_inv_loc_id,
            p_inventory_organization_id   => null,
            p_customer_id                 => l_cust_acct_id,
            p_address_id                  => p_address_id,
            p_site_use_id                 => p_site_use_id,
            x_return_status               => x_return_status,
             x_msg_count                   => x_msg_count,
             x_msg_data                    => x_msg_data);

          mo_global.set_policy_context('S', l_org_id);

       if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.site_to_invloc_linkage',
                     'After calling arp_clas_pkg.insert_po_loc_associations');
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.site_to_invloc_linkage',
                     'x_return_status = ' || x_return_status);
       end if;

       IF x_return_status in ('E','U') THEN
          Rollback to site_to_invloc_linkage_PUB;
          RAISE EXCP_USER_DEFINED;
       END IF;

      END IF;
   ELSE
      Rollback to site_to_invloc_linkage_PUB;
       if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.site_to_invloc_linkage',
                     'p_country is NULL');
       end if;
      FND_MESSAGE.SET_NAME ('CSP', 'CSP_ADDRESS_REQD');
      FND_MESSAGE.SET_TOKEN ('TEXT', x_msg_data);
      FND_MSG_PUB.ADD;
      RAISE EXCP_USER_DEFINED;
   END IF;
 ELSE
       if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.site_to_invloc_linkage',
                     'Else part : CSP_INTRANSIT_LOCATION_USED is N');
       end if;

   OPEN  get_csp_location;
   FETCH get_csp_location INTO csp_location_rec;
   CLOSE get_csp_location;

       if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.site_to_invloc_linkage',
                     'csp_location_rec.country = ' || csp_location_rec.country);
       end if;

   IF csp_location_rec.country IS NULL THEN
      OPEN  get_country_location;
      FETCH get_country_location INTO csp_location_rec;
      CLOSE get_country_location;
   END IF;
     csp_location_rec.ADDRESS_LINE_1 := FND_MESSAGE.GET_STRING('CSP', 'CSP_ADDRESS_DESC');

   -- If address fields are not null, create a new inventory location.  Otherwise, return error.
   IF p_country IS NOT NULL THEN

       if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.site_to_invloc_linkage',
                     'p_country is NOT NULL and p_country = ' || p_country);
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.site_to_invloc_linkage',
                     'Before calling do_create_ship_to_location...');
       end if;

     do_create_ship_to_location(
      p_location_id            => p_location_id,
      p_style                  => csp_location_rec.style,
      p_address_line_1         => csp_location_rec.ADDRESS_LINE_1 ,
      p_address_line_2         => csp_location_rec.ADDRESS_LINE_2,
      p_address_line_3         => csp_location_rec.ADDRESS_LINE_3,
      p_country                => csp_location_rec.country,
      p_postal_code            => csp_location_rec.postal_code,
      p_region_1               => csp_location_rec.region_1,
      p_region_2               => csp_location_rec.region_2,
      p_region_3               => csp_location_rec.region_3,
      p_town_or_city           => csp_location_rec.town_or_city,
      p_tax_name               => csp_location_rec.tax_name,
      p_telephone_number_1     => csp_location_rec.telephone_number_1,
      p_telephone_number_2     => csp_location_rec.telephone_number_2,
      p_telephone_number_3     =>csp_location_rec.telephone_number_3,
      p_loc_information13      => csp_location_rec.loc_information13,
      p_loc_information14      => csp_location_rec.loc_information14,
      p_loc_information15      => csp_location_rec.loc_information15,
      p_loc_information16      => csp_location_rec.loc_information16,
      p_loc_information17      => csp_location_rec.loc_information17,
      p_loc_information18      => csp_location_rec.loc_information18,
      p_loc_information19      => csp_location_rec.loc_information19,
      p_loc_information20      => csp_location_rec.loc_information20,
      p_object_version_number  => l_object_version_number,
       p_attribute1                  => csp_location_rec.attribute1,
      p_attribute2                  => csp_location_rec.attribute2,
      p_attribute3                  => csp_location_rec.attribute3,
      p_attribute4                  => csp_location_rec.attribute4,
      p_attribute5                  => csp_location_rec.attribute5,
      p_attribute6                  => csp_location_rec.attribute6,
      p_attribute7                  => csp_location_rec.attribute7,
      p_attribute8                  => csp_location_rec.attribute8,
      p_attribute9                  => csp_location_rec.attribute9,
      p_attribute10                  => csp_location_rec.attribute10,
      p_attribute11                  => csp_location_rec.attribute11,
      p_attribute12                  => csp_location_rec.attribute12,
      p_attribute13                  => csp_location_rec.attribute13,
      p_attribute14                  => csp_location_rec.attribute14,
      p_attribute15                  => csp_location_rec.attribute15,
      p_attribute16                  => csp_location_rec.attribute16,
      p_attribute17                  => csp_location_rec.attribute17,
      p_attribute18                  => csp_location_rec.attribute18,
      p_attribute19                  => csp_location_rec.attribute19,
      p_attribute20                  => csp_location_rec.attribute20,
      p_attribute_category          => csp_location_rec.attribute_category,
      x_return_status          => x_return_status,
      x_msg_count              => x_msg_count,
      x_msg_data               => x_msg_data);

       if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.site_to_invloc_linkage',
                     'After do_create_ship_to_location... with x_return_status = ' || x_return_status);
       end if;

      l_inv_loc_id := p_location_id;
      IF x_return_status in ('E','U') THEN
         Rollback to site_to_invloc_linkage_PUB;
         /*FND_MESSAGE.SET_NAME ('CSP', 'CSP_STA_API_ERROR');
         FND_MESSAGE.SET_TOKEN ('TEXT', x_msg_data);
         FND_MSG_PUB.ADD;*/
         RAISE EXCP_USER_DEFINED;
      ELSE

       if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.site_to_invloc_linkage',
                     'p_address_id = ' || p_address_id);
       end if;

           SELECT  org_id
           INTO    l_org_id
           FROM    HZ_CUST_ACCT_SITES_ALL
           WHERE   cust_acct_site_id = p_address_id;

       if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.site_to_invloc_linkage',
                     'l_org_id = ' || l_org_id);
       end if;

           /*
           select operating_unit
           into l_ou_id
           from org_organization_Definitions
           where organization_id = l_org_id;
           */
           l_ou_id := l_org_id;

       if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.site_to_invloc_linkage',
                     'l_ou_id = ' || l_ou_id);
       end if;

          SELECT TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1,1), ' ', NULL, SUBSTRB(USERENV('CLIENT_INFO'),1,10)))
          INTO   l_org_id
          FROM   dual;

       if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.site_to_invloc_linkage',
                     'l_org_id = ' || l_org_id);
       end if;

          mo_global.set_policy_context('S', l_ou_id);

       if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.site_to_invloc_linkage',
                     'Before arp_clas_pkg.insert_po_loc_associations...');
       end if;

         -- Create the linkage between the site use and the inventory location.
         arp_clas_pkg.insert_po_loc_associations(
            p_inventory_location_id       => l_inv_loc_id,
            p_inventory_organization_id   => null,
            p_customer_id                 => p_customer_id,
            p_address_id                  => p_address_id,
            p_site_use_id                 => p_site_use_id,
            x_return_status               => x_return_status,
             x_msg_count                   => x_msg_count,
             x_msg_data                    => x_msg_data);

          mo_global.set_policy_context('S', l_org_id);

       if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.site_to_invloc_linkage',
                     'After arp_clas_pkg.insert_po_loc_associations...');
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.site_to_invloc_linkage',
                     'x_return_status = ' || x_return_status);
       end if;

       IF x_return_status in ('E','U') THEN
          Rollback to site_to_invloc_linkage_PUB;
          RAISE EXCP_USER_DEFINED;
       END IF;

      END IF;
   ELSE
      Rollback to site_to_invloc_linkage_PUB;
       if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.site_to_invloc_linkage',
                     'p_country is NULL...');
       end if;
      /*FND_MESSAGE.SET_NAME ('CSP', 'CSP_ADDRESS_REQD');
      FND_MESSAGE.SET_TOKEN ('TEXT', x_msg_data);
      FND_MSG_PUB.ADD;*/
      RAISE EXCP_USER_DEFINED;
   END IF;
 END IF;
   EXCEPTION
      WHEN EXCP_USER_DEFINED THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         fnd_msg_pub.count_and_get
         ( p_count   => x_msg_count
         , p_data    => x_msg_data);
       if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.site_to_invloc_linkage',
                     'In EXCP_USER_DEFINED block');
       end if;
      WHEN FND_API.G_EXC_ERROR THEN
         JTF_PLSQL_API.HANDLE_EXCEPTIONS(
            P_API_NAME => L_API_NAME
           ,P_PKG_NAME => G_PKG_NAME
           ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
           ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PUB
           ,X_MSG_COUNT    => x_MSG_COUNT
           ,X_MSG_DATA     => x_MSG_DATA
           ,X_RETURN_STATUS => x_RETURN_STATUS);
       if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.site_to_invloc_linkage',
                     'In FND_API.G_EXC_ERROR block');
       end if;
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         JTF_PLSQL_API.HANDLE_EXCEPTIONS(
            P_API_NAME => L_API_NAME
           ,P_PKG_NAME => G_PKG_NAME
           ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
           ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PUB
           ,X_MSG_COUNT    => x_MSG_COUNT
           ,X_MSG_DATA     => x_MSG_DATA
           ,X_RETURN_STATUS => x_RETURN_STATUS);
       if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.site_to_invloc_linkage',
                     'In FND_API.G_EXC_UNEXPECTED_ERROR block');
       end if;
      WHEN OTHERS THEN
         Rollback to site_to_invloc_linkage_PUB;
       if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.site_to_invloc_linkage',
                     'In Others block... sqlerrm = ' || sqlerrm);
       end if;
         FND_MESSAGE.SET_NAME('CSP', 'CSP_UNEXPECTED_EXEC_ERRORS');
         FND_MESSAGE.SET_TOKEN('ROUTINE', l_api_name, FALSE);
         FND_MESSAGE.SET_TOKEN('SQLERRM', sqlerrm, FALSE);
         FND_MSG_PUB.ADD;
         fnd_msg_pub.count_and_get
           ( p_count => x_msg_count
           , p_data  => x_msg_data);
         x_return_status := FND_API.G_RET_STS_ERROR;

END site_to_invloc_linkage;
   PROCEDURE call_internal_hook (
      p_package_name      IN       VARCHAR2,
      p_api_name          IN       VARCHAR2,
      p_processing_type   IN       VARCHAR2,
      x_return_status     OUT NOCOPY      VARCHAR2
   )
   IS
      CURSOR c1
      IS
         SELECT hook_package, hook_api
           FROM jtf_hooks_data
          WHERE package_name = p_package_name
            AND api_name = p_api_name
            AND execute_flag = 'Y'
            AND processing_type = p_processing_type
          ORDER BY execution_order;

      v_cursorid   INTEGER;
      v_blockstr   VARCHAR2(2000);
      v_dummy      INTEGER;
	  l_module_name VARCHAR2(100)	:= 'csp.plsql.csp_ship_to_address_pvt.call_internal_hook';
   BEGIN

	if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
		FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
			l_module_name,
			'BEGIN...');
	end if;

      x_return_status := fnd_api.g_ret_sts_success;

      FOR i IN c1
      LOOP
         v_cursorid := DBMS_SQL.open_cursor;
         v_blockstr :=
            ' begin ' || i.hook_package || '.' || i.hook_api || '(:1); end; ';

		if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
			FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
				l_module_name,
				'calling hook API...');
			FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
				l_module_name,
				'i.hook_package = ' || i.hook_package);
			FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
				l_module_name,
				'i.hook_api = ' || i.hook_api);
		end if;

         DBMS_SQL.parse (v_cursorid, v_blockstr, DBMS_SQL.v7);
         DBMS_SQL.bind_variable (v_cursorid, ':1', x_return_status, 20);
         v_dummy := DBMS_SQL.execute (v_cursorid);
         DBMS_SQL.variable_value (v_cursorid, ':1', x_return_status);
         DBMS_SQL.close_cursor (v_cursorid);

		if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
			FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
				l_module_name,
				'x_return_status = ' || x_return_status);
		end if;

         IF NOT (x_return_status = fnd_api.g_ret_sts_success)
         THEN
            fnd_message.set_name ('JTF', 'JTF_TASK_MISSING_RETURN_STATUS');
            fnd_message.set_token (
               'P_PROCEDURE',
               i.hook_package || '.' || i.hook_api,false
            );
            fnd_msg_pub.add;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            RAISE fnd_api.g_exc_unexpected_error;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;

         IF x_return_status IS NULL
         THEN
            fnd_message.set_name ('JTF', 'JTF_TASK_MISSING_RETURN_STATUS');
            fnd_msg_pub.add;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END LOOP;
   EXCEPTION
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
      WHEN OTHERS
      THEN
         fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
         fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM,false);
         fnd_msg_pub.add;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
   END;

   PROCEDURE cust_inv_loc_link
   (     p_api_version              IN NUMBER
        ,p_Init_Msg_List            IN VARCHAR2     := FND_API.G_FALSE
        ,p_commit                   IN VARCHAR2     := FND_API.G_FALSE
        ,px_location_id             IN OUT NOCOPY NUMBER
        ,p_party_site_id            IN NUMBER
        ,p_cust_account_id          IN NUMBER
        ,p_customer_id              IN NUMBER
		,p_org_id					IN NUMBER		:= NULL
        ,p_attribute_category       IN VARCHAR2
        ,p_attribute1               IN VARCHAR2
        ,p_attribute2               IN VARCHAR2
        ,p_attribute3               IN VARCHAR2
        ,p_attribute4               IN VARCHAR2
        ,p_attribute5               IN VARCHAR2
        ,p_attribute6               IN VARCHAR2
        ,p_attribute7               IN VARCHAR2
        ,p_attribute8               IN VARCHAR2
        ,p_attribute9               IN VARCHAR2
        ,p_attribute10              IN VARCHAR2
        ,p_attribute11              IN VARCHAR2
        ,p_attribute12              IN VARCHAR2
        ,p_attribute13              IN VARCHAR2
        ,p_attribute14              IN VARCHAR2
        ,p_attribute15              IN VARCHAR2
        ,p_attribute16              IN VARCHAR2
        ,p_attribute17              IN VARCHAR2
        ,p_attribute18              IN VARCHAR2
        ,p_attribute19              IN VARCHAR2
        ,p_attribute20              IN VARCHAR2
        ,x_return_status            OUT NOCOPY VARCHAR2
        ,x_msg_count                OUT NOCOPY NUMBER
        ,x_msg_data                 OUT NOCOPY VARCHAR2
    ) IS
    l_location_id 	        NUMBER := px_location_id;
    l_return_status	        VARCHAR2(1);
    l_msg_count 		    NUMBER;
    l_msg_data		        VARCHAR2(2000);
    l_msg			        VARCHAR2(2000);
    l_site_use_id		    NUMBER;
    l_address_id		    NUMBER;
    l_api_version_number    NUMBER := 1.0;
    l_api_name              CONSTANT VARCHAR2(30) := 'cust_inv_loc_link';
    --l_party_site_id 	    NUMBER := to_number(Name_In('csp_requirement_headers.party_site_id'));
    --l_account_id 		    NUMBER := to_number(Name_In('csp_requirement_headers.account_id'));
    l_org_id 		        NUMBER;
    l_inv_location_id	    NUMBER;
    l_inv_loc		        NUMBER;
    l_Return_val 		    BOOLEAN := FALSE;
    l_pay_application_id	CONSTANT NUMBER := 801;
    l_status 		        VARCHAR2(10);
    l_industry		        VARCHAR2(10);
    l_state		            VARCHAR2(30);
    l_state_code		    NUMBER;
    l_county		        VARCHAR2(30);
    l_county_code		    NUMBER;
    l_city		            VARCHAR2(30);
    l_city_code		        NUMBER;
    l_state_abbrev	        VARCHAR2(30);
    l_county_name		    VARCHAR2(240);
    l_city_name		        VARCHAr2(240);

    CURSOR  site_use_cur IS
        SELECT c_site_use.site_use_id, c_acct_site.cust_acct_site_id
        FROM hz_cust_site_uses_all c_site_use,
    	 hz_cust_acct_sites_all c_acct_site
        WHERE c_site_use.site_use_code = 'SHIP_TO'
        AND c_site_use.status = 'A'
        AND c_site_use.cust_acct_site_id = c_acct_site.cust_acct_site_id
        AND c_acct_site.cust_account_id = p_cust_account_id
        AND c_acct_site.party_site_id = p_party_site_id
        AND c_acct_site.org_id = l_org_id;

      CURSOR invloc_check_cur IS
        SELECT location_id
        FROM po_location_associations_all
        WHERE site_use_id = l_site_use_id;

   /*   CURSOR po_loc_assoc_exists_cur IS
        SELECT location_id
        FROM po_location_Associations_all
        WHERE location_id = l_inv_location_id;
   */

      CURSOR address_cur IS
        SELECT country, address1, address2, address3,
               address4, city, postal_code, state,
               province, county
        FROM hz_locations
        WHERE location_id = px_location_id;

      address_rec   address_cur%ROWTYPE;

  BEGIN
    SAVEPOINT cust_inv_loc_link_PUB;

    IF (px_location_id IS NOT NULL) THEN

      /*OPEN po_loc_Assoc_exists_cur;
      FETCH po_loc_Assoc_exists_cur INTO l_inv_loc;

      IF (po_loc_assoc_exists_cur%NOTFOUND) THEN
      */
	  -- bug 11829269
      IF(p_cust_account_id IS NOT NULL and p_party_site_id IS NOT NULL) THEN
		BEGIN
			if p_org_id is null then
				/*
                SELECT TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1,1), ' ', NULL,
					SUBSTRB(USERENV('CLIENT_INFO'),1,10)))
				INTO l_org_id
				FROM DUAL;*/
                l_org_id := mo_global.get_current_org_id;

                if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                        'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.cust_inv_loc_link',
                        'l_org_id = ' || l_org_id);
                end if;

                if l_org_id is null then
                    po_moac_utils_pvt.INITIALIZE;
                    l_org_id := mo_global.get_current_org_id;
                end if;
			else
				l_org_id := p_org_id;
			end if;
        END;

       if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.cust_inv_loc_link',
                     'l_org_id = ' || l_org_id);
       end if;

        OPEN site_use_cur;
        FETCH site_use_cur INTO l_site_use_id, l_address_id;
        CLOSE site_use_cur;

       if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.cust_inv_loc_link',
                     'l_site_use_id = ' || l_site_use_id);
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.cust_inv_loc_link',
                     'l_address_id = ' || l_address_id);
       end if;

        -- do a check to see if inventory location already exists, execute foll.code
        -- only if it does not exist. If inventory_location exists,
        -- copy that to ship_to_location_id
        OPEN invloc_check_cur;
        FETCH invloc_check_cur into l_inv_location_id;
        OPEN address_cur;
        FETCH address_cur INTO address_rec;
        CLOSE address_cur;
        IF (invloc_check_cur%NOTFOUND) THEN
          IF (address_rec.country like 'US%') THEN
            l_state := address_rec.state;
            l_county := address_rec.county;
            l_city := address_rec.city;
            BEGIN
              select city_name, county_name, state_abbrev
              into l_city_name, l_county_name, l_state_abbrev
              from pay_us_city_names ct,
                   pay_us_states st,
                   pay_us_counties c
              where ct.state_code = st.state_code
              and   ct.county_code = c.county_code
              and   c.state_code = st.state_code
              and   st.state_abbrev = l_state
              and   upper(c.county_name) = upper(l_county)
              and   upper(ct.city_name) = upper(l_city);
            EXCEPTION
              when no_data_found then
                null;
            END;

          END IF;

       if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     'csp.plsql.CSP_SHIP_TO_ADDRESS_PVT.cust_inv_loc_link',
                     'Before calling site_to_invloc_linkage...');
       end if;

          site_to_invloc_linkage(
       	    p_customer_id		=> p_customer_id,
	        p_address_id		=> l_address_id,
	        p_site_use_id		=> l_site_use_id,
            p_location_id		=> l_location_id,
            p_style		        => 'GENERIC', -- address_Rec.country,
            p_address_line_1	=> address_rec.address1,
            p_address_line_2	=> address_rec.address2,
            p_address_line_3	=> address_rec.address3,
            p_country		    => address_rec.country,
	        p_postal_code	    => address_rec.postal_code,
            p_region_1		    => nvl(l_county_name, address_rec.county),
            p_region_2		    => nvl(l_state_Abbrev, address_rec.state),
	        p_region_3		    => null,
            p_town_or_city	    => nvl(l_city_name, address_rec.city),
            p_tax_name		    => null,
            p_telephone_number_1	=> null,
            p_telephone_number_2	=> null,
            p_telephone_number_3	=> null,
            p_loc_information13	=> null,
	        p_loc_information14	=> null,
	        p_loc_information15	=> null,
	        p_loc_information16	=> null,
	        p_loc_information17	=> null,
	        p_loc_information18	=> null,
	        p_loc_information19	=> null,
	        p_loc_information20	=> null,
	        p_api_version_number => l_api_version_number,
	        p_init_msg_list	    => 'T'
             ,P_ATTRIBUTE_CATEGORY => null --Name_In('HR_DESC_FLEX.attribute_category')
	       ,P_ATTRIBUTE1		=> null --Name_In('HR_DESC_FLEX.Attribute1')
	       ,P_ATTRIBUTE2		=> null --Name_In('HR_DESC_FLEX.Attribute2')
	       ,P_ATTRIBUTE3		=> null --Name_In('HR_DESC_FLEX.Attribute3')
	       ,P_ATTRIBUTE4		=> null --Name_In('HR_DESC_FLEX.Attribute4')
	       ,P_ATTRIBUTE5		=> null --Name_In('HR_DESC_FLEX.Attribute5')
	       ,P_ATTRIBUTE6		=> null --Name_In('HR_DESC_FLEX.Attribute6')
	       ,P_ATTRIBUTE7		=> null --Name_In('HR_DESC_FLEX.Attribute7')
	       ,P_ATTRIBUTE8		=> null --Name_In('HR_DESC_FLEX.Attribute8')
	       ,P_ATTRIBUTE9		=> null --Name_In('HR_DESC_FLEX.Attribute9')
	       ,P_ATTRIBUTE10		=> null --Name_In('HR_DESC_FLEX.Attribute10')
	       ,P_ATTRIBUTE11		=> null --Name_In('HR_DESC_FLEX.Attribute11')
	       ,P_ATTRIBUTE12		 => null --('HR_DESC_FLEX.Attribute12')
	       ,P_ATTRIBUTE13		 => null --Name_In('HR_DESC_FLEX.Attribute13')
	       ,P_ATTRIBUTE14		 => null --Name_In('HR_DESC_FLEX.Attribute14')
	       ,P_ATTRIBUTE15		 => null --Name_In('HR_DESC_FLEX.Attribute15')
	       ,P_ATTRIBUTE16		 => null --Name_In('HR_DESC_FLEX.Attribute16')
	       ,P_ATTRIBUTE17		 => null --Name_In('HR_DESC_FLEX.Attribute17')
	       ,P_ATTRIBUTE18		 => null --Name_In('HR_DESC_FLEX.Attribute18')
	       ,P_ATTRIBUTE19		 => null --Name_In('HR_DESC_FLEX.Attribute19')
	       ,P_ATTRIBUTE20		 => null --Name_In('HR_DESC_FLEX.Attribute20')
	       ,x_return_status	     => l_return_status
	       ,X_MSG_COUNT          => l_msg_count
 	       ,X_MSG_DATA           => l_msg_data
          );

          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              RAISE FND_API.G_EXC_ERROR;
          END IF;
          px_location_id := l_location_id;
        ELSE
          px_location_id := l_inv_location_id;
        END IF;
      ELSE
        -- not sure how to get cust_site_use_id if cust acct is null
        null;
      END IF;
    END If;
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        JTF_PLSQL_API.HANDLE_EXCEPTIONS(
             P_API_NAME => L_API_NAME
            ,P_PKG_NAME => G_PKG_NAME
            ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
            ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PUB
            ,X_MSG_COUNT    => X_MSG_COUNT
            ,X_MSG_DATA     => X_MSG_DATA
            ,X_RETURN_STATUS => X_RETURN_STATUS);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        JTF_PLSQL_API.HANDLE_EXCEPTIONS(
             P_API_NAME => L_API_NAME
            ,P_PKG_NAME => G_PKG_NAME
            ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
            ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PUB
            ,X_MSG_COUNT    => X_MSG_COUNT
            ,X_MSG_DATA     => X_MSG_DATA
            ,X_RETURN_STATUS => X_RETURN_STATUS);
    WHEN OTHERS THEN
      Rollback to cust_inv_loc_link_pub;
      FND_MESSAGE.SET_NAME('CSP', 'CSP_UNEXPECTED_EXEC_ERRORS');
      FND_MESSAGE.SET_TOKEN('ROUTINE', l_api_name, false);
      FND_MESSAGE.SET_TOKEN('SQLERRM', sqlerrm, false);
      FND_MSG_PUB.ADD;
      fnd_msg_pub.count_and_get
              ( p_count => x_msg_count
              , p_data  => x_msg_data);
      x_return_status := FND_API.G_RET_STS_ERROR;

  END;

	-- bug # 8333969
   PROCEDURE rs_primary_ship_to_addr
   (
      p_api_version        IN NUMBER
      ,p_Init_Msg_List     IN VARCHAR2     := FND_API.G_FALSE
      ,p_commit            IN VARCHAR2     := FND_API.G_FALSE
      ,p_rs_type				IN	VARCHAR2
      ,p_rs_id					IN	NUMBER
      ,p_rs_site_use_id		IN	NUMBER
      ,x_return_status     OUT NOCOPY VARCHAR2
      ,x_msg_count         OUT NOCOPY NUMBER
      ,x_msg_data          OUT NOCOPY VARCHAR2
   ) IS

   l_old_site_use_id    NUMBER;
   l_customer_id        NUMBER;
   l_old_inv_loc_id     NUMBER;
   l_old_status         VARCHAR2(1);
   l_new_inv_loc_id     NUMBER;
   l_new_status         VARCHAR2(1);

   CURSOR rs_current_primary_addr IS
      SELECT
        site_use_id,
        customer_id,
        inv_loc_id,
        status
      FROM
        csp_rs_ship_to_addresses_v
      WHERE
        resource_id = p_rs_id
        AND resource_type = p_rs_type
        AND primary_flag = 'Y';

   CURSOR rs_get_ship_to_addr IS
      SELECT
        customer_id,
        inv_loc_id,
        status
      FROM
        csp_rs_ship_to_addresses_v
      WHERE
        resource_id = p_rs_id
        AND resource_type = p_rs_type
        AND site_use_id = p_rs_site_use_id;

   BEGIN

      if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
         FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                    'csp.plsql.'|| G_PKG_NAME ||'.rs_primary_ship_to_addr',
                    'Begin');

         FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                    'csp.plsql.'|| G_PKG_NAME ||'.rs_primary_ship_to_addr',
                    'Parameters are: '
                    || 'p_api_version=' || p_api_version
                    || ',p_Init_Msg_List=' || p_Init_Msg_List
                    || ',p_commit=' || p_commit
                    || ',p_rs_type=' || p_rs_type
                    || ',p_rs_id=' || p_rs_id
                    || ',p_rs_site_use_id=' || p_rs_site_use_id);
      end if;

      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF FND_API.to_Boolean(p_Init_Msg_List)
      THEN
         FND_MSG_PUB.initialize;
      END IF;


      /*
         Logic in brief
         1. Get current Primary Ship To address
         2. If New site_use_id is same as old primary site_use_id then return
         3. Make old primary site_use_id as non primary
         4. Update customer account site record to non primary
         5. Make new site_use_id as primary
         6. Update customer account site record to primary
         7. COMMIT is required
      */

      -- Step 1: Get current Primary Ship To address
      open rs_current_primary_addr;
      fetch rs_current_primary_addr into l_old_site_use_id,
                                          l_customer_id,
                                          l_old_inv_loc_id,
                                          l_old_status;
      close rs_current_primary_addr;

      if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
         FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                    'csp.plsql.'|| G_PKG_NAME ||'.rs_primary_ship_to_addr',
                    'l_old_site_use_id=' || l_old_site_use_id
                    || ',l_customer_id=' || l_customer_id
                    || ',l_old_inv_loc_id=' || l_old_inv_loc_id
                    || ',l_old_status=' || l_old_status);
      end if;

      -- Step 2: If New site_use_id is same as old primary site_use_id then return
      IF l_old_site_use_id = p_rs_site_use_id THEN
         return;
      END IF;

      -- Step 3: Make old primary site_use_id as non primary
      DO_UPDATE_SITE_USE(
         P_SITE_USE_ID => l_old_site_use_id,
         P_PRIMARY_FLAG => 'N',
         P_STATUS => l_old_status,
         P_CUSTOMER_ID => l_customer_id,
         P_INV_LOCATION_ID => l_old_inv_loc_id,
         X_RETURN_STATUS => x_return_status,
         X_MSG_COUNT => x_msg_count,
         X_MSG_DATA => x_msg_data
      );

      if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
         FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                    'csp.plsql.'|| G_PKG_NAME ||'.rs_primary_ship_to_addr',
                    'x_return_status=' || x_return_status
                    || ',x_msg_count=' || x_msg_count
                    || ',x_msg_data=' || x_msg_data);
      end if;

      -- Step 4: Update customer account site record to non primary
      IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
         update HZ_CUST_ACCT_SITES_ALL
            set bill_to_flag = 'Y',
            ship_to_flag = 'Y'
         where cust_account_id = l_customer_id
         and cust_acct_site_id = (
            select cust_acct_site_id from HZ_CUST_SITE_USES_ALL
            where site_use_id = l_old_site_use_id);
      ELSE
         return;
      END IF;

      -- Step 5: Make new site_use_id as primary
      open rs_get_ship_to_addr;
      fetch rs_get_ship_to_addr into l_customer_id,
                                       l_new_inv_loc_id,
                                       l_new_status;
      close rs_get_ship_to_addr;

      if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
         FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                    'csp.plsql.'|| G_PKG_NAME ||'.rs_primary_ship_to_addr',
                    'p_rs_site_use_id=' || p_rs_site_use_id
                    || ',l_customer_id=' || l_customer_id
                    || ',l_new_inv_loc_id=' || l_new_inv_loc_id
                    || ',l_new_status=' || l_new_status);
      end if;

      DO_UPDATE_SITE_USE(
         P_SITE_USE_ID => p_rs_site_use_id,
         P_PRIMARY_FLAG => 'Y',
         P_STATUS => l_new_status,
         P_CUSTOMER_ID => l_customer_id,
         P_INV_LOCATION_ID => l_new_inv_loc_id,
         X_RETURN_STATUS => x_return_status,
         X_MSG_COUNT => x_msg_count,
         X_MSG_DATA => x_msg_data
      );

      if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
         FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                    'csp.plsql.'|| G_PKG_NAME ||'.rs_primary_ship_to_addr',
                    'x_return_status=' || x_return_status
                    || ',x_msg_count=' || x_msg_count
                    || ',x_msg_data=' || x_msg_data);
      end if;

      -- Step 6: Update customer account site record to primary
      IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
         update HZ_CUST_ACCT_SITES_ALL
            set bill_to_flag = 'P',
            ship_to_flag = 'P'
         where cust_account_id = l_customer_id
         and cust_acct_site_id = (
            select cust_acct_site_id from HZ_CUST_SITE_USES_ALL
            where site_use_id = p_rs_site_use_id);
      ELSE
         return;
      END IF;

      -- Step 7: COMMIT if requried
      IF p_commit = FND_API.G_TRUE THEN
         COMMIT;
      END IF;

   END;  -- End of rs_primary_ship_to_addr

   PROCEDURE rs_inactivate_ship_to
   (
      p_api_version        IN NUMBER
      ,p_Init_Msg_List     IN VARCHAR2     := FND_API.G_FALSE
      ,p_commit            IN VARCHAR2     := FND_API.G_FALSE
      ,p_rs_type				IN	VARCHAR2
      ,p_rs_id					IN	NUMBER
      ,p_rs_site_use_id		IN	NUMBER
      ,x_return_status     OUT NOCOPY VARCHAR2
      ,x_msg_count         OUT NOCOPY NUMBER
      ,x_msg_data          OUT NOCOPY VARCHAR2
   ) IS

   l_customer_id     NUMBER;
   l_inv_loc_id      NUMBER;
   l_primary_flag    VARCHAR(1);

   CURSOR rs_get_ship_to_addr IS
   SELECT
     customer_id,
     inv_loc_id,
     primary_flag
   FROM
     csp_rs_ship_to_addresses_v
   WHERE
     resource_id = p_rs_id
     AND resource_type = p_rs_type
     AND site_use_id = p_rs_site_use_id;

   BEGIN

      if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
         FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                    'csp.plsql.'|| G_PKG_NAME ||'.rs_inactivate_ship_to',
                    'Begin');

         FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                    'csp.plsql.'|| G_PKG_NAME ||'.rs_inactivate_ship_to',
                    'Parameters are: '
                    || 'p_api_version=' || p_api_version
                    || ',p_Init_Msg_List=' || p_Init_Msg_List
                    || ',p_commit=' || p_commit
                    || ',p_rs_type=' || p_rs_type
                    || ',p_rs_id=' || p_rs_id
                    || ',p_rs_site_use_id=' || p_rs_site_use_id);
      end if;

      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF FND_API.to_Boolean(p_Init_Msg_List)
      THEN
         FND_MSG_PUB.initialize;
      END IF;

      /*
         Logic in brief
         1. Get ship_to address detail
         2. Call DO_UPDATE_SITE_USE to update it
         3. COMMIT if required
      */

      -- Step 1: Get ship_to address detail
      open rs_get_ship_to_addr;
      fetch rs_get_ship_to_addr into l_customer_id,
                                       l_inv_loc_id,
                                       l_primary_flag;
      close rs_get_ship_to_addr;

      if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
         FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                    'csp.plsql.'|| G_PKG_NAME ||'.rs_primary_ship_to_addr',
                    'p_rs_site_use_id=' || p_rs_site_use_id
                    || ',l_customer_id=' || l_customer_id
                    || ',l_inv_loc_id=' || l_inv_loc_id
                    || ',l_primary_flag=' || l_primary_flag);
      end if;

      -- Step 2: Call DO_UPDATE_SITE_USE to update it
      DO_UPDATE_SITE_USE(
         P_SITE_USE_ID => p_rs_site_use_id,
         P_PRIMARY_FLAG => l_primary_flag,
         P_STATUS => 'I',
         P_CUSTOMER_ID => l_customer_id,
         P_INV_LOCATION_ID => l_inv_loc_id,
         X_RETURN_STATUS => x_return_status,
         X_MSG_COUNT => x_msg_count,
         X_MSG_DATA => x_msg_data
      );

      if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
         FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                    'csp.plsql.'|| G_PKG_NAME ||'.rs_primary_ship_to_addr',
                    'x_return_status=' || x_return_status
                    || ',x_msg_count=' || x_msg_count
                    || ',x_msg_data=' || x_msg_data);
      end if;

      -- Step 3: COMMIT if required
      IF x_return_status = FND_API.G_RET_STS_SUCCESS
         AND p_commit = FND_API.G_TRUE
      THEN
         COMMIT;
      END IF;

   END;  -- End of rs_inactivate_ship_to

procedure copy_hz_cust_site (
				p_src_org_id				IN NUMBER
				,p_dest_org_id				IN NUMBER
				,p_cust_site_id				IN NUMBER
				,p_hr_location_id			IN NUMBER
				,p_customer_id				IN NUMBER
				,x_return_status           OUT NOCOPY VARCHAR2
				,x_msg_count               OUT NOCOPY NUMBER
				,x_msg_data                OUT NOCOPY VARCHAR2
				) IS
	l_module_name	VARCHAR2(100)	:= 'csp.plsql.csp_ship_to_address_pvt.copy_hz_cust_site';
	l_current_org_id	NUMBER;
	l_msg varchar2(2000);
	v_cust_acct_site_rec  hz_cust_account_site_v2pub.cust_acct_site_rec_type;
	x_cust_acct_site_id NUMBER;
	l_cust_acct_site_use_id NUMBER;
	v_cust_site_use_rec hz_cust_account_site_v2pub.CUST_SITE_USE_REC_TYPE;
	v_customer_profile_rec  HZ_CUSTOMER_PROFILE_V2PUB.CUSTOMER_PROFILE_REC_TYPE;
	v_ship_bill_site  number;
	v_bill_site_id number;
	l_existing_bill_to number;
	v_bill_acct_site_rec hz_cust_account_site_v2pub.cust_acct_site_rec_type;
	x_bill_acct_site_id number;
	l_bill_acct_site_use_id number;
	v_bill_site_use_rec hz_cust_account_site_v2pub.CUST_SITE_USE_REC_TYPE;
	v_bill_cust_profile_rec HZ_CUSTOMER_PROFILE_V2PUB.CUSTOMER_PROFILE_REC_TYPE;
	x_site_use_id NUMBER;
	temp_ship_to_use_id number;

	cursor get_cust_acct_site_uses is
		select site_use_id
		from hz_cust_site_uses_all
		where cust_acct_site_id = p_cust_site_id;

   cursor get_bill_site_id is
		select cust_acct_site_id
		from HZ_CUST_SITE_USES_ALL
		where site_use_code = 'BILL_TO'
		and site_use_id = v_ship_bill_site;

   cursor check_bill_to_location is
		select newu.site_use_id
		from HZ_CUST_SITE_USES_ALL orgu,
		HZ_CUST_ACCT_SITES_ALL orgs,
		HZ_CUST_SITE_USES_ALL newu,
		HZ_CUST_ACCT_SITES_ALL news
		where orgu.site_use_code = 'BILL_TO'
		and orgu.site_use_id = v_ship_bill_site
		and orgu.cust_acct_site_id = orgs.cust_acct_site_id
		and news.party_site_id = orgs.party_site_id
		and news.cust_acct_site_id = newu.cust_acct_site_id
		and newu.site_use_code = 'BILL_TO'
		and newu.location = orgu.location
		and news.org_id = p_dest_org_id;

BEGIN

	if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
		 FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
			l_module_name,
			'Begin... p_src_org_id=' || p_src_org_id
			|| ', p_dest_org_id=' || p_dest_org_id
			|| ', p_cust_site_id=' || p_cust_site_id
			|| ', p_hr_location_id=' || p_hr_location_id
			|| ', p_customer_id=' || p_customer_id);
	end if;

	x_return_status := FND_API.G_RET_STS_SUCCESS;
	l_current_org_id := mo_global.get_current_org_id;

	if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
		 FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
			l_module_name,
			'l_current_org_id = ' || l_current_org_id);
	end if;

	-- get cust_site record in src ou
	po_moac_utils_pvt.set_org_context(p_src_org_id);
	hz_cust_account_site_v2pub.get_cust_acct_site_rec (
						  p_init_msg_list => FND_API.G_TRUE,
						  p_cust_acct_site_id => p_cust_site_id,
						  x_cust_acct_site_rec => v_cust_acct_site_rec,
						  x_return_status => x_return_status,
						  x_msg_count => x_msg_count,
						  x_msg_data => x_msg_data);
	po_moac_utils_pvt.set_org_context(l_current_org_id);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		l_msg := x_msg_data;
		FND_MESSAGE.SET_NAME('CSP', 'CSP_COPY_SITE_ERRORS');
		FND_MESSAGE.SET_TOKEN('CSP_MSG', l_msg, FALSE);
		FND_MSG_PUB.ADD;
		fnd_msg_pub.count_and_get
			( p_count => x_msg_count
			, p_data  => x_msg_data);
		x_return_status := FND_API.G_RET_STS_ERROR;
		RAISE FND_API.G_EXC_ERROR;
	END IF; -- IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

	if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
		FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
						l_module_name,
						'populated v_cust_acct_site_rec');
	end if;

	v_cust_acct_site_rec.cust_acct_site_id := NULL;
	v_cust_acct_site_rec.tp_header_id := NULL;
	v_cust_acct_site_rec.language := NULL;
	v_cust_acct_site_rec.created_by_module := 'CSPSHIPAD';
	v_cust_acct_site_rec.org_id := p_dest_org_id;

	-- now create same site in source ou
	po_moac_utils_pvt.set_org_context(p_dest_org_id);
	hz_cust_account_site_v2pub.create_cust_acct_site (
													p_init_msg_list => FND_API.G_TRUE,
													p_cust_acct_site_rec => v_cust_acct_site_rec,
													x_cust_acct_site_id => x_cust_acct_site_id,
													x_return_status => x_return_status,
													x_msg_count => x_msg_count,
													x_msg_data => x_msg_data);
	po_moac_utils_pvt.set_org_context(l_current_org_id);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		l_msg := x_msg_data;
		FND_MESSAGE.SET_NAME('CSP', 'CSP_COPY_SITE_ERRORS');
		FND_MESSAGE.SET_TOKEN('CSP_MSG', l_msg, FALSE);
		FND_MSG_PUB.ADD;
		fnd_msg_pub.count_and_get
			( p_count => x_msg_count
			, p_data  => x_msg_data);
		x_return_status := FND_API.G_RET_STS_ERROR;
		RAISE FND_API.G_EXC_ERROR;
	END IF; -- IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

	if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
		FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
							l_module_name,
							'x_cust_acct_site_id=' || x_cust_acct_site_id);
	end if;

	-- now fetch all site uses records and copy them to source ou
	OPEN get_cust_acct_site_uses;
	LOOP
		FETCH get_cust_acct_site_uses into l_cust_acct_site_use_id;
		EXIT WHEN get_cust_acct_site_uses%NOTFOUND;

		po_moac_utils_pvt.set_org_context(p_src_org_id);
		hz_cust_account_site_v2pub.get_cust_site_use_rec (
						p_init_msg_list => FND_API.G_TRUE,
						p_site_use_id => l_cust_acct_site_use_id,
						x_cust_site_use_rec => v_cust_site_use_rec,
						x_customer_profile_rec => v_customer_profile_rec,
						x_return_status => x_return_status,
						x_msg_count => x_msg_count,
						x_msg_data => x_msg_data);
		po_moac_utils_pvt.set_org_context(l_current_org_id);

		IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
			l_msg := x_msg_data;
			FND_MESSAGE.SET_NAME('CSP', 'CSP_COPY_SITE_ERRORS');
			FND_MESSAGE.SET_TOKEN('CSP_MSG', l_msg, FALSE);
			FND_MSG_PUB.ADD;
			fnd_msg_pub.count_and_get
				  ( p_count => x_msg_count
				  , p_data  => x_msg_data);
			x_return_status := FND_API.G_RET_STS_ERROR;
			RAISE FND_API.G_EXC_ERROR;
		END IF; -- IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

		if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
			FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
							l_module_name,
							'populated v_cust_site_use_rec');
		end if;

		v_cust_site_use_rec.site_use_id := NULL;
		v_cust_site_use_rec.primary_flag := 'N';
		v_cust_site_use_rec.created_by_module := 'CSPSHIPAD';
		v_cust_site_use_rec.org_id := p_dest_org_id;
		v_cust_site_use_rec.cust_acct_site_id := x_cust_acct_site_id;

		if v_cust_site_use_rec.site_use_code = 'SHIP_TO' then
			if v_cust_site_use_rec.bill_to_site_use_id is not null then
				v_ship_bill_site := v_cust_site_use_rec.bill_to_site_use_id;

				open get_bill_site_id;
				fetch get_bill_site_id into v_bill_site_id;
				close get_bill_site_id;

				if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
					FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
						l_module_name,
						'v_bill_site_id = ' || v_bill_site_id);
				end if;

				if v_bill_site_id <> p_cust_site_id then

					open check_bill_to_location;
					fetch check_bill_to_location into l_existing_bill_to;
					close check_bill_to_location;

					if l_existing_bill_to is null then

						-- do lots of stuff here
						po_moac_utils_pvt.set_org_context(p_src_org_id);
						hz_cust_account_site_v2pub.get_cust_acct_site_rec (
							p_init_msg_list => FND_API.G_TRUE,
							p_cust_acct_site_id => v_bill_site_id,
							x_cust_acct_site_rec => v_bill_acct_site_rec,
							x_return_status => x_return_status,
							x_msg_count => x_msg_count,
							x_msg_data => x_msg_data);
						po_moac_utils_pvt.set_org_context(l_current_org_id);

						IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
							l_msg := x_msg_data;
							FND_MESSAGE.SET_NAME('CSP', 'CSP_COPY_SITE_ERRORS');
							FND_MESSAGE.SET_TOKEN('CSP_MSG', l_msg, FALSE);
							FND_MSG_PUB.ADD;
							fnd_msg_pub.count_and_get
								( p_count => x_msg_count
								, p_data  => x_msg_data);
							x_return_status := FND_API.G_RET_STS_ERROR;
							RAISE FND_API.G_EXC_ERROR;
						END IF; -- IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

						if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
							FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
								l_module_name,
								'populated v_bill_acct_site_rec');
						end if;

						v_bill_acct_site_rec.cust_acct_site_id := NULL;
						v_bill_acct_site_rec.tp_header_id := NULL;
						v_bill_acct_site_rec.language := NULL;
						v_bill_acct_site_rec.created_by_module := 'CSPSHIPAD';
						v_bill_acct_site_rec.org_id := p_dest_org_id;

						-- now create same site in source ou
						po_moac_utils_pvt.set_org_context(p_dest_org_id);
						hz_cust_account_site_v2pub.create_cust_acct_site (
							 p_init_msg_list => FND_API.G_TRUE,
							 p_cust_acct_site_rec => v_bill_acct_site_rec,
							 x_cust_acct_site_id => x_bill_acct_site_id,
							 x_return_status => x_return_status,
							 x_msg_count => x_msg_count,
							 x_msg_data => x_msg_data);
						po_moac_utils_pvt.set_org_context(l_current_org_id);

						IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
							l_msg := x_msg_data;
							FND_MESSAGE.SET_NAME('CSP', 'CSP_COPY_SITE_ERRORS');
							FND_MESSAGE.SET_TOKEN('CSP_MSG', l_msg, FALSE);
							FND_MSG_PUB.ADD;
							fnd_msg_pub.count_and_get
								( p_count => x_msg_count
								, p_data  => x_msg_data);
							x_return_status := FND_API.G_RET_STS_ERROR;
							RAISE FND_API.G_EXC_ERROR;
						END IF; -- IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

						if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
							FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
								l_module_name,
								'x_bill_acct_site_id=' || x_bill_acct_site_id);
						end if;

						l_bill_acct_site_use_id := v_ship_bill_site;

						po_moac_utils_pvt.set_org_context(p_src_org_id);
						hz_cust_account_site_v2pub.get_cust_site_use_rec (
							p_init_msg_list => FND_API.G_TRUE,
							p_site_use_id => l_bill_acct_site_use_id,
							x_cust_site_use_rec => v_bill_site_use_rec,
							x_customer_profile_rec => v_bill_cust_profile_rec,
							x_return_status => x_return_status,
							x_msg_count => x_msg_count,
							x_msg_data => x_msg_data);
						po_moac_utils_pvt.set_org_context(l_current_org_id);

						IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
							l_msg := x_msg_data;
							FND_MESSAGE.SET_NAME('CSP', 'CSP_COPY_SITE_ERRORS');
							FND_MESSAGE.SET_TOKEN('CSP_MSG', l_msg, FALSE);
							FND_MSG_PUB.ADD;
							fnd_msg_pub.count_and_get
								( p_count => x_msg_count
								, p_data  => x_msg_data);
							x_return_status := FND_API.G_RET_STS_ERROR;
							RAISE FND_API.G_EXC_ERROR;
						END IF; -- IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

						if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
							FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
								l_module_name,
								'populated v_bill_site_use_rec');
						end if;

						v_bill_site_use_rec.site_use_id := NULL;
						v_bill_site_use_rec.primary_flag := 'N';
						v_bill_site_use_rec.created_by_module := 'CSPSHIPAD';
						v_bill_site_use_rec.org_id := p_dest_org_id;
						v_bill_site_use_rec.cust_acct_site_id := x_bill_acct_site_id;

						po_moac_utils_pvt.set_org_context(p_dest_org_id);
						hz_cust_account_site_v2pub.create_cust_site_use (
							 p_init_msg_list => FND_API.G_TRUE,
							 p_cust_site_use_rec => v_bill_site_use_rec,
							 p_customer_profile_rec => v_bill_cust_profile_rec,
							 p_create_profile => FND_API.G_FALSE,
							 p_create_profile_amt => FND_API.G_FALSE,
							 x_site_use_id => x_site_use_id,
							 x_return_status => x_return_status,
							 x_msg_count => x_msg_count,
							 x_msg_data => x_msg_data);
						po_moac_utils_pvt.set_org_context(l_current_org_id);

						IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
							l_msg := x_msg_data;
							FND_MESSAGE.SET_NAME('CSP', 'CSP_COPY_SITE_ERRORS');
							FND_MESSAGE.SET_TOKEN('CSP_MSG', l_msg, FALSE);
							FND_MSG_PUB.ADD;
							fnd_msg_pub.count_and_get
								( p_count => x_msg_count
								, p_data  => x_msg_data);
							x_return_status := FND_API.G_RET_STS_ERROR;
							po_moac_utils_pvt.set_org_context(l_current_org_id);
							RAISE FND_API.G_EXC_ERROR;
						END IF; -- IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

						if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
							FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
								l_module_name,
								'x_site_use_id=' || x_site_use_id);
						end if;

						v_cust_site_use_rec.bill_to_site_use_id := x_site_use_id;

					else
						v_cust_site_use_rec.bill_to_site_use_id := l_existing_bill_to;
					end if;
				else
					v_cust_site_use_rec.bill_to_site_use_id := null;
				end if;
			end if;
		end if;

		if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
			FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
								l_module_name,
								'v_cust_site_use_rec.site_use_code=' || v_cust_site_use_rec.site_use_code
								|| ', v_cust_site_use_rec.bill_to_site_use_id=' || v_cust_site_use_rec.bill_to_site_use_id);
		end if;

		po_moac_utils_pvt.set_org_context(p_dest_org_id);
		hz_cust_account_site_v2pub.create_cust_site_use (
											  p_init_msg_list => FND_API.G_TRUE,
											  p_cust_site_use_rec => v_cust_site_use_rec,
											  p_customer_profile_rec => v_customer_profile_rec,
											  p_create_profile => FND_API.G_FALSE,
											  p_create_profile_amt => FND_API.G_FALSE,
											  x_site_use_id => x_site_use_id,
											  x_return_status => x_return_status,
											  x_msg_count => x_msg_count,
											  x_msg_data => x_msg_data);
		po_moac_utils_pvt.set_org_context(l_current_org_id);

		IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
			l_msg := x_msg_data;
			FND_MESSAGE.SET_NAME('CSP', 'CSP_COPY_SITE_ERRORS');
			FND_MESSAGE.SET_TOKEN('CSP_MSG', l_msg, FALSE);
			FND_MSG_PUB.ADD;
			fnd_msg_pub.count_and_get
				( p_count => x_msg_count
				, p_data  => x_msg_data);
			x_return_status := FND_API.G_RET_STS_ERROR;
			po_moac_utils_pvt.set_org_context(l_current_org_id);
			RAISE FND_API.G_EXC_ERROR;
		END IF; -- IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

		if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
			FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
						l_module_name,
						'x_site_use_id=' || x_site_use_id);
		end if;

		if v_cust_site_use_rec.site_use_code = 'SHIP_TO' then
			temp_ship_to_use_id := x_site_use_id;
		end if;

	END LOOP;
	close get_cust_acct_site_uses;

	if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
		FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
			l_module_name,
			'x_cust_acct_site_id=' || x_cust_acct_site_id
			|| ', temp_ship_to_use_id=' || temp_ship_to_use_id);
	end if;

	-- update inventory_location link for this new site_use
	po_moac_utils_pvt.set_org_context(p_dest_org_id);
	arp_clas_pkg.insert_po_loc_associations(
		p_inventory_location_id       => p_hr_location_id,
		p_inventory_organization_id   => p_dest_org_id,
		p_customer_id                 => p_customer_id,
		p_address_id                  => x_cust_acct_site_id,
		p_site_use_id                 => temp_ship_to_use_id,
		x_return_status               => x_return_status,
		x_msg_count                   => x_msg_count,
		x_msg_data                    => x_msg_data);
	po_moac_utils_pvt.set_org_context(l_current_org_id);

	if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
		FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
			l_module_name,
			'arp_clas_pkg.insert_po_loc_associations... x_return_status=' || x_return_status);
	end if;

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		l_msg := x_msg_data;
		FND_MESSAGE.SET_NAME('CSP', 'CSP_COPY_SITE_ERRORS');
		FND_MESSAGE.SET_TOKEN('CSP_MSG', l_msg, FALSE);
		FND_MSG_PUB.ADD;
		fnd_msg_pub.count_and_get
			( p_count => x_msg_count
			, p_data  => x_msg_data);
		x_return_status := FND_API.G_RET_STS_ERROR;
		RAISE FND_API.G_EXC_ERROR;
	END IF; -- IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

	if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
		FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
			l_module_name,
			'Done!!!');
	end if;
END;

PROCEDURE ship_to_address_handler
   (p_resource_type           IN VARCHAR2
   ,p_resource_id             IN NUMBER
   ,p_location_id             IN OUT NOCOPY NUMBER
   ,p_timezone                IN VARCHAR2
   ,p_primary_flag            IN VARCHAR2
   ,p_status                  IN VARCHAR2
   ,x_return_status           OUT NOCOPY VARCHAR2
   ,x_msg_count               OUT NOCOPY NUMBER
   ,x_msg_data                OUT NOCOPY VARCHAR2
   ) IS

	v_location_id	NUMBER;
	v_customer_id	NUMBER;
	l_address_line_1 VARCHAR2(240);
	l_address_line_2 VARCHAR2(240);
	l_address_line_3 VARCHAR2(240);
	l_town_or_city VARCHAR2(30);
	l_postal_code VARCHAR2(30);
	l_country VARCHAR2(60);
	l_style VARCHAR2(7);
	l_region_1 VARCHAR2(120);
	l_region_2 VARCHAR2(120);
	l_region_3 VARCHAR2(120);
	l_tax_name VARCHAR2(15);
	l_telephone_number_1 VARCHAR2(60);
	l_telephone_number_2 VARCHAR2(60);
	l_telephone_number_3 VARCHAR2(60);
	l_loc_information13 VARCHAR2(150);
	l_loc_information14 VARCHAR2(150);
	l_loc_information15 VARCHAR2(150);
	l_loc_information16 VARCHAR2(150);
	l_loc_information17 VARCHAR2(150);
	l_loc_information18 VARCHAR2(150);
	l_loc_information19 VARCHAR2(150);
	l_loc_information20 VARCHAR2(150);
	l_object_version_number NUMBER;
	l_attribute_category VARCHAR2(30);
	l_attribute1 VARCHAR2(150);
	l_attribute2 VARCHAR2(150);
	l_attribute3 VARCHAR2(150);
	l_attribute4 VARCHAR2(150);
	l_attribute5 VARCHAR2(150);
	l_attribute6 VARCHAR2(150);
	l_attribute7 VARCHAR2(150);
	l_attribute8 VARCHAR2(150);
	l_attribute9 VARCHAR2(150);
	l_attribute10 VARCHAR2(150);
	l_attribute11 VARCHAR2(150);
	l_attribute12 VARCHAR2(150);
	l_attribute13 VARCHAR2(150);
	l_attribute14 VARCHAR2(150);
	l_attribute15 VARCHAR2(150);
	l_attribute16 VARCHAR2(150);
	l_attribute17 VARCHAR2(150);
	l_attribute18 VARCHAR2(150);
	l_attribute19 VARCHAR2(150);
	l_attribute20 VARCHAR2(150);
	l_module_name VARCHAR2(150);

   cursor get_loc_details is
	SELECT
		hra.address_line_1,
		hra.address_line_2,
		hra.address_line_3,
		hra.town_or_city,
		hra.postal_code,
		hra.country,
		hra.style,
		hra.region_1,
		hra.region_2,
		hra.region_3,
		hra.tax_name,
		hra.telephone_number_1,
		hra.telephone_number_2,
		hra.telephone_number_3,
		hra.loc_information13,
		hra.loc_information14,
		hra.loc_information15,
		hra.loc_information16,
		hra.loc_information17,
		hra.loc_information18,
		hra.loc_information19,
		hra.loc_information20,
		hra.object_version_number,
		hra.attribute_category,
		hra.attribute1,
		hra.attribute2,
		hra.attribute3,
		hra.attribute4,
		hra.attribute5,
		hra.attribute6,
		hra.attribute7,
		hra.attribute8,
		hra.attribute9,
		hra.attribute10,
		hra.attribute11,
		hra.attribute12,
		hra.attribute13,
		hra.attribute14,
		hra.attribute15,
		hra.attribute16,
		hra.attribute17,
		hra.attribute18,
		hra.attribute19,
		hra.attribute20
	  FROM hr_locations_all hra
	  where hra.location_id = p_location_id;
BEGIN
	l_module_name := 'csp.plsql.csp_ship_to_address_pvt.ship_to_address_handler2';
	v_location_id := p_location_id;

	if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
		FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
			l_module_name,
			'Begin... p_resource_type=' || p_resource_type
			|| ', p_resource_id=' || p_resource_id
			|| ', v_location_id=' || v_location_id
			|| ', p_timezone=' || p_timezone
			|| ', p_primary_flag=' || p_primary_flag
			|| ', p_status=' || p_status);
	end if;

	x_return_status := FND_API.G_RET_STS_SUCCESS;

	if p_location_id is not null then
		open get_loc_details;
		fetch get_loc_details into
			l_address_line_1,
			l_address_line_2,
			l_address_line_3,
			l_town_or_city,
			l_postal_code,
			l_country,
			l_style,
			l_region_1,
			l_region_2,
			l_region_3,
			l_tax_name,
			l_telephone_number_1,
			l_telephone_number_2,
			l_telephone_number_3,
			l_loc_information13,
			l_loc_information14,
			l_loc_information15,
			l_loc_information16,
			l_loc_information17,
			l_loc_information18,
			l_loc_information19,
			l_loc_information20,
			l_object_version_number,
			l_attribute_category,
			l_attribute1,
			l_attribute2,
			l_attribute3,
			l_attribute4,
			l_attribute5,
			l_attribute6,
			l_attribute7,
			l_attribute8,
			l_attribute9,
			l_attribute10,
			l_attribute11,
			l_attribute12,
			l_attribute13,
			l_attribute14,
			l_attribute15,
			l_attribute16,
			l_attribute17,
			l_attribute18,
			l_attribute19,
			l_attribute20;
		close get_loc_details;

		ship_to_address_handler(
			p_task_assignment_id		=> null,
			p_resource_type			=> p_resource_type,
			p_resource_id			=> p_resource_id,
			p_customer_id			=> v_customer_id,
			p_location_id			=> v_location_id,
			p_style				=> l_style,
			p_address_line_1			=> l_address_line_1,
			p_address_line_2			=> l_address_line_2,
			p_address_line_3			=> l_address_line_3,
			p_country				=> l_country,
			p_postal_code			=> l_postal_code,
			p_region_1			=> l_region_1,
			p_region_2			=> l_region_2,
			p_region_3			=> l_region_3,
			p_town_or_city			=> l_town_or_city,
			p_tax_name			=> l_tax_name,
			p_telephone_number_1		=> l_telephone_number_1,
			p_telephone_number_2		=> l_telephone_number_2,
			p_telephone_number_3		=> l_telephone_number_3,
			p_loc_information13		=> l_loc_information13,
			p_loc_information14		=> l_loc_information14,
			p_loc_information15		=> l_loc_information15,
			p_loc_information16		=> l_loc_information16,
			p_loc_information17		=> l_loc_information17,
			p_loc_information18		=> l_loc_information18,
			p_loc_information19		=> l_loc_information19,
			p_loc_information20		=> l_loc_information20,
			p_timezone			=> p_timezone,
			p_primary_flag			=> p_primary_flag,
			p_status				=> p_status,
			p_object_version_number		=> l_object_version_number,
			p_api_version_number		=> 1.0,
			p_init_msg_list			=> 'Y',
			p_commit				=> 'F',
			p_attribute_category		=> l_attribute_category,
			p_attribute1			=> l_attribute1,
			p_attribute2			=> l_attribute2,
			p_attribute3			=> l_attribute3,
			p_attribute4			=> l_attribute4,
			p_attribute5			=> l_attribute5,
			p_attribute6			=> l_attribute6,
			p_attribute7			=> l_attribute7,
			p_attribute8			=> l_attribute8,
			p_attribute9			=> l_attribute9,
			p_attribute10			=> l_attribute10,
			p_attribute11			=> l_attribute11,
			p_attribute12			=> l_attribute12,
			p_attribute13			=> l_attribute13,
			p_attribute14			=> l_attribute14,
			p_attribute15			=> l_attribute15,
			p_attribute16			=> l_attribute16,
			p_attribute17			=> l_attribute17,
			p_attribute18			=> l_attribute18,
			p_attribute19			=> l_attribute19,
			p_attribute20			=> l_attribute20,
			x_return_status			=> x_return_status,
			x_msg_count			=> x_msg_count,
			x_msg_data			=> x_msg_data
			);

		if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
			FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
				l_module_name,
				'x_return_status=' || x_return_status);
		end if;

	end if;

	if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
		FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
			l_module_name,
			'Done!!!');
	end if;

END;

END CSP_SHIP_TO_ADDRESS_PVT;

/
