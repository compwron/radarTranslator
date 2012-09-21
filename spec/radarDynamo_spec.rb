
# test data load of sample data set

subject.radars.size.should == 2
subject.classifications.size.should == 4
subject.classifications.should == {'Adopt', 'Trial', 'Assess', 'Hold'}
subject.aggregate_state.technologies.should = {'Python', 'Ruby', 'Maven'} # test data


subject.data.should .... ?