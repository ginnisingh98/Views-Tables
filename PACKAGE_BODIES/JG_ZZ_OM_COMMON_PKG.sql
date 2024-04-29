--------------------------------------------------------
--  DDL for Package Body JG_ZZ_OM_COMMON_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JG_ZZ_OM_COMMON_PKG" AS
/* $Header: jgzzomcb.pls 120.13 2005/10/06 01:15:16 appradha ship $ */

PG_DEBUG NUMBER ;

/*----------------------------------------------------------------------------*
 |   PUBLIC FUNCTIONS/PROCEDURES  					      |
 *----------------------------------------------------------------------------*/

/*----------------------------------------------------------------------------*
 | PROCEDURE                                                                  |
 |    copy_gdff                           			      	      |
 |                                                                            |
 | DESCRIPTION                                                                |
 |    For each row created in the current submission of OM Invoicing process, |
 |    this procedure copies required global attribute columns to the interface|
 |    table. 				                                      |
 |									      |
 | PARAMETERS                                                                 |
 |   INPUT                                                 		      |
 |      p_interface_line_rec    OE_Invoice_PUB.OE_GDF_Rec_Type                |
 |                              Interface line record declared in OEXPINVS.pls|
 |   OUTPUT                                                		      |
 |      x_interface_line_rec    OE_Invoice_PUB.OE_GDF_Rec_Type                |
 |                              Interface line record declared in OEXPINVS.pls|
 |      x_error_buffer          VARCHAR2 -- Error Message  	              |
 |      x_return_code         	NUMBER   -- Error Code.           	      |
 |                                          0 - Success, 2 - Failure. 	      |
 |                                                                            |
 | HISTORY                                                                    |
 |                                                                            |
 |    24-JAN-2000 Harsh Takle      Created.                                   |
 |    01-SEP-2000 Satyadeep Chandrashekar Added debug messages(bug 1395908)   |
 *----------------------------------------------------------------------------*/
PROCEDURE copy_gdff (
        p_interface_line_rec IN     OE_Invoice_PUB.OE_GDF_Rec_Type,
        x_interface_line_rec IN OUT NOCOPY OE_Invoice_PUB.OE_GDF_Rec_Type,
	x_return_code        IN OUT NOCOPY NUMBER,
	x_error_buffer       IN OUT NOCOPY VARCHAR2) IS

--
  l_country_code VARCHAR2(2);
BEGIN

  x_error_buffer := NULL;
  x_return_code := 0;
  l_country_code := NULL;
  x_interface_line_rec := p_interface_line_rec;

  --Following line is commented as a part of bug 2133665
  --l_country_code := fnd_profile.value('JGZZ_COUNTRY_CODE');
  --
  l_country_code := SUBSTR(p_interface_line_rec.line_gdf_attr_category,4,2);
  --
  OE_DEBUG_PUB.ADD('JG pkg Country Code is ' || l_country_code);

  IF NVL(l_country_code,'$') IN ('BR','AR','CO') THEN

    IF (PG_DEBUG > 0)  THEN
      OE_DEBUG_PUB.ADD('JG pkg calling JL Pkg ');
    END IF;
     JL_ZZ_RECEIV_INTERFACE.copy_gdff (p_interface_line_rec,
                                    x_interface_line_rec,
		                    x_return_code,
		                    x_error_buffer);

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (PG_DEBUG > 0)  THEN
       OE_DEBUG_PUB.ADD('JG-Exception when others');
    END IF;
       x_error_buffer := SQLERRM;
       x_return_code := 2;

END copy_gdff;

/*----------------------------------------------------------------------------*
 | PROCEDURE                                                                  |
 |    default_gdff                           			      	      |
 |                                                                            |
 | DESCRIPTION                                                                |
 |    When the item is entered on Sales Order Line, if inventory item id is   |
 |    not null then this procedure will default global descriptive flexfield  |
 |    values if they are null                                                 |
 |									      |
 | PARAMETERS                                                                 |
 |   INPUT                                                 		      |
 |      p_line_rec              oe_order_pub.line_rec_type Interface line     |
 |                              record declared in OEXPORDS.pls               |
 |   OUTPUT                                                		      |
 |      x_line_rec              oe_order_pub.line_rec_type Interface line     |
 |                              record declared in OEXPORDS.pls               |
 |      x_error_buffer          VARCHAR2 -- Error Message  	              |
 |      x_return_code         	NUMBER   -- Error Code.           	      |
 |                                          0 - Success, 2 - Failure. 	      |
 |                                                                            |
 | HISTORY                                                                    |
 |                                                                            |
 |    24-JAN-2000 Harsh Takle      Created.                                   |
 *----------------------------------------------------------------------------*/
PROCEDURE default_gdff
     (p_line_rec     IN     oe_order_pub.line_rec_type,
      x_line_rec        OUT NOCOPY oe_order_pub.line_rec_type,
      x_return_code  IN OUT NOCOPY NUMBER,
      x_error_buffer IN OUT NOCOPY VARCHAR2
      ) IS
--
  l_country_code VARCHAR2(2);
  l_org_id       NUMBER;
BEGIN
    l_org_id := MO_GLOBAL.get_current_org_id;

  x_error_buffer := NULL;
  x_return_code := 0;
  l_country_code := NULL;
  x_line_rec := p_line_rec;

  --Bug 2354736
  --l_country_code := FND_PROFILE.VALUE('JGZZ_COUNTRY_CODE');
  l_country_code := JG_ZZ_SHARED_PKG.GET_COUNTRY(l_org_id, null);

  IF NVL(l_country_code,'$') IN ('BR','AR','CO') THEN
     JL_ZZ_RECEIV_INTERFACE.default_gdff (p_line_rec,
                                          x_line_rec,
                                          x_return_code,
                                          x_error_buffer,
                                          l_org_id); --Bug fix 2354736);

  END IF;

EXCEPTION
  WHEN OTHERS THEN
       x_error_buffer := SQLERRM;
       x_return_code := 2;

END default_gdff;

/*----------------------------------------------------------------------------*
 | PROCEDURE                                                                  |
 |    copy_gdf                           			      	      |
 |                                                                            |
 | DESCRIPTION                                                                |
 |    For each row created in the current submission of OM Invoicing process, |
 |    this procedure copies required global attribute columns to the interface|
 |    table. 				                                      |
 |									      |
 | PARAMETERS                                                                 |
 |   OUTPUT                                                		      |
 |      x_interface_line_rec    OE_Invoice_PUB.OE_GDF_Rec_Type                |
 |                              Interface line record declared in OEXPINVS.pls|
 |      x_error_buffer          VARCHAR2 -- Error Message  	              |
 |      x_return_code         	NUMBER   -- Error Code.           	      |
 |                                          0 - Success, 2 - Failure. 	      |
 |                                                                            |
 | HISTORY                                                                    |
 |                                                                            |
 |    01-AUG-2001 Sudhir Sekuri     Created.                                  |
 *----------------------------------------------------------------------------*/
PROCEDURE copy_gdf ( x_interface_line_rec IN OUT NOCOPY OE_Invoice_PUB.OE_GDF_Rec_Type,
	             x_return_code        IN OUT NOCOPY NUMBER,
                     x_error_buffer       IN OUT NOCOPY VARCHAR2) IS

  l_country_code VARCHAR2(2);
BEGIN

  x_error_buffer := NULL;
  x_return_code := 0;
  l_country_code := NULL;

  --Following line is commented as a part of bug 2133665
  --l_country_code := fnd_profile.value('JGZZ_COUNTRY_CODE');
  --
  l_country_code := SUBSTR(x_interface_line_rec.line_gdf_attr_category,4,2);
  --
  IF (PG_DEBUG > 0)  THEN
    OE_DEBUG_PUB.ADD('JG pkg Country Code is ' || l_country_code);
  END IF;

  IF NVL(l_country_code,'$') IN ('BR','AR','CO') THEN

  IF (PG_DEBUG > 0)  THEN
     OE_DEBUG_PUB.ADD('JG pkg calling JL Pkg ');
  END IF;
     JL_ZZ_RECEIV_INTERFACE.copy_gdf (x_interface_line_rec,
		                      x_return_code,
		                      x_error_buffer);

  END IF;

EXCEPTION
  WHEN OTHERS THEN
     IF (PG_DEBUG > 0)  THEN
       OE_DEBUG_PUB.ADD('JG-Exception when others');
     END IF;
       x_error_buffer := SQLERRM;
       x_return_code := 2;

END copy_gdf;

/*----------------------------------------------------------------------------*
 | PROCEDURE                                                                  |
 |    default_gdf                           			      	      |
 |                                                                            |
 | DESCRIPTION                                                                |
 |    When the item is entered on Sales Order Line, if inventory item id is   |
 |    not null then this procedure will default global descriptive flexfield  |
 |    values if they are null                                                 |
 |									      |
 | PARAMETERS                                                                 |
 |   OUTPUT                                                		      |
 |      x_line_rec              oe_order_pub.line_rec_type Interface line     |
 |                              record declared in OEXPORDS.pls               |
 |      x_error_buffer          VARCHAR2 -- Error Message  	              |
 |      x_return_code         	NUMBER   -- Error Code.           	      |
 |                                          0 - Success, 2 - Failure. 	      |
 |                                                                            |
 | HISTORY                                                                    |
 |                                                                            |
 |    06-AUG-2001 Sudhir Sekuri      Created.                                 |
 *----------------------------------------------------------------------------*/
PROCEDURE default_gdf
     (x_line_rec     IN OUT NOCOPY oe_order_pub.line_rec_type,
      x_return_code  IN OUT NOCOPY NUMBER,
      x_error_buffer IN OUT NOCOPY VARCHAR2
    ) IS

  l_country_code VARCHAR2(2);
  l_org_id       NUMBER;
BEGIN
    l_org_id := MO_GLOBAL.get_current_org_id;

  x_error_buffer := NULL;
  x_return_code := 0;
  l_country_code := NULL;

  --Bug 2354736
  --l_country_code := FND_PROFILE.VALUE('JGZZ_COUNTRY_CODE');
  l_country_code := JG_ZZ_SHARED_PKG.GET_COUNTRY(l_org_id, null);

  IF NVL(l_country_code,'$') IN ('BR','AR','CO') THEN
    JL_ZZ_RECEIV_INTERFACE.default_gdf (x_line_rec,
                                        x_return_code,
                                        x_error_buffer,
                                        l_org_id); --Bug fix 2354736

  END IF;

EXCEPTION
  WHEN OTHERS THEN
       x_error_buffer := SQLERRM;
       x_return_code := 2;

END default_gdf;

BEGIN

PG_DEBUG := to_number(NVL(FND_PROFILE.value('ONT_DEBUG_LEVEL'), '0'));

END JG_ZZ_OM_COMMON_PKG;

/
