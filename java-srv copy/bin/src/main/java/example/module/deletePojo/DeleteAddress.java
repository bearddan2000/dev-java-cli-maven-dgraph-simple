package example.module.deletePojo;

import lombok.Builder;
import lombok.Getter;

@Builder
@Getter
public final class DeleteAddress {
    private final String uid;
}