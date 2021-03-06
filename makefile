# Yes we could have use rake, but rake is so slow and verbose ...
# Look at this as a collection of shell commands.

.PHONY: migrate_test test doc clean clean_tree profile

# launch rspec
test:
	bundle exec rspec

focus:
	bundle exec rspec -tfocus

profile:
	bundle exec rspec -p

# generate yard doc
doc:
	bundle exec yardoc

# migrate test database
migrate_test:
	bundle exec sequel -m db/migrations -e test config/database.yml

# Start server for core presentation
show:
	bundle exec showoff serve showoff/core-2012-06-11

# console
console:
	bundle exec sequel -e test config/database.yml
        

# generate constants tree of a starting required file
constants:

%.tree:
	bundle exec ruby utils/constant_tree.rb $*  | tee $@

core.tree: \ .tree
	mv $< $@

clean_tree:
	rm *.tree

clean: clean_tree
