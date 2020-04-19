path = docker
env = prod
debug = 0
userDb = user_prod
nameDb = db_prod


clean:
	docker system prune -f -a

clean_files:
	cd src/symfony && rm -f composer.lock && rm -rf vendor && rm -f symfony.lock && rm -rf var/cache && rm -f .env.local.php && rm -f .env.test
	
build:
	cd $(path) && docker-compose build

up:
	cd $(path) && docker-compose up 

up_bg:
	cd $(path) && docker-compose up -d

build_up:
	cd $(path) && docker-compose up --build

build_up_bg:
	cd $(path) && docker-compose up --build -d

stop:
	cd $(path) && docker-compose stop

setup:
	docker run --rm --interactive --tty --volume $(PWD)/src/symfony:/app composer install && cd $(path) && docker-compose exec php-fpm chown -R www-data:www-data /var/www && docker-compose exec php-fpm php symfony/bin/console doctrine:schema:update --force && docker-compose exec pgsql psql -U $(userDb) -f /opt/init.sql $(nameDb)

full_setup:
	cd $(path) && docker-compose build && docker-compose up -d && docker run --rm --interactive --tty --volume $(PWD)/../src/symfony:/app --env APP_ENV=$(env) --env APP_DEBUG=$(debug) composer install && docker-compose exec php-fpm chown -R www-data:www-data /var/www && docker-compose exec php-fpm php symfony/bin/console doctrine:schema:update --force && docker-compose exec pgsql psql -U $(userDb) -f /opt/init.sql $(nameDb)
	
db_delete:
	cd $(path) && docker-compose exec php-fpm php symfony/bin/console doctrine:database:drop --force

db_create:
	cd $(path) && docker-compose exec php-fpm php symfony/bin/console doctrine:database:create && docker-compose exec php-fpm php symfony/bin/console doctrine:schema:update --force

db_create_full:
	cd $(path) && docker-compose exec php-fpm php symfony/bin/console doctrine:database:create && docker-compose exec php-fpm php symfony/bin/console doctrine:schema:update --force && docker-compose exec pgsql psql -U $(userDb) -f /opt/init.sql $(nameDb)

db_recreate:
	cd $(path) && docker-compose exec php-fpm php symfony/bin/console doctrine:database:drop --force && docker-compose exec php-fpm php symfony/bin/console doctrine:database:create && docker-compose exec php-fpm php symfony/bin/console doctrine:schema:update --force

db_recreate_full:
	cd $(path) && docker-compose exec php-fpm php symfony/bin/console doctrine:database:drop --force && docker-compose exec php-fpm php symfony/bin/console doctrine:database:create && docker-compose exec php-fpm php symfony/bin/console doctrine:schema:update --force && docker-compose exec pgsql psql -U $(userDb) -f /opt/init.sql $(nameDb)

db_update:
	cd $(path) && docker-compose exec php-fpm php symfony/bin/console doctrine:schema:update --force

composer_install:
	docker run --rm --interactive --tty --volume $(PWD)/src/symfony:/app --env APP_ENV=$(env) --env APP_DEBUG=$(debug) composer install

composer_update:
	docker run --rm --interactive --tty --volume $(PWD)/src/symfony:/app --env APP_ENV=$(env) --env APP_DEBUG=$(debug) composer update
	
composer_update_prod:
	docker run --rm --interactive --tty --volume $(PWD)/src/symfony:/app --env APP_ENV=prod --env APP_DEBUG=0 composer update --no-dev
	
dev_deployment:
	cd $(path) && docker-compose up --build -d
	docker run --rm --interactive --tty --volume $(PWD)/src/symfony:/app --env APP_ENV=dev --env APP_DEBUG=1 composer install;
	docker run --rm --interactive --tty --volume $(PWD)/src/symfony:/app --env APP_ENV=dev --env APP_DEBUG=1 composer dump-env dev
	rm src/symfony/.env
	cd $(path) && docker-compose exec php-fpm php symfony/bin/console cache:clear && docker-compose exec php-fpm chown -R www-data:www-data /var/www && docker-compose exec php-fpm php symfony/bin/console doctrine:schema:update --force


prod_first_deployment:
	cd $(path) && docker-compose up --build -d
	docker run --rm --interactive --tty --volume $(PWD)/src/symfony:/app --env APP_ENV=prod --env APP_DEBUG=0 composer install --no-dev --optimize-autoloader;
	docker run --rm --interactive --tty --volume $(PWD)/src/symfony:/app --env APP_ENV=prod --env APP_DEBUG=0 composer dump-env prod
	rm -f src/symfony/.env
	rm -f src/symfony/phpunit.xml.dist
	rm -rf src/symfony/.git*
	rm -rf src/symfony/tests
	cd $(path) && docker-compose exec php-fpm php symfony/bin/console cache:clear && docker-compose exec php-fpm chown -R www-data:www-data /var/www && docker-compose exec php-fpm php symfony/bin/console doctrine:schema:update --force && docker-compose exec pgsql psql -U $(userDb) -f /opt/init.sql $(nameDb)


prod_deployment:
	cd $(path) && docker-compose up --build -d
	docker run --rm --interactive --tty --volume $(PWD)/src/symfony:/app --env APP_ENV=prod --env APP_DEBUG=0 composer install --no-dev --optimize-autoloader;
	docker run --rm --interactive --tty --volume $(PWD)/src/symfony:/app --env APP_ENV=prod --env APP_DEBUG=0 composer dump-env prod
	rm -f src/symfony/phpunit.xml.dist
	rm -rf src/symfony/.git*
	rm -rf src/symfony/tests
	rm -f src/symfony/.env.test
	cd $(path) && docker-compose exec php-fpm php symfony/bin/console cache:clear && docker-compose exec php-fpm chown -R www-data:www-data /var/www && docker-compose exec php-fpm php symfony/bin/console doctrine:schema:update --force
