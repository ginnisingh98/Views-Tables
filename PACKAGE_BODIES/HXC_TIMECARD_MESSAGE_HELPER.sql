--------------------------------------------------------
--  DDL for Package Body HXC_TIMECARD_MESSAGE_HELPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_TIMECARD_MESSAGE_HELPER" AS
/* $Header: hxctcdmsg.pkb 120.2 2006/08/15 22:14:20 arundell noship $ */

c_max_messages_displayed NUMBER := 30;
c_message_level_token VARCHAR2(80) := 'FND_MESSAGE_TYPE';

g_messages  hxc_message_table_type;

g_package   varchar2(30) := 'hxc_timecard_message_helper.';

  Procedure initializeErrors is
  Begin

     g_messages := hxc_message_table_type();

  End initializeErrors;

   Procedure tryFindingMessage
      (p_message_name out nocopy varchar2
       ,p_message_app  out nocopy varchar2
       ,p_message_tokens in out nocopy varchar2
       ) is

   Begin

      hr_message.provide_error;

      p_message_name := hr_message.last_message_name;
      p_message_app  := hr_message.last_message_app;

      if(p_message_name is null) then
         -- Bug 3036930
         p_message_name := 'HXC_HXT_DEP_VAL_ORAERR';
         p_message_tokens := substr('ERROR&' || SQLERRM,1,2000);
      end if;

   End tryFindingMessage;

   Procedure addErrorToCollection
      (p_messages IN OUT NOCOPY HXC_MESSAGE_TABLE_TYPE
       ,p_message_name IN fnd_new_messages.message_name%type
       ,p_message_level IN VARCHAR2
       ,p_message_field in VARCHAR2
       ,p_message_tokens in VARCHAR2
       ,p_application_short_name in fnd_application.application_short_name%type
       ,p_time_building_block_id in hxc_time_building_blocks.time_building_block_id%type
       ,p_time_building_block_ovn in hxc_time_building_blocks.object_version_number%type
       ,p_time_attribute_id in hxc_time_attributes.time_attribute_id%type
       ,p_time_attribute_ovn in hxc_time_attributes.object_version_number%type
       ,p_message_extent in VARCHAR2 DEFAULT null       --Bug#2873563
       ) is

      l_message_index NUMBER;
      l_message_name  fnd_new_messages.message_name%type;
      l_message_app   fnd_application.application_short_name%type;
      l_message_tokens varchar2(4000);  -- Bug 3036930
      l_proc varchar2(72) := g_package||'addErrorToCollection';

   BEGIN

      if (p_messages is null) then

         --
         -- Initialize collection
         --

         p_messages := HXC_MESSAGE_TABLE_TYPE();

      end if;
      l_message_tokens := p_message_tokens; -- Bug 3036930
      if(p_message_name = hxc_timecard.c_exception) then
         tryFindingMessage(l_message_name,l_message_app,l_message_tokens); -- Bug 3036930
      else
         l_message_name := p_message_name;
         l_message_app  := p_application_short_name;
      end if;

      --
      -- Check passed values (that aren't based on types)
      -- Modified for 115.10 - added business message
      -- using constants.

      if (p_message_level NOT IN
           (hxc_timecard.c_error,
            hxc_timecard.c_warning,
            hxc_timecard.c_confirmation,
            hxc_timecard.c_information,
            hxc_timecard.c_business_message)) then

         FND_MESSAGE.SET_NAME('HXC','HXC_XXXXXX_INVALID_MSGTYPE');
         FND_MESSAGE.RAISE_ERROR;

      end if;

      if (length(p_message_field) > 80) then

         FND_MESSAGE.SET_NAME('HXC','HXC_XXXXX_FIELD_TOO_LONG');
         FND_MESSAGE.SET_TOKEN('FIELD_NAME',p_message_field);
         FND_MESSAGE.RAISE_ERROR;

      end if;

      if(length(p_message_tokens) > 4000) then

         FND_MESSAGE.SET_NAME('HXC','HXC_XXXXX_TOKENS_TOO_LONG');
         FND_MESSAGE.SET_TOKEN('TOKENS',p_message_tokens);
         FND_MESSAGE.RAISE_ERROR;

      end if;

      --
      -- Add the error to the collection
      --

      p_messages.extend;

      l_message_index := p_messages.last;

      p_messages(l_message_index) :=
         HXC_MESSAGE_TYPE
         (l_message_name
          ,p_message_level
          ,p_message_field
          ,l_message_tokens -- Bug 3036930
          ,l_message_app
          ,p_time_building_block_id
          ,p_time_building_block_ovn
          ,p_time_attribute_id
          ,p_time_attribute_ovn
          ,p_message_extent			--Bug#2873563
          );

   END addErrorToCollection;

   PROCEDURE processErrors(p_messages IN OUT nocopy hxc_self_service_time_deposit.message_table) IS

      l_message_count NUMBER;
      l_error_message VARCHAR2(4000);
      l_fnd_separator VARCHAR2(5) := FND_GLOBAL.LOCAL_CHR(0);

      l_token_table hxc_deposit_wrapper_utilities.t_simple_table;

   BEGIN
      --
      -- loop over the error msgs. return immediately if the message_table is blank
      --
      if(p_messages is null) then
         return;
      end if;

      l_message_count:=p_messages.first;

      LOOP

         EXIT WHEN NOT p_messages.exists(l_message_count);
         EXIT WHEN l_message_count > c_max_messages_displayed;

         if(p_messages(l_message_count).on_oa_msg_stack = FALSE ) then
            --AI5 message hasnt been processed yet


            --
            -- Set on 'stack'
            --
            FND_MESSAGE.SET_NAME
               (p_messages(l_message_count).application_short_name
                ,p_messages(l_message_count).message_name
                );

            IF p_messages(l_message_count).message_tokens IS NOT NULL THEN
               --
               -- parse string into a more accessible form
               --
               hxc_deposit_wrapper_utilities.string_to_table('&',
                                                             '&'||p_messages(l_message_count).message_tokens,
                                                             l_token_table);

               -- table should be full of TOKEN, VALUE pairs. The number of TOKEN, VALUE pairs is l_token_table/2

               FOR l_token in 0..(l_token_table.count/2)-1 LOOP

                  FND_MESSAGE.SET_TOKEN
                     (TOKEN => l_token_table(2*l_token)
                      ,VALUE => l_token_table(2*l_token+1)
                      );

               END LOOP;
            END IF;  -- end tokens
            --
            -- Next set a token, which indicates the "level" of this message
            -- to the middle tier.
            -- Three values are supported by the framework:
            -- "W" - for warning, shown in a dialogue box
            -- "I" - for information, also shown in a dialogue box
            -- "E" - for error, shown in an OAException
            --

            FND_MESSAGE.SET_TOKEN
               (TOKEN => c_message_level_token
                ,VALUE => nvl(substr(p_messages(l_message_count).message_level,1,1),'E')
                );

            --
            -- Add this message to the message list
            --
            fnd_msg_pub.add;

            --
            -- Indicate that this message has been added to the stack
            --
            p_messages(l_message_count).on_oa_msg_stack := TRUE;

         END IF; -- is this msg already stacked?

         l_message_count:=p_messages.next(l_message_count);

      END LOOP; -- loop over msg table

   END processErrors;

   Procedure processErrors
      (p_messages in out nocopy hxc_message_table_type) is

      l_index number;
      l_msg_index number;

      l_proc varchar2(45) := g_package||'processErrors';

   Begin

      if(p_messages is not null) then

         if(g_messages is null) then

            g_messages := hxc_message_table_type();

         end if;

         l_index := p_messages.first;

         Loop
            Exit When Not p_messages.exists(l_index);

            g_messages.extend;

            if((p_messages(l_index).message_name is null)
               or
                  (p_messages(l_index).message_name = '')) then
               g_messages(g_messages.last) :=
                  hxc_message_type
                  ('HXC_366510_EMPTY_MESSAGE',
                   hxc_timecard.c_error,
                   null,
                   'APPLICATION_SHORT_NAME&'||p_messages(l_index).application_short_name,
                   'HXC',
                   null,
                   null,
                   null,
                   null,
                   hxc_timecard.c_blk_children_extent
                   );
            else
               g_messages(g_messages.last) :=
                  hxc_message_type
                  (p_messages(l_index).message_name,
                   p_messages(l_index).MESSAGE_LEVEL,
                   p_messages(l_index).MESSAGE_FIELD,
                   p_messages(l_index).MESSAGE_TOKENS,
                   p_messages(l_index).APPLICATION_SHORT_NAME,
                   p_messages(l_index).TIME_BUILDING_BLOCK_ID,
                   p_messages(l_index).TIME_BUILDING_BLOCK_OVN,
                   p_messages(l_index).TIME_ATTRIBUTE_ID,
                   p_messages(l_index).TIME_ATTRIBUTE_OVN,
                   p_messages(l_index).message_extent
                   );
            end if;

            l_index := p_messages.next(l_index);
         End Loop;

         p_messages.delete;

      end if;

   End processErrors;

   Function noErrors return BOOLEAN is

      l_index number;
      l_found BOOLEAN := false;

   Begin

      if(g_messages is null) then
         return true;
      else
         If(g_messages.count>0) then
            l_index := g_messages.first;
            Loop
               Exit when ((not g_messages.exists(l_index)) or (l_found));
               if(g_messages(l_index).message_level = hxc_timecard.c_error) then
                  l_found := true;
               end if;
               l_index := g_messages.next(l_index);
            End Loop;
            if(l_found) then
               return false;
            else
               return true;
            end if;
         else
            return true;
         end if;
      end if;

   End noErrors;

   Procedure prepareErrors Is

      l_index number;

      l_token_table hxc_deposit_wrapper_utilities.t_simple_table;

      l_token number;
      l_proc  varchar2(70) := g_package||'prepareErrors';

   Begin

      if(NOT noerrors) then

         fnd_msg_pub.initialize;

         l_index  := g_messages.first;

         Loop
            exit when not g_messages.exists(l_index);

            --
            -- For the moment, just set on the stack
            --

            if((g_messages(l_index).message_name is not null)
               AND
                  (g_messages(l_index).application_short_name is not null)
               AND
                  ((g_messages(l_index).message_level <> hxc_timecard.c_pte)
                   AND
                      (g_messages(l_index).message_level <> hxc_timecard.c_reason_attribute)
                   )
               ) then

               fnd_message.set_name
                  (g_messages(l_index).application_short_name
                   ,g_messages(l_index).message_name
                   );
               IF g_messages(l_index).message_tokens IS NOT NULL THEN
                  --
                  -- parse string into a more accessible form
                  --
                  hxc_deposit_wrapper_utilities.string_to_table('&',
                                                                '&'||g_messages(l_index).message_tokens,
                                                                l_token_table);

                  -- table should be full of TOKEN, VALUE pairs. The number of TOKEN, VALUE pairs is l_token_table/2

                  for l_token in 0..(l_token_table.count/2)-1 LOOP

                     fnd_message.set_token
                        (token => l_token_table(2*l_token)
                         ,value => l_token_table(2*l_token+1)
                         );

                  end loop;
               end if;  -- end tokens

               fnd_msg_pub.add;

               fnd_message.clear;

            end if;

            l_index := g_messages.next(l_index);

         End Loop;

      end if;

   End prepareErrors;

   Function prepareMessages return hxc_message_table_type is

      l_messages  hxc_message_table_type := hxc_message_table_type();
      l_index     number;
      l_proc      varchar2(70) := 'hxc_timecard_message_helper.prepareMessages';


   Begin
      --
      -- Copy the complete set of messages to the return variable
      -- ready to be passed back to the middle tier
      --
      l_index := g_messages.first;
      Loop
         Exit when not g_messages.exists(l_index);

         if(instr(g_messages(l_index).message_level,'PTE')=0) then

            l_messages.extend();

            l_messages(l_messages.last) :=
               hxc_message_type
               (g_messages(l_index).MESSAGE_NAME
                ,g_messages(l_index).MESSAGE_LEVEL
                ,g_messages(l_index).MESSAGE_FIELD
                ,g_messages(l_index).MESSAGE_TOKENS
                ,g_messages(l_index).APPLICATION_SHORT_NAME
                ,g_messages(l_index).TIME_BUILDING_BLOCK_ID
                ,g_messages(l_index).TIME_BUILDING_BLOCK_OVN
                ,g_messages(l_index).TIME_ATTRIBUTE_ID
                ,g_messages(l_index).TIME_ATTRIBUTE_OVN
                ,g_messages(l_index).message_extent	--Bug#2873563
                );

         end if;

         l_index := g_messages.next(l_index);
      End Loop;

      return l_messages;

   End prepareMessages;

   Function getMessages return hxc_message_table_type is

   Begin

      if(g_messages is null) then

         g_messages := hxc_message_table_type();

      end if;

      return g_messages;

   End getMessages;

END hxc_timecard_message_helper;

/
