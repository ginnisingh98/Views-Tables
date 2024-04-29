--------------------------------------------------------
--  DDL for Package Body OE_PRINT_FLEX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_PRINT_FLEX" AS
/* $Header: OEXUPRFB.pls 115.2 2003/10/20 07:16:43 appldev ship $ */

-- Purpose: This package is used by the OE_BLKTPRT_FLEX_HDR_V and
-- OE_BLKTPRT_FLEX_LINES_V views to print the DFF data from the blanket header
-- and blanket lines.The context is set initially and the structure is validated
-- Once the context is set and the structure validated, the api returns a value
-- or description based on the p_value parameter, that indicates a 'D' or 'V'
-- The structure validation information is cached in g_valid_structure for
-- performance considerations.
--

g_valid_structure boolean;
G_PKG_NAME CONSTANT VARCHAR2(30) := 'OE_PRINT_FLEX';
G_FUNCTION_NAME CONSTANT VARCHAR2(30) := 'GET_FLEXDESC';
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;


FUNCTION get_flexdesc(
        p_appl_short_name IN varchar2 ,
        p_desc_flex_name IN varchar2,
        p_values_or_ids IN varchar2 ,
        p_validation_date IN date,
        p_context    IN varchar2 ,
        p_attribute1 IN varchar2 ,
        p_attribute2 IN varchar2 ,
        p_attribute3 IN varchar2 ,
        p_attribute4 IN varchar2 ,
        p_attribute5 IN varchar2 ,
        p_attribute6 IN varchar2 ,
        p_attribute7 IN varchar2 ,
        p_attribute8 IN varchar2 ,
        p_attribute9 IN varchar2 ,
        p_attribute10 IN varchar2 ,
        p_attribute11 IN varchar2 ,
        p_attribute12 IN varchar2 ,
        p_attribute13 IN varchar2 ,
        p_attribute14 IN varchar2 ,
        p_attribute15 IN varchar2 ,
        p_attribute16 IN varchar2 ,
        p_attribute17 IN varchar2 ,
        p_attribute18 IN varchar2 ,
        p_attribute19 IN varchar2 ,
        p_attribute20 IN varchar2 ,
        p_value IN varchar2 , -- Either 'V' for value or 'D' for description is passed
        p_segment_number IN NUMBER , -- Will have a value of 1 to 21
        p_context_reset_flag IN varchar2)
RETURN VARCHAR2 IS

l_val_desc varchar2(400) := null;


BEGIN

  IF p_context_reset_flag = 'Y' THEN
     g_valid_structure := FALSE;
  END IF;
     IF l_debug_level > 0 THEN
        oe_debug_pub.add('START: '||G_PKG_NAME||':'||G_FUNCTION_NAME);
	oe_debug_pub.add('-----------------------------------------------');
	oe_debug_pub.add('appl_short_name = ' || p_appl_short_name);
	oe_debug_pub.add('desc_flex_name  = ' || p_desc_flex_name);
	oe_debug_pub.add('values_or_ids   = ' || p_values_or_ids);
	oe_debug_pub.add('validation_date = ' || p_validation_date);
        oe_debug_pub.add('p_validation_date = '||p_validation_date);
        oe_debug_pub.add('p_context = '||p_context);
        oe_debug_pub.add('p_attribute1 = ' ||p_attribute1);
        oe_debug_pub.add('p_attribute2 = ' ||p_attribute2);
        oe_debug_pub.add('p_attribute3 = ' ||p_attribute3);
        oe_debug_pub.add('p_attribute4 = ' ||p_attribute4);
        oe_debug_pub.add('p_attribute5 = ' ||p_attribute5);
        oe_debug_pub.add('p_attribute6 = ' ||p_attribute6);
        oe_debug_pub.add('p_attribute7 = ' ||p_attribute7);
        oe_debug_pub.add('p_attribute8 = ' ||p_attribute8);
        oe_debug_pub.add('p_attribute9 = ' ||p_attribute9);
        oe_debug_pub.add('p_attribute10= ' ||p_attribute10);
        oe_debug_pub.add('p_attribute11= ' ||p_attribute11);
        oe_debug_pub.add('p_attribute12= ' ||p_attribute12);
        oe_debug_pub.add('p_attribute13= ' ||p_attribute13);
        oe_debug_pub.add('p_attribute14= ' ||p_attribute14);
        oe_debug_pub.add('p_attribute15= ' ||p_attribute15);
        oe_debug_pub.add('p_attribute16= ' ||p_attribute16);
        oe_debug_pub.add('p_attribute17= ' ||p_attribute17);
        oe_debug_pub.add('p_attribute18= ' ||p_attribute18);
        oe_debug_pub.add('p_attribute19= ' ||p_attribute19);
        oe_debug_pub.add('p_attribute20= ' ||p_attribute20);
        oe_debug_pub.add('p_value = ' ||p_value);
        oe_debug_pub.add('p_segment_number = ' ||p_segment_number);
	oe_debug_pub.add('-----------------------------------------------');
     END IF;

IF NOT g_valid_structure THEN

--===============================
-- set the context value
--===============================
     IF l_debug_level > 0 THEN
	oe_debug_pub.add('About to set the context');
     END IF;
	FND_FLEX_DESCVAL.set_context_value(p_context);
     IF l_debug_level > 0 THEN
	oe_debug_pub.add('set the context success');
     END IF;


--===============================
-- set column values for the Attributes
--===============================

     IF l_debug_level > 0 THEN
	oe_debug_pub.add('About to set the column values');
     END IF;
	fnd_flex_descval.set_column_value('ATTRIBUTE1',p_attribute1);
	fnd_flex_descval.set_column_value('ATTRIBUTE2',p_attribute2);
	fnd_flex_descval.set_column_value('ATTRIBUTE3',p_attribute3);
	fnd_flex_descval.set_column_value('ATTRIBUTE4',p_attribute4);
	fnd_flex_descval.set_column_value('ATTRIBUTE5',p_attribute5);
	fnd_flex_descval.set_column_value('ATTRIBUTE6',p_attribute6);
	fnd_flex_descval.set_column_value('ATTRIBUTE7',p_attribute7);
	fnd_flex_descval.set_column_value('ATTRIBUTE8',p_attribute8);
	fnd_flex_descval.set_column_value('ATTRIBUTE9',p_attribute9);
	fnd_flex_descval.set_column_value('ATTRIBUTE10',p_attribute10);
	fnd_flex_descval.set_column_value('ATTRIBUTE11',p_attribute11);
	fnd_flex_descval.set_column_value('ATTRIBUTE12',p_attribute12);
	fnd_flex_descval.set_column_value('ATTRIBUTE13',p_attribute13);
	fnd_flex_descval.set_column_value('ATTRIBUTE14',p_attribute14);
	fnd_flex_descval.set_column_value('ATTRIBUTE15',p_attribute15);
	fnd_flex_descval.set_column_value('ATTRIBUTE16',p_attribute16);
	fnd_flex_descval.set_column_value('ATTRIBUTE17',p_attribute17);
	fnd_flex_descval.set_column_value('ATTRIBUTE18',p_attribute18);
	fnd_flex_descval.set_column_value('ATTRIBUTE19',p_attribute19);
	fnd_flex_descval.set_column_value('ATTRIBUTE20',p_attribute20);
     IF l_debug_level > 0 THEN
	oe_debug_pub.add('set the column values - success');
     END IF;

     IF l_debug_level > 0 THEN
	oe_debug_pub.add('***********************************************');
	oe_debug_pub.add('Calling FND_FLEX_DESCVAL.validate_desccols with:');
	oe_debug_pub.add('appl_short_name = ' || p_appl_short_name);
	oe_debug_pub.add('desc_flex_name  = ' || p_desc_flex_name);
	oe_debug_pub.add('values_or_ids   = ' || p_values_or_ids);
	oe_debug_pub.add('validation_date = ' || p_validation_date);
	oe_debug_pub.add('***********************************************');
     END IF;

   g_valid_structure := FND_FLEX_DESCVAL.validate_desccols(
      p_appl_short_name,
      p_desc_flex_name,
      p_values_or_ids,
      p_validation_date);

   IF g_valid_structure THEN
     IF l_debug_level > 0 THEN
        oe_debug_pub.add('structure validated successfully');
     END IF;
   ELSE
     IF l_debug_level > 0 THEN
        oe_debug_pub.add('structure validation failed');
     END IF;
     FND_MESSAGE.SET_NAME('ONT','OE_INVALID_FLEXFIELD_STRUCT');
     FND_MESSAGE.SET_TOKEN('FFSTRUCTURE',p_desc_flex_name);
     OE_MSG_PUB.Add;
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

END IF;

  IF (p_value = 'D' AND g_valid_structure) THEN

     IF l_debug_level > 0 THEN
        oe_debug_pub.add('segment number = '||p_segment_number);
     END IF;

     l_val_desc := FND_FLEX_DESCVAL.segment_description(p_segment_number);

     IF l_debug_level > 0 THEN
        oe_debug_pub.add('description = '||l_val_desc);
     END IF;

  ELSIF (p_value = 'V' AND g_valid_structure) THEN

     l_val_desc := FND_FLEX_DESCVAL.segment_value(p_segment_number);

     IF l_debug_level > 0 THEN
        oe_debug_pub.add('value = '||l_val_desc);
     END IF;

  END IF;


  IF l_debug_level > 0 THEN
     oe_debug_pub.add('returning the values');
     oe_debug_pub.add('END: '||G_PKG_NAME||':'||G_FUNCTION_NAME);
  END IF;

  Return(l_val_desc);

EXCEPTION

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    WHEN OTHERS THEN
       IF l_debug_level > 0 THEN
          oe_debug_pub.add('In the exception section');
       END IF;
       IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   G_FUNCTION_NAME
            );
       END IF;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

End get_flexdesc;

END OE_PRINT_FLEX;

/
