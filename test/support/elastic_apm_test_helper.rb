module ElasticAPMTestHelper
  def with_apm_transaction
    EcsLogRails.stub(:_elastic_apm_module, FakeElasticAPM.new) do
      yield
    end
  end

  def without_apm_transaction
    apm = FakeElasticAPM.new.tap { it.disable! }
    EcsLogRails.stub(:_elastic_apm_module, apm) do
      yield
    end
  end
end
