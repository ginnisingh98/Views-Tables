--------------------------------------------------------
--  DDL for Package Body ARP_DESCR_FLEX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_DESCR_FLEX" as
/* $Header: ARPLDFSB.pls 115.3 2002/11/15 02:40:33 anukumar ship $             */


/*---------------------------------------------------------------------------*
 |                                                                           |
 | PUBLIC PROCEDURE: get_concatenated_segments                               |
 |                                                                           |
 |   This procedure returns the concatenated segments and context values     |
 |   of the descriptive flexfields in the ra_customer_trx and                |
 |   ra_customer_trx_lines tables.                                           |
 |   For now, this function hardcodes all column and flexfield information.  |
 |   When PL/SQL supports dynamic SQL, this function could be rewritten to   |
 |   be more generic.                                                        |
 |                                                                           |
 | EXAMPLES                                                                  |
 |                                                                           |
 |                                                                           |
 *---------------------------------------------------------------------------*/

procedure get_concatenated_segments( p_flex_name                 in varchar2,
                                     p_table_name                in varchar2,
                                     p_customer_trx_id           in number,
                                     p_customer_trx_line_id      in number,
                                     p_concatenated_segments in out NOCOPY varchar2,
                                     p_context              in out NOCOPY varchar2) IS


first boolean;

cursor ra_customer_trx_lines_C(   p_flex_name in varchar2,
                                  p_customer_trx_line_id in number) IS
select decode(u.descriptive_flexfield_name,
              'RA_INTERFACE_LINES',
                decode(u.application_column_name,
                 'INTERFACE_LINE_ATTRIBUTE1',  l.interface_line_attribute1,
                 'INTERFACE_LINE_ATTRIBUTE2',  l.interface_line_attribute2,
                 'INTERFACE_LINE_ATTRIBUTE3',  l.interface_line_attribute3,
                 'INTERFACE_LINE_ATTRIBUTE4',  l.interface_line_attribute4,
                 'INTERFACE_LINE_ATTRIBUTE5',  l.interface_line_attribute5,
                 'INTERFACE_LINE_ATTRIBUTE6',  l.interface_line_attribute6,
                 'INTERFACE_LINE_ATTRIBUTE7',  l.interface_line_attribute7,
                 'INTERFACE_LINE_ATTRIBUTE8',  l.interface_line_attribute8,
                 'INTERFACE_LINE_ATTRIBUTE9',  l.interface_line_attribute9,
                 'INTERFACE_LINE_ATTRIBUTE10', l.interface_line_attribute10,
                 'INTERFACE_LINE_ATTRIBUTE11', l.interface_line_attribute11,
                 'INTERFACE_LINE_ATTRIBUTE12', l.interface_line_attribute12,
                 'INTERFACE_LINE_ATTRIBUTE13', l.interface_line_attribute13,
                 'INTERFACE_LINE_ATTRIBUTE14', l.interface_line_attribute14,
                 'INTERFACE_LINE_ATTRIBUTE15', l.interface_line_attribute15),
             'RA_CUSTOMER_TRX_LINES_GOV',  l.default_ussgl_transaction_code,
             'RA_CUSTOMER_TRX_LINES', decode(u.application_column_name,
                                             'ATTRIBUTE1',  l.attribute1,
                                             'ATTRIBUTE2',  l.attribute2,
                                             'ATTRIBUTE3',  l.attribute3,
                                             'ATTRIBUTE4',  l.attribute4,
                                             'ATTRIBUTE5',  l.attribute5,
                                             'ATTRIBUTE6',  l.attribute6,
                                             'ATTRIBUTE7',  l.attribute7,
                                             'ATTRIBUTE8',  l.attribute8,
                                             'ATTRIBUTE9',  l.attribute9,
                                             'ATTRIBUTE10', l.attribute10,
                                             'ATTRIBUTE11', l.attribute11,
                                             'ATTRIBUTE12', l.attribute12,
                                             'ATTRIBUTE13', l.attribute13,
                                             'ATTRIBUTE14', l.attribute14,
                                             'ATTRIBUTE15', l.attribute15)
              ) segment_value,
        decode(u.descriptive_flexfield_name,
               'RA_INTERFACE_LINES',        l.interface_line_context,
               'RA_CUSTOMER_TRX_LINES_GOV', l.default_ussgl_trx_code_context,
               'RA_CUSTOMER_TRX_LINES',     l.attribute_category,
                                            '') context,
        f.concatenated_segment_delimiter delimiter
from  fnd_descr_flex_column_usages u,
      fnd_descriptive_flexs f,
      ra_customer_trx_lines l
where u.descriptive_flexfield_name    = p_flex_name
and   u.application_id                = 222
and   u.enabled_flag                  = 'Y'
and   u.descriptive_flexfield_name    = f.descriptive_flexfield_name
and   u.application_id                = f.application_id
and   nvl(
          decode(u.descriptive_flexfield_name,
                 'RA_INTERFACE_LINES',        l.interface_line_context,
                 'RA_CUSTOMER_TRX_LINES_GOV', l.default_ussgl_trx_code_context,
                 'RA_CUSTOMER_TRX_LINES',     l.attribute_category,
                                              ''),
          'Global Data Elements'
         )            =  descriptive_flex_context_code
and   customer_trx_line_id = p_customer_trx_line_id
order by column_seq_num;

cursor ra_customer_trx_C(   p_flex_name in varchar2,
                            p_customer_trx_id in number) IS
select decode(u.descriptive_flexfield_name,
              'RA_INTERFACE_HEADER',
                decode(u.application_column_name,
                 'INTERFACE_HEADER_ATTRIBUTE1',  t.interface_header_attribute1,
                 'INTERFACE_HEADER_ATTRIBUTE2',  t.interface_header_attribute2,
                 'INTERFACE_HEADER_ATTRIBUTE3',  t.interface_header_attribute3,
                 'INTERFACE_HEADER_ATTRIBUTE4',  t.interface_header_attribute4,
                 'INTERFACE_HEADER_ATTRIBUTE5',  t.interface_header_attribute5,
                 'INTERFACE_HEADER_ATTRIBUTE6',  t.interface_header_attribute6,
                 'INTERFACE_HEADER_ATTRIBUTE7',  t.interface_header_attribute7,
                 'INTERFACE_HEADER_ATTRIBUTE8',  t.interface_header_attribute8,
                 'INTERFACE_HEADER_ATTRIBUTE9',  t.interface_header_attribute9,
               'INTERFACE_HEADER_ATTRIBUTE10', t.interface_header_attribute10,
               'INTERFACE_HEADER_ATTRIBUTE11', t.interface_header_attribute11,
               'INTERFACE_HEADER_ATTRIBUTE12', t.interface_header_attribute12,
               'INTERFACE_HEADER_ATTRIBUTE13', t.interface_header_attribute13,
               'INTERFACE_HEADER_ATTRIBUTE14', t.interface_header_attribute14,
               'INTERFACE_HEADER_ATTRIBUTE15', t.interface_header_attribute15),
             'RA_CUSTOMER_TRX_GOV',  t.default_ussgl_transaction_code,
             'RA_CUSTOMER_TRX', decode(u.application_column_name,
                                             'ATTRIBUTE1',  t.attribute1,
                                             'ATTRIBUTE2',  t.attribute2,
                                             'ATTRIBUTE3',  t.attribute3,
                                             'ATTRIBUTE4',  t.attribute4,
                                             'ATTRIBUTE5',  t.attribute5,
                                             'ATTRIBUTE6',  t.attribute6,
                                             'ATTRIBUTE7',  t.attribute7,
                                             'ATTRIBUTE8',  t.attribute8,
                                             'ATTRIBUTE9',  t.attribute9,
                                             'ATTRIBUTE10', t.attribute10,
                                             'ATTRIBUTE11', t.attribute11,
                                             'ATTRIBUTE12', t.attribute12,
                                             'ATTRIBUTE13', t.attribute13,
                                             'ATTRIBUTE14', t.attribute14,
                                             'ATTRIBUTE15', t.attribute15)
              ) segment_value,
        decode(u.descriptive_flexfield_name,
               'RA_INTERFACE_HEADER',    t.interface_header_context,
               'RA_CUSTOMER_TRX_GOV',    t.default_ussgl_trx_code_context,
               'RA_CUSTOMER_TRX',        t.attribute_category,
                                         '') context,
        f.concatenated_segment_delimiter delimiter
from  fnd_descr_flex_column_usages u,
      fnd_descriptive_flexs f,
      ra_customer_trx t
where u.descriptive_flexfield_name    = p_flex_name
and   u.application_id                = 222
and   u.enabled_flag                  = 'Y'
and   u.descriptive_flexfield_name    = f.descriptive_flexfield_name
and   u.application_id                = f.application_id
and   nvl(
          decode(u.descriptive_flexfield_name,
                 'RA_INTERFACE_HEADER',  t.interface_header_context,
                 'RA_CUSTOMER_TRX_GOV',  t.default_ussgl_trx_code_context,
                 'RA_CUSTOMER_TRX',      t.attribute_category,
                                         ''),
          'Global Data Elements'
         )            =  descriptive_flex_context_code
and   customer_trx_id = p_customer_trx_id
order by column_seq_num;

begin

    first := true;
    p_concatenated_segments := '';
    p_context := '';

    /*----------------------------------------------------------------+
     |  Select each segment of the flexfield in order and concatenate |
     |  it onto the previous segments.                                |
     +----------------------------------------------------------------*/

    if (p_table_name  = 'RA_CUSTOMER_TRX_LINES')
    then
         FOR segments in ra_customer_trx_lines_C(p_flex_name,
                                                 p_customer_trx_line_id )
         LOOP
           if (first <> true)
           then p_concatenated_segments := p_concatenated_segments ||
                                           segments.delimiter;
           else first := false;
           end if;

           p_concatenated_segments := p_concatenated_segments ||
                                    segments.segment_value;

           p_context := segments.context;

         END LOOP;
     end if;

    if (p_table_name  = 'RA_CUSTOMER_TRX')
    then
         FOR segments in ra_customer_trx_C(p_flex_name,
                                           p_customer_trx_id )
         LOOP
           if (first <> true)
           then p_concatenated_segments := p_concatenated_segments ||
                                           segments.delimiter;
           else first := false;
           end if;

           p_concatenated_segments := p_concatenated_segments ||
                                    segments.segment_value;

           p_context := segments.context;

         END LOOP;
     end if;

end;



end ARP_DESCR_FLEX;

/
