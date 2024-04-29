--------------------------------------------------------
--  DDL for Package Body OE_OPM_RMA_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_OPM_RMA_UTILS" AS
/* $Header: OEXOPMIB.pls 120.0 2005/05/31 23:23:29 appldev noship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_OPM_RMA_UTILS';


--  get_opm_lot_quantities

PROCEDURE get_opm_lot_quantities
(   p_line_id IN NUMBER,
    p_lot_number IN VARCHAR2,
    p_sublot_number IN VARCHAR2,
    p_quantity OUT NOCOPY NUMBER,
    p_quantity2 OUT NOCOPY NUMBER
)

IS

l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

BEGIN

     IF l_debug_level > 0 THEN
            OE_DEBUG_PUB.add('Entering Get_opm_lot_quantities ',1);
     END IF;


    IF (p_line_id IS  NULL OR
        p_line_id = FND_API.G_MISS_NUM)
    THEN
       IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
        OE_MSG_PUB.Add_Exc_Msg
        (   G_PKG_NAME
          , 'get_opm_lot_quantities'
          , 'line_id = '|| p_line_id );
       END IF;

       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF; -- IF (p_line_id IS  NULL OR

   IF p_line_id <> FND_API.G_MISS_NUM THEN

     SELECT quantity,
            quantity2
     INTO   p_quantity,
            p_quantity2
     FROM   oe_lot_serial_numbers
     WHERE  line_id   = p_line_id
      and   lot_number = p_lot_number
      and   sublot_number = p_sublot_number;

   END IF;


EXCEPTION

   WHEN NO_DATA_FOUND THEN
         IF l_debug_level > 0 THEN
            OE_DEBUG_PUB.add('Get_opm_lot_quantities has error ',1);
            OE_DEBUG_PUB.add('Error Message at 1 : '||sqlerrm,1);
         END IF;

          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

   WHEN OTHERS THEN

         IF l_debug_level > 0 THEN
            OE_DEBUG_PUB.add('Get_opm_lot_quantities has error ',1);
            OE_DEBUG_PUB.add('Error Message at 2 : '||sqlerrm,1);
         END IF;

         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END get_opm_lot_quantities;

END OE_OPM_RMA_UTILS;

/
