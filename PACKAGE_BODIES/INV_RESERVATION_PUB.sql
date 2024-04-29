--------------------------------------------------------
--  DDL for Package Body INV_RESERVATION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_RESERVATION_PUB" AS
/* $Header: INVRSVPB.pls 120.4.12010000.2 2008/12/17 07:00:51 skommine ship $ */

g_pkg_name CONSTANT VARCHAR2(30) := 'INV_Reservation_PUB';
g_version_printed        BOOLEAN      := FALSE;


PROCEDURE mydebug (p_message IN VARCHAR2,p_module_name IN VARCHAR2,p_level IN NUMBER)
   IS
BEGIN
      IF g_version_printed THEN
        inv_log_util.TRACE ('$Header: INVRSVPB.pls 120.4.12010000.2 2008/12/17 07:00:51 skommine ship $',g_pkg_name||'.'||p_module_name, p_level);
      END IF;
      inv_log_util.TRACE (p_message,g_pkg_name||'.'||p_module_name, p_level);

END mydebug;


-- INVCONV
-- Change this version of create_reservation to invoke the new overloaded version
-- introduced for inventory convergence
-- ==============================================================================
PROCEDURE create_reservation
  (
     p_api_version_number        IN  NUMBER
   , p_init_msg_lst              IN  VARCHAR2 DEFAULT fnd_api.g_false
   , x_return_status             OUT NOCOPY VARCHAR2
   , x_msg_count                 OUT NOCOPY NUMBER
   , x_msg_data                  OUT NOCOPY VARCHAR2
   , p_rsv_rec                   IN  inv_reservation_global.mtl_reservation_rec_type
   , p_serial_number             IN  inv_reservation_global.serial_number_tbl_type
   , x_serial_number             OUT NOCOPY inv_reservation_global.serial_number_tbl_type
   , p_partial_reservation_flag  IN  VARCHAR2 DEFAULT fnd_api.g_false
   , p_force_reservation_flag    IN  VARCHAR2 DEFAULT fnd_api.g_false
   , p_validation_flag           IN  VARCHAR2 DEFAULT fnd_api.g_true
   , p_over_reservation_flag     IN  NUMBER DEFAULT 0
   , x_quantity_reserved         OUT NOCOPY NUMBER
   , x_reservation_id            OUT NOCOPY NUMBER
   , p_partial_rsv_exists        IN  BOOLEAN DEFAULT FALSE
   , p_substitute_flag           IN  BOOLEAN DEFAULT FALSE /* Bug 6044651 */

   ) IS

     l_api_version_number 	        CONSTANT NUMBER       := 1.0;
     l_api_name           	        CONSTANT VARCHAR2(30) := 'Create_Reservation';
     l_return_status      	        VARCHAR2(1) := fnd_api.g_ret_sts_success;
     l_debug                       NUMBER      := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);

     l_rsv_rec                    inv_reservation_global.mtl_reservation_rec_type;
     l_progress                    NUMBER;
     l_secondary_quantity_reserved NUMBER;

BEGIN
   --  Standard call to check for call compatibility
   IF NOT fnd_api.compatible_api_call(l_api_version_number
                                      , p_api_version_number
                                      , l_api_name
                                      , G_PKG_NAME
                                      ) THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   --  Initialize message list.
   IF fnd_api.to_boolean(p_init_msg_lst) THEN
      fnd_msg_pub.initialize;
   END IF;

   -- INVCONV  BEGIN 4066306
   l_rsv_rec := p_rsv_rec;
   -- Initialize process attributes
   -- Bug 7587155 - Assign NULL only if the initialization uses G_MISS_XXX.
   --
   IF (l_rsv_rec.secondary_uom_code = FND_API.G_MISS_CHAR) THEN
      l_rsv_rec.secondary_uom_code := NULL;
   END IF;

   IF (l_rsv_rec.secondary_uom_id = FND_API.G_MISS_NUM) THEN
      l_rsv_rec.secondary_uom_id := NULL;
   END IF;

   IF (l_rsv_rec.secondary_reservation_quantity = FND_API.G_MISS_NUM) THEN
      l_rsv_rec.secondary_reservation_quantity := NULL;
   END IF;

   IF (l_rsv_rec.secondary_detailed_quantity = FND_API.G_MISS_NUM) THEN
      l_rsv_rec.secondary_detailed_quantity := NULL;
   END IF;
   -- INVCONV  END  7587155 and 4066306

   l_progress := 10;
   IF l_debug=1 THEN
     mydebug('Calling the overloaded procedure create_reservation',l_api_name,9);
   END IF;

   -- BUG 4360466 - ensure p_partial_rsv_exists is passed
   inv_reservation_pub.create_reservation
       (
          p_api_version_number        => 1.0
        , p_init_msg_lst              => p_init_msg_lst
        , x_return_status             => l_return_status
        , x_msg_count                 => x_msg_count
        , x_msg_data                  => x_msg_data
        , p_rsv_rec		      => l_rsv_rec
        , p_serial_number	      => p_serial_number
        , x_serial_number	      => x_serial_number
        , p_partial_reservation_flag  => p_partial_reservation_flag
        , p_force_reservation_flag    => p_force_reservation_flag
        , p_validation_flag           => p_validation_flag
	, p_over_reservation_flag     => p_over_reservation_flag
        , x_quantity_reserved         => x_quantity_reserved
        , x_secondary_quantity_reserved => l_secondary_quantity_reserved
        , x_reservation_id            => x_reservation_id
	, p_partial_rsv_exists        => p_partial_rsv_exists
	, p_substitute_flag           => p_substitute_flag    /* Bug 6044651 */
        );

      IF (l_debug=1) THEN
          mydebug ('Return Status after creating reservations '||l_return_status,l_api_name,1);
      END IF;


      IF l_return_status = fnd_api.g_ret_sts_error THEN
        IF l_debug=1 THEN
             mydebug('Raising expected error'||l_return_status,l_api_name,9);
        END IF;
        RAISE fnd_api.g_exc_error;

      END IF ;

      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
        IF l_debug=1 THEN
                 mydebug('Raising unexpected error'||l_return_status,l_api_name,9);
        END IF;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      x_return_status := l_return_status;

      IF (l_debug=1) THEN
	 mydebug ('Return Status '||x_return_status,l_api_name,9);
	 mydebug ('Reservation Quantity '||x_quantity_reserved,l_api_name,9);
	 mydebug ('Secondary Reservation Quantity '||l_secondary_quantity_reserved,l_api_name,9);
	 mydebug('Reservation Id '||x_reservation_id,l_api_name,9);
      END IF;


EXCEPTION

    WHEN fnd_api.g_exc_error THEN
        x_return_status := fnd_api.g_ret_sts_error;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count => x_msg_count
           , p_data  => x_msg_data
           );
        IF l_debug=1 THEN
            mydebug('Error Obtained at'||l_progress,l_api_name,9);
        END IF;

   WHEN fnd_api.g_exc_unexpected_error THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );

        IF l_debug=1 THEN
            mydebug('Error Obtained at'||l_progress,l_api_name,9);
        END IF;


    WHEN OTHERS THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
          THEN
           fnd_msg_pub.add_exc_msg
             (  g_pkg_name
              , l_api_name
              );
        END IF;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
             );

        IF l_debug=1 THEN
            mydebug('Error Obtained at'||l_progress,l_api_name,9);
        END IF;


END create_reservation;


-- INVCONV BEGIN
-- OVERLOADED Version of create_reservation introduced for inventory convergence
-- Incorporate secondary_quantity_reserved
-- Strip out PROCESS_BRANCH logic
-- =======================================
PROCEDURE create_reservation
  (
     p_api_version_number        IN  NUMBER
   , p_init_msg_lst              IN  VARCHAR2 DEFAULT fnd_api.g_false
   , x_return_status             OUT NOCOPY VARCHAR2
   , x_msg_count                 OUT NOCOPY NUMBER
   , x_msg_data                  OUT NOCOPY VARCHAR2
   , p_rsv_rec                   IN  inv_reservation_global.mtl_reservation_rec_type
   , p_serial_number             IN  inv_reservation_global.serial_number_tbl_type
   , x_serial_number             OUT NOCOPY inv_reservation_global.serial_number_tbl_type
   , p_partial_reservation_flag  IN  VARCHAR2 DEFAULT fnd_api.g_false
   , p_force_reservation_flag    IN  VARCHAR2 DEFAULT fnd_api.g_false
   , p_validation_flag           IN  VARCHAR2 DEFAULT fnd_api.g_true
   , p_over_reservation_flag     IN  NUMBER DEFAULT 0
   , x_quantity_reserved         OUT NOCOPY NUMBER
   , x_secondary_quantity_reserved OUT NOCOPY NUMBER
   , x_reservation_id            OUT NOCOPY NUMBER
   , p_partial_rsv_exists        IN  BOOLEAN DEFAULT FALSE
   , p_substitute_flag           IN  BOOLEAN DEFAULT FALSE /* Bug 6044651 */


   ) IS

     l_api_version_number 	        CONSTANT NUMBER       := 1.0;
     l_api_name           	        CONSTANT VARCHAR2(30) := 'Create_Reservation';
     l_return_status      	        VARCHAR2(1) := fnd_api.g_ret_sts_success;
     l_debug                       NUMBER      := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);

     /**** {{ R12 Enhanced reservations code changes }}****/
     --   l_mtl_reservation_tbl         inv_reservation_global.mtl_reservation_tbl_type;
     --    l_from_rsv_rec inv_reservation_global.mtl_reservation_rec_type := p_rsv_rec;
     --    l_to_rsv_rec                  inv_reservation_global.mtl_reservation_rec_type;
     --   l_mtl_reservation_tbl_count   NUMBER;
     l_error_code                  NUMBER;
     --  l_rsv_updated                 BOOLEAN :=FALSE;
     -- l_primary_uom_code            VARCHAR2(3);
     l_progress                    NUMBER;
     -- l_quantity_reserved           NUMBER;
     -- l_secondary_quantity_reserved NUMBER;                  -- INVCONV
     /*** End R12 ***/

BEGIN
   --  Standard call to check for call compatibility
   IF NOT fnd_api.compatible_api_call(l_api_version_number
                                      , p_api_version_number
                                      , l_api_name
                                      , G_PKG_NAME
                                      ) THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   --  Initialize message list.
   IF fnd_api.to_boolean(p_init_msg_lst) THEN
      fnd_msg_pub.initialize;
   END IF;

   l_progress := 10;
   l_progress := 40;

   /**** {{ R12 Enhanced reservations code changes }}****/
   /****
   --Do not need this code as this is being moved to the private API
   -- Commneting out the code

   IF p_partial_rsv_exists THEN
      --Since create reservation is called by OM even when they updated the existing reservation
      --we need to query existing reservations and see if the existing reservation can be updated.
      IF l_debug=1 THEN

        mydebug('Partial reservation flag passed as true,need to check existing reservations',l_api_name,1);
        mydebug('The value of partial reservations flag is ='||p_partial_reservation_flag,l_api_name,1);

      END IF;

       l_progress :=50;

       inv_reservation_pvt.convert_quantity
                                         (x_return_status      => l_return_status,
                                          px_rsv_rec           => l_from_rsv_rec
                                         );

       IF l_debug=1 THEN
          mydebug('REturn Status from convert quantity'||l_return_status,l_api_name,9);
       END IF;

       IF l_return_status = fnd_api.g_ret_sts_error THEN

           IF l_debug=1 THEN
             mydebug('Raising expected error'||l_return_status,l_api_name,9);
           END IF;
           RAISE fnd_api.g_exc_error;

       ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN

            IF l_debug=1 THEN
              mydebug('Rasing Unexpected error'||l_return_status,l_api_name,9);
            END IF;
            RAISE fnd_api.g_exc_unexpected_error;

       END IF;

       l_progress :=60;

       IF l_debug=1 THEN
          mydebug('Calling query reservation to query existing reservations'||l_return_status,l_api_name,9);
       END IF;

       l_progress := 70;

       inv_reservation_pvt.query_reservation
                  (p_api_version_number             => 1.0,
                   p_init_msg_lst                   => fnd_api.g_false,
                   x_return_status                  => l_return_status,
                   x_msg_count                      => x_msg_count,
                   x_msg_data                       => x_msg_data,
                   p_query_input                    => l_from_rsv_rec,
                   p_lock_records                   => fnd_api.g_true,
                   x_mtl_reservation_tbl            => l_mtl_reservation_tbl,
                   x_mtl_reservation_tbl_count      => l_mtl_reservation_tbl_count,
                   x_error_code                     => l_error_code
                  );


         IF l_debug=1 THEN
           mydebug ('Return Status after querying reservations '||l_return_status,l_api_name,1);
         END IF;

         l_progress := 80;

         IF l_return_status = fnd_api.g_ret_sts_error THEN

           IF l_debug=1 THEN
             mydebug('Raising expected error'||l_return_status,l_api_name,9);
           END IF;
           RAISE fnd_api.g_exc_error;

         ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN

            IF l_debug=1 THEN
              mydebug('Rasing Unexpected error'||l_return_status,l_api_name,9);
            END IF;
            RAISE fnd_api.g_exc_unexpected_error;

         END IF;

         IF (l_debug=1) THEN

           mydebug ('x_mtl_reservation_tbl_count='|| l_mtl_reservation_tbl_count,l_api_name,4);

         END IF;

         IF l_debug=1 THEN

          inv_reservation_pvt.print_rsv_rec (p_rsv_rec);
         END IF;

         l_progress := 90;

         FOR i IN 1..l_mtl_reservation_tbl_count LOOP
             inv_reservation_pvt.print_rsv_rec (l_mtl_reservation_tbl(i));

             --If the queried reservation record is staged or has a lot number stamped or is
             -- revision controlled or has an LPN Id stamped or has a different SubInventory
             l_progress := 100;

             IF ((l_mtl_reservation_tbl(i).staged_flag='Y')
                OR (nvl(l_mtl_reservation_tbl(i).lot_number,'@@@')<>nvl(p_rsv_rec.lot_number,'@@@') AND p_rsv_rec.lot_number<>fnd_api.g_miss_char)
                OR (nvl(l_mtl_reservation_tbl(i).revision,'@@@')<>nvl(p_rsv_rec.revision,'@@@')AND p_rsv_rec.revision <>fnd_api.g_miss_char)
                OR (nvl(l_mtl_reservation_tbl(i).lpn_id,-1)<>nvl(p_rsv_rec.lpn_id,-1)AND p_rsv_rec.lpn_id <> fnd_api.g_miss_num)
                OR (nvl(l_mtl_reservation_tbl(i).subinventory_code,'@@@')<>nvl(p_rsv_rec.subinventory_code,'@@@')AND p_rsv_rec.subinventory_code <>fnd_api.g_miss_char)) THEN

                  IF (l_debug=1) THEN
                    mydebug('Skipping reservation record',l_api_name,9);
                  END IF;

                   l_progress := 110;

                   GOTO next_record;
             ELSE

               IF (l_debug=1) THEN

                mydebug('Need to update reservation record',l_api_name,9);
               END IF;

               IF l_debug=1 THEN

                mydebug('Reservation record that needs to be updated',l_api_name,9);
                inv_reservation_pvt.print_rsv_rec (l_mtl_reservation_tbl(i));

               END IF;

               l_progress := 120;

               l_to_rsv_rec.primary_reservation_quantity := l_from_rsv_rec.primary_reservation_quantity
                                                          + l_mtl_reservation_tbl(i).primary_reservation_quantity;
               -- INVCONV BEGIN
               -- Look at the reservation table row to determine if this is a dual control item.
               -- If it is dual control and a secondary_reservation_quantity has been supplied,
               -- then  calculate the to_resv_rec.secondary_reservation_quantity.
               -- Otherwise leave it empty to be computed as necessary by the private level API
               IF l_mtl_reservation_tbl(i).secondary_reservation_quantity is not NULL and
                 l_to_rsv_rec.secondary_reservation_quantity is not NULL THEN
                   l_to_rsv_rec.secondary_reservation_quantity := l_from_rsv_rec.secondary_reservation_quantity
                                                          + l_mtl_reservation_tbl(i).secondary_reservation_quantity;

               END IF;
               -- INVCONV END
               l_progress := 130;

               IF l_from_rsv_rec.reservation_uom_code = l_mtl_reservation_tbl(i).reservation_uom_code THEN

                  l_to_rsv_rec.reservation_quantity := l_from_rsv_rec.reservation_quantity + l_mtl_reservation_tbl(i).reservation_quantity;

               ELSE

                l_to_rsv_rec.reservation_quantity := NULL;

               END IF;

               l_progress := 140;

               IF (l_debug=1) THEN

                  mydebug('Calling update reservations to update reservation record',l_api_name,9);

               END IF;

     inv_reservation_pub.update_reservation
     (p_api_version_number          => 1.0,
     p_init_msg_lst                => fnd_api.g_false,
     x_return_status               => l_return_status,
     x_msg_count                   => x_msg_count,
     x_msg_data                    => x_msg_data,
     x_quantity_reserved           => l_quantity_reserved,
     x_secondary_quantity_reserved => l_secondary_quantity_reserved,  -- INVCONV
     p_original_rsv_rec            => l_mtl_reservation_tbl(i),
     p_to_rsv_rec                  => l_to_rsv_rec,
     p_original_serial_number      => p_serial_number,
     p_to_serial_number            => p_serial_number,
     p_validation_flag             => fnd_api.g_true,
     p_partial_reservation_flag    => p_partial_reservation_flag,
     p_check_availability          => fnd_api.g_true
     );

               l_progress := 150;

              IF (l_debug=1) THEN
                mydebug ('Return Status after updating reservations '||l_return_status,l_api_name,1);
              END IF;

             IF l_return_status = fnd_api.g_ret_sts_error THEN

              IF l_debug=1 THEN
                 mydebug('Raising expected error'||l_return_status,l_api_name,9);
              END IF;

              RAISE fnd_api.g_exc_error;

             ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN

              IF l_debug=1 THEN
                mydebug('Raising Unexpected error'||l_return_status,l_api_name,9);
              END IF;

              RAISE fnd_api.g_exc_unexpected_error;
             END IF;

            l_progress := 160;

            l_quantity_reserved:=l_quantity_reserved - l_mtl_reservation_tbl(i).primary_reservation_quantity;

            x_quantity_reserved := l_quantity_reserved;
            x_reservation_id    := l_mtl_reservation_tbl(i).reservation_id;

            l_rsv_updated := TRUE;
            x_return_status := l_return_status;
            EXIT;

          END IF;

          <<next_record>>
             NULL;
         END LOOP;

   END IF;

   -- End. Do not need this as we are moving this to the private package.

   IF NOT l_rsv_updated  THEN

     --End. Commenting the code as this is moved to the private package
     ********************/
     /*** End R12 ***/

      l_progress := 180;
      IF l_debug=1 THEN
         mydebug('Calling create Reservations to create reservations',l_api_name,9);
      END IF;

      -- BUG 5244157 - Ensure parameters passed accurately from public to private layer
      inv_reservation_pvt.create_reservation
       (
          p_api_version_number        => 1.0
        , p_init_msg_lst              => fnd_api.g_false
        , x_return_status             => l_return_status
        , x_msg_count                 => x_msg_count
        , x_msg_data                  => x_msg_data
        , p_rsv_rec		      => p_rsv_rec
        , p_serial_number	      => p_serial_number
        , x_serial_number	      => x_serial_number
        , p_partial_reservation_flag  => p_partial_reservation_flag
        , p_force_reservation_flag    => p_force_reservation_flag                       -- 5244157
        , p_validation_flag           => fnd_api.g_true
	, p_over_reservation_flag     => p_over_reservation_flag
        , x_quantity_reserved         => x_quantity_reserved
        , x_secondary_quantity_reserved => x_secondary_quantity_reserved  		-- INVCONV
        , x_reservation_id            => x_reservation_id
	, p_substitute_flag           => p_substitute_flag                              /* Bug 6044651 */
        );

      IF (l_debug=1) THEN
          mydebug ('Return Status after creating reservations '||l_return_status,l_api_name,1);
      END IF;


     IF l_return_status = fnd_api.g_ret_sts_error THEN
        IF l_debug=1 THEN
             mydebug('Raising expected error'||l_return_status,l_api_name,9);
        END IF;
        RAISE fnd_api.g_exc_error;

     END IF ;

     IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN

        IF l_debug=1 THEN
                 mydebug('Raising unexpected error'||l_return_status,l_api_name,9);
        END IF;
        RAISE fnd_api.g_exc_unexpected_error;
     END IF;

     x_return_status := l_return_status;

     /**** {{ R12 Enhanced reservations code changes }}****/
     --END IF; -- Commented out for R12
     /*** End R12 ***/

   IF (l_debug=1) THEN
    mydebug ('Return Status '||x_return_status,l_api_name,9);
    mydebug ('Reservation Quantity '||x_quantity_reserved,l_api_name,9);
    mydebug ('secondary Reservation Quantity '||x_secondary_quantity_reserved,l_api_name,9);
    mydebug('Reservation Id '||x_reservation_id,l_api_name,9);
   END IF;


EXCEPTION

    WHEN fnd_api.g_exc_error THEN
        x_return_status := fnd_api.g_ret_sts_error;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count => x_msg_count
           , p_data  => x_msg_data
           );
        IF l_debug=1 THEN
            mydebug('Error Obtained at'||l_progress,l_api_name,9);
        END IF;

   WHEN fnd_api.g_exc_unexpected_error THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );

        IF l_debug=1 THEN
            mydebug('Error Obtained at'||l_progress,l_api_name,9);
        END IF;


    WHEN OTHERS THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
          THEN
           fnd_msg_pub.add_exc_msg
             (  g_pkg_name
              , l_api_name
              );
        END IF;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
             );

        IF l_debug=1 THEN
            mydebug('Error Obtained at'||l_progress,l_api_name,9);
        END IF;


END create_reservation;
-- INVCONV END
-- ============

-- INVCONV BEGIN
-- Add parameter x_secondary_quantity_reserved
-- Strip out process inventory forking logic
PROCEDURE update_reservation
  (
     p_api_version_number            IN  NUMBER
   , p_init_msg_lst                  IN  VARCHAR2 DEFAULT fnd_api.g_false
   , x_return_status                 OUT NOCOPY VARCHAR2
   , x_msg_count                     OUT NOCOPY NUMBER
   , x_msg_data                      OUT NOCOPY VARCHAR2
   , x_quantity_reserved             OUT NOCOPY NUMBER
   , x_secondary_quantity_reserved   OUT NOCOPY NUMBER
   , p_original_rsv_rec              IN  inv_reservation_global.mtl_reservation_rec_type
   , p_to_rsv_rec                    IN  inv_reservation_global.mtl_reservation_rec_type
   , p_original_serial_number        IN  inv_reservation_global.serial_number_tbl_type
   , p_to_serial_number              IN  inv_reservation_global.serial_number_tbl_type
   , p_validation_flag               IN  VARCHAR2 DEFAULT fnd_api.g_true
   , p_partial_reservation_flag      IN  VARCHAR2 DEFAULT fnd_api.g_false
   , p_check_availability            IN  VARCHAR2 DEFAULT fnd_api.g_false
   , p_over_reservation_flag         IN  NUMBER DEFAULT 0
   ) IS


     l_api_version_number 	 	CONSTANT NUMBER       := 1.0;
     l_api_name           	        CONSTANT VARCHAR2(30) := 'Update_Reservation';
     l_return_status                    VARCHAR2(1)           := fnd_api.g_ret_sts_success;
     l_quantity_reserved                NUMBER;
     l_secondary_quantity_reserved      NUMBER;
     l_debug                            NUMBER      := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);

BEGIN
   --  Standard call to check for call compatibility
   IF NOT fnd_api.compatible_api_call(l_api_version_number
                                      , p_api_version_number
                                      , l_api_name
                                      , G_PKG_NAME
                                      ) THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   --  Initialize message list.
   IF fnd_api.to_boolean(p_init_msg_lst) THEN
      fnd_msg_pub.initialize;
   END IF;

-- INVCONV BEGIN
-- Strip out all inventory branching logic
-- Start Process Branching Logic ----
-- End Process Branching Logic ----
-- INVCONV END

   -- bug 1611697 - Performance
   --  Allow validation_flag to be false if false is passed to this api.
   --  Previously, always called pvt api with true.

 IF l_debug=1 THEN
   mydebug('The value of the p_partial_reservation_flag is :'||p_partial_reservation_flag,l_api_name,9);
   mydebug('The value of the p_check_availability is :'  ||p_check_availability,l_api_name,9);

 END IF;
   inv_reservation_pvt.update_reservation
     (
        p_api_version_number        => 1.0
      , p_init_msg_lst              => fnd_api.g_false
      , x_return_status             => l_return_status
      , x_msg_count                 => x_msg_count
      , x_msg_data                  => x_msg_data
      , x_quantity_reserved         => l_quantity_reserved
      , x_secondary_quantity_reserved => l_secondary_quantity_reserved
      , p_original_rsv_rec	         => p_original_rsv_rec
      , p_to_rsv_rec	               => p_to_rsv_rec
      , p_original_serial_number    => p_original_serial_number
      , p_to_serial_number	         => p_to_serial_number
      , p_validation_flag           => p_validation_flag
      , p_partial_reservation_flag  => p_partial_reservation_flag
      , p_check_availability        => p_check_availability
      , p_over_reservation_flag     => p_over_reservation_flag
      );

   IF l_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
   END IF ;

   IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   x_return_status      := l_return_status;
   x_quantity_reserved  := l_quantity_reserved;
   x_secondary_quantity_reserved  := l_secondary_quantity_reserved;

EXCEPTION

    WHEN fnd_api.g_exc_error THEN
        x_return_status := fnd_api.g_ret_sts_error;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count => x_msg_count
           , p_data  => x_msg_data
           );

   WHEN fnd_api.g_exc_unexpected_error THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );

    WHEN OTHERS THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
          THEN
           fnd_msg_pub.add_exc_msg
             (  g_pkg_name
              , l_api_name
              );
        END IF;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
             );

END update_reservation;


-- INVCONV
-- Update call to private layer to incorporate secondary_quantity_reserved
PROCEDURE update_reservation
  (
     p_api_version_number            IN  NUMBER
   , p_init_msg_lst                  IN  VARCHAR2 DEFAULT fnd_api.g_false
   , x_return_status                 OUT NOCOPY VARCHAR2
   , x_msg_count                     OUT NOCOPY NUMBER
   , x_msg_data                      OUT NOCOPY VARCHAR2
   , p_original_rsv_rec              IN  inv_reservation_global.mtl_reservation_rec_type
   , p_to_rsv_rec                    IN  inv_reservation_global.mtl_reservation_rec_type
   , p_original_serial_number        IN  inv_reservation_global.serial_number_tbl_type
   , p_to_serial_number              IN  inv_reservation_global.serial_number_tbl_type
   , p_validation_flag               IN  VARCHAR2 DEFAULT fnd_api.g_true
   , p_check_availability            IN  VARCHAR2 DEFAULT fnd_api.g_false
   , p_over_reservation_flag         IN  NUMBER DEFAULT 0
   ) IS


     l_api_version_number 	 CONSTANT NUMBER       :=  1.0;
     l_api_name           	 CONSTANT VARCHAR2(30) := 'Update_Reservation';
     l_return_status      	 VARCHAR2(1)           :=  fnd_api.g_ret_sts_success;
     l_quantity_reserved    NUMBER;
     l_secondary_quantity_reserved    NUMBER;                                           -- INVCONV
     l_debug                NUMBER      := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);

BEGIN
   --  Standard call to check for call compatibility
   IF NOT fnd_api.compatible_api_call(l_api_version_number
                                      , p_api_version_number
                                      , l_api_name
                                      , G_PKG_NAME
                                      ) THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   --  Initialize message list.
   IF fnd_api.to_boolean(p_init_msg_lst) THEN
      fnd_msg_pub.initialize;
   END IF;

   IF l_debug=1 THEN
     mydebug('Calling the overloaded procedure update_reservation',l_api_name,9);
   END IF;


   inv_reservation_pub.update_reservation
     (p_api_version_number          => 1.0,
      p_init_msg_lst                => fnd_api.g_false,
      x_return_status               => l_return_status,
      x_msg_count                   => x_msg_count,
      x_msg_data                    => x_msg_data,
      x_quantity_reserved           => l_quantity_reserved,
      x_secondary_quantity_reserved => l_secondary_quantity_reserved,
      p_original_rsv_rec            => p_original_rsv_rec,
      p_to_rsv_rec                  => p_to_rsv_rec,
      p_original_serial_number      => p_original_serial_number ,
      p_to_serial_number            => p_to_serial_number,
      p_validation_flag             => p_validation_flag,
      p_partial_reservation_flag    => fnd_api.g_false,
      p_check_availability          => p_check_availability,
      p_over_reservation_flag       => p_over_reservation_flag
      );


    IF (l_debug=1) THEN
     mydebug ('Return Status after updating reservations '||l_return_status,l_api_name,1);
    END IF;

    IF l_return_status = fnd_api.g_ret_sts_error THEN

      IF l_debug=1 THEN
        mydebug('Raising expected error'||l_return_status,l_api_name,9);
      END IF;

      RAISE fnd_api.g_exc_error;

    ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN

      IF l_debug=1 THEN
       mydebug('Raising Unexpected error'||l_return_status,l_api_name,9);
      END IF;

      RAISE fnd_api.g_exc_unexpected_error;
    END IF;


x_return_status := l_return_status;

EXCEPTION

 WHEN fnd_api.g_exc_error THEN
 x_return_status := fnd_api.g_ret_sts_error;
 --  Get message count and data
 fnd_msg_pub.count_and_get
   (  p_count => x_msg_count
    , p_data  => x_msg_data
   );

 WHEN fnd_api.g_exc_unexpected_error THEN
 x_return_status := fnd_api.g_ret_sts_unexp_error ;

        --  Get message count and data
 fnd_msg_pub.count_and_get
 (  p_count  => x_msg_count
 , p_data   => x_msg_data
 );

 WHEN OTHERS THEN
 x_return_status := fnd_api.g_ret_sts_unexp_error ;

 IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
 THEN
  fnd_msg_pub.add_exc_msg
    (  g_pkg_name
     , l_api_name
    );
  END IF;

  --  Get message count and data
 fnd_msg_pub.count_and_get
 (  p_count  => x_msg_count
 , p_data   => x_msg_data
 );

END update_reservation;


-- INVCONV
-- Invoke OVERLOAD version of relieve_reservation
PROCEDURE relieve_reservation
  (
     p_api_version_number        IN  NUMBER
   , p_init_msg_lst              IN  VARCHAR2 DEFAULT fnd_api.g_false
   , x_return_status             OUT NOCOPY VARCHAR2
   , x_msg_count                 OUT NOCOPY NUMBER
   , x_msg_data                  OUT NOCOPY VARCHAR2
   , p_rsv_rec
      IN  inv_reservation_global.mtl_reservation_rec_type
   , p_primary_relieved_quantity IN NUMBER
   , p_relieve_all               IN VARCHAR2 DEFAULT fnd_api.g_true
   , p_original_serial_number
      IN  inv_reservation_global.serial_number_tbl_type
   , p_validation_flag           IN  VARCHAR2 DEFAULT fnd_api.g_true
   , x_primary_relieved_quantity OUT NOCOPY NUMBER
   , x_primary_remain_quantity   OUT NOCOPY NUMBER
   ) IS
     l_api_version_number 	 CONSTANT NUMBER       := 1.0;
     l_api_name           	 CONSTANT VARCHAR2(30) := 'Relieve_Reservation';
     l_return_status      	 VARCHAR2(1) := fnd_api.g_ret_sts_success;
     l_debug                     NUMBER      := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0); -- INVCONV
     l_secondary_relieved_quantity  NUMBER;                                                   -- INVCONV
     l_secondary_remain_quantity NUMBER;                                                      -- INVCONV
BEGIN
   --  Standard call to check for call compatibility
   IF NOT fnd_api.compatible_api_call(l_api_version_number
                                      , p_api_version_number
                                      , l_api_name
                                      , G_PKG_NAME
                                      ) THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   --  Initialize message list.
   IF fnd_api.to_boolean(p_init_msg_lst) THEN
      fnd_msg_pub.initialize;
   END IF;

   IF l_debug=1 THEN
     mydebug('Calling the overloaded procedure relieve_reservation',l_api_name,9);
   END IF;

   inv_reservation_pub.relieve_reservation
  (
     p_api_version_number        => 1.0
   , p_init_msg_lst              => p_init_msg_lst
   , x_return_status             => l_return_status
   , x_msg_count                 => x_msg_count
   , x_msg_data                  => x_msg_data
   , p_rsv_rec			 => p_rsv_rec
   , p_primary_relieved_quantity => p_primary_relieved_quantity
   , p_secondary_relieved_quantity => l_secondary_relieved_quantity
   , p_relieve_all               => p_relieve_all
   , p_original_serial_number	 => p_original_serial_number
   , p_validation_flag           => p_validation_flag
   , x_primary_relieved_quantity => x_primary_relieved_quantity
   , x_secondary_relieved_quantity => l_secondary_relieved_quantity
   , x_primary_remain_quantity   => x_primary_remain_quantity
   , x_secondary_remain_quantity => l_secondary_remain_quantity
   );

   IF l_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
   END IF ;

   IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   x_return_status := l_return_status;

EXCEPTION

    WHEN fnd_api.g_exc_error THEN
        x_return_status := fnd_api.g_ret_sts_error;
        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count => x_msg_count
           , p_data  => x_msg_data
           );
   WHEN fnd_api.g_exc_unexpected_error THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );
   WHEN OTHERS THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;
        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
          THEN
           fnd_msg_pub.add_exc_msg
             (  g_pkg_name
              , l_api_name
              );
        END IF;
        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
             );
END relieve_reservation;

-- INVCONV
-- Introduce new overload
-- Incorporate secondary quantities
-- ================================
PROCEDURE relieve_reservation
  (
     p_api_version_number        IN  NUMBER
   , p_init_msg_lst              IN  VARCHAR2 DEFAULT fnd_api.g_false
   , x_return_status             OUT NOCOPY VARCHAR2
   , x_msg_count                 OUT NOCOPY NUMBER
   , x_msg_data                  OUT NOCOPY VARCHAR2
   , p_rsv_rec
      IN  inv_reservation_global.mtl_reservation_rec_type
   , p_primary_relieved_quantity IN NUMBER
   , p_secondary_relieved_quantity IN NUMBER
   , p_relieve_all               IN VARCHAR2 DEFAULT fnd_api.g_true
   , p_original_serial_number
      IN  inv_reservation_global.serial_number_tbl_type
   , p_validation_flag           IN  VARCHAR2 DEFAULT fnd_api.g_true
   , x_primary_relieved_quantity OUT NOCOPY NUMBER
   , x_secondary_relieved_quantity OUT NOCOPY NUMBER
   , x_primary_remain_quantity   OUT NOCOPY NUMBER
   , x_secondary_remain_quantity OUT NOCOPY NUMBER
   ) IS
     l_api_version_number 	 CONSTANT NUMBER       := 1.0;
     l_api_name           	 CONSTANT VARCHAR2(30) := 'Relieve_Reservation';
     l_return_status      	 VARCHAR2(1) := fnd_api.g_ret_sts_success;
BEGIN
   --  Standard call to check for call compatibility
   IF NOT fnd_api.compatible_api_call(l_api_version_number
                                      , p_api_version_number
                                      , l_api_name
                                      , G_PKG_NAME
                                      ) THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   --  Initialize message list.
   IF fnd_api.to_boolean(p_init_msg_lst) THEN
      fnd_msg_pub.initialize;
   END IF;

   inv_reservation_pvt.relieve_reservation
  (
     p_api_version_number        => 1.0
   , p_init_msg_lst              => fnd_api.g_false
   , x_return_status             => l_return_status
   , x_msg_count                 => x_msg_count
   , x_msg_data                  => x_msg_data
   , p_rsv_rec			 => p_rsv_rec
   , p_primary_relieved_quantity => p_primary_relieved_quantity
   , p_secondary_relieved_quantity  => p_secondary_relieved_quantity
   , p_relieve_all               => p_relieve_all
   , p_original_serial_number	 => p_original_serial_number
   , p_validation_flag           => fnd_api.g_true
   , x_primary_relieved_quantity => x_primary_relieved_quantity
   , x_secondary_relieved_quantity => x_secondary_relieved_quantity
   , x_primary_remain_quantity   => x_primary_remain_quantity
   , x_secondary_remain_quantity => x_secondary_remain_quantity
   );

   IF l_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
   END IF ;

   IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   x_return_status := l_return_status;

EXCEPTION

    WHEN fnd_api.g_exc_error THEN
        x_return_status := fnd_api.g_ret_sts_error;
        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count => x_msg_count
           , p_data  => x_msg_data
           );
   WHEN fnd_api.g_exc_unexpected_error THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );
   WHEN OTHERS THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;
        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
          THEN
           fnd_msg_pub.add_exc_msg
             (  g_pkg_name
              , l_api_name
              );
        END IF;
        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
             );
END relieve_reservation;
-- INVCONV END

--
-- INVCONV BEGIN
-- Strip out process forking logic
PROCEDURE delete_reservation
  (
     p_api_version_number       IN  NUMBER
   , p_init_msg_lst             IN  VARCHAR2 DEFAULT fnd_api.g_false
   , x_return_status            OUT NOCOPY VARCHAR2
   , x_msg_count                OUT NOCOPY NUMBER
   , x_msg_data                 OUT NOCOPY VARCHAR2
   , p_rsv_rec
            IN  inv_reservation_global.mtl_reservation_rec_type
   , p_serial_number
             IN  inv_reservation_global.serial_number_tbl_type
   )IS
     l_api_version_number 	 CONSTANT NUMBER       := 1.0;
     l_api_name           	 CONSTANT VARCHAR2(30) := 'Delete_Reservation';
     l_return_status      	 VARCHAR2(1) := fnd_api.g_ret_sts_success;
BEGIN
   --  Standard call to check for call compatibility
   IF NOT fnd_api.compatible_api_call(l_api_version_number
                                      , p_api_version_number
                                      , l_api_name
                                      , G_PKG_NAME
                                      ) THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   --  Initialize message list.
   IF fnd_api.to_boolean(p_init_msg_lst) THEN
      fnd_msg_pub.initialize;
   END IF;

   inv_reservation_pvt.delete_reservation
  (
     p_api_version_number       => 1.0
   , p_init_msg_lst             => fnd_api.g_false
   , x_return_status            => l_return_status
   , x_msg_count                => x_msg_count
   , x_msg_data                 => x_msg_data
   , p_rsv_rec			=> p_rsv_rec
   , p_original_serial_number	=> p_serial_number
   , p_validation_flag          => fnd_api.g_true
   );

   IF l_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
   END IF ;

   IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   x_return_status := l_return_status;

EXCEPTION

    WHEN fnd_api.g_exc_error THEN
        x_return_status := fnd_api.g_ret_sts_error;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count => x_msg_count
           , p_data  => x_msg_data
           );

   WHEN fnd_api.g_exc_unexpected_error THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );

    WHEN OTHERS THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
          THEN
           fnd_msg_pub.add_exc_msg
             (  g_pkg_name
              , l_api_name
              );
        END IF;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
             );

END delete_reservation;

-- INVCONV
-- Strip out process forking logic
PROCEDURE transfer_reservation
  (
     p_api_version_number            IN  NUMBER
   , p_init_msg_lst                  IN  VARCHAR2 DEFAULT fnd_api.g_false
   , x_return_status                 OUT NOCOPY VARCHAR2
   , x_msg_count                     OUT NOCOPY NUMBER
   , x_msg_data                      OUT NOCOPY VARCHAR2
   , p_is_transfer_supply            IN  VARCHAR2 DEFAULT fnd_api.g_true
   , p_original_rsv_rec
            IN  inv_reservation_global.mtl_reservation_rec_type
   , p_to_rsv_rec
            IN  inv_reservation_global.mtl_reservation_rec_type
   , p_original_serial_number
            IN  inv_reservation_global.serial_number_tbl_type
   , p_to_serial_number
            IN  inv_reservation_global.serial_number_tbl_type
   , p_validation_flag               IN  VARCHAR2 DEFAULT fnd_api.g_true
   , p_over_reservation_flag         IN  NUMBER DEFAULT 0
   , x_to_reservation_id             OUT NOCOPY NUMBER
   ) IS
      l_api_version_number 	 CONSTANT NUMBER       := 1.0;
      l_api_name           	 CONSTANT VARCHAR2(30) := 'Transfer_Reservation';
      l_return_status      	 VARCHAR2(1) := fnd_api.g_ret_sts_success;
BEGIN
   --  Standard call to check for call compatibility
   IF NOT fnd_api.compatible_api_call(l_api_version_number
                                      , p_api_version_number
                                      , l_api_name
                                      , G_PKG_NAME
                                      ) THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   --  Initialize message list.
   IF fnd_api.to_boolean(p_init_msg_lst) THEN
      fnd_msg_pub.initialize;
   END IF;

-- Start Process Branching Logic ----
-- INVCONV - Process Branching Logic removed from here
-- End Process Branching Logic ----

   -- bug 1611697 - Performance
   --  Allow validation_flag to be false if false is passed to this api.
   --  Previously, always called pvt api with true.
   /**** {{ R12 Enhanced reservations code changes }}****/
   IF (p_to_serial_number.COUNT > 0 OR p_original_serial_number.COUNT > 0)
     THEN
      inv_reservation_pvt.transfer_reservation
	(
	 p_api_version_number          => 1.0
	 , p_init_msg_lst              => fnd_api.g_false
	 , x_return_status             => l_return_status
	 , x_msg_count                 => x_msg_count
	 , x_msg_data                  => x_msg_data
	 , p_original_rsv_rec	       => p_original_rsv_rec
	 , p_to_rsv_rec	               => p_to_rsv_rec
	 , p_original_serial_number    => p_original_serial_number
	 , p_to_serial_number          => p_to_serial_number
	 , p_validation_flag           => p_validation_flag
	 , p_over_reservation_flag     => p_over_reservation_flag
	 , x_reservation_id            => x_to_reservation_id
	 );
    ELSE
      /*** End R12 ***/
      inv_reservation_pvt.transfer_reservation
	(
	 p_api_version_number          => 1.0
	 , p_init_msg_lst              => fnd_api.g_false
	 , x_return_status             => l_return_status
	 , x_msg_count                 => x_msg_count
	 , x_msg_data                  => x_msg_data
	 , p_original_rsv_rec	       => p_original_rsv_rec
	 , p_to_rsv_rec	               => p_to_rsv_rec
	 , p_original_serial_number    => p_original_serial_number
	 , p_validation_flag           => p_validation_flag
	 , p_over_reservation_flag     => p_over_reservation_flag
	 , x_reservation_id            => x_to_reservation_id
	 );
      /**** {{ R12 Enhanced reservations code changes }}****/
   END IF;
   /*** End R12 ***/
   IF l_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
   END IF ;

   IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   x_return_status := l_return_status;

EXCEPTION

   WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

      --  Get message count and data
      fnd_msg_pub.count_and_get
	(  p_count => x_msg_count
           , p_data  => x_msg_data
           );

   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;

      --  Get message count and data
      fnd_msg_pub.count_and_get
	(  p_count  => x_msg_count
           , p_data   => x_msg_data
	   );

   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
	THEN
	 fnd_msg_pub.add_exc_msg
	   (  g_pkg_name
              , l_api_name
              );
      END IF;

      --  Get message count and data
      fnd_msg_pub.count_and_get
	(  p_count  => x_msg_count
           , p_data   => x_msg_data
	   );

END transfer_reservation;

-- INVCONV
-- Strip out process forking logic
PROCEDURE query_reservation
  (
     p_api_version_number            IN  NUMBER
   , p_init_msg_lst                  IN  VARCHAR2 DEFAULT fnd_api.g_false
   , x_return_status                 OUT NOCOPY VARCHAR2
   , x_msg_count                     OUT NOCOPY NUMBER
   , x_msg_data                      OUT NOCOPY VARCHAR2
   , p_query_input
           IN  inv_reservation_global.mtl_reservation_rec_type
   , p_lock_records                  IN  VARCHAR2 DEFAULT fnd_api.g_false
   , p_sort_by_req_date
           IN  NUMBER   DEFAULT inv_reservation_global.g_query_no_sort
   , p_cancel_order_mode
           IN  NUMBER   DEFAULT inv_reservation_global.g_cancel_order_no
   , x_mtl_reservation_tbl
           OUT NOCOPY inv_reservation_global.mtl_reservation_tbl_type
   , x_mtl_reservation_tbl_count     OUT NOCOPY NUMBER
   , x_error_code                    OUT NOCOPY NUMBER
   ) IS
     l_api_version_number 	 CONSTANT NUMBER       := 1.0;
     l_api_name           	 CONSTANT VARCHAR2(30) := 'Query_Reservation';
     l_return_status      	 VARCHAR2(1) := fnd_api.g_ret_sts_success;
     -- OPM BUG 1415345 BEGIN
     l_query_input               inv_reservation_global.mtl_reservation_rec_type
                                 := p_query_input;
     -- OPM BUG 1415345 END
BEGIN
   --  Standard call to check for call compatibility
   IF NOT fnd_api.compatible_api_call(l_api_version_number
                                      , p_api_version_number
                                      , l_api_name
                                      , G_PKG_NAME
                                      ) THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   --  Initialize message list.
   IF fnd_api.to_boolean(p_init_msg_lst) THEN
      fnd_msg_pub.initialize;
   END IF;

-- Start Process Branching Logic ----
-- INVCONV - Remove Process Branching Logic
-- End Process Branching Logic ----


   inv_reservation_pvt.query_reservation
     (
        p_api_version_number        => 1.0
      , p_init_msg_lst              => fnd_api.g_false
      , x_return_status             => l_return_status
      , x_msg_count                 => x_msg_count
      , x_msg_data                  => x_msg_data
      , p_query_input		    => l_query_input
      , p_lock_records              => p_lock_records
      , p_sort_by_req_date          => p_sort_by_req_date
      , p_cancel_order_mode         => p_cancel_order_mode
      , x_mtl_reservation_tbl	    => x_mtl_reservation_tbl
      , x_mtl_reservation_tbl_count => x_mtl_reservation_tbl_count
      , x_error_code                => x_error_code
      );

   IF l_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
   END IF ;

   IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   x_return_status := l_return_status;

EXCEPTION

    WHEN fnd_api.g_exc_error THEN
        x_return_status := fnd_api.g_ret_sts_error;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count => x_msg_count
           , p_data  => x_msg_data
           );

   WHEN fnd_api.g_exc_unexpected_error THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );

    WHEN OTHERS THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
          THEN
           fnd_msg_pub.add_exc_msg
             (  g_pkg_name
              , l_api_name
              );
        END IF;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
             );

END query_reservation;

-- INVCONV
-- Strip out process forking logic
/*
** ----------------------------------------------------------------------
** For Order Management(OM) use only. Please read below:
** MUST PASS DEMAND SOURCE HEADER ID AND DEMAND SOURCE LINE ID
** ----------------------------------------------------------------------
** This API has been written exclusively for Order Management, who query
** reservations extensively.
** The generic query reservation API, query_reservation(see signature above)
** builds a dynamic SQL to satisfy all callers as it does not know what the
** search criteria is, at design time.
** The dynamic SQL consumes soft parse time, which reduces performance.
** An excessive use of query_reservation contributes to performance
** degradation because of soft parse times.
** Since we know what OM would always use to query reservations
** - demand source header id and demand source line id, a new API
** with static SQL would be be effective, with reduced performance impact.
** ----------------------------------------------------------------------
** Since OM has been using query_reservation before this, the signature of the
** new API below remains the same to cause minimal impact.
** ----------------------------------------------------------------------
*/
PROCEDURE query_reservation_om_hdr_line
  (
     p_api_version_number            IN  NUMBER
   , p_init_msg_lst                  IN  VARCHAR2 DEFAULT fnd_api.g_false
   , x_return_status                 OUT NOCOPY VARCHAR2
   , x_msg_count                     OUT NOCOPY NUMBER
   , x_msg_data                      OUT NOCOPY VARCHAR2
   , p_query_input
           IN  inv_reservation_global.mtl_reservation_rec_type
   , p_lock_records                  IN  VARCHAR2 DEFAULT fnd_api.g_false
   , p_sort_by_req_date
           IN  NUMBER   DEFAULT inv_reservation_global.g_query_no_sort
   , p_cancel_order_mode
           IN  NUMBER   DEFAULT inv_reservation_global.g_cancel_order_no
   , x_mtl_reservation_tbl
           OUT NOCOPY inv_reservation_global.mtl_reservation_tbl_type
   , x_mtl_reservation_tbl_count     OUT NOCOPY NUMBER
   , x_error_code                    OUT NOCOPY NUMBER
   ) IS
     l_api_version_number 	 CONSTANT NUMBER       := 1.0;
     l_api_name           	 CONSTANT VARCHAR2(30) := 'Query_Reservation';
     l_return_status      	 VARCHAR2(1) := fnd_api.g_ret_sts_success;
     -- OPM BUG 1415345 BEGIN
     l_query_input             inv_reservation_global.mtl_reservation_rec_type
                               := p_query_input;
     -- OPM BUG 1415345 END
BEGIN
   --  Standard call to check for call compatibility
   IF NOT fnd_api.compatible_api_call(l_api_version_number
                                      , p_api_version_number
                                      , l_api_name
                                      , G_PKG_NAME
                                      ) THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   --  Initialize message list.
   IF fnd_api.to_boolean(p_init_msg_lst) THEN
      fnd_msg_pub.initialize;
   END IF;


-- Start Process Branching Logic ----
-- INVCONV - Strip out process forking logic
-- End Process Branching Logic ----

   inv_reservation_pvt.query_reservation_om_hdr_line
     (
        p_api_version_number        => 1.0
      , p_init_msg_lst              => fnd_api.g_false
      , x_return_status             => l_return_status
      , x_msg_count                 => x_msg_count
      , x_msg_data                  => x_msg_data
      , p_query_input		    => l_query_input
      , p_lock_records              => p_lock_records
      , p_sort_by_req_date          => p_sort_by_req_date
      , p_cancel_order_mode         => p_cancel_order_mode
      , x_mtl_reservation_tbl	    => x_mtl_reservation_tbl
      , x_mtl_reservation_tbl_count => x_mtl_reservation_tbl_count
      , x_error_code                => x_error_code
      );

   IF l_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
   END IF ;

   IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   x_return_status := l_return_status;

EXCEPTION

    WHEN fnd_api.g_exc_error THEN
        x_return_status := fnd_api.g_ret_sts_error;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count => x_msg_count
           , p_data  => x_msg_data
           );

   WHEN fnd_api.g_exc_unexpected_error THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );

    WHEN OTHERS THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
          THEN
           fnd_msg_pub.add_exc_msg
             (  g_pkg_name
              , l_api_name
              );
        END IF;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
             );

END query_reservation_om_hdr_line;

END inv_reservation_pub;

/
